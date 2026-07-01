#pragma once

#import <UIKit/UIKit.h>

namespace RemoteAssets {

// GitHub raw URLs — روابط صحيحة https://
static const char *kToggleIconURL =
    "https://raw.githubusercontent.com/mortrxess/icon/main/logo4.png";
static const char *kLogoURL =
    "https://raw.githubusercontent.com/mortrxess/icon/main/logo4.png";

void LoadUIImageFromURL(const char *url, void (^handler)(UIImage *image));

} // namespace RemoteAssets
