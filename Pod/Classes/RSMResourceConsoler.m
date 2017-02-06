//
//  RSMResourceConsoler.m
//  Luna
//
//  Created by Justin Yang on 31/10/2016.
//  Copyright © 2016 dianping. All rights reserved.
//

#import "RSMResourceConsoler.h"
#import <UIKit/UIKit.h>

NSString *const RSMResourceConsoleLogChanged = @"kResourceConsoleLogChanged";

@implementation RSMResorceEntity

- (void)setDuration:(NSNumber *)duration {
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                                                      scale:5
                                                                                           raiseOnExactness:NO
                                                                                            raiseOnOverflow:NO
                                                                                           raiseOnUnderflow:NO
                                                                                        raiseOnDivideByZero:NO];
    NSDecimalNumber *ouncesDecimal = [[NSDecimalNumber alloc] initWithDouble:duration.doubleValue];
    NSDecimalNumber *formatedDuration = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    _duration = formatedDuration;
}

@end

@interface RSMResourceConsoler ()

@property (nonatomic, strong) NSMutableArray<RSMResorceEntity *> *entities;
@property (nonatomic, assign) NSInteger maxNum;

@end

@implementation RSMResourceConsoler

#pragma mark - Lifecycle

+ (instancetype)consoler {
    static RSMResourceConsoler *__instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __instance = [[RSMResourceConsoler alloc] init];
    });
    return __instance;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _maxNum = 300;
        _entities = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidReceiveMemoryWarning)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public

- (void)addLogEnttiy:(RSMResorceEntity *)entity {
    if (entity != nil) {
        [self.entities addObject:entity];
        
        [self trimLogs];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:RSMResourceConsoleLogChanged object:nil];
    }
}

- (void)clearAllLogs {
    [self.entities removeAllObjects];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RSMResourceConsoleLogChanged object:nil];
}

#pragma mark - Notifications

- (void)applicationDidReceiveMemoryWarning {
    [self clearAllLogs];
}

#pragma mark - Private

- (void)trimLogs {
    if (self.entities.count >= self.maxNum) {
        [self.entities removeObjectsInRange:NSMakeRange(0, self.entities.count / 2)];
    }
}

#pragma mark - Getter & Setter

- (NSArray<RSMResorceEntity *> *)logs {
    return self.entities;
}

@end
