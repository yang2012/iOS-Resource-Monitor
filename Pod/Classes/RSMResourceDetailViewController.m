//
//  RSMResourceDetailViewController.m
//  Luna
//
//  Created by Justin Yang on 31/10/2016.
//  Copyright © 2016 dianping. All rights reserved.
//

#import "RSMResourceDetailViewController.h"
#import "RSMResourceConsoler.h"
#import "NSData+RSMGzip.h"

@interface RSMResourceDetailViewController ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UITextView *textView;

@end

@implementation RSMResourceDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"资源详情";
    self.view.backgroundColor = [UIColor blackColor];
    
    if (self.entity.response != nil) {
        if ([self.entity.response.MIMEType hasPrefix:@"image"]) {
            self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:self.entity.data]];
            [self.view addSubview:self.imageView];
        } else {
            self.textView.text = [self formatedDescriptionForRequest:self.entity.request
                                                            response:self.entity.response
                                                        responseData:self.entity.data];
            [self.view addSubview:self.textView];
        }
    } else {
        self.textView.text = [self formatedDescriptionForError:self.entity.error];
        [self.view addSubview:self.textView];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGSize size = self.view.bounds.size;
    
    [self.imageView sizeToFit];
    CGSize imageSize = self.imageView.frame.size;
    CGRect imageFrame = self.imageView.frame;
    imageFrame.origin.x = (size.width - imageSize.width) / 2;
    imageFrame.origin.y = (size.height - imageSize.height) / 2;
    self.imageView.frame = imageFrame;
    
    self.textView.frame = CGRectMake(0, 0, size.width, size.height);
}

#pragma mark - Setter & Getter

- (NSString *)formatedDescriptionForRequest:(NSURLRequest *)request
                                   response:(NSURLResponse *)response
                               responseData:(NSData *)data {
    NSMutableString *desc = [NSMutableString string];
    NSDictionary<NSString *, NSString *> *requestHeaders = request.allHTTPHeaderFields;
    [desc appendString:@"----Request----\n"];
    [desc appendFormat:@"\n[URL]\n%@\n", request.URL.absoluteString];
    [desc appendFormat:@"\n[Method]\n%@\n", request.HTTPMethod];
    [desc appendString:@"\n[Headers]\n"];
    for (NSString *key in requestHeaders.allKeys) {
        NSString *value = requestHeaders[key];
        [desc appendFormat:@"-%@:%@\n", key, value];
    }
    if (request.HTTPBody.length > 0) {
        [desc appendFormat:@"\n[Body]\n%@\n", [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]];
    }
    
    [desc appendString:@"\n-----------------------"];
    [desc appendString:@"\n\n"];
    
    [desc appendString:@"----Response----\n"];
    [desc appendFormat:@"\n[Type]\n%@\n", response.MIMEType];
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        [desc appendString:@"\n[Headers]\n"];
        NSDictionary<NSString *, NSString *> *responseHeaders = httpResponse.allHeaderFields;
        for (NSString *key in responseHeaders.allKeys) {
            NSString *value = responseHeaders[key];
            [desc appendFormat:@"-%@:%@\n", key, value];
        }
        
        [desc appendString:@"\n[Cookies]\n"];
        NSArray<NSHTTPCookie *> *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:httpResponse.allHeaderFields forURL:response.URL];
        for (NSHTTPCookie *cookie in cookies) {
            [desc appendFormat:@"-%@:%@\n", cookie.name, cookie.value];
        }
        
        NSString *encoding = httpResponse.allHeaderFields[@"Content-Encoding"];
        if ([encoding isEqualToString:@"gzip"]) {
            data = [data rsm_dataByGZipDecompressing] ? : data;
        }
    }
    [desc appendFormat:@"\n[Data]\n%@\n", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    
    [desc appendString:@"\n\n"];
    return desc;
}

- (NSString *)formatedDescriptionForError:(NSError *)error {
    NSMutableString *desc = [NSMutableString string];
    [desc appendFormat:@"[URL]\n%@\n", error.userInfo[NSURLErrorFailingURLErrorKey]];
    [desc appendFormat:@"[Code]\n%@\n", @(error.code)];
    [desc appendFormat:@"[Desc]\n%@\n", error.userInfo[NSLocalizedDescriptionKey]];
    return desc;
}

- (UITextView *)textView {
    if (_textView == nil) {
        _textView = [[UITextView alloc] init];
        _textView.editable = NO;
        _textView.font = [UIFont systemFontOfSize:15];
        _textView.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    }
    return _textView;
}

@end
