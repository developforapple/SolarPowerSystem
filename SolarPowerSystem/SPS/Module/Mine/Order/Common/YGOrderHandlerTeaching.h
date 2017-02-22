//
//  YGOrderHandlerTeaching.h
//  Golf
//
//  Created by bo wang on 2016/12/15.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGOrderHandler.h"
#import "YGOrderCommon.h"

typedef NS_ENUM(NSUInteger, YGOrderTeachingAction) {
    YGOrderTeachingAction_Base = YGOrderTypeTeaching<<5,
    YGOrderTeachingAction_Pay,
    YGOrderTeachingAction_Delete,
};

@interface YGOrderHandlerTeaching : YGOrderHandler

+ (NSString *)actionTitleString:(YGOrderTeachingAction)actionType;

- (void)handleAction:(YGOrderTeachingAction)actionType;

@end
