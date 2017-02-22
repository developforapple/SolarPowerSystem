//
//  YGOrderMallCell.m
//  Golf
//
//  Created by bo wang on 2016/10/28.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGOrderMallCell.h"
#import "YGMallOrderModel.h"
#import "YGOrderHandlerMall.h"

@interface YGOrderMallCell () <UICollectionViewDataSource,UICollectionViewDelegate>
{
    CGSize _itemSize;
}

@property (weak, nonatomic) IBOutlet UIView *duiPanel;
@property (weak, nonatomic) IBOutlet UIButton *yunbiBtn;

@property (weak, nonatomic) IBOutlet UIView *singleCommodityPanel;
@property (weak, nonatomic) IBOutlet UILabel *singleTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *singleSpecLabel;
@property (weak, nonatomic) IBOutlet UIImageView *singleCommodityImageView;

@property (weak, nonatomic) IBOutlet UIView *multiCommodityPanel;
@property (weak, nonatomic) IBOutlet UICollectionView *commodityListView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *commodityListLayout;

@property (strong, nonatomic) NSArray *commodityList;
@property (assign, nonatomic) BOOL multiMode;

@property (strong, nonatomic) YGOrderHandlerMall *handler;
@end

@implementation YGOrderMallCell

+ (CGFloat)estimatedRowHeight
{
    return 180.f;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    if (self.commodityListView) {
        self.commodityListView.allowsSelection = NO;
        [self.commodityListView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"YGMultiCommodityCell"];
        _itemSize = self.commodityListLayout.itemSize;
    }
}

- (YGMallOrderModel *)order
{
    id o = [super order];
    if (![o isKindOfClass:[YGMallOrderModel class]]) return nil;
    return o;
}

- (void)configureWithOrder:(YGMallOrderModel *)order
{
    if (![order isKindOfClass:[YGMallOrderModel class]]) return;
    
    self.commodityList = [order commodityList];
    self.multiMode = self.commodityList.count > 1;

    [super configureWithOrder:order];
}

- (void)configureStatusPanel
{
    [super configureStatusPanel];
    
    YGMallOrderModel *order = [self order];
    YGMallOrderStatus status = order.order_state;
    NSInteger orderTotal = order.order_total;
    BOOL showFreightStr = YES;
    
    switch (status) {
        case YGMallOrderStatusUnpaid:{
            self.statusLabel.text = @"待付款";
            self.statusLabel.textColor = kYGStatusOrangeColor;
        }   break;
        case YGMallOrderStatusPaid:{
            self.statusLabel.text = @"待发货";
            self.statusLabel.textColor = kYGStatusOrangeColor;
        }   break;
        case YGMallOrderStatusShipped:{
            self.statusLabel.text = @"待确认收货";
            self.statusLabel.textColor = kYGStatusOrangeColor;
        }   break;
        case YGMallOrderStatusReceived:{
            self.statusLabel.text = @"待评价";
            self.statusLabel.textColor = kYGStatusBlueColor;
        }   break;
        case YGMallOrderStatusReviewed:{
            self.statusLabel.text = @"已完成";
            self.statusLabel.textColor = kYGStatusBlueColor;
        }   break;
        case YGMallOrderStatusClosed:{
            self.statusLabel.text = @"已取消";
            self.statusLabel.textColor = kYGStatusGrayColor;
            showFreightStr = NO;
        }   break;
        case YGMallOrderStatusApplyRefund:{
            self.statusLabel.text = @"申请退款中";
            self.statusLabel.textColor = kYGStatusRedColor;
            showFreightStr = NO;
        }   break;
        case YGMallOrderStatusRefunded:{
            self.statusLabel.text = @"退款完成";
            self.statusLabel.textColor = kYGStatusRedColor;
        }   break;
        case YGMallOrderStatusCreating:
        case YGMallOrderStatusCreatingRefund:break;
    }
    
    NSString *paymentTitle = [order paymentTitle];
    NSString *freightStr = (order.freight>0 && showFreightStr)?@"(含运费)":@"";
    NSString *priceStr = [NSString stringWithFormat:@"%@:￥%ld%@",paymentTitle,orderTotal/100,freightStr];
    
    self.priceTitleLabel.text = priceStr;
    self.subPriceTitleLabel.text = [NSString stringWithFormat:@"共%ld件商品",(long)order.quantity];
    
    BOOL hasYunbi = order.isYunbiVisible;
    self.yunbiBtn.hidden = !hasYunbi;
    if (hasYunbi) {
        [self.yunbiBtn setTitle:[NSString stringWithFormat:@"返%ld",(long)order.give_yunbi/100] forState:UIControlStateNormal];
    }
    
    BOOL isVirtualOrder = order.isVirtualOrder;
    self.duiPanel.hidden = !isVirtualOrder;
    self.duiPanel.horizontalZero_ = !isVirtualOrder;
}

- (void)configureContentPanel
{
    [super configureContentPanel];
    
    self.multiCommodityPanel.hidden = !self.multiMode;
    self.singleCommodityPanel.hidden = self.multiMode;
    
    if (self.multiMode) {
        [self setupMultiPanel];
    }else{
        [self setupSinglePanel];
    }
}

- (void)configureActionPanel
{
    [super configureActionPanel];
    
    YGMallOrderModel *order = [self order];
    YGOrderMallAction actionType = YGOrderMallAction_Base;
    BOOL deleteBtnVisible = NO;
    
    switch (order.order_state) {
        case YGMallOrderStatusUnpaid:{
            actionType = YGOrderMallAction_Pay;
        }   break;
        case YGMallOrderStatusPaid:{
            actionType = YGOrderMallAction_Refund;
        }   break;
        case YGMallOrderStatusShipped:{
            actionType = YGOrderMallAction_Received;
        }   break;
        case YGMallOrderStatusReceived:{
            actionType = YGOrderMallAction_Review;
        }   break;
        case YGMallOrderStatusReviewed:{
            deleteBtnVisible = YES;
        }   break;
        case YGMallOrderStatusClosed:{
            deleteBtnVisible = YES;
            actionType = YGOrderMallAction_Rebuy;
        }   break;
        case YGMallOrderStatusApplyRefund:{
            actionType = YGOrderMallAction_CancelRefund;
        }   break;
        case YGMallOrderStatusRefunded:{
            deleteBtnVisible = YES;
            actionType = YGOrderMallAction_Rebuy;
        }   break;
        case YGMallOrderStatusCreating:
        case YGMallOrderStatusCreatingRefund:break;
    }
    [self setDeleteBtnVisible:deleteBtnVisible];
    self.actionBtn_1.tag = actionType;
    self.actionBtn_1.hidden = actionType==YGOrderMallAction_Base;
    [self.actionBtn_1 setTitle:[YGOrderHandlerMall actionTitleString:actionType] forState:UIControlStateNormal];
    self.actionBtn_1.selected = actionType==YGOrderMallAction_Pay || actionType==YGOrderMallAction_Received;
    self.actionBtn_1.highlighted = actionType==YGOrderMallAction_Rebuy || actionType==YGOrderMallAction_Review;
}

- (void)setupSinglePanel
{
    self.commodityListLayout.itemSize = CGSizeMake(1, 1);
    YGMallOrderCommodity *commodity = [self.commodityList firstObject];
    self.singleTitleLabel.text = commodity.commodity_name;
    self.singleSpecLabel.text = commodity.spec_name;
    [self.singleCommodityImageView sd_setImageWithURL:[NSURL URLWithString:commodity.photo_image]];
}

- (void)setupMultiPanel
{
    self.commodityListLayout.itemSize = _itemSize;
    [self.commodityListView reloadData];
}

- (YGOrderHandlerMall *)handler
{
    if (!_handler || _handler.order != self.order) {
        _handler = [YGOrderHandlerMall handlerWithOrder:self.order];
        _handler.viewCtrl = [self viewController];
    }
    return _handler;
}

- (void)actionBtn1Action:(UIButton *)btn
{
    [super actionBtn1Action:btn];
    YGOrderMallAction action = btn.tag;
    [self.handler handleAction:action];
}

- (void)deleteBtnAction:(id)sender
{
    [super deleteBtnAction:sender];
    [self.handler handleAction:YGOrderMallAction_Delete];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.commodityList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YGMultiCommodityCell" forIndexPath:indexPath];
    cell.userInteractionEnabled = NO;
    
    if (indexPath.item < self.commodityList.count) {
        YGMallOrderCommodity *commodity = self.commodityList[indexPath.item];
        UIImageView *imageView = [cell.contentView viewWithTag:10086];
        if (!imageView) {
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _itemSize.width, _itemSize.height)];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.tag = 10086;
            [cell.contentView addSubview:imageView];
        }
        imageView.frame = CGRectMake(0, 0, _itemSize.width, _itemSize.height);
        [imageView sd_setImageWithURL:[NSURL URLWithString:commodity.photo_image]];
    }
    return cell;
}

@end

NSString *const kYGOrderMallCell = @"YGOrderMallCell";
