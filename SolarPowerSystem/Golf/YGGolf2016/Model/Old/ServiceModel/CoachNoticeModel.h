//
//  CoachNoticeModel.h
//  Golf
//
//  Created by 黄希望 on 15/6/4.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  消息通知类型
 */
typedef NS_ENUM(NSInteger,YGCoachNoticeType)
{
    YGCoachNoticeTypeOrderPaid          = 1, // 订单已付款
    YGCoachNoticeTypeNewAppointment     = 2, // 新的预约
    YGCoachNoticeTypeCacelAppointment   = 3, // 取消预约
    YGCoachNoticeTypeNewComment         = 4  // 新的评价
    
};

@interface CoachNoticeModel : NSObject

// 消息Id
@property (nonatomic,assign) int msgId;
// 用户Id
@property (nonatomic,assign) int memberId;
// 消息类型
@property (nonatomic,assign) YGCoachNoticeType msgType;
// 根据类型，关联Id
@property (nonatomic,assign) int relativeId;
// 用户头像
@property (nonatomic,strong) NSString *headImage;
// 用户显示的名称
@property (nonatomic,strong) NSString *displayName;
// 标题名称
@property (nonatomic,strong) NSString *valueOne;
// 显示的内容
@property (nonatomic,strong) NSString *valueTwo;
// 消息时间
@property (nonatomic,strong) NSString *msgTime;

// 新加字段

// 消息标题
@property (strong, nonatomic) NSString *msgTitle;
// 消息内容
@property (strong, nonatomic) NSString *msgContent;
// 课时Id
@property (assign, nonatomic) NSInteger periodId;
// 课程ID
@property (assign, nonatomic) NSInteger classId;

- (id)initWithDic:(id)data;

@end
