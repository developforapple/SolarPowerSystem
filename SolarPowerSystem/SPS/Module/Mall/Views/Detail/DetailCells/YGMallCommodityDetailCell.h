//
//  YGMallCommodityDetailCell.h
//  Golf
//
//  Created by bo wang on 2016/11/22.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YGLineView;

@interface YGMallCommodityDetailCell : UITableViewCell

#pragma mark - ImageCell
@property (weak, nonatomic) IBOutlet UIView *imagePreviewPanel;

#pragma mark - NameCell
@property (weak, nonatomic) IBOutlet UILabel *commodityNameLabel;

#pragma mark - PriceCell
@property (weak, nonatomic) IBOutlet UILabel *yungaoPriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *discountBtn;

#pragma mark - ExtraInfo
@property (weak, nonatomic) IBOutlet UILabel *originPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *soldAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *freightLabel;

#pragma mark - FlashSaleCell
@property (weak, nonatomic) IBOutlet UILabel *flashSalePriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *flashSaleStockLabel;
@property (weak, nonatomic) IBOutlet UIView *flashSaleTimePanel;
@property (weak, nonatomic) IBOutlet UILabel *flashSaleTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *flashSaleCountdownPanel;
@property (weak, nonatomic) IBOutlet UILabel *flashSaleNoticeLabel;
@property (weak, nonatomic) IBOutlet UILabel *hourLabel;
@property (weak, nonatomic) IBOutlet UILabel *minLabel;
@property (weak, nonatomic) IBOutlet UILabel *secLabel;

@property (copy, nonatomic) void (^shouldUpdateData)(void);

#pragma mark - YunbiCell
@property (weak, nonatomic) IBOutlet UIButton *yunbiBtn;
@property (weak, nonatomic) IBOutlet UILabel *yunbiLabel;
@property (weak, nonatomic) IBOutlet UIView *yunbiLineView;


#pragma mark - ReviewCell
@property (weak, nonatomic) IBOutlet UILabel *reviewAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *reviewRateLabel;


#pragma mark - NoticeCell
@property (assign, nonatomic) BOOL isBuyNote;
@property (weak, nonatomic) IBOutlet UILabel *noticeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *noticeContentLabel;

@property (strong, nonatomic) CommodityInfoModel *commodity;
- (void)configureWithCommodity:(CommodityInfoModel *)commodity;

+ (CGFloat)cellHeightForIdentifier:(NSString *)identifier
                         commodity:(CommodityInfoModel *)commodity
                         isBuyNote:(BOOL)isBuyNote;

@end


UIKIT_EXTERN NSString *const kYGMallCommodityDetailCell_Image;
UIKIT_EXTERN NSString *const kYGMallCommodityDetailCell_Name;
UIKIT_EXTERN NSString *const kYGMallCommodityDetailCell_Price;
UIKIT_EXTERN NSString *const kYGMallCommodityDetailCell_ExtraInfo;
UIKIT_EXTERN NSString *const kYGMallCommodityDetailCell_FlashSale;
UIKIT_EXTERN NSString *const kYGMallCommodityDetailCell_Yunbi;
UIKIT_EXTERN NSString *const kYGMallCommodityDetailCell_Review;
UIKIT_EXTERN NSString *const kYGMallCommodityDetailCell_Notice;
