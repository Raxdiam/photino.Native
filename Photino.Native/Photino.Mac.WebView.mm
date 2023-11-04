#import "Photino.Mac.WebView.h"
#include <AppKit/AppKit.h>
#include <Foundation/Foundation.h>
#include <WebKit/WebKit.h>

@interface PhotinoWebView () <WKScriptMessageHandler>
@property(nonatomic, strong) NSMutableArray<NSString *> *receivedFilePaths;
@end

@implementation PhotinoWebView

- (instancetype)initWithFrame:(CGRect)frame
                configuration:(WKWebViewConfiguration *)configuration {
    self = [super initWithFrame:frame configuration:configuration];
    if (self) {
        [self.configuration.userContentController
            addScriptMessageHandler:self
                               name:@"dropHandler"];
    }
    return self;
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"dropHandler"]) {
        NSDictionary *messageBody = message.body;
        NSString *elementId = messageBody[@"elementId"];

        if (elementId && self.receivedFilePaths.count > 0) {
            char *elementIdc = strdup([elementId UTF8String]);
            char **pathsc =
                (char **)calloc(self.receivedFilePaths.count, sizeof(char *));
            for (NSUInteger i = 0; i < self.receivedFilePaths.count; i++) {
                NSString *filePath = self.receivedFilePaths[i];
                const char *cStr = [filePath UTF8String];

                pathsc[i] = (char *)calloc(strlen(cStr) + 1, sizeof(char));
                strcpy(pathsc[i], cStr);
            }

            fileDragDropCallback(elementIdc, pathsc, (int)self.receivedFilePaths.count);

            [self.receivedFilePaths removeAllObjects];
        }
    }
}

- (NSString *)resolveFilePath:(NSURL *)fileURL {
    NSString *filePath = nil;

    BOOL isAcccessing = [fileURL startAccessingSecurityScopedResource];
    if (isAcccessing) {
        filePath = [fileURL path];
        [fileURL stopAccessingSecurityScopedResource];
    } else {
        NSLog(@"Unable to access %@", fileURL);
    }

    return filePath;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSPasteboard *pasteboard = [sender draggingPasteboard];

    if (self.receivedFilePaths != nil) {
        [self.receivedFilePaths removeAllObjects];
    } else {
        self.receivedFilePaths = [[NSMutableArray alloc] init];
    }

    NSArray *items = [pasteboard pasteboardItems];
    for (NSPasteboardItem *item in items) {
        NSURL *fileURL =
            [NSURL URLWithString:[item stringForType:NSPasteboardTypeFileURL]];
        NSString *filePath = [self resolveFilePath:fileURL];
        if (filePath) {
            [self.receivedFilePaths addObject:filePath];
        }
    }

    return [super performDragOperation:sender];
}

@end