//
//  YGMallCommoditySpecViewCtrl.m
//  Golf
//
//  Created by bo wang on 2016/10/12.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallCommoditySpecViewCtrl.h"
#import "YGCollectionViewLayout.h"
#import "YGMallCommoditySpecOptionCell.h"
#import "YGMallCommoditySpecInfoView.h"

@interface YGMallCommoditySpecViewCtrl ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UIView *bgBlurView;
@property (weak, nonatomic) IBOutlet UIView *specPanel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *originPriceTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *originPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *specPanelTopToBottomGuideConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *specPanelHeightConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *specCollectionView;
@property (weak, nonatomic) IBOutlet YGLeftAlignmentFlowLayout *specLayout;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property (strong, nonatomic) NSMutableSet<CommoditySpecAttr *> *selectedOptions;
@property (strong, nonatomic) CommoditySpecSKUModel *curSKU;
@property (assign, nonatomic) int status; // 0 未选择规格 1 有货 2 无货
@property (assign, nonatomic) NSInteger quantity;
@end

@implementation YGMallCommoditySpecViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.hidden = YES;
    self.selectedOptions = [NSMutableSet set];
    self.specLayout.maximumInteritemSpacing = 15.f;
    self.quantity = 1;
    self.status = 0;
    
    [self dismiss];
}

#pragma mark - UI

- (void)show:(CommodityInfoModel *)commodity
{
    self.commodity = commodity;
    [self show];
}

- (void)show
{
    self.bgBlurView.alpha = 0.f;
    self.specPanelTopToBottomGuideConstraint.constant = 0.f;
    [self.specCollectionView reloadData];
    [self updateHeightConstraintBeforeVisible];
    [self update];
    [self.view layoutIfNeeded];
    self.view.hidden = NO;
    
    [UIView animateWithDuration:.4f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.specPanelTopToBottomGuideConstraint.constant = -self.specPanelHeightConstraint.constant;
        [self.view layoutIfNeeded];
        self.bgBlurView.alpha = 1.f;
    } completion:^(BOOL finished) {
        if (self.specCollectionView.contentSize.height > CGRectGetHeight(self.specCollectionView.bounds)) {
            [self.specCollectionView flashScrollIndicators];
        }
    }];
}

- (void)dismiss
{
    [UIView animateWithDuration:.4f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.specPanelTopToBottomGuideConstraint.constant = 0.f;
        [self.view layoutIfNeeded];
        self.bgBlurView.alpha = 0.f;
    } completion:^(BOOL finished) {
        self.view.hidden = YES;
    }];
}

- (void)update
{
    NSArray *selectedOptionsArray = [self.selectedOptions allObjects];
    [self.commodity updateAttrArrayBySelectedAttr:selectedOptionsArray];
    self.curSKU = [self.commodity skuWithSelectedAttr:selectedOptionsArray];
    [self.specCollectionView reloadData];
    [self updatePriceInfo];
    [self updateRemainInfo];
    [self updateSubmitBtn];
}

- (void)updatePriceInfo
{
    NSInteger price = self.curSKU?(self.curSKU.selling_price/100):self.commodity.sellingPrice;
    NSInteger originPrice = self.curSKU?(self.curSKU.original_price/100):self.commodity.originalPrice;
    BOOL priceDiff = price!=originPrice;
    
    self.originPriceLabel.hidden = self.originPriceTitleLabel.hidden = !priceDiff;
    if (priceDiff) {
        NSMutableAttributedString *priceString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"￥%ld",(long)originPrice]];
        priceString.yy_font = [UIFont systemFontOfSize:12];
        priceString.yy_color = RGBColor(153, 153, 153, 1);
        priceString.yy_strikethroughStyle = NSUnderlineStyleSingle;
        priceString.yy_strikethroughColor = RGBColor(153, 153, 153, 1);
        self.originPriceLabel.attributedText = priceString;
    }
    self.priceLabel.text = [NSString stringWithFormat:@"￥%ld",(long)price];
}

- (void)updateRemainInfo
{
    int status = 0;
    if (self.curSKU) {
        status = 1;
        CommoditySpecSKUModel *sku = self.curSKU;
        NSInteger surplusQuantity = sku.stock_quantity-sku.sold_quantity; // 剩余数量
        if (surplusQuantity <= 0) {
            status = 2;
            self.amountLabel.text = @"库存不足";
        }else if(sku.buy_limit != 0 && surplusQuantity >= sku.buy_limit){ // 有限购，且剩余数量大于限购数量。显示限购提示
            self.amountLabel.text = [NSString stringWithFormat:@"库存%ld件（每人限购%ld件）",(long)surplusQuantity,(long)sku.buy_limit];
        }else{
            self.amountLabel.text = [NSString stringWithFormat:@"库存%ld件",(long)surplusQuantity];
        }
    }else if(self.commodity && self.commodity.skuArray.count == 0){
        // 商品没有规格可选时
        status = 1;
        CommodityInfoModel *commodity = self.commodity;
        NSInteger surplusQuantity = commodity.stockQuantity-commodity.soldQuantity; // 剩余数量
        if (surplusQuantity <= 0) {
            self.amountLabel.text = @"库存不足";
            status = 2;
        }else if (commodity.buyLimit != 0 && surplusQuantity >= commodity.buyLimit){
            self.amountLabel.text = [NSString stringWithFormat:@"库存%ld件（每人限购%ld件）",(long)surplusQuantity,(long)commodity.buyLimit];
        }else{
            self.amountLabel.text = [NSString stringWithFormat:@"库存%ld件",(long)surplusQuantity];
        }
    }else{
        // 商品规格未选全时
        status = 0;
        self.amountLabel.text = @"";
    }
    self.status = status;
}

- (void)updateHeightConstraintBeforeVisible
{
    CGFloat contentH = [self.specLayout collectionViewContentSize].height;
    contentH += (92.f+48.f);//顶部48的区域 底部54的按钮
    contentH = MIN(MAX(160.f, contentH), Device_Height*2/3.f); //最低160 最高屏幕2/3
    self.specPanelHeightConstraint.constant = ceilf(contentH);
    [self.view layoutIfNeeded];
}

- (void)updateSubmitBtn
{
    // normal 请选择规格
    // highlight 确定
    // disable 无货
    if (self.status == 0) {
        self.submitBtn.backgroundColor = RGBColor(187, 187, 187, 1);
        [self.submitBtn setTitle:@"请选择规格" forState:UIControlStateNormal];
        [self.submitBtn setTitleColor:RGBColor(102, 102, 102, 1) forState:UIControlStateNormal];
        self.submitBtn.userInteractionEnabled = YES;
    }else if (self.status == 1){
        self.submitBtn.backgroundColor = MainHighlightColor;
        [self.submitBtn setTitle:@"确定" forState:UIControlStateNormal];
        [self.submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.submitBtn.userInteractionEnabled = YES;
    }else if (self.status == 2){
        self.submitBtn.backgroundColor = RGBColor(187, 187, 187, 1);
        [self.submitBtn setTitle:@"该规格暂时无货" forState:UIControlStateNormal];
        [self.submitBtn setTitleColor:RGBColor(102, 102, 102, 1) forState:UIControlStateNormal];
        self.submitBtn.userInteractionEnabled = NO;
    }
}

#pragma mark - Data
- (CommoditySpecAttrModel *)attrModelAtInSection:(NSInteger )section
{
    return self.commodity.attrArray[section];
}

- (CommoditySpecAttr *)optionAtIndexPath:(NSIndexPath *)indexPath
{
    CommoditySpecAttrModel *attrModel = [self attrModelAtInSection:indexPath.section];
    return attrModel.attr[indexPath.row];
}

- (void)convertSelection:(CommoditySpecAttr *)option
{
    if (!option.selectable){
        return;
    }
    
    if (option.selected) {
        [self.selectedOptions removeObject:option];
    }else{
        CommoditySpecAttr *shouldRemovedAttr;
        for (CommoditySpecAttr *attr in self.selectedOptions) {
            if (attr.propId == option.propId) {
                shouldRemovedAttr = attr;
                break;
            }
        }
        if (shouldRemovedAttr) {
            [self.selectedOptions removeObject:shouldRemovedAttr];
        }
        [self.selectedOptions addObject:option];
    }
}

- (void)reset
{
    self.quantity = 1;
    [self.selectedOptions removeAllObjects];
    [self update];
}

#pragma mark - Action
- (IBAction)close:(id)sender
{
    [self dismiss];
}

- (IBAction)submit:(id)sender
{
    if (self.commodity.skuArray.count == 0) {
        if (self.commodity.stockQuantity - self.commodity.soldQuantity <= 0) {
            [SVProgressHUD showInfoWithStatus:@"库存不足"];
        }else if (self.submitBlock) {
            self.submitBlock(nil,self.quantity);
        }
        return;
    }
    
    if (!self.curSKU){
        [SVProgressHUD showInfoWithStatus:@"请选择规格"];
        return;
    }
    
    NSInteger surplusQuantity = self.curSKU.stock_quantity-self.curSKU.sold_quantity;
    if (surplusQuantity <= 0) {
        [SVProgressHUD showInfoWithStatus:@"库存不足"];
    }else if (self.quantity == 0) {
        [SVProgressHUD showInfoWithStatus:@"数量不能为0"];
    }else if (self.curSKU.buy_limit != 0 && self.quantity > self.curSKU.buy_limit) {
        [SVProgressHUD showInfoWithStatus:@"已超过限购数量"];
    }else if (self.quantity > surplusQuantity) {
        [SVProgressHUD showInfoWithStatus:@"库存不足"];
    }else{
        if (self.submitBlock) {
            self.submitBlock(self.curSKU,self.quantity);
        }
    }
}

#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.commodity.attrArray.count+1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == self.commodity.attrArray.count) {
        return 1;
    }
    return [self attrModelAtInSection:section].attr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == self.commodity.attrArray.count) {
        YGMallCommoditySpecOptionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kYGMallCommoditySpecQuantityCell forIndexPath:indexPath];
        [cell setQuantityDidChanged:^(NSInteger quantity) {
            self.quantity = quantity;
        }];
        if (self.curSKU) {
            [cell configureWithSKU:self.curSKU];
        }else{
            [cell configureWithCommodity:self.commodity];
        }
        return cell;
    }
    
    YGMallCommoditySpecOptionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kYGMallCommoditySpecOptionCell forIndexPath:indexPath];
    [cell configureWithOption:[self optionAtIndexPath:indexPath]];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        YGMallCommoditySpecInfoView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kYGMallCommoditySpecHeader forIndexPath:indexPath];
        if (indexPath.section == self.commodity.attrArray.count) {
            header.titleLabel.text = @"数量";
        }else{
            [header configureWithAttrModel:[self attrModelAtInSection:indexPath.section]];
        }
        return header;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == self.commodity.attrArray.count) {
        CGFloat width = CGRectGetWidth(collectionView.bounds) - self.specLayout.sectionInset.left - self.specLayout.sectionInset.right;
        return CGSizeMake(width, 32.f);
    }
    return [YGMallCommoditySpecOptionCell sizeOfOption:[self optionAtIndexPath:indexPath]];
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != self.commodity.attrArray.count) {
        CommoditySpecAttr *attr = [self optionAtIndexPath:indexPath];
        BOOL selectable = attr.selectable;
//        if (!selectable) { //提示
//            [SVProgressHUD showInfoWithStatus:@""];
//        }
        return selectable;
    }
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != self.commodity.attrArray.count) {
        CommoditySpecAttr *attr = [self optionAtIndexPath:indexPath];
        [self convertSelection:attr];
        [self update];
    }
}

@end
