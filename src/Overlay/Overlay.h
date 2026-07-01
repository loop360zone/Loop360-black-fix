#pragma once

#import <UIKit/UIKit.h>

@interface StateScriptOverlay : NSObject
+ (instancetype)shared;
- (void)install;
- (void)toggleMenu;
@end
