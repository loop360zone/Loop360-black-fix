#include "Overlay.h"
#include "../Settings.h"
#include "../Menu/MenuRenderer.h"
#include "../Features/ESP.h"
#include "../Features/Aimbot.h"
#include "../Features/Movement.h"
#include "../Features/PlayerScale.h"
#include "../Features/Weapon.h"
#include "../Features/Teleport.h"
#include "../Assets/RemoteAssets.h"

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <QuartzCore/QuartzCore.h>

#include "imgui.h"
#include "imgui_impl_metal.h"

static UIWindow *SSFindGameWindow(void) {
    UIWindow *best = nil;
    CGFloat bestArea = 0.f;
    for (UIWindow *w in UIApplication.sharedApplication.windows) {
        if (!w || w.hidden || w.alpha < 0.01f) continue;
        if (w.windowLevel < UIWindowLevelNormal) continue;
        CGRect f = w.bounds;
        CGFloat area = f.size.width * f.size.height;
        if (area > bestArea) {
            bestArea = area;
            best = w;
        }
    }
    if (best) return best;
    return UIApplication.sharedApplication.keyWindow;
}

@interface StateScriptOverlayView : MTKView
@end

@implementation StateScriptOverlayView
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!Settings::bShowMenu.load()) return nil;
    return [super hitTest:point withEvent:event];
}
@end

@interface StateScriptOverlay () <MTKViewDelegate>
@property (nonatomic, weak) UIWindow *hostWindow;
@property (nonatomic, strong) UIWindow *menuWindow;
@property (nonatomic, strong) StateScriptOverlayView *mtkView;
@property (nonatomic, strong) UIButton *toggleButton;
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

- (void)ensureMenuOverlayForGame:(UIWindow *)game {
    if (self.menuWindow) return;

    if (!self.device) {
        self.device = MTLCreateSystemDefaultDevice();
    }
    if (!self.device) return;

    if (!self.commandQueue) {
        self.commandQueue = [self.device newCommandQueue];
    }
    if (!self.commandQueue) return;

    CGRect bounds = game ? game.bounds : UIScreen.mainScreen.bounds;
    UIWindowScene *scene = game.windowScene;
    UIWindow *menu = nil;
    if (scene) {
        menu = [[UIWindow alloc] initWithWindowScene:scene];
        menu.frame = bounds;
    } else {
        menu = [[UIWindow alloc] initWithFrame:bounds];
    }

    menu.windowLevel = UIWindowLevelAlert + 1;
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
    mtk.paused = YES;
    mtk.enableSetNeedsDisplay = NO;

    UIViewController *vc = [UIViewController new];
    vc.view = mtk;
    menu.rootViewController = vc;

    self.menuWindow = menu;
    self.mtkView = mtk;
}

- (void)install {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *game = SSFindGameWindow();
        if (!game) return;

        self.hostWindow = game;
        [self setupToggleButtonOnWindow:game];
        [self setupWatermarkOnWindow:game];

        if (self.toggleButton) {
            [game bringSubviewToFront:self.toggleButton];
        }
        if (self.watermarkLabel) {
            [game bringSubviewToFront:self.watermarkLabel];
        }
    });
}

- (void)setupToggleButtonOnWindow:(UIWindow *)game {
    if (self.toggleButton) {
        if (self.toggleButton.superview != game) {
            [game addSubview:self.toggleButton];
        }
        return;
    }

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(16, 56, 58, 58);
    btn.backgroundColor = [[UIColor colorWithRed:0.05f green:0.55f blue:0.20f alpha:1] colorWithAlphaComponent:0.94f];
    btn.layer.cornerRadius = 29;
    btn.layer.borderWidth = 2.5f;
    btn.layer.borderColor = [UIColor colorWithWhite:1.f alpha:0.9f].CGColor;
    btn.clipsToBounds = YES;
    btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [btn setTitle:@"360" forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [btn addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [btn addGestureRecognizer:pan];

    [game addSubview:btn];
    self.toggleButton = btn;

    __weak UIButton *weakBtn = btn;
    RemoteAssets::LoadUIImageFromURL(RemoteAssets::kToggleIconURL, ^(UIImage *image) {
        UIButton *b = weakBtn;
        if (!b || !image) return;
        [b setImage:image forState:UIControlStateNormal];
        [b setTitle:nil forState:UIControlStateNormal];
    });
}

- (void)setupWatermarkOnWindow:(UIWindow *)game {
    if (Settings::bStreamerMode.load()) return;

    if (self.watermarkLabel) {
        if (self.watermarkLabel.superview != game) {
            [game addSubview:self.watermarkLabel];
        }
        return;
    }

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, game.bounds.size.height - 36, 200, 28)];
    label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    label.text = @"Loop360";
    label.textColor = [UIColor colorWithRed:0.2f green:1.f blue:0.45f alpha:1.f];
    label.font = [UIFont boldSystemFontOfSize:14];
    label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.45f];
    label.layer.cornerRadius = 6.f;
    label.clipsToBounds = YES;
    label.textAlignment = NSTextAlignmentCenter;
    label.userInteractionEnabled = YES;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleMenu)];
    [label addGestureRecognizer:tap];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [label addGestureRecognizer:pan];

    [game addSubview:label];
    self.watermarkLabel = label;
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    UIView *view = gesture.view;
    CGPoint t = [gesture translationInView:view.superview];
    view.center = CGPointMake(view.center.x + t.x, view.center.y + t.y);
    [gesture setTranslation:CGPointZero inView:view.superview];
}

- (void)toggleMenu {
    bool show = !Settings::bShowMenu.load();
    Settings::bShowMenu.store(show);

    if (!self.menuWindow || !self.mtkView) {
        [self ensureMenuOverlayForGame:self.hostWindow];
    }

    if (self.menuWindow) {
        self.menuWindow.hidden = !show;
    }
    if (self.mtkView) {
        self.mtkView.paused = !show;
        self.mtkView.userInteractionEnabled = show;
    }

    if (self.hostWindow) {
        if (self.toggleButton) {
            [self.hostWindow bringSubviewToFront:self.toggleButton];
        }
        if (self.watermarkLabel) {
            [self.hostWindow bringSubviewToFront:self.watermarkLabel];
        }
    }
}

- (void)applyStreamerMode {
    if (self.toggleButton) {
        self.toggleButton.hidden = Settings::bStreamerMode.load();
    }
    if (self.watermarkLabel) {
        self.watermarkLabel.hidden = Settings::bStreamerMode.load();
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
