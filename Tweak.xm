#import <UIKit/UIKit.h>
#include "Settings.h"
#include "Overlay/Overlay.h"

static void SSScheduleInstall(void) {
    const int64_t delays[] = {1, 2, 3, 5, 8, 13, 21, 30, 45, 60};
    for (int i = 0; i < 10; i++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delays[i] * NSEC_PER_SEC),
                       dispatch_get_main_queue(), ^{
            [[StateScriptOverlay shared] install];
        });
    }
}

static void SSOnAppActive(void) {
    Settings::bIsAppActive.store(true);
    SSScheduleInstall();
}

static void SSOnAppInactive(void) {
    Settings::bIsAppActive.store(false);
}

%hook UIApplication

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BOOL ok = %orig;
    SSOnAppActive();
    return ok;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    %orig;
    SSOnAppActive();
}

- (void)applicationWillResignActive:(UIApplication *)application {
    %orig;
    SSOnAppInactive();
}

%end

%hook UIWindow

- (void)makeKeyAndVisible {
    %orig;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[StateScriptOverlay shared] install];
    });
}

%end

%ctor {
    @autoreleasepool {
        Settings::Load();
        Settings::bIsAppActive.store(true);
        SSScheduleInstall();
    }
}
