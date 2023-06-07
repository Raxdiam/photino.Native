#ifdef __APPLE__
#pragma once
#include "Photino.h"

@interface UiDelegate : NSObject <WKUIDelegate, WKScriptMessageHandler, WKNavigationDelegate> {
    @public
    NSWindow * window;
    WKWebView * webView;
    Photino * photino;
    WebMessageReceivedCallback webMessageReceivedCallback;
    WebNavigationStartedCallback webNavigationStartedCallback;
    WebContentLoadingCallback webContentLoadingCallback;
    WebNavigationCompletedCallback webNavigationCompletedCallback;
}

@property (nonatomic) BOOL contentLoadingCalled;

@end
#endif