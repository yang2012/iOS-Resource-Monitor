//
//  RSMResourceFilterHeadView.m
//  Pods
//
//  Created by Justin Yang on 29/11/2016.
//
//

#import "RSMResourceFilterHeaderView.h"
#import "RSMResourceFilterModel.h"
#import <LegoBase/UIColor+nvutils.h>
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@class RSMResourceFilterSubHeaderView;

@protocol RSMResourceFilterSubHeadViewDelegate <NSObject>

- (void)subHeadViewDidClick:(RSMResourceFilterSubHeaderView *)subHeaderView;

@end

@interface RSMResourceFilterSubHeaderView : UIView

@property (nonatomic, weak) id<RSMResourceFilterSubHeadViewDelegate> delegate;
@property (nonatomic, weak) RSMResourceFilterModel *model;

- (void)toggleStatus;

@end

@interface RSMResourceFilterSubHeaderView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UIView *seperatorView;

@property (nonatomic, assign) BOOL rotated;

@end

@implementation RSMResourceFilterSubHeaderView

- (instancetype)initWithModel:(RSMResourceFilterModel *)model {
    self = [super init];
    
    if (self) {
        _model = model;
        _rotated = NO;
        
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = [UIColor nvColorWithHexString:@"333"];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.text = model.title;
        [self addSubview:_titleLabel];
        
        _arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rsm_arrow"]];
        _arrowImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_arrowImageView];
        
        _seperatorView = [UIView new];
        _seperatorView.translatesAutoresizingMaskIntoConstraints = NO;
        _seperatorView.backgroundColor = [UIColor nvColorWithHexString:@"d7d7d7"];
        [self addSubview:_seperatorView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClick)];
        [self addGestureRecognizer:tapGesture];
    }
    
    return self;
}

- (void)updateConstraints {
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.titleLabel.superview);
    }];
    
    [self.arrowImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-15);
        make.centerY.equalTo(self);
    }];
    
    [self.seperatorView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@1);
        make.height.equalTo(self.seperatorView.superview).offset(-20);
        make.trailingMargin.equalTo(@0);
        make.centerY.equalTo(self);
    }];
    
    [super updateConstraints];
}

- (void)toggleStatus {
    self.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.arrowImageView.transform = self.rotated ? CGAffineTransformIdentity : CGAffineTransformMakeRotation(M_PI);
                     }
                     completion:^(BOOL finished) {
                         self.rotated = !self.rotated;
                         self.userInteractionEnabled = YES;
                     }];
}

- (void)didClick {
    [self.delegate subHeadViewDidClick:self];
}

@end

@interface RSMResourceFilterHeaderView () <RSMResourceFilterSubHeadViewDelegate>

@property (nonatomic, copy) NSArray<RSMResourceFilterModel *> *models;

@property (nonatomic, strong) RSMResourceFilterSubHeaderView *selectedSubHeaderView;
@property (nonatomic, copy) NSArray<RSMResourceFilterSubHeaderView *> *subHeadViews;

@end

@implementation RSMResourceFilterHeaderView

- (instancetype)initWithModels:(NSArray<RSMResourceFilterModel *> *)models {
    self = [super init];
    
    if (self) {
        _models = [models copy];
        
        UIView *topLine = [UIView new];
        topLine.backgroundColor = [UIColor nvColorWithHexString:@"d7d7d7"];
        topLine.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:topLine];
        
        UIView *bottomLine = [UIView new];
        bottomLine.backgroundColor = [UIColor nvColorWithHexString:@"d7d7d7"];
        bottomLine.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:bottomLine];
        
        [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self);
            make.height.equalTo(@1);
            make.leading.and.top.equalTo(self);
        }];
        
        [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self);
            make.height.equalTo(@1);
            make.leading.and.bottom.equalTo(self);
        }];
        
        [self p_configureWithModels:models];
    }
    
    return self;
}

- (void)reset {
    [self.selectedSubHeaderView toggleStatus];
    self.selectedSubHeaderView = nil;
}

- (void)p_configureWithModels:(NSArray<RSMResourceFilterModel *> *)models {
    self.subHeadViews = [models.rac_sequence map:^id(RSMResourceFilterModel *model) {
        RSMResourceFilterSubHeaderView *subHeadView = [[RSMResourceFilterSubHeaderView alloc] initWithModel:model];
        subHeadView.translatesAutoresizingMaskIntoConstraints = NO;
        subHeadView.delegate = self;
        RAC(subHeadView.titleLabel, text) = [RACObserve(model, defaultIndex) map:^id(NSNumber *defaultIndex) {
            return defaultIndex.integerValue < model.values.count ? [model.values[defaultIndex.integerValue] uppercaseString] : @"UNKNOW";
        }];
        return subHeadView;
    }].array;
    
    for (NSUInteger index = 0; index < self.subHeadViews.count; index++) {
        RSMResourceFilterSubHeaderView *subHeadView = self.subHeadViews[index];
        [self addSubview:subHeadView];
        
        RSMResourceFilterSubHeaderView *previousView = nil;
        if (index > 0) {
            previousView = self.subHeadViews[index - 1];
        }
        [subHeadView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.equalTo(@0);
            if (previousView != nil) {
                make.width.equalTo(previousView);
                make.leading.equalTo(previousView.mas_trailing);
            } else {
                make.leading.equalTo(self);
            }
            
            if (index == self.subHeadViews.count - 1) {
                make.trailing.equalTo(self);
            }
        }];
    }
    
    self.subHeadViews.lastObject.seperatorView.hidden = YES;
}

- (void)subHeadViewDidClick:(RSMResourceFilterSubHeaderView *)subHeaderView {
    [subHeaderView toggleStatus];
    
    if ([self.selectedSubHeaderView isEqual:subHeaderView]) {
        self.selectedSubHeaderView = nil;
        [self.delegate headerView:self didUnselectModel:subHeaderView.model];
    } else {
        [self.selectedSubHeaderView toggleStatus];
        
        self.selectedSubHeaderView = subHeaderView;
        [self.delegate headerView:self didSelectModel:subHeaderView.model];
    }
}

@end
