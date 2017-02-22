//
//  YGMallCartViewCtrl.m
//  Golf
//
//  Created by bo wang on 2016/10/10.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallCartViewCtrl.h"
#import "YGMallCartCommodityCell.h"
#import "YGMallCartGroupCell.h"
#import "YGMallCartDiscountCell.h"
#import "YGMallCart.h"
#import "YGMallCartFeatureViewCtrl.h"
#import "YGMallOrderViewCtrl.h"
#import "YGMallCartSubmitNoticeViewCtrl.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface YGMallCartViewCtrl ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *featureContainer;
@property (strong, nonatomic) YGMallCartFeatureViewCtrl *featureViewCtrl;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomPanel;   //底部操作区域
@property (weak, nonatomic) IBOutlet UIButton *bottomSelectionBtn;//底部全选按钮
@property (weak, nonatomic) IBOutlet UIButton *bottomSubmitBtn;//底部结算和删除按钮
@property (weak, nonatomic) IBOutlet UIView *bottomPriceView;//底部价格区域
@property (weak, nonatomic) IBOutlet UILabel *bottomPriceLabel;//底部价格Label
@property (strong, nonatomic) YGMallCart *cart;
@end

@implementation YGMallCartViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    YGPostBuriedPoint(YGMallPointCart);
    [self initUI];
    [self initData];
}

- (void)reload
{
    [self.cart loadCartData];
}

#pragma mark - UI
- (void)initUI
{
    ygweakify(self);
    [self.view layoutIfNeeded];
    self.tableView.contentInset = UIEdgeInsetsMake(63, 0, CGRectGetHeight(self.bottomPanel.bounds), 0);
    [self.tableView setRefreshHeaderEnable:YES footerEnable:NO callback:^(YGRefreshType type) {
        ygstrongify(self);
        [self.cart loadCartData];
    }];
}

- (void)updateUI
{
    if (self.cart.isEditing && [self.cart isEmpty]) {
        //编辑过后购物车已被清空
        self.cart.editing = NO;
    }
    
    [self.tableView reloadData];
    [self updateBottomPanel];
    
    BOOL featureVisible = !self.cart.isEditing && self.cart.isEmpty;
    if (featureVisible) {
        [self rightButtonAction:nil];
        self.navigationItem.title = @"购物车";
    }else{
        NSInteger kinds = self.cart.isEditing?self.cart.selectedEditList.count:self.cart.selectedList.count;
        self.navigationItem.title = [NSString stringWithFormat:@"%@(%lu)",self.cart.isEditing?@"编辑":@"购物车",kinds];
        [self rightButtonAction:self.cart.isEditing?@"完成":@"编辑"];
    }
    
    [self.featureContainer setHidden:!featureVisible animated:YES];
    self.featureViewCtrl.visible = featureVisible;
    [UIView animateWithDuration:.2f animations:^{
        if (featureVisible) {
            [self.view bringSubviewToFront:self.featureContainer];
        }else{
            [self.view sendSubviewToBack:self.featureContainer];
        }
    } completion:nil];
}

- (void)updateBottomPanel
{
    self.bottomSelectionBtn.selected = [self.cart isSelectedAll];
    self.bottomPriceView.hidden = self.cart.isEditing;
    [self.bottomSubmitBtn setTitle:self.cart.isEditing?@"删除":@"结算" forState:UIControlStateNormal];
    CGFloat price = [self.cart updatePrice];
    self.bottomPriceLabel.text = [NSString stringWithFormat:@"￥%.0f",price];
}

#pragma mark - Data
- (void)initData
{
    ygweakify(self);
    self.featureViewCtrl.cart = self.cart = [[YGMallCart alloc] init];
    self.cart.defaultSelectionInfo = self.defaultSelectionInfo;
    [self.cart setCartResetCallbck:^(BOOL suc) {
        ygstrongify(self);
        [self.tableView.mj_header endRefreshing];
        if (suc) {
            [SVProgressHUD dismiss];
            [self updateUI];
        }else{
            [SVProgressHUD showErrorWithStatus:self.cart.lastError];
        }
    }];
    [self.cart setUpdateCallback:^{
        ygstrongify(self);
        [self updateUI];
    }];
    [self.cart loadCartData];
    self.defaultSelectionInfo = nil;
}

- (CommodityModel *)commodityAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row == 0) return nil;
    NSArray *groups = self.cart.isEditing?self.cart.editGroups:self.cart.groups;
    YGMallCartGroup *group = groups[indexPath.section];
    CommodityModel *commodity = group.commodity[indexPath.row];//-1];
    return commodity;
}

- (YGMallCartGroup *)groupInSection:(NSInteger)section
{
    NSArray *groups = self.cart.isEditing?self.cart.editGroups:self.cart.groups;
    return groups[section];
}

- (void)prepareDeleteCommodities:(NSArray<CommodityModel *> *)commodities
{
    if (commodities.count == 0) {
        [SVProgressHUD showInfoWithStatus:@"请选择需要删除的商品"];
        return;
    }
    NSString *message;
    if (commodities.count == 1) {
        message =[NSString stringWithFormat:@"从购物车删除：%@",[[commodities firstObject] commodityName]];
    }else{
        message = @"多个商品即将从购物车中删除";
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认删除？" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self performDeleteCommodities:commodities];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)performDeleteCommodities:(NSArray<CommodityModel *> *)commodities
{
    [SVProgressHUD show];
    ygweakify(self);
    [self.cart deleteCommodities:commodities completion:^(BOOL suc) {
        // 成功删除之后会重新获取数据刷新界面。这里不用刷新
        if (!suc) {
            ygstrongify(self);
            [SVProgressHUD showErrorWithStatus:self.cart.lastError];
        }
    }];
}

- (void)prepareSubmit:(NSInteger)commodityType
{
    NSArray<YGMallCartGroup *> *groups = [self.cart prepareCrateOrder:commodityType];
    YGMallOrderModel *order = [YGMallOrderModel createOrderModelInGroups:groups];
    YGMallOrderViewCtrl *vc = [YGMallOrderViewCtrl instanceFromStoryboard];
    vc.order = order;
    ygweakify(self);
    [vc setDidSubmitOrderCallback:^{
        ygstrongify(self);
        [self.cart loadCartData];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Action
- (void)doRightNavAction
{
    self.cart.editing = !self.cart.isEditing;
    [self updateUI];
}

- (IBAction)nextStep:(UIButton *)sender
{
    if (self.cart.isEditing) {
        [self prepareDeleteCommodities:self.cart.selectedEditList];
        return;
    }
    
    if (self.cart.selectedList.count == 0) {
        [SVProgressHUD showInfoWithStatus:@"没有选择任何商品"];
        return;
    }
    
    NSInteger type = [self.cart selectedCommodityType];
    if (type == -1) {
        // 不可以合并结算
        ygweakify(self);
        YGMallCartSubmitNoticeViewCtrl *vc = [YGMallCartSubmitNoticeViewCtrl instanceFromStoryboard];
        vc.cart = self.cart;
        [vc setDidChoiceCommodities:^(NSArray *commodities) {
            ygstrongify(self);
            [self.cart justSelectCommodities:commodities];
        }];
        [vc setWillSubmitCommodity:^(NSInteger type) {
            ygstrongify(self);
            [self prepareSubmit:type];
        }];
        [vc show];
    }else{
        [self prepareSubmit:type];
    }
}

- (IBAction)selectAll:(id)sender
{
    if ([self.cart canSelectAll]) {
        [self.cart convertAllSelection];
    }else{
        [SVProgressHUD showInfoWithStatus:@"购物车有商品无法购买"];
    }
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.cart.isEditing?self.cart.editGroups.count:self.cart.groups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    YGMallCartGroup *group = [self groupInSection:section];
    return group.commodity.count;//+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ygweakify(self);
    YGMallCartCommodityCell *cell = [tableView dequeueReusableCellWithIdentifier:kYGMallCartCommodityCell forIndexPath:indexPath];
    [cell setWillDeleteCallback:^(CommodityModel *cm) {
        ygstrongify(self);
        [self prepareDeleteCommodities:@[cm]];
    }];
    [cell setDidChangedQuantityCallback:^(CommodityModel *cm) {
        ygstrongify(self);
        [self updateBottomPanel];
    }];
    [cell configureWithCommodity:[self commodityAtIndexPath:indexPath] inCart:self.cart];
    return cell;
    
    // 以下为商家进行分组的cells
//    ygweakify(self);
//    if (indexPath.row == 0) {
//        YGMallCartGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:kYGMallCartGroupCell forIndexPath:indexPath];
//        [cell setGroupSelectionBlock:^(YGMallCartGroup *g) {
//            ygstrongify(self);
//            [self.cart convertGroupSelection:g];
//        }];
//        [cell configureWithGroup:[self groupInSection:indexPath.section] inCart:self.cart];
//        return cell;
//    }
//    
//    YGMallCartCommodityCell *cell = [tableView dequeueReusableCellWithIdentifier:kYGMallCartCommodityCell forIndexPath:indexPath];
//    [cell setWillDeleteCallback:^(CommodityModel *cm) {
//        ygstrongify(self);
//        [self prepareDeleteCommodities:@[cm]];
//    }];
//    [cell setDidChangedQuantityCallback:^(CommodityModel *cm) {
//        ygstrongify(self);
//        [self updateBottomPanel];
//    }];
//    [cell configureWithCommodity:[self commodityAtIndexPath:indexPath] inCart:self.cart];
//    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommodityModel *commodity = [self commodityAtIndexPath:indexPath];
    BOOL hasYunbi = commodity.giveYunbi>0;
    BOOL isVirtual = commodity.commodityType == 2;
    NSInteger extra = hasYunbi + isVirtual;
    return 96.f + (extra==0?0:(extra==1?38.f:64.f));
//    return indexPath.row==0?40.f:96.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        CommodityModel *commodity = [self commodityAtIndexPath:indexPath];
        if ([self.cart canSelectCommodity:commodity]) {
            [self.cart convertSelection:commodity];
        }else{
            [SVProgressHUD showInfoWithStatus:@"该商品已无法购买"];
        }
    }
    
//    if (indexPath.row == 0) {
//        YGMallCartGroup *group = [self groupInSection:indexPath.section];
//        if ([self.cart canSelectGroup:group]) {
//            [self.cart convertGroupSelection:group];
//        }else{
//            [SVProgressHUD showInfoWithStatus:@"该商家有商品已无法购买"];
//        }
//    }else{
//        CommodityModel *commodity = [self commodityAtIndexPath:indexPath];
//        if ([self.cart canSelectCommodity:commodity]) {
//            [self.cart convertSelection:commodity];
//        }else{
//            [SVProgressHUD showInfoWithStatus:@"该商品已无法购买"];
//        }
//    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return !self.cart.isEditing;// && indexPath.row!=0;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        CommodityModel *commodity = [self commodityAtIndexPath:indexPath];
        if (commodity) {
            [self prepareDeleteCommodities:@[commodity]];
        }
    }];
    action.backgroundColor = RGBColor(255, 147, 18, 1);
    return @[action];
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"YGMallCartFeatureViewCtrlSegueID"]) {
        self.featureViewCtrl = segue.destinationViewController;
    }
}

@end
