#ifdef __APPLE__
#pragma once
#include "Photino.h"
#include <WebKit/WebKit.h>

@interface PhotinoWebView : WKWebView {
    @public
    FileDragDropCallback fileDragDropCallback;
}
@end
#endif