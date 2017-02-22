//
//  YGMallOrderRefundReasonViewCtrl.h
//  Golf
//
//  Created by bo wang on 2016/11/7.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGBasePopViewController.h"

/**
 选择退款原因
 */
@interface YGMallOrderRefundReasonViewCtrl : YGBasePopViewController
@property (copy, nonatomic) NSString *reason;
@property (copy, nonatomic) void (^didSelectedReason)(NSString *reason);
@end
