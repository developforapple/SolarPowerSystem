//
//  YGMallOrderViewCtrl.m
//  Golf
//
//  Created by bo wang on 2016/10/19.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallOrderViewCtrl.h"
#import "YGMallOrderModel.h"
#import "YGMallOrderStatusView.h"
#import "YGMallOrderOperateView.h"
#import "YGMallOrderCell.h"
#import "YGCouponListViewCtrl.h"

#import "YGOrderHandlerMall.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface YGMallOrderViewCtrl () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet YGMallOrderStatusView *statusPanel;//订单状态。这里需要使用strong使statusPanel没显示时不被释放
@property (weak, nonatomic) IBOutlet YGMallOrderOperateView *operatePanel;//订单操作
@property (weak, nonatomic) IBOutlet UIView *virtualOrderNoticePanel; //虚拟订单提示信息
@property (weak, nonatomic) IBOutlet UIView *submitOrderPanel; //提交订单
@property (weak, nonatomic) IBOutlet UILabel *submitOrderPriceLabel;
@property (weak, nonatomic) IBOutlet UIView *submitRefundPanel;//提交退款申请
@property (weak, nonatomic) IBOutlet UIButton *submitRefundBtn;
@property (assign, nonatomic) BOOL loading;
@property (assign, nonatomic) BOOL didCouponLoaded; //优惠券信息是否已加载过
@property (assign, nonatomic) BOOL needUpdateOrder;
@property (strong, nonatomic) YGOrderHandlerMall *handler;
@end

@implementation YGMallOrderViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
    [self initNotification];
    [self loadOrderInfoIfNeed];
    [self loadCouponInfoIfNeed];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateUI];
}

#pragma mark - Data
- (void)initNotification
{
    ygweakify(self);
    [[[NSNotificationCenter defaultCenter]
      rac_addObserverForName:kYGOrderDidChangedNotification object:nil]
     subscribeNext:^(NSNotification *x) {
         ygstrongify(self);
         YGMallOrderModel *order = x.object;
         if (order && [order isKindOfClass:[YGMallOrderModel class]] && (order.order_id == self.orderId || order.tempOrderId == self.orderId)) {
             
             if (order.tempOrderId != 0 && self.didSubmitOrderCallback) {
                 self.didSubmitOrderCallback();
             }
             
             self.order = order;
             NSDictionary *userInfo = x.userInfo;
             _needUpdateOrder = [userInfo[kYGOrderNotificationNeedRequestKey] boolValue];
             if (_needUpdateOrder) {
                 [self loadOrderInfoIfNeed];
             }else{
                 [self updateUI];
             }
         }
     }];
    [[[NSNotificationCenter defaultCenter]
      rac_addObserverForName:kYGOrderDidDeletedNotification object:nil]
     subscribeNext:^(NSNotification *x) {
         ygstrongify(self);
         YGMallOrderModel *order = x.object;
         if (order && [order isKindOfClass:[YGMallOrderModel class]] && order.order_id == self.orderId) {
             [self.navigationController popViewControllerAnimated:YES];
         }
     }];
}

- (void)setOrder:(YGMallOrderModel *)order
{
    _order = order;
    self.orderId = order.order_id;
    self.handler = [YGOrderHandlerMall handlerWithOrder:order];
    self.handler.viewCtrl = self;
}

- (void)loadOrderInfoIfNeed
{
    if (!self.order || self.needUpdateOrder) {
        self.loading = YES;
        [ServerService fetchOrderDetail:self.orderId callBack:^(id obj) {
            self.needUpdateOrder = NO;
            self.loading = NO;
            self.order = obj;
            if ( ([self.order canApplyRefund] || [self.order canCancelApplyRefund]) && self.isApplyRefund) {
                self.order.tempStatus = YGMallOrderStatusCreatingRefund;//创建退款或者创建取消退款
            }else{
                self.isApplyRefund = NO;
            }
            [self updateUI];
        } failure:^(id error) {
        }];
    }
}

- (void)loadCouponInfoIfNeed
{
    if (self.order && self.order.tempStatus == YGMallOrderStatusCreating && !self.didCouponLoaded) {
        self.didCouponLoaded = YES;
        YGCouponFilter *filter = [YGCouponFilter filterWithCommodityOrder:self.order];
        [YGCouponHelper bestCouponWithFilter:filter completion:^(BOOL suc, CouponModel *coupon) {
            if (suc) {
                self.order.coupon = coupon;
                self.order.noValidCoupon = !coupon;
                [self updateUI];
            }
        }];
    }
}

- (void)refreshOrderInfo
{
    _needUpdateOrder = YES;
    [self loadOrderInfoIfNeed];
}

#pragma mark - UI
- (void)initUI
{
    [self updateOrderStatus];
    [self updateBottomPanel];
}

- (void)updateUI
{
    if (self.order.tempStatus == YGMallOrderStatusCreating) {
        self.navigationItem.title = @"订单确认";
    }else if ([self.order isCreatingRefund]){
        self.navigationItem.title = @"申请退款";
    }else if([self.order isCreatingCancelRefund]){
        self.navigationItem.title = @"取消申请退款";
    }else{
        self.navigationItem.title = @"订单详情";
    }
    
    [self updateOrderStatus];
    [self updateBottomPanel];
    [self updateVisible];
}

- (void)updateOrderStatus
{
    BOOL visible = [self isStatusPanelVisible];
    self.statusPanel.hidden = !visible;
    [self.statusPanel configureWithOrder:self.order];
    if (visible) {
        self.tableView.tableHeaderView = self.statusPanel;
    }else{
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        view.backgroundColor = [UIColor clearColor];
        self.tableView.tableHeaderView = view;
    }
    [self.tableView reloadData];
}

- (void)updateBottomPanel
{
    UIEdgeInsets insets = self.tableView.contentInset;
    
    if (!self.order) {
        self.operatePanel.hidden = YES;
        self.submitRefundPanel.hidden = YES;
        self.virtualOrderNoticePanel.hidden = YES;
        self.submitOrderPanel.hidden = YES;
    }else if (self.order.tempStatus == YGMallOrderStatusCreating) {
        BOOL isVirtual = [self.order isVirtualOrder];
        self.operatePanel.hidden = YES;
        self.submitRefundPanel.hidden = YES;
        self.submitOrderPanel.hidden = NO;
        self.virtualOrderNoticePanel.hidden = !isVirtual;
        self.submitOrderPriceLabel.text = [NSString stringWithFormat:@"￥%ld",[self.order needToPayAmount]/100];
        insets.bottom = isVirtual?24.f:0.f;
    }else if (self.order.tempStatus == YGMallOrderStatusCreatingRefund){
        self.operatePanel.hidden = YES;
        self.submitRefundPanel.hidden = NO;
        self.submitOrderPanel.hidden = YES;
        self.virtualOrderNoticePanel.hidden = YES;
        [self.submitRefundBtn setTitle:[self.order isCreatingCancelRefund]?@"取消申请":@"确定申请退款" forState:UIControlStateNormal];
    }else{
        self.operatePanel.hidden = NO;
        self.submitRefundPanel.hidden = YES;
        self.submitOrderPanel.hidden = YES;
        self.virtualOrderNoticePanel.hidden = YES;
        [self.operatePanel configureWithOrder:self.order];
        insets.bottom = 6.f;
    }
    self.tableView.contentInset = insets;
}

- (void)updateVisible
{
    if (self.loading) { 
        [self.loadingIndicator startAnimating];
    }else{
        [self.loadingIndicator stopAnimating];
    }
    [self.tableView setHidden:self.loading animated:YES];
}

#pragma mark - Actions
- (IBAction)submitOrder:(id)sender
{
    [self.handler create];
}

- (IBAction)submitRefund:(id)sender
{
    if ([self.order isCreatingRefund]) {
        [self.handler applyRefund];
    }else if ([self.order isCreatingCancelRefund]) {
        [self.handler cancelRefund];
    }
}

#pragma mark -
// section 是否是顶部地址section
- (BOOL)isAddressSection:(NSInteger)section
{
    return section == 0;
}

- (BOOL)isRefundReasonCell:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    return [self isAddressSection:indexPath.section] && (row == 0);
}

- (YGMallOrderCommodity *)commodityAtIndexPathIfHave:(NSIndexPath *)indexPath
{
    if (![self isCommodityInfoSection:indexPath.section]) return nil;
    
    YGMallOrderModel *subOrder = self.order.order[indexPath.section-1];
    NSInteger commodityCount = subOrder.commodity.count;
    NSInteger cellsAbove = [self.order isInRefundCreating]?2:1;
    NSInteger row = indexPath.row;
    NSInteger idx = row-cellsAbove;
    if (idx >= 0 && idx < commodityCount) {
        return subOrder.commodity[idx];
    }
    return nil;
}

// section是否是显示商品信息的section
- (BOOL)isCommodityInfoSection:(NSInteger)section
{
    return section - 1 < self.order.order.count && section != 0;
}

// indexPath 是否是一个商品分组的第一个商品cell
- (BOOL)isFirstCommodityInGroupAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self isCommodityInfoSection:indexPath.section]) return NO;
    
    NSInteger cellsAbove = [self.order isInRefundCreating]?2:1;
    return indexPath.row == cellsAbove;
}

// section是否是显示优惠券的section
- (BOOL)isCouponSection:(NSInteger)section
{
    return section - 1 == self.order.order.count;
}

// section是否是显示合计内容的section
- (BOOL)isAmountSection:(NSInteger)section
{
    return section - 2 == self.order.order.count;
}

// section是否是显示云币信息的section
- (BOOL)isYunbiSection:(NSInteger)section
{
    return section - 3 == self.order.order.count;
}

#pragma mark -
// 是否显示顶部蓝色状态区域
- (BOOL)isStatusPanelVisible
{
    return self.order.tempStatus != YGMallOrderStatusCreating;
}

// 根据indexPath找到合适的cell
- (NSString *)cellIdentifierAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    NSString *identifier;
    if ([self isAddressSection:section]) {
        if ([self.order isVirtualOrder]) {
            if ([self.order isInRefundCreating]) {
                identifier = kYGMallOrderCell_Refund;
            }else{
                identifier = kYGMallOrderCell_Address;
            }
        }else{
            if ([self.order isInRefundCreating]) {
                identifier = kYGMallOrderCell_Refund;
            }else if([self.order isLogisticsVisible] && row == 0){
                identifier = kYGMallOrderCell_Logistics;
            }else{
                identifier = kYGMallOrderCell_Address;
            }
        }
    }else if ([self isCommodityInfoSection:section]){
        // 正在创建退款申请时，在商品上面额外显示子订单编号
        int flag = [self.order isInRefundCreating]?1:0;
        YGMallOrderModel *subOrder = self.order.order[section-1];

        if (flag && row == 0) {
            identifier = kYGMallOrderCell_OrderNumber;
        }else if (row == flag) {
            identifier = kYGMallOrderCell_Group;
        }else if(row - flag <= subOrder.commodity.count){
            identifier = kYGMallOrderCell_Commodity;
        }else if(row - flag == subOrder.commodity.count + 1){
            identifier = kYGMallOrderCell_Delivery;
        }else{
            identifier = kYGMallOrderCell_Message;
        }
    }else if ([self isCouponSection:section]){
        identifier = kYGMallOrderCell_Coupon;
    }else if ([self isAmountSection:section]){
        identifier = kYGMallOrderCell_Amount;
    }else if ([self isYunbiSection:section]){
        identifier = kYGMallOrderCell_Yunbi;
    }
    return identifier;
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.order.order.count + 4; //收货地址、优惠券、合计、云币、商品分组数
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number = 0;
    if ([self isAddressSection:section]) {
        if ([self.order isVirtualOrder]) {
            // 虚拟订单比较特殊
            if ([self.order isInOrderCreating] || [self.order isInRefundCreating]) {
                number = 1; //创建订单时显示电话，创建退款时显示退款原因
            }
            // 虚拟订单不显示物流信息
        }else{
            //普通订单
            number++; //总是显示收货地址或者退款原因
            if ([self.order isLogisticsVisible]) {
                number ++; //显示物流信息
            }
        }
    }else if ([self isCommodityInfoSection:section]){
        YGMallOrderModel *subOrder = self.order.order[section-1];
        number = subOrder.commodity.count + 3 + ([self.order isInRefundCreating]?1:0);
    }else if ([self isCouponSection:section]){
        number = [self.order isCouponVisible]?1:0;
    }else if ([self isAmountSection:section]){
        number = 1;
    }else if ([self isYunbiSection:section]){
        number = [self.order isYunbiVisible]?1:0;
    }
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [self cellIdentifierAtIndexPath:indexPath];
    YGMallOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    ygweakify(self);
    [cell setWillUpdateCallback:^{
        ygstrongify(self);
        [self updateUI];
    }];
    [cell configureWithOrder:self.order atIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [self cellIdentifierAtIndexPath:indexPath];
    Class c = [YGMallOrderCell classForIdentifier:identifier];
    CGFloat height = [c preferredHeight];
    
    if ([self.order isVirtualOrder]) {
        YGMallOrderCommodity *commodity = [self commodityAtIndexPathIfHave:indexPath];
        if (commodity && commodity.evidence_list.count > 0) {
            // 含有兑换券时 高度需要加上兑换券区域的高度
            height += [commodity evidenceHeight:kEvidenceUnitHeight spacing:kEvidenceSpacing];
        }
    }
    
    if ([self isFirstCommodityInGroupAtIndexPath:indexPath]) {
        height += 10.f;//每个分组的第一个商品，上面多10px的空白
    }
    
    if ([self isFirstCommodityInGroupAtIndexPath:indexPath]) {
        
    }else if ([self.order isVirtualOrder] && [self isAddressSection:indexPath.section]){
        height = 48.f;  //虚拟订单的地址栏高度只有48
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self isAddressSection:section]) {
        return 1.f;
    }else if ([self isCouponSection:section] && ![self.order isCouponVisible]){
        return 1.f;
    }else if ([self isYunbiSection:section] && ![self.order isYunbiVisible]){
        return 1.f;
    }
    return 10.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ygweakify(self);
    if ([self.order isInOrderCreating] && [self isCouponSection:indexPath.section] && [self.order isCouponVisible]) {
        YGCouponListViewCtrl *vc = [YGCouponListViewCtrl instanceFromStoryboard];
        vc.selectionMode = YES;
        vc.curCoupon = self.order.coupon;
        vc.filter = [YGCouponFilter filterWithCommodityOrder:self.order];
        [vc setDidSelectedCoupon:^(CouponModel *coupon) {
            ygstrongify(self);
            self.order.coupon = coupon;
            [self updateUI];
            [self.navigationController popToViewController:self animated:YES];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([self isYunbiSection:indexPath.section] && [self.order isYunbiVisible]){
        //显示云币Notice
        NSString *msg = [NSString stringWithFormat:@"确认收货后完成评价，立返%ld云币至您的账户中，1云币价值1元现金",(long)self.order.give_yunbi/100];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }else if ([self isRefundReasonCell:indexPath] && [self.order isCreatingRefund]){
        //选择退款原因
        [self.handler selectRefundReason:^(NSString *reason) {
            ygstrongify(self);
            self.order.return_memo = reason;
            [self updateUI];
        }];
    }
}

@end
