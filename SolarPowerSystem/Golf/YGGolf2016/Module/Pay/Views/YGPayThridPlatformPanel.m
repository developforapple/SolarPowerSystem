//
//  YGPayThridPlatformPanel.m
//  Golf
//
//  Created by bo wang on 2016/12/2.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGPayThridPlatformPanel.h"
#import "YGPayThridPlatformCell.h"

CGFloat kYGPayThirdPlatformPanelHeight = 0.f;
static CGFloat kPlatformCellHeight = 54.f;
static CGFloat kPlatformMoreHeight = 36.f;

@interface YGPayThridPlatformPanel () <UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) NSArray<YGPayPlatformItem *> *items;
@end

@implementation YGPayThridPlatformPanel

- (void)awakeFromNib
{
    [super awakeFromNib];
    kYGPayThirdPlatformPanelHeight = kPlatformCellHeight * self.config.defaultVisibleCount;
}

- (void)updateWithConfig:(YGPayThirdPlatformPanelConfig *)config
{
    _config = config;
    self.items = [YGPayPlatformItem itemsWithPlatforms:config.platforms];
    [self.tableView reloadData];
    [self adjustHeight];
}

- (BOOL)willShowMoreBtn
{
    return !self.config.moreBtnHidden && self.items.count > self.config.defaultVisibleCount;
}

- (BOOL)isMoreBtnCell:(NSInteger)row
{
    if (![self willShowMoreBtn]) return NO;
    return row == self.config.defaultVisibleCount;
}

- (void)selectionDidChanged:(YGPayPlatformItem *)item
{
    BOOL isSelected = item.selected;
    
    if (isSelected) {
        for (YGPayPlatformItem *aItem in self.items) {
            if (aItem != item) {
                aItem.selected = NO;
            }
        }
    }else{
        for (YGPayPlatformItem *aItem in self.items) {
            aItem.selected = NO;
        }
    }
    [self.tableView reloadData];
    
    self.curPlatform = isSelected?@(item.platform):nil;
    if (self.selectedPlatformDidChangedCallback) {
        self.selectedPlatformDidChangedCallback(self.curPlatform);
    }
}

- (void)adjustHeight
{
    CGFloat height;
    if (![self willShowMoreBtn]) {
        height = self.items.count * kPlatformCellHeight;
    }else{
        height = self.config.defaultVisibleCount * kPlatformCellHeight + kPlatformMoreHeight;
    }
    kYGPayThirdPlatformPanelHeight = height;
    if (self.shouldAdjustHeightCallback) {
        self.shouldAdjustHeightCallback(height);
    }
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (![self willShowMoreBtn]) {
        return self.items.count;
    }
    return self.config.defaultVisibleCount + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isMoreBtnCell:indexPath.row]) {
        static NSString *const cellid = @"YGPayShowMorePlatformCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid forIndexPath:indexPath];
        return cell;
    }
    
    YGPayThridPlatformCell *cell = [tableView dequeueReusableCellWithIdentifier:kYGPayThridPlatformCell forIndexPath:indexPath];
    [cell configureWithItem:self.items[indexPath.row]];
    ygweakify(self);
    [cell setSelectionDidChanged:^(YGPayPlatformItem *platform) {
        ygstrongify(self);
        [self selectionDidChanged:platform];
    }];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isMoreBtnCell:indexPath.row]) {
        return kPlatformMoreHeight;
    }
    return kPlatformCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self isMoreBtnCell:indexPath.row]) {
        self.config.moreBtnHidden = YES;
        [self.tableView reloadData];
        [self adjustHeight];
    }
}

@end

@implementation YGPayThirdPlatformPanelConfig
- (instancetype)init
{
    self = [super init];
    if (self) {
        self->_defaultVisibleCount = 3;
        self->_moreBtnHidden = NO;
    }
    return self;
}
@end
