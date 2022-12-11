#ifdef __APPLE__
#pragma once
#include "../../Shared/Photino.h"

@interface UrlSchemeHandler : NSObject <WKURLSchemeHandler> {
    @public
    WebResourceRequestedCallback requestHandler;
}
@end
#endif