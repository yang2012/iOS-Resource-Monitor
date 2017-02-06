//
//  RSMResourceFilterHeadView.h
//  Pods
//
//  Created by Justin Yang on 29/11/2016.
//
//

#import <UIKit/UIKit.h>

@class RSMResourceFilterModel;
@class RSMResourceFilterHeaderView;

@protocol RSMResourceFilterHeaderViewDelegate <NSObject>

- (void)headerView:(RSMResourceFilterHeaderView *)headerView didSelectModel:(RSMResourceFilterModel *)model;

- (void)headerView:(RSMResourceFilterHeaderView *)headerView didUnselectModel:(RSMResourceFilterModel *)model;

@end

typedef void(^RSMResourceFilterHeadViewSelection)(RSMResourceFilterModel *);

@interface RSMResourceFilterHeaderView : UIView

@property (nonatomic, weak) id<RSMResourceFilterHeaderViewDelegate> delegate;

- (instancetype)initWithModels:(NSArray<RSMResourceFilterModel *> *)models;

- (void)reset;

@end
