//
//  YGMallCommoditySpecOptionCell.m
//  Golf
//
//  Created by bo wang on 2016/10/12.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallCommoditySpecOptionCell.h"
#import "CommodityInfoModel.h"

@interface YGMallCommoditySpecOptionCell () <YGMallQuantityControlDelegate>

@end

@implementation YGMallCommoditySpecOptionCell

+ (CGSize)sizeOfOption:(CommoditySpecAttr *)option
{
    if (!CGSizeEqualToSize(option.attrValueSizeCache, CGSizeZero)) {
        return option.attrValueSizeCache;
    }
    
    CGSize size = [option.attrValue sizeForFont:[UIFont systemFontOfSize:12] size:CGSizeMake(2000, 27) mode:NSLineBreakByWordWrapping];
    size.width += 24.f;
    size.height = 27.f;
    size.width = MAX(50.f, ceilf(size.width));//最小宽度50
    option.attrValueSizeCache = size;
    return size;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if (self.optionLabel) {
        self.optionLabel.layer.masksToBounds = YES;
        self.optionLabel.layer.cornerRadius = 2.f;
        self.optionLabel.layer.borderWidth = .5f;
    }
    
    if (self.quantityControl) {
        self.quantityControl.value = 1;
    }
}

- (void)configureWithOption:(CommoditySpecAttr *)option
{
    _option = option;
    
    BOOL selectable = option.selectable;
    BOOL selected = option.selected;
    
    if (!selectable) {
        //灰色不可选状态
        self.optionLabel.textColor = RGBColor(238, 238, 238, 1);
        self.optionLabel.backgroundColor = [UIColor whiteColor];
        self.optionLabel.layer.borderColor = RGBColor(238, 238, 238, 1).CGColor;
    }else if (selected){
        //蓝色选中状态
        self.optionLabel.textColor = RGBColor(36, 157, 243, 1);
        self.optionLabel.backgroundColor = RGBColor(233, 245, 254, 1);
        self.optionLabel.layer.borderColor = MainHighlightColor.CGColor;
    }else{
        //默认状态
        self.optionLabel.textColor = RGBColor(51, 51, 51, 1);
        self.optionLabel.backgroundColor = [UIColor whiteColor];
        self.optionLabel.layer.borderColor = RGBColor(204, 204, 204, 1).CGColor;
    }
    
    self.optionLabel.text = option.attrValue;
}

- (void)configureWithSKU:(CommoditySpecSKUModel *)sku
{
    if (sku != _sku) {
        _sku = sku;
        self.quantityControl.value = 1;
        [self quantityDidChangeTo:1];
        
        NSInteger surplusQuantity = sku.stock_quantity-sku.sold_quantity; // 剩余数量
        
        if (surplusQuantity <= 0) {
            self.quantityControl.value = 0;
            [self quantityDidChangeTo:0];
            self.quantityNotice.text = @"库存不足";
        }else if(sku.buy_limit != 0 && surplusQuantity >= sku.buy_limit){ // 有限购，且剩余数量大于限购数量。显示限购提示
            self.quantityNotice.text = [NSString stringWithFormat:@"库存%ld件（每人限购%ld件）",(long)surplusQuantity,(long)sku.buy_limit];
        }else{
            self.quantityNotice.text = [NSString stringWithFormat:@"库存%ld件",(long)surplusQuantity];
        }
    }
}

- (void)configureWithCommodity:(CommodityInfoModel *)commodity
{
    if (!_commodity) {
        _commodity = commodity;
        self.quantityControl.value = 1;
        [self quantityDidChangeTo:1];
        NSInteger surplusQuantity = commodity.stockQuantity-commodity.soldQuantity; // 剩余数量
        if (surplusQuantity <= 0) {
            self.quantityControl.value = 0;
            [self quantityDidChangeTo:0];
            self.quantityNotice.text = @"库存不足";
        }else if (commodity.buyLimit != 0 && surplusQuantity >= commodity.buyLimit){
            self.quantityNotice.text = [NSString stringWithFormat:@"库存%ld件（每人限购%ld件）",(long)surplusQuantity,(long)commodity.buyLimit];
        }else{
            self.quantityNotice.text = [NSString stringWithFormat:@"库存%ld件",(long)surplusQuantity];
        }
    }
}

- (void)quantityDidChangeTo:(NSInteger)value
{
    if (self.quantityDidChanged) {
        self.quantityDidChanged(value);
    }
}

#pragma mark - Delegate
- (BOOL)quantityControl:(YGMallQuantityControl *)control shouldChangeValue:(NSInteger)toValue from:(NSInteger)fromValue
{
    BOOL shouldChange = YES;
    if (toValue < 1) {
        shouldChange = NO;
    }else if (self.sku){
        BOOL canBuy = self.sku.buy_limit == 0 || toValue <= self.sku.buy_limit;   //超过购买限制
        BOOL haveStock = toValue <= (self.sku.stock_quantity-self.sku.sold_quantity); //数量超过剩余商品数量
        shouldChange = canBuy && haveStock;
    }else if (self.commodity){
        BOOL canBuy = self.commodity.buyLimit == 0 || toValue <= self.commodity.buyLimit;//超过购买限制
        BOOL haveStock = toValue <= (self.commodity.stockQuantity-self.commodity.soldQuantity);//数量超过剩余商品数量
        shouldChange = canBuy && haveStock;
    }
    return shouldChange;
}

- (void)quantityControl:(YGMallQuantityControl *)control didChangedValue:(NSInteger)value
{
    [self quantityDidChangeTo:value];
}

@end

NSString *const kYGMallCommoditySpecOptionCell = @"YGMallCommoditySpecOptionCell";
NSString *const kYGMallCommoditySpecQuantityCell = @"YGMallCommoditySpecQuantityCell";
