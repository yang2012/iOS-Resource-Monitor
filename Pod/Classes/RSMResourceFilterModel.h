//
//  RSMResourceFilterModel.h
//  Pods
//
//  Created by Justin Yang on 29/11/2016.
//
//

#import <Foundation/Foundation.h>

typedef void(^RSMResourceFilterModelSelection)(NSString *value);

@interface RSMResourceFilterModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSArray<NSString *> *values;
@property (nonatomic, assign) NSInteger defaultIndex;
@property (nonatomic, copy) RSMResourceFilterModelSelection selection;

@end
