#import <UIKit/UIKit.h>
#include "Settings.h"
#include "Overlay/Overlay.h"

static void SSScheduleInstall(void) {
    const int64_t delays[] = {5, 9, 13, 17};
    for (int i = 0; i < 4; i++) {
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

- (void)applicationDidBecomeActive:(UIApplication *)application {
    %orig;
    SSOnAppActive();
}

- (void)applicationWillResignActive:(UIApplication *)application {
    %orig;
    SSOnAppInactive();
}

%end

%ctor {
    @autoreleasepool {
        Settings::Load();
    }
}
