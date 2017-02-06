//
//  RSMWebViewResourceURLProtocol.m
//  Luna
//
//  Created by Justin Yang on 28/10/2016.
//  Copyright © 2016 dianping. All rights reserved.
//

#import "RSMResourceMonitorURLProtocol.h"
#import "RSMResourceConsoler.h"

static NSString *const RSMResourceURLProtocolStartTimeKey = @"RSMResourceURLProtocolStartTimeKey";

@interface RSMResourceMonitorURLProtocol ()

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSMutableData *data;

@end

@implementation RSMResourceMonitorURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    return [NSURLProtocol propertyForKey:RSMResourceURLProtocolStartTimeKey inRequest:request] == nil;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    //标示改request已经处理过了，防止无限循环
    NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
    [NSURLProtocol setProperty:@(startTime) forKey:RSMResourceURLProtocolStartTimeKey inRequest:mutableReqeust];
    self.connection = [NSURLConnection connectionWithRequest:mutableReqeust delegate:self];
}

- (void)stopLoading {
    [self.connection cancel];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
    
    if (data.length > 0) {
        [self.data appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
    
    NSNumber *startTimeInterval = [NSURLProtocol propertyForKey:RSMResourceURLProtocolStartTimeKey inRequest:connection.currentRequest];
    if (startTimeInterval != nil) {
        NSTimeInterval endTimeInterval = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval duration = endTimeInterval - [startTimeInterval doubleValue];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            RSMResorceEntity *entity = [RSMResorceEntity new];
            entity.request = connection.currentRequest;
            entity.response = self.response;
            entity.data = self.data;
            entity.duration = @(duration);
            [[RSMResourceConsoler consoler] addLogEnttiy:entity];
        });
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSURLRequest *request = connection.currentRequest;
    
    NSNumber *startTimeInterval = [NSURLProtocol propertyForKey:RSMResourceURLProtocolStartTimeKey inRequest:request];
    if (startTimeInterval != nil) {
        NSTimeInterval endTimeInterval = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval duration = endTimeInterval - [startTimeInterval doubleValue];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            RSMResorceEntity *entity = [RSMResorceEntity new];
            entity.duration = @(duration);
            entity.request = request;
            entity.error = error;
            [[RSMResourceConsoler consoler] addLogEnttiy:entity];
        });
    }
    
    [self.client URLProtocol:self didFailWithError:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.response = response;
    
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    if (response) {
        [self.client URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
        return nil;
    }
    return request;
}

- (NSMutableData *)data {
    if (_data == nil) {
        _data = [NSMutableData data];
    }
    return _data;
}

@end
