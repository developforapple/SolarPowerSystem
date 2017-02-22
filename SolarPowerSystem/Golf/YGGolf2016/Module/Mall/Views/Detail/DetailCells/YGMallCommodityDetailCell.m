//
//  YGMallCommodityDetailCell.m
//  Golf
//
//  Created by bo wang on 2016/11/22.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallCommodityDetailCell.h"
#import "XLCycleScrollView.h"
#import "ImageBrowser.h"
#import "YGCountdownTimer.h"

@interface YGMallCommodityDetailCell ()<XLCycleScrollViewDelegate,XLCycleScrollViewDatasource>

#pragma mark - ImageCell
@property (strong, nonatomic) XLCycleScrollView *cycleScrollView;
@property (strong, nonatomic) NSArray *pictureList;

#pragma mark - FlashSale
@property (strong, nonatomic) YGCountdownTimer *timer;

@end

@implementation YGMallCommodityDetailCell

+ (CGFloat)cellHeightForIdentifier:(NSString *)identifier
                         commodity:(CommodityInfoModel *)commodity
                         isBuyNote:(BOOL)isBuyNote
{
    if (!commodity) return 1.f;
    
    if ([identifier isEqualToString:kYGMallCommodityDetailCell_Image]) {
        return Device_Width*11/16.f;
    }
    if ([identifier isEqualToString:kYGMallCommodityDetailCell_Name]) {
        
        NSString *name = commodity.commodityName;
        CGFloat referW = Device_Width - 2 * 14.f;
        CGFloat h = [name heightForFont:[UIFont systemFontOfSize:16] width:referW];
        return ceilf(h+24.f);
    }
    if ([identifier isEqualToString:kYGMallCommodityDetailCell_Price]) {
        return 40.f;
    }
    if ([identifier isEqualToString:kYGMallCommodityDetailCell_ExtraInfo]) {
        return 28.f;
    }
    if ([identifier isEqualToString:kYGMallCommodityDetailCell_FlashSale]) {
        return 68.f;
    }
    if ([identifier isEqualToString:kYGMallCommodityDetailCell_Yunbi]) {
        return 44.f;
    }
    if ([identifier isEqualToString:kYGMallCommodityDetailCell_Review]) {
        return 48.f;
    }
    if ([identifier isEqualToString:kYGMallCommodityDetailCell_Notice]) {
        NSString *content = isBuyNote?commodity.buyGuide:commodity.introduction;
        CGFloat referW = Device_Width - 2 * 14.f;
        CGFloat h = [content heightForFont:[UIFont systemFontOfSize:14] width:referW];
        h = MAX(20.f, h);
        h += (12 + 16 + 12);
        return ceilf(h);
    }
    return 1.f;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
}

- (void)configureWithCommodity:(CommodityInfoModel *)cim
{
    if (cim && self.commodity == cim) return;
    
    self.commodity = cim;
    
    if (self.imagePreviewPanel) {
        
        NSMutableArray *list = [NSMutableArray array];
        [list addObject:cim.photoImage];
        [list addObjectsFromArray:cim.pictureList];
        self.pictureList = list;
        
        [self createScrollView];
    }
    
    if (self.commodityNameLabel) {
        self.commodityNameLabel.text = cim.commodityName;
    }
    
    if (self.yungaoPriceLabel) {
        self.yungaoPriceLabel.text = [NSString stringWithFormat:@"%d",cim.sellingPrice];
        float rebate = ((float)cim.sellingPrice/MAX(cim.originalPrice, 1)) * 10;
        [self.discountBtn setTitle:[NSString stringWithFormat:@"%.01f折",rebate] forState:UIControlStateNormal];
    }
    
    if (self.originPriceLabel) {
        self.originPriceLabel.text = [NSString stringWithFormat:@"￥%d",cim.originalPrice];
        self.soldAmountLabel.text = [NSString stringWithFormat:@"已售%d件",cim.soldQuantity];
        self.freightLabel.text = cim.freight>0&&cim.commodityType == 1?[NSString stringWithFormat:@"运费: %d元",cim.freight]: @"运费: 免运费";
    }
    
    if (self.flashSalePriceLabel) {
        YGFlashSaleModel *flashSale = cim.flash_sale;
        self.flashSalePriceLabel.text = [NSString stringWithFormat:@"%ld",(long)flashSale.flash_price];
        self.flashSaleStockLabel.text = flashSale.quantity>0?[NSString stringWithFormat:@"仅剩%ld件",(long)flashSale.quantity]:@"已抢空";

        switch ([flashSale flashSaleStatus]) {
            case YGFlashSaleStatusWaiting:{
                //未开始
                NSTimeInterval time = flashSale.flash_time;
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
                
                NSString *text;
                if ([date isToday]) {
                    text = [NSString stringWithFormat:@"今日%02ld:%02ld开抢",(long)date.hour,(long)date.minute];
                }else{
                    NSDate *previousDay = [date dateByAddingDays:-1];
                    if ([previousDay isToday]) {
                        text = [NSString stringWithFormat:@"明日%02ld:%02ld开抢",(long)date.hour,(long)date.minute];;
                    }else{
                        text = [NSString stringWithFormat:@"%02ld月%02ld日%02ld:%02ld开抢",(long)date.month,(long)date.day,(long)date.hour,(long)date.minute];
                    }
                }
                self.flashSaleCountdownPanel.hidden = NO;
                self.flashSaleTimeLabel.text = text;
                self.flashSaleNoticeLabel.text = @"距离开始还有:";
                
                [self.timer cancel];
                
                ygweakify(self);
                self.timer = [[YGCountdownTimer alloc] initWithTime:time interval:1.f shouldStart:^BOOL(YGCountdownTimer *theTimer) {
                    return theTimer.countdown > 0;
                } callback:^(YGCountdownTimer *theTimer) {
                    ygstrongify(self);
                    RunOnMainQueue(^{
                        self.hourLabel.text = [NSString stringWithFormat:@"%02lu",(unsigned long)theTimer.hour];
                        self.minLabel.text = [NSString stringWithFormat:@"%02lu",(unsigned long)theTimer.minute];
                        self.secLabel.text = [NSString stringWithFormat:@"%02lu",(unsigned long)theTimer.second];
                        if (theTimer.timeout) {
                            [theTimer cancel];
                            [self refreshDataWhenTimeout];
                        }
                    });
                }];
            }   break;
                
            case YGFlashSaleStatusStarted:{
                //抢购已开始
                self.flashSaleCountdownPanel.hidden = NO;
                self.flashSaleTimeLabel.text = @"抢购中，手快有手慢无";
                self.flashSaleNoticeLabel.text = @"距离结束还有:";
                
                [self.timer cancel];
                
                ygweakify(self);
                self.timer = [[YGCountdownTimer alloc] initWithTime:flashSale.end_time interval:1.f shouldStart:^BOOL(YGCountdownTimer *theTimer) {
                    return theTimer.countdown > 0;
                } callback:^(YGCountdownTimer *theTimer) {
                    ygstrongify(self);
                    RunOnMainQueue(^{
                        if (theTimer.timeout) {
                            [theTimer cancel];
                            [self refreshDataWhenTimeout];
                        }else{
                            self.hourLabel.text = [NSString stringWithFormat:@"%02lu",(unsigned long)theTimer.hour];
                            self.minLabel.text = [NSString stringWithFormat:@"%02lu",(unsigned long)theTimer.minute];
                            self.secLabel.text = [NSString stringWithFormat:@"%02lu",(unsigned long)theTimer.second];
                        }
                    });
                }];
            }   break;
            case YGFlashSaleStatusEnd:{
                self.flashSaleTimeLabel.text = @"抢购已结束";
                self.flashSaleCountdownPanel.hidden = YES;
            }   break;
        }
    }
    
    if (self.yunbiBtn) {
        [self.yunbiBtn setTitle:[NSString stringWithFormat:@"返%d",cim.yunbi] forState:UIControlStateNormal];
        self.yunbiLabel.text = [NSString stringWithFormat:@"确认收货并完成评价，立返%d个云币至账户中",cim.yunbi];
        self.yunbiLineView.hidden = (BOOL)cim.flash_sale;
    }
    
    if (self.reviewAmountLabel) {
        if (cim.commentQuantity > 0) {
            self.reviewAmountLabel.text = [NSString stringWithFormat:@"（%d）",cim.commentQuantity];
            self.reviewRateLabel.text = [NSString stringWithFormat:@"好评率%d%%",cim.highPraiseRate];
        }else{
            self.reviewAmountLabel.text = @"";
            self.reviewRateLabel.text = @"暂无";
        }
    }
    
    if (self.noticeTitleLabel) {
        if (self.isBuyNote) {
            self.noticeTitleLabel.text = @"· 购买须知";
            self.noticeContentLabel.text = cim.buyGuide.length>0?cim.buyGuide:@"暂无商品须知";
        }else{
            self.noticeTitleLabel.text = @"· 商品简介";
            self.noticeContentLabel.text = cim.introduction.length>0?cim.introduction:@"暂无商品简介";
        }
    }
}

- (void)refreshDataWhenTimeout
{
    if (self.shouldUpdateData) {
        self.shouldUpdateData();
    }
}

#pragma mark - ImageCell
- (void)createScrollView
{
    if (_cycleScrollView) {
        _cycleScrollView.delegate = nil;
        _cycleScrollView.datasource = nil;
        if (_cycleScrollView.superview) {
            [_cycleScrollView removeFromSuperview];
        }
        _cycleScrollView = nil;
    }
    _cycleScrollView = [[XLCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, Device_Width, Device_Width*11/16.) autoScroll:NO];
    _cycleScrollView.delegate = self;
    _cycleScrollView.datasource = self;
    _cycleScrollView.needCustomIndicatorTintColor = YES;
    [self.imagePreviewPanel addSubview:_cycleScrollView];
}

- (NSInteger)numberOfPages
{
    return _pictureList.count;
}

- (NSString *)pageAtIndex:(NSInteger)index
{
    if (index == _pictureList.count) {
        return nil;
    }
    return [_pictureList objectAtIndex:index];
}

- (void)XLCycleScrollViewClickAction:(NSInteger)page
{
    CGRect convertRect = [_cycleScrollView.superview convertRect:_cycleScrollView.frame toView:[GolfAppDelegate shareAppDelegate].window];
    [ImageBrowser IBWithImages:self.pictureList isCollection:NO currentIndex:page initRt:convertRect isEdit:NO highQuality:YES vc:[GolfAppDelegate shareAppDelegate].currentController backRtBlock:nil completion:nil];
}

@end

NSString *const kYGMallCommodityDetailCell_Image = @"YGMallCommodityDetailCell_Image";
NSString *const kYGMallCommodityDetailCell_Name = @"YGMallCommodityDetailCell_Name";
NSString *const kYGMallCommodityDetailCell_Price = @"YGMallCommodityDetailCell_Price";
NSString *const kYGMallCommodityDetailCell_ExtraInfo = @"YGMallCommodityDetailCell_ExtraInfo";
NSString *const kYGMallCommodityDetailCell_FlashSale = @"YGMallCommodityDetailCell_FlashSale";
NSString *const kYGMallCommodityDetailCell_Yunbi = @"YGMallCommodityDetailCell_Yunbi";
NSString *const kYGMallCommodityDetailCell_Review = @"YGMallCommodityDetailCell_Review";
NSString *const kYGMallCommodityDetailCell_Notice = @"YGMallCommodityDetailCell_Notice";
