//
//  RSMResourceConsoler.h
//  Luna
//
//  Created by Justin Yang on 31/10/2016.
//  Copyright © 2016 dianping. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const RSMResourceConsoleLogChanged;

@interface RSMResorceEntity : NSObject

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, copy) NSData *data;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSNumber *duration;

@end

@interface RSMResourceConsoler : NSObject

@property (nonatomic, copy, readonly) NSArray<RSMResorceEntity *> *logs;

+ (instancetype)consoler;

- (void)addLogEnttiy:(RSMResorceEntity *)entity;
- (void)clearAllLogs;

@end
