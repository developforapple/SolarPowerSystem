//
//  YGDepositInfoModel.h
//  Golf
//
//  Created by bo wang on 2016/11/9.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DepositInfoModel : NSObject <NSCopying,NSCoding>

@property(assign, nonatomic) NSInteger banlance;
@property(assign, nonatomic) NSInteger freezeTotal;
@property(assign, nonatomic) NSInteger badTotal;
@property(assign, nonatomic) NSInteger handingfee;

@property(assign, nonatomic) NSInteger avaliableBanlance;

@property(assign, nonatomic) BOOL no_deposit; //免保证金 可以使用云高垫付
@property(assign, nonatomic) NSInteger waitPayCount;
@property(assign, nonatomic) NSInteger waitPayCount2;
@property(assign, nonatomic) NSInteger waitPayCount3;
@property(assign, nonatomic) NSInteger waitPayCount4; //7.1 新增。教学订场的待支付数量
@property(assign, nonatomic) NSInteger remainClassCount;
@property(assign, nonatomic) NSInteger commentCount;
@property(assign, nonatomic) NSInteger newMsgCount;
@property(assign, nonatomic) NSInteger couponTotal;
@property(assign, nonatomic) NSInteger yunbiBalance;
@property(assign, nonatomic) NSInteger memberLevel;
@property(copy,   nonatomic) NSString *servicePhone;

// 教练信息属性
@property(assign, nonatomic) NSInteger coachLevel;        //-2未上传资料 －1已传资料待审核，0：未认证 大于0教练等级
@property(assign, nonatomic) float starLevel;
@property(strong, nonatomic) NSArray *timeSet;      //未设置的不返回此字段，已设置的表示每时段是否允许预订，1：允许，0：不允许
@property(assign, nonatomic) NSInteger todayOrderCount;   //今天已付款订单
@property(assign, nonatomic) NSInteger waitTeachCount;    //等待上课的预约数
@property(assign, nonatomic) NSInteger waitconfirmCount;  //等待确认的预约数
@property(assign, nonatomic) NSInteger teachingMsgCount;  //新消息数量

@end
