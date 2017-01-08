//
//  AppDelegate.m
//  CriolloToDoServer
//
//  Created by Cătălin Stan on 05/01/2017.
//  Copyright © 2017 Criollo. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate () <CRServerDelegate>

@property (nonatomic, nonnull, strong) CRHTTPServer *server;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.server = [[CRHTTPServer alloc] initWithDelegate:self];
    
    NSError *error;
    if ( ! [self.server startListening:&error] ) {
        [CRApp logErrorFormat:@"Error starting server: %@", error];
        [CRApp terminate:nil];
        return;
    }
    
    [CRApp log:@"Successfully started server"];
    
    [self.server add:^(CRRequest * _Nonnull request, CRResponse * _Nonnull response, CRRouteCompletionBlock  _Nonnull completionHandler) {
        [response setValue:[NSBundle mainBundle].bundleIdentifier forHTTPHeaderField:@"Server"];
        completionHandler();
    }];
    
    [self.server get:@"/ping" block:^(CRRequest * _Nonnull request, CRResponse * _Nonnull response, CRRouteCompletionBlock  _Nonnull completionHandler) {
        [response setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
        [response send:@{@"status": @YES}];
    }];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	[self.server stopListening];
}

#pragma mark - CRServerDelegate

- (void)server:(CRServer *)server didFinishRequest:(CRRequest *)request {
    static dispatch_queue_t loggingQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loggingQueue = dispatch_queue_create("loggingQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(loggingQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
    });
    dispatch_async(loggingQueue, ^{
        [CRApp logFormat:@"%@ %@ - %lu", [NSDate date], request, request.response.statusCode];
    });
}

@end
