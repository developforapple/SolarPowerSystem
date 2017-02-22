//
//  YGMallOrderReviewCell.h
//  Golf
//
//  Created by bo wang on 2016/11/8.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YGMallOrderModel;
@class YGMallOrderCommodity;

UIKIT_EXTERN NSString *const kYGMallOrderReviewCell;

@interface YGMallOrderReviewCell : UITableViewCell

@property (strong, nonatomic) YGMallOrderCommodity *commodity;

@end
