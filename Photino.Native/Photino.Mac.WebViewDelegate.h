#ifdef __APPLE__
#pragma once
#include "Photino.h"

@interface WebViewDelegate : NSObject <WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler> {
    @public
    NSWindow * window;
    BOOL contextMenuEnabled;
    WebMessageReceivedCallback webMessageReceivedCallback;
}
@end
#endif