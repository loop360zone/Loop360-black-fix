#include "Overlay.h"
#include "../Settings.h"
#include "../Menu/MenuRenderer.h"
#include "../Features/ESP.h"
#include "../Features/Aimbot.h"
#include "../Features/Movement.h"
#include "../Features/PlayerScale.h"
#include "../Features/Weapon.h"
#include "../Features/Teleport.h"

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <QuartzCore/QuartzCore.h>

#include "imgui.h"
#include "imgui_impl_metal.h"

@interface SSPassthroughView : UIView
@end

@implementation SSPassthroughView
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *sub in [self.subviews reverseObjectEnumerator]) {
        if (sub.hidden || sub.alpha < 0.01f || !sub.userInteractionEnabled) continue;
        CGPoint p = [self convertPoint:point toView:sub];
        UIView *hit = [sub hitTest:p withEvent:event];
        if (hit) return hit;
    }
    return nil;
}
@end

static UIWindowScene *SSFindBestWindowScene(void) {
    UIWindowScene *bestScene = nil;
    CGFloat bestArea = 0.f;

    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if (![scene isKindOfClass:[UIWindowScene class]]) continue;
        UIWindowScene *ws = (UIWindowScene *)scene;
        if (ws.activationState == UISceneActivationStateBackground) continue;

        for (UIWindow *w in ws.windows) {
            if (!w || w.hidden || w.alpha < 0.01f) continue;
            if (w.windowLevel > UIWindowLevelAlert + 500) continue;
            CGFloat area = w.bounds.size.width * w.bounds.size.height;
            if (area > bestArea) {
                bestArea = area;
                bestScene = ws;
            }
        }
    }

    if (bestScene) return bestScene;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    UIWindow *fallback = nil;
    CGFloat fbArea = 0.f;
    for (UIWindow *w in UIApplication.sharedApplication.windows) {
        if (!w || w.hidden || w.alpha < 0.01f) continue;
        CGFloat area = w.bounds.size.width * w.bounds.size.height;
        if (area > fbArea) {
            fbArea = area;
            fallback = w;
        }
    }
#pragma clang diagnostic pop
    return fallback.windowScene;
}

static CGRect SSBoundsForScene(UIWindowScene *scene) {
    if (scene && !CGRectIsEmpty(scene.coordinateSpace.bounds)) {
        return scene.coordinateSpace.bounds;
    }
    return UIScreen.mainScreen.bounds;
}

@interface StateScriptOverlayView : MTKView
@property (nonatomic, assign) BOOL imguiCapturesInput;
@property (nonatomic, assign) BOOL imguiContextReady;
@end

@implementation StateScriptOverlayView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!Settings::bShowMenu.load()) return nil;
    if (!self.imguiCapturesInput) return nil;
    return [super hitTest:point withEvent:event];
}

- (void)feedTouch:(UITouch *)touch down:(BOOL)down {
    if (!touch || !self.imguiContextReady) return;
    ImGuiIO &io = ImGui::GetIO();
    CGPoint loc = [touch locationInView:self];
    CGFloat sf = self.contentScaleFactor > 0.f ? self.contentScaleFactor : 1.f;
    io.AddMousePosEvent(loc.x * sf, loc.y * sf);
    io.AddMouseButtonEvent(0, down);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self feedTouch:touches.anyObject down:YES];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self feedTouch:touches.anyObject down:YES];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self feedTouch:touches.anyObject down:NO];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self feedTouch:touches.anyObject down:NO];
}

@end

@interface StateScriptOverlay () <MTKViewDelegate>
@property (nonatomic, weak) UIWindow *hostWindow;
@property (nonatomic, weak) UIWindowScene *hostScene;
@property (nonatomic, strong) UIWindow *controlsWindow;
@property (nonatomic, strong) UIWindow *menuWindow;
@property (nonatomic, strong) SSPassthroughView *controlsRootView;
@property (nonatomic, strong) StateScriptOverlayView *mtkView;
@property (nonatomic, strong) UILabel *watermarkLabel;
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, assign) CFTimeInterval lastFrameTime;
@property (nonatomic, assign) BOOL imguiReady;
@end

@implementation StateScriptOverlay

+ (instancetype)shared {
    static StateScriptOverlay *instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ instance = [[StateScriptOverlay alloc] init]; });
    return instance;
}

- (instancetype)init {
    if ((self = [super init])) {
        _lastFrameTime = CACurrentMediaTime();
    }
    return self;
}

- (UIWindow *)pickHostWindowInScene:(UIWindowScene *)scene {
    UIWindow *best = nil;
    CGFloat bestArea = 0.f;
    for (UIWindow *w in scene.windows) {
        if (!w || w.hidden || w.alpha < 0.01f) continue;
        if (w == self.controlsWindow || w == self.menuWindow) continue;
        if (w.windowLevel > UIWindowLevelAlert + 500) continue;
        CGFloat area = w.bounds.size.width * w.bounds.size.height;
        if (area > bestArea) {
            bestArea = area;
            best = w;
        }
    }
    return best;
}

- (void)ensureControlsWindowForScene:(UIWindowScene *)scene bounds:(CGRect)bounds {
    if (!scene) return;

    if (!self.controlsWindow || self.controlsWindow.windowScene != scene) {
        self.controlsWindow = nil;
        self.controlsRootView = nil;
        self.watermarkLabel = nil;

        UIWindow *controls = [[UIWindow alloc] initWithWindowScene:scene];
        controls.frame = bounds;
        controls.windowLevel = UIWindowLevelAlert + 350;
        controls.backgroundColor = UIColor.clearColor;
        controls.opaque = NO;
        controls.userInteractionEnabled = YES;
        controls.hidden = NO;

        SSPassthroughView *root = [[SSPassthroughView alloc] initWithFrame:bounds];
        root.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        root.backgroundColor = UIColor.clearColor;
        root.userInteractionEnabled = YES;

        UIViewController *vc = [UIViewController new];
        vc.view = root;
        controls.rootViewController = vc;

        self.controlsWindow = controls;
        self.controlsRootView = root;
    } else {
        self.controlsWindow.frame = bounds;
        self.controlsRootView.frame = bounds;
    }

    [self setupWatermarkOnControlsRoot:self.controlsRootView bounds:bounds];
    [self applyStreamerMode];

    self.controlsWindow.hidden = Settings::bStreamerMode.load();
}

- (void)ensureMenuOverlayForScene:(UIWindowScene *)scene bounds:(CGRect)bounds {
    if (!scene) return;
    if (self.menuWindow && self.menuWindow.windowScene == scene) {
        self.menuWindow.frame = bounds;
        if (self.mtkView) self.mtkView.frame = bounds;
        return;
    }

    if (!self.device) {
        self.device = MTLCreateSystemDefaultDevice();
    }
    if (!self.device) return;

    if (!self.commandQueue) {
        self.commandQueue = [self.device newCommandQueue];
    }
    if (!self.commandQueue) return;

    UIWindow *menu = [[UIWindow alloc] initWithWindowScene:scene];
    menu.frame = bounds;
    menu.windowLevel = UIWindowLevelAlert + 300;
    menu.backgroundColor = UIColor.clearColor;
    menu.opaque = NO;
    menu.userInteractionEnabled = YES;
    menu.hidden = YES;

    StateScriptOverlayView *mtk = [[StateScriptOverlayView alloc] initWithFrame:bounds device:self.device];
    mtk.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    mtk.delegate = self;
    mtk.preferredFramesPerSecond = Settings::targetFPS.load();
    mtk.clearColor = MTLClearColorMake(0, 0, 0, 0);
    mtk.backgroundColor = UIColor.clearColor;
    mtk.layer.opaque = NO;
    mtk.userInteractionEnabled = YES;
    mtk.multipleTouchEnabled = NO;
    mtk.paused = YES;
    mtk.enableSetNeedsDisplay = NO;
    mtk.imguiCapturesInput = NO;
    mtk.imguiContextReady = NO;

    UIViewController *vc = [UIViewController new];
    vc.view = mtk;
    menu.rootViewController = vc;

    self.menuWindow = menu;
    self.mtkView = mtk;
}

- (void)install {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindowScene *scene = SSFindBestWindowScene();
        if (!scene) return;

        CGRect bounds = SSBoundsForScene(scene);
        UIWindow *host = [self pickHostWindowInScene:scene];
        self.hostScene = scene;
        self.hostWindow = host;

        [self ensureControlsWindowForScene:scene bounds:bounds];
        [self ensureMenuOverlayForScene:scene bounds:bounds];

        if (self.watermarkLabel) {
            [self.controlsRootView bringSubviewToFront:self.watermarkLabel];
        }
    });
}

- (void)setupWatermarkOnControlsRoot:(UIView *)root bounds:(CGRect)bounds {
    if (Settings::bStreamerMode.load()) return;
    if (!root) return;

    if (self.watermarkLabel) {
        if (self.watermarkLabel.superview != root) {
            [root addSubview:self.watermarkLabel];
        }
        return;
    }

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, bounds.size.height - 44, 240, 36)];
    label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    label.text = @"  Loop360  ";
    label.textColor = [UIColor colorWithRed:0.2f green:1.f blue:0.45f alpha:1.f];
    label.font = [UIFont boldSystemFontOfSize:16];
    label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.62f];
    label.layer.cornerRadius = 10.f;
    label.layer.borderWidth = 1.5f;
    label.layer.borderColor = [UIColor colorWithRed:0.2f green:0.85f blue:0.4f alpha:0.85f].CGColor;
    label.clipsToBounds = YES;
    label.textAlignment = NSTextAlignmentCenter;
    label.userInteractionEnabled = YES;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleMenu)];
    [label addGestureRecognizer:tap];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleWatermarkPan:)];
    [label addGestureRecognizer:pan];

    [root addSubview:label];
    self.watermarkLabel = label;
}

- (void)handleWatermarkPan:(UIPanGestureRecognizer *)gesture {
    if (gesture.view != self.watermarkLabel) return;
    UIView *view = gesture.view;
    if (!view.superview) return;
    CGPoint t = [gesture translationInView:view.superview];
    view.center = CGPointMake(view.center.x + t.x, view.center.y + t.y);
    [gesture setTranslation:CGPointZero inView:view.superview];
}

- (void)toggleMenu {
    bool show = !Settings::bShowMenu.load();
    Settings::bShowMenu.store(show);

    UIWindowScene *scene = self.hostScene ?: SSFindBestWindowScene();
    CGRect bounds = SSBoundsForScene(scene);
    [self ensureControlsWindowForScene:scene bounds:bounds];
    [self ensureMenuOverlayForScene:scene bounds:bounds];

    if (self.menuWindow) {
        self.menuWindow.hidden = !show;
    }
    if (self.mtkView) {
        self.mtkView.paused = !show;
        self.mtkView.userInteractionEnabled = show;
        if (!show) {
            self.mtkView.imguiCapturesInput = NO;
        }
    }

    if (self.controlsWindow && !Settings::bStreamerMode.load()) {
        self.controlsWindow.hidden = NO;
    }
    if (self.watermarkLabel) {
        [self.controlsRootView bringSubviewToFront:self.watermarkLabel];
    }
}

- (void)applyStreamerMode {
    BOOL hide = Settings::bStreamerMode.load();
    if (self.controlsWindow) {
        self.controlsWindow.hidden = hide;
    }
    if (self.watermarkLabel) {
        self.watermarkLabel.hidden = hide;
    }
}

- (void)setupImGui {
    if (self.imguiReady || !self.mtkView) return;
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO &io = ImGui::GetIO();
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;
    io.DisplaySize = ImVec2((float)self.mtkView.bounds.size.width, (float)self.mtkView.bounds.size.height);
    io.Fonts->AddFontDefault();
    ImGui_ImplMetal_Init(self.device);
    self.mtkView.imguiContextReady = YES;
    self.imguiReady = YES;
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    if (self.imguiReady) {
        ImGuiIO &io = ImGui::GetIO();
        io.DisplaySize = ImVec2((float)size.width, (float)size.height);
    }
}

- (void)drawInMTKView:(MTKView *)view {
    if (!Settings::bIsAppActive.load() || !Settings::bShowMenu.load()) return;

    CFTimeInterval now = CACurrentMediaTime();
    float dt = (float)(now - self.lastFrameTime);
    self.lastFrameTime = now;

    [self setupImGui];
    [self applyStreamerMode];

    float w = (float)view.drawableSize.width;
    float h = (float)view.drawableSize.height;
    if (w <= 0.f || h <= 0.f) return;

    if (!Settings::Cheatoff.load()) {
        ESPFeature::Update(w, h);
        AimbotFeature::Update(w, h);
        MovementFeature::Update(dt);
        PlayerScaleFeature::Update();
        WeaponFeature::Update();
        TeleportFeature::UpdateAuto();
    }

    id<MTLCommandBuffer> cmd = [self.commandQueue commandBuffer];
    MTLRenderPassDescriptor *pass = view.currentRenderPassDescriptor;
    if (!pass) return;

    ImGui_ImplMetal_NewFrame(pass);
    ImGui::NewFrame();

    MenuRenderer::Render(w, h);
    MenuRenderer::RenderOverlay(w, h);

    ImGui::Render();

    StateScriptOverlayView *overlayView = (StateScriptOverlayView *)view;
    overlayView.imguiCapturesInput = ImGui::GetIO().WantCaptureMouse;

    id<MTLRenderCommandEncoder> enc = [cmd renderCommandEncoderWithDescriptor:pass];
    ImGui_ImplMetal_RenderDrawData(ImGui::GetDrawData(), cmd, enc);
    [enc endEncoding];

    [cmd presentDrawable:view.currentDrawable];
    [cmd commit];
}

@end

void StateScriptOverlayInstall() {
    [[StateScriptOverlay shared] install];
}

void StateScriptOverlayToggleMenu() {
    [[StateScriptOverlay shared] toggleMenu];
}
