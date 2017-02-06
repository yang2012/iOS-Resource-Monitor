//
//  RSMResourceFilterView.h
//  Pods
//
//  Created by Justin Yang on 29/11/2016.
//
//

#import <UIKit/UIKit.h>
#import "RSMResourceFilterModel.h"

@interface RSMResourceFilterView : UIView

- (instancetype)initWithModels:(NSArray<RSMResourceFilterModel *> *)models;

- (void)reset:(BOOL)animated;

@end
