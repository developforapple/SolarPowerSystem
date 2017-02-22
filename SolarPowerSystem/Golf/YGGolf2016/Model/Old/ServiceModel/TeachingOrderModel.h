//
//  TeachingOrderModel.h
//  Golf
//
//  Created by 黄希望 on 15/5/13.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 订单状态
 */
typedef NS_ENUM(NSInteger,YGTeachingOrderStatusType) {
    YGTeachingOrderStatusTypeTeaching       = 1, // 教学中
    YGTeachingOrderStatusTypeCompleted      = 2, // 已完成
    YGTeachingOrderStatusTypeExpired        = 3, // 已过期
    YGTeachingOrderStatusTypeCanceled       = 4, // 已取消
    YGTeachingOrderStatusTypeWaitPay        = 6  // 待付款
    
};

@interface TeachingOrderModel : NSObject

@property (nonatomic,assign) int orderId;               //订单号
@property (nonatomic,strong) NSString *orderTime;       //订单时间
@property (nonatomic,assign) YGTeachingOrderStatusType orderState;            //订单状态
@property (nonatomic,assign) int price;                 //单价
@property (nonatomic,assign) int orderTotal;            //总价
@property (nonatomic,assign) int giveYunbi;             //赠送云币
@property (nonatomic,assign) int productId;             //产品ID
@property (nonatomic,strong) NSString *productName;     //"产品名称",
@property (nonatomic,assign) int academyId;             //学院ID
@property (nonatomic,assign) int classType;             //产品类型 1：标准课 2：团体课 3：公开课 4：套课
@property (nonatomic,assign) int coachId;               //教练ID
@property (nonatomic,strong) NSString *displayName;     //"教练名称",
@property (nonatomic,strong) NSString *nickName;        //"昵称"
@property (nonatomic,strong) NSString *headImage;       //教练头像
@property (nonatomic,strong) NSString *linkPhone;
@property (nonatomic,assign) int memberId;
@property (nonatomic) int classHour;

@property (nonatomic,assign) NSTimeInterval orderTimestamp; //订单时间戳 秒


- (id)initWithDic:(id)data;

@end
