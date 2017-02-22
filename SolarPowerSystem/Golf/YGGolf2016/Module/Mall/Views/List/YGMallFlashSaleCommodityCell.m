//
//  YGMallFlashSaleCommodityCell.m
//  Golf
//
//  Created by bo wang on 2016/11/16.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallFlashSaleCommodityCell.h"
#import <PINCache/PINCache.h>

@interface YGMallFlashSaleCommodityCell ()
@property (weak, nonatomic) IBOutlet UIButton *highlightBtn;
@end

@implementation YGMallFlashSaleCommodityCell

- (void)configureWithCommodity:(CommodityModel *)commodity
{
    self.commodity = commodity;
    
    YGFlashSaleModel *flashSale = commodity.flash_sale;
    if (!flashSale || ![flashSale isKindOfClass:[YGFlashSaleModel class]]) return;
    
    NSInteger quantity = flashSale.quantity;
    YGFlashSaleState state = flashSale.flash_status;
    
    [self.commodityImageView sd_setImageWithURL:[NSURL URLWithString:commodity.photoImage] placeholderImage:[UIImage imageNamed:@"default_"]];
    self.commodityTitleLabel.text = commodity.commodityName;
    self.saleStockLabel.text = quantity>0?[NSString stringWithFormat:@"仅剩%ld件",(long)quantity]:@"已抢空";
    self.commodityPriceLabel.text = [NSString stringWithFormat:@"%ld",(long)flashSale.flash_price];
    self.commodityOriginPriceLabel.text = [NSString stringWithFormat:@"￥%ld",(long)flashSale.selling_price];
    
    if (commodity.sellingStatus == 2) {
        self.saleStockBlurLabel.hidden = NO;
        self.saleStockBlurLabel.text = @"已下架";
    }else if (commodity.sellingStatus == 3){
        self.saleStockBlurLabel.hidden = NO;
        self.saleStockBlurLabel.text = @"已售罄";
    }else if(flashSale.quantity <= 0){
        self.saleStockBlurLabel.hidden = NO;
        self.saleStockBlurLabel.text = @"已抢空";
    }else{
        self.saleStockBlurLabel.hidden = YES;
    }
    
    switch (state) {
        case YGFlashSaleStateAuction:{
            
            [self.saleActionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.saleActionBtn setTitle:@"立即抢购" forState:UIControlStateNormal];
            [self.saleActionBtn setBackgroundColor:MainHighlightColor];
            self.saleActionBtn.layer.borderColor = [UIColor clearColor].CGColor;
            self.saleActionBtn.userInteractionEnabled = NO;
            self.saleStatusLabel.text = flashSale.flash_text;
            
        }   break;
            
        case YGFlashSaleStateBuy:{
            
            [self.saleActionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.saleActionBtn setTitle:@"直接购买" forState:UIControlStateNormal];
            [self.saleActionBtn setBackgroundColor:MainHighlightColor];
            self.saleActionBtn.layer.borderColor = [UIColor clearColor].CGColor;
            self.saleStatusLabel.text = flashSale.flash_text;
            self.saleActionBtn.userInteractionEnabled = NO;
            
        }   break;
            
        case YGFlashSaleStateAlert:{
        
            [self.saleActionBtn setTitleColor:MainHighlightColor forState:UIControlStateNormal];
            [self.saleActionBtn setTitle:@"立即提醒" forState:UIControlStateNormal];
            [self.saleActionBtn setBackgroundColor:[UIColor whiteColor]];
            self.saleActionBtn.layer.borderColor = MainHighlightColor.CGColor;
            self.saleStatusLabel.text = flashSale.flash_text;
            self.saleActionBtn.userInteractionEnabled = YES;

        }   break;
            
        case YGFlashSaleStateCancelAlert:{
            
            [self.saleActionBtn setTitleColor:RGBColor(102, 102, 102, 1) forState:UIControlStateNormal];
            [self.saleActionBtn setTitle:@"取消提醒" forState:UIControlStateNormal];
            [self.saleActionBtn setBackgroundColor:[UIColor whiteColor]];
            self.saleActionBtn.layer.borderColor = RGBColor(102, 102, 102, 1).CGColor;
            self.saleStatusLabel.text = flashSale.flash_text;
            self.saleActionBtn.userInteractionEnabled = YES;
            
        }   break;
            
        case YGFlashSaleStateSellout:{
        
            [self.saleActionBtn setTitleColor:RGBColor(102, 102, 102, 1) forState:UIControlStateNormal];
            [self.saleActionBtn setTitle:@"暂无货" forState:UIControlStateNormal];
            [self.saleActionBtn setBackgroundColor:RGBColor(187, 187, 187, 1)];
            self.saleActionBtn.layer.borderColor = [UIColor clearColor].CGColor;
            self.saleStatusLabel.text = flashSale.flash_text;
            self.saleActionBtn.userInteractionEnabled = NO;
            
        }   break;
    }
}

- (IBAction)buyAction:(UIButton *)btn
{
    YGFlashSaleModel *flashSale = self.commodity.flash_sale;
    switch (flashSale.flash_status) {
        case YGFlashSaleStateAuction:
        case YGFlashSaleStateBuy:
        case YGFlashSaleStateSellout:break;
        case YGFlashSaleStateAlert:{
            [[LoginManager sharedManager] loginIfNeed:[self viewController] doSomething:^(id data) {
                [ServerService updateMallCommodityArrivalNotice:self.commodity.commodityId type:1 addOpera:YES token:[[PINCache sharedCache] objectForKey:WKDeviceTokenKey] callBack:^(id obj) {
                    
                    flashSale.flash_notice = YES;
                    flashSale.flash_status = YGFlashSaleStateCancelAlert;
                    [self configureWithCommodity:self.commodity];
                    
                    [SVProgressHUD showSuccessWithStatus:@"设置成功，开抢前10分钟会提醒您"];
                    
                } failure:^(id error) {
                }];
            }];
            
        }   break;
            
        case YGFlashSaleStateCancelAlert:{
            [ServerService updateMallCommodityArrivalNotice:self.commodity.commodityId type:1 addOpera:NO token:[[PINCache sharedCache] objectForKey:WKDeviceTokenKey] callBack:^(id obj) {
                flashSale.flash_notice = NO;
                flashSale.flash_status = YGFlashSaleStateAlert;
                [self configureWithCommodity:self.commodity];
                
                [SVProgressHUD showSuccessWithStatus:@"提醒已取消"];
                
            } failure:^(id error) {
            }];
            
        }   break;
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    self.highlightBtn.highlighted = highlighted;
}

@end


NSString *const kYGMallFlashSaleCommodityCell = @"YGMallFlashSaleCommodityCell";

@implementation YGMallFlashSaleDateCell

- (void)configureWithCommodity:(CommodityModel *)commodity
{
    YGFlashSaleModel *flashSale = commodity.flash_sale;
    if (!flashSale) return;
    
    NSTimeInterval time = flashSale.flash_time;
    NSTimeInterval serverTime = flashSale.server_time;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    
    if (time <= serverTime || [date isToday]) {
        self.dateLabel.text = @"今日抢购";
    }else{
        NSDate *previousDay = [date dateByAddingDays:-1];
        if ([previousDay isToday]) {
            self.dateLabel.text = @"明日开抢";
        }else{
            self.dateLabel.text = [NSString stringWithFormat:@"%ld月%ld日开抢",(long)date.month,(long)date.day];
        }
    }
    
}

@end

NSString *const kYGMallFlashSaleDateCell = @"YGMallFlashSaleDateCell";
