#include "RemoteAssets.h"

namespace RemoteAssets {

void LoadUIImageFromURL(const char *url, void (^handler)(UIImage *image)) {
    if (!url || !handler) return;
    NSURL *nsurl = [NSURL URLWithString:[NSString stringWithUTF8String:url]];
    if (!nsurl) {
        handler(nil);
        return;
    }

    NSURLSessionDataTask *task = [[NSURLSession sharedSession]
        dataTaskWithURL:nsurl
      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
          dispatch_async(dispatch_get_main_queue(), ^{
              if (error || !data || data.length == 0) {
                  handler(nil);
                  return;
              }
              UIImage *img = [UIImage imageWithData:data scale:2.f];
              handler(img);
          });
      }];
    [task resume];
}

} // namespace RemoteAssets
