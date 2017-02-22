//
//  YGPayCell.h
//  Golf
//
//  Created by bo wang on 2016/10/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGPayment.h"

@interface YGPayCell : UITableViewCell
+ (CGFloat)cellHeight;
@property (copy, nonatomic) void (^shouldAdjustHeight)(CGFloat h);
@property (strong, readonly, nonatomic) YGPayment *payment;
- (void)configureWithPayment:(YGPayment *)payment;
@end

UIKIT_EXTERN NSString *const kYGPayCell_YungaoPayment;
@interface YGPayCell_YungaoPayment : YGPayCell
@property (weak, nonatomic) IBOutlet UIButton *yunbiBtn;
@property (weak, nonatomic) IBOutlet UILabel *yunbiLabel;
@property (weak, nonatomic) IBOutlet UIButton *balanceBtn;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@end

UIKIT_EXTERN NSString *const kYGPayCell_3rdPayment;
@interface YGPayCell_3rdPayment : YGPayCell
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@end

UIKIT_EXTERN NSString *const kYGPayCell_Start;
@interface YGPayCell_Start : YGPayCell
@property (weak, nonatomic) IBOutlet UIButton *payBtn;
@property (copy, nonatomic) void (^willStartPayAction)(void);
@end
