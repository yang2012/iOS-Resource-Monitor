//
//  RSMResourceConsoleViewController.m
//  Luna
//
//  Created by Justin Yang on 31/10/2016.
//  Copyright © 2016 dianping. All rights reserved.
//

#import "RSMResourceConsoleViewController.h"
#import "RSMResourceDetailViewController.h"
#import "RSMResourceFilterView.h"
#import "RSMResourceConsoler.h"
#import "RSMResourceFilterModel.h"
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface RSMResourceLogCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *methodLabel;

@end

@implementation RSMResourceLogCell

@end

@interface RSMResourceConsoleViewController ()

@property (nonatomic, strong) RSMResourceFilterView *filterView;
@property (nonatomic, copy) NSArray<RSMResorceEntity *> *logs;
@property (nonatomic, copy) NSString *selectedStatus;
@property (nonatomic, copy) NSString *selectedMIMEType;

@end

@implementation RSMResourceConsoleViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStylePlain];
    
    if (self) {
        _selectedStatus = [self defaultStatus];
        _selectedMIMEType = [self defaultMIMEType];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"网络请求";
    self.clearsSelectionOnViewWillAppear = YES;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                                           target:self
                                                                                           action:@selector(clear)];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"RSMResourceLogCell" bundle:nil]
         forCellReuseIdentifier:[self cellIdentifier]];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 40;
    
    [self filterLogs];
    
    __weak RSMResourceConsoleViewController *weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:RSMResourceConsoleLogChanged
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      RSMResourceConsoleViewController *strongSelf = weakSelf;
                                                      [strongSelf filterLogs];
                                                  }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.filterView reset:NO];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.logs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RSMResourceLogCell *cell = [tableView dequeueReusableCellWithIdentifier:[self cellIdentifier] forIndexPath:indexPath];
    RSMResorceEntity *entity = self.logs[indexPath.row];
    cell.statusLabel.text = entity.error == nil ? @"200" : @(entity.error.code).stringValue;
    cell.urlLabel.text = entity.request.URL.absoluteString;
    cell.methodLabel.text = [NSString stringWithFormat:@"Method:%@", entity.request.HTTPMethod];
    cell.typeLabel.text = [NSString stringWithFormat:@"Type:%@", entity.response.MIMEType ? : @"Unkown"];
    cell.sizeLabel.text = [NSString stringWithFormat:@"Size:%@B", @(entity.data.length)];
    cell.durationLabel.text = [NSString stringWithFormat:@"Time:%@s", entity.duration];
    
    UIColor *statusColor = entity.error == nil ? [UIColor colorWithRed:0 green:148/255.0 blue:10/255.0 alpha:1] : [UIColor redColor];
    cell.statusLabel.textColor = statusColor;
    cell.urlLabel.textColor = statusColor;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RSMResorceEntity *entity = self.logs[indexPath.row];
    RSMResourceDetailViewController *detailVC = [[RSMResourceDetailViewController alloc] init];
    detailVC.entity = entity;
    [self.navigationController pushViewController:detailVC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.filterView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

#pragma mark - Action

- (void)clear {
    [self.consoler clearAllLogs];
}

- (void)filterLogs {
    self.logs = [self.consoler.logs.rac_sequence filter:^BOOL(RSMResorceEntity *entity) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)entity.response;
        
        if (![self.selectedStatus isEqualToString:[self defaultStatus]]) {
            if ([self.selectedStatus isEqualToString:[self successStatus]]) {
                if (entity.error != nil) {
                    return NO;
                }
            } else {
                if (entity.error == nil) {
                    return NO;
                }
            }
        }
        
        if (![self.selectedMIMEType isEqualToString:[self defaultMIMEType]]) {
            if (![response.MIMEType hasPrefix:self.selectedMIMEType]) {
                return NO;
            }
        }
        return YES;
    }].array;
    
    [self.tableView reloadData];
}

#pragma mark - Getter & Setter

- (NSString *)defaultStatus {
    return @"all";
}

- (NSString *)defaultMIMEType {
    return @"all";
}

- (NSString *)successStatus {
    return @"success";
}

- (NSString *)failStatus {
    return @"fail";
}

- (NSArray<NSString *> *)formatedStatuses {
    return @[[self defaultStatus], [self successStatus], [self failStatus]];
}

- (NSArray<NSString *> *)formatedMIMETypes {
    return @[[self defaultMIMEType], @"application", @"text", @"image"];
}

- (NSString *)cellIdentifier {
    return @"consoleCell";
}

- (RSMResourceConsoler *)consoler {
    if (_consoler == nil) {
        _consoler = [RSMResourceConsoler consoler];
    }
    return _consoler;
}

- (RSMResourceFilterView *)filterView {
    if (_filterView == nil) {
        RSMResourceFilterModel *statusModel = [[RSMResourceFilterModel alloc] init];
        statusModel.title = @"Status";
        statusModel.values = [self formatedStatuses];
        
        __weak RSMResourceConsoleViewController *weakSelf = self;
        statusModel.selection = ^(NSString *value) {
            RSMResourceConsoleViewController *strongSelf = weakSelf;
            strongSelf.selectedStatus = value;
        };
        
        RSMResourceFilterModel *mimeModel = [[RSMResourceFilterModel alloc] init];
        mimeModel.title = @"MIME";
        mimeModel.values = [self formatedMIMETypes];
        mimeModel.selection = ^(NSString *value) {
            RSMResourceConsoleViewController *strongSelf = weakSelf;
            strongSelf.selectedMIMEType = value;
        };
        
        RSMResourceFilterView *headerView = [[RSMResourceFilterView alloc] initWithModels:@[statusModel, mimeModel]];
        headerView.backgroundColor = [UIColor whiteColor];
        headerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
        
        _filterView = headerView;
    }
    return _filterView;
}

- (void)setSelectedStatus:(NSString *)selectedStatus {
    _selectedStatus = [selectedStatus copy];
    
    [self filterLogs];
}

- (void)setSelectedMIMEType:(NSString *)selectedMIMEType {
    _selectedMIMEType = [selectedMIMEType copy];
    
    [self filterLogs];
}

@end
