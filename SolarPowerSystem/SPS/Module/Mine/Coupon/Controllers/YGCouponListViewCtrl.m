//
//  YGCouponListViewCtrl.m
//  Golf
//
//  Created by bo wang on 2016/10/24.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGCouponListViewCtrl.h"
#import "YGCouponCell.h"
#import "YGCouponDetailViewCtrl.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "CouponModel.h"

@interface YGCouponListViewCtrl () <UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<CouponModel *> *couponList;
@property (assign, nonatomic) int pageNo;
@property (assign, nonatomic) BOOL isLoading;
@end

@implementation YGCouponListViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
    
    self.pageNo = 1;
    self.couponList = [NSMutableArray array];
    [self loadData:NO];
}

#pragma mark - UI
- (void)initUI
{
    ygweakify(self);
    [self.tableView setRefreshHeaderEnable:YES footerEnable:YES callback:^(YGRefreshType type) {
        ygstrongify(self);
        [self loadData:YGRefreshTypeFooter==type];
    }];
    if (self.selectionMode) {
        [self rightButtonAction:@"确定"];
    }
}

- (void)doRightNavAction
{
    if (self.didSelectedCoupon) {
        self.didSelectedCoupon(self.curCoupon);
    }
}

#pragma mark - Data

- (void)loadData:(BOOL)isMore
{
    if (self.isLoading) {
        if (isMore) {
            [self.tableView.mj_footer endRefreshing];
        }else{
            [self.tableView.mj_header endRefreshing];
        }
        return;
    }
    
    if (!isMore) {
        self.pageNo = 1;
    }
    self.isLoading = YES;
    
    [YGCouponHelper fetchCouponListUseFilter:self.filter enabledCoupon:self.selectionMode pageNo:self.pageNo completion:^(BOOL suc, BOOL noMore, NSArray<CouponModel *> *list) {
        if (suc) {
            
            BOOL isFirstPage = self.pageNo == 1;
            
            if (noMore) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }else{
                [self.tableView.mj_footer endRefreshing];
            }
            [self.tableView.mj_header endRefreshing];
            
            if (isFirstPage) {
                [self.couponList removeAllObjects];
            }
            [self.couponList addObjectsFromArray:list];
            
            if (self.selectionMode) {
                // 从最新可用优惠券列表中找到当前已记录的优惠券，找到了就更新它，没有找到就选择第一个可用优惠券
                if (self.curCoupon) {
                    CouponModel *tmpCoupon;
                    for (CouponModel *aCoupon in self.couponList) {
                        if (self.curCoupon.couponId == aCoupon.couponId && aCoupon.usable) {
                            tmpCoupon = aCoupon;
                            break;
                        }
                    }
                    if (tmpCoupon) {
                        self.curCoupon = tmpCoupon;
                    }else{
                        for (CouponModel *aCoupon in self.couponList) {
                            if (aCoupon.usable) {
                                self.curCoupon = aCoupon;
                                break;
                            }
                        }
                    }
                }else{
                    for (CouponModel *aCoupon in self.couponList) {
                        if (aCoupon.usable) {
                            self.curCoupon = aCoupon;
                            break;
                        }
                    }
                }
                
                // 更新列表
                [self.tableView reloadData];
                
                // 选中当前记录的优惠券
                if (self.curCoupon) {
                    NSInteger idx = [self.couponList indexOfObject:self.curCoupon];
                    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:2] animated:YES scrollPosition:UITableViewScrollPositionNone];
                }else if(self.couponList.count != 0){
                    //有优惠券，但是都不可用，选择section1
                    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] animated:YES scrollPosition:UITableViewScrollPositionNone];
                }else{
                    //当前无任何优惠券
                    [self.tableView reloadEmptyDataSet];
                }
                
            }else{
                [self.tableView reloadData];
            }
            
            self.isLoading = NO;
            self.pageNo++;
            
        }else{
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            [SVProgressHUD showErrorWithStatus:@"获取失败"];
        }
        [self.tableView reloadEmptyDataSet];
    }];
}

#pragma mark -
- (BOOL)isInputSection:(NSInteger)section
{
    return section == 0;
}

- (BOOL)isNonuseCouponSection:(NSInteger)section
{
    return self.selectionMode && section == 1;
}

- (BOOL)isCouponListSection:(NSInteger)section
{
    return self.selectionMode? ( section == 2  ) : ( section == 1 );
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.selectionMode) {
        return self.couponList.count==0?1:3; //列表里没有任何优惠券，就不显示“不使用优惠券”
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self isCouponListSection:section]) {
        return self.couponList.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ygweakify(self);
    if ([self isInputSection:indexPath.section]) {
        YGCouponInputCell *cell = [tableView dequeueReusableCellWithIdentifier:kYGCouponInputCell forIndexPath:indexPath];
        [cell setDidAddCoupon:^(CouponModel *c) {
            ygstrongify(self);
            [self loadData:NO];
        }];
        return cell;
    }
    
    if ([self isNonuseCouponSection:indexPath.section]) {
        YGCouponNonuseCell *cell = [tableView dequeueReusableCellWithIdentifier:kYGCouponNonuseCell  forIndexPath:indexPath];
        return cell;
    }
    
    YGCouponCell *cell = [tableView dequeueReusableCellWithIdentifier:kYGCouponCell forIndexPath:indexPath];
    cell.selectionMode = self.selectionMode;
    [cell configureWithCoupon:self.couponList[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isCouponListSection:indexPath.section]) {
        return 100.f;
    }
    return 36.f;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isInputSection:indexPath.section]) {
        return [NSIndexPath indexPathForRow:0 inSection:1];
    }
    if (self.selectionMode) {
        CouponModel *coupon = self.couponList[indexPath.row];
        if (!coupon.usable) {
            [SVProgressHUD showErrorWithStatus:@"此现金券当前不可用"];
            return [tableView indexPathForSelectedRow];
        }
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectionMode) {
        if ([self isNonuseCouponSection:indexPath.section]) {
            self.curCoupon = nil;
        }else{
            CouponModel *coupon = self.couponList[indexPath.row];
            if (coupon.usable) {
                self.curCoupon = coupon;
            }
        }
    }else if([self isCouponListSection:indexPath.section]){
        YGCouponDetailViewCtrl *vc = [YGCouponDetailViewCtrl instanceFromStoryboard];
        vc.couponModel = self.couponList[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Empty
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"暂无现金券可用"];
    text.yy_font = [UIFont systemFontOfSize:12];
    text.yy_color = RGBColor(101, 186, 247, 1);
    return text;
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"img_none_list_gray"];
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    BOOL display = self.couponList.count == 0;
    self.tableView.backgroundColor = display?[UIColor whiteColor]:RGBColor(236, 236, 236, 1);
    return display;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return YES;
}

- (BOOL)emptyDataSetShouldBeForcedToDisplay:(UIScrollView *)scrollView
{
    return self.couponList.count == 0;
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return -64.f;
}

@end
