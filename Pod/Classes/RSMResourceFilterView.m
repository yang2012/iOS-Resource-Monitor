//
//  RSMResourceFilterView.m
//  Pods
//
//  Created by Justin Yang on 29/11/2016.
//
//

#import "RSMResourceFilterView.h"
#import "RSMResourceFilterHeaderView.h"
#import <NVLayout/UIView+Layout.h>
#import <LegoBase/UIColor+nvutils.h>
#import <Masonry/Masonry.h>

@interface RSMResourceFilterView () <UITableViewDelegate, UITableViewDataSource, RSMResourceFilterHeaderViewDelegate>

@property (nonatomic, copy) NSArray<RSMResourceFilterModel *> *models;
@property (nonatomic, strong) RSMResourceFilterModel *showingModel;

@property (nonatomic, strong) RSMResourceFilterHeaderView *headerView;
@property (nonatomic, strong) UITableView *contentTableView;
@property (nonatomic, strong) UIView *backgroundView;

@end

@implementation RSMResourceFilterView

- (instancetype)initWithModels:(NSArray<RSMResourceFilterModel *> *)models {
    self = [super init];
    
    if (self) {
        _models = [models copy];
        
        _headerView = [[RSMResourceFilterHeaderView alloc] initWithModels:models];
        _headerView.delegate = self;
        _headerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_headerView];
        
        _contentTableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                         style:UITableViewStylePlain];
        _contentTableView.tableFooterView = [UIView new];
        _contentTableView.delegate = self;
        _contentTableView.dataSource = self;
        [_contentTableView registerClass:[UITableViewCell class]
                  forCellReuseIdentifier:[self cellIdentifier]];
        
        _backgroundView = [UIView new];
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(backgroundDidTap)];
        [_backgroundView addGestureRecognizer:tapGesture];
        
        [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    
    return self;
}

- (void)reset:(BOOL)animated {
    [self.headerView reset];
    [self hideFilterContentView:animated
                     completion:^(BOOL finished) {
        self.showingModel = nil;
    }];
}

#pragma mark - Action

- (void)backgroundDidTap {
    [self reset:YES];
}

- (void)showFilterContentView {
    UIView *containerView = [UIApplication sharedApplication].keyWindow;
    CGRect headerRect = [self convertRect:self.headerView.frame toView:containerView];
    CGFloat originY = headerRect.origin.y + headerRect.size.height;
    self.backgroundView.frame = CGRectMake(0, originY, containerView.width, containerView.bottom - originY);
    self.backgroundView.alpha = 0;
    [containerView addSubview:self.backgroundView];
    
    self.contentTableView.frame = CGRectMake(0, originY, containerView.width, 0);
    [containerView addSubview:self.contentTableView];
    
    [UIView animateWithDuration:0.3f
                     animations:^{
                         self.backgroundView.alpha = 1;
                         self.contentTableView.height = 200;
                     }];
}

- (void)hideFilterContentView:(BOOL)animated
                   completion:(void (^ __nullable)(BOOL finished))completion {
    [UIView animateWithDuration:animated ? 0.3f : 0
                     animations:^{
                         self.contentTableView.height = 0;
                         self.backgroundView.alpha = 0;
                     } completion:^(BOOL finished) {
                         [self.backgroundView removeFromSuperview];
                         [self.contentTableView removeFromSuperview];
                         if (completion) {
                             completion(finished);
                         }
                     }];
}

#pragma mark - RSMResourceFilterHeaderViewDelegate

- (void)headerView:(RSMResourceFilterHeaderView *)headerView didSelectModel:(RSMResourceFilterModel *)model {
    BOOL needReloadData = self.showingModel != nil;
    
    self.showingModel = model;
    
    if (needReloadData) {
        [self.contentTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self showFilterContentView];
    }
}

- (void)headerView:(RSMResourceFilterHeaderView *)headerView didUnselectModel:(RSMResourceFilterModel *)model {
    [self hideFilterContentView:YES
                     completion:^(BOOL finished) {
        self.showingModel = nil;
    }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *value = self.showingModel.values[indexPath.row];
    self.showingModel.defaultIndex = indexPath.row;
    [self reset:YES];
    if (self.showingModel.selection) {
        self.showingModel.selection(value);
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.showingModel.values.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self cellIdentifier]
                                                            forIndexPath:indexPath];
    BOOL selected = indexPath.row == self.showingModel.defaultIndex;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [self.showingModel.values[indexPath.row] uppercaseString];
    cell.textColor = selected ? [UIColor nvColorWithHexString:@"297ce3"] : [UIColor nvColorWithHexString:@"333333"];
    return cell;
}

#pragma mark - Setter & Getter

- (void)setShowingModel:(RSMResourceFilterModel *)showingModel {
    _showingModel = showingModel;
    
    [self.contentTableView reloadData];
}

- (NSString *)cellIdentifier {
    return @"filterCell";
}

@end
