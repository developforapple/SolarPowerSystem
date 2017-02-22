//
//  YGOrderHandlerTeachBooking.h
//  Golf
//
//  Created by bo wang on 2016/10/31.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGOrderHandler.h"
#import "YGOrderCommon.h"

typedef NS_ENUM(NSUInteger, YGOrderTeachBookingAction) {
    YGOrderTeachBookingAction_Base = YGOrderTypeTeachBooking<<5,
    YGOrderTeachBookingAction_Pay,
    YGOrderTeachBookingAction_Delete
};

@interface YGOrderHandlerTeachBooking : YGOrderHandler

+ (NSString *)actionTitleString:(YGOrderTeachBookingAction)actionType;

- (void)handleAction:(YGOrderTeachBookingAction)actionType;

- (void)pay;

@end
