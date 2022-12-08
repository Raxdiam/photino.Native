#ifdef __APPLE__
#pragma once
#include "Photino.h"

@interface WindowDelegate : NSObject <WKUIDelegate> {
    @public
    NSWindow * window;
    Photino * photino;
}
@end
#endif