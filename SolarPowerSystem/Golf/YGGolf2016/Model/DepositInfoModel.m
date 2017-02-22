//
//  YGDepositInfoModel.m
//  Golf
//
//  Created by bo wang on 2016/11/9.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "DepositInfoModel.h"
#import "YYModel.h"

@interface DepositInfoModel ()<YYModel>

@end

@implementation DepositInfoModel

YYModelDefaultCode

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper
{
    static NSDictionary *mapper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mapper = @{@"banlance"          :@"deposit_balance",
                   @"freezeTotal"       :@"deposit_freeze_total",
                   @"badTotal"          :@"deposit_bad_total",
                   @"handingfee"        :@"deposit_handingfee",
                   @"no_deposit"        :@"no_deposit",
                   @"waitPayCount"      :@"wait_pay_count",
                   @"waitPayCount2"     :@"wait_pay_count2",
                   @"waitPayCount3"     :@"wait_pay_count3",
                   @"waitPayCount4"     :@"wait_pay_count4",
                   @"remainClassCount"  :@"remain_class_count",
                   @"commentCount"      :@"comment_count",
                   @"servicePhone"      :@"service_phone",
                   @"couponTotal"       :@"coupon_total",
                   @"yunbiBalance"      :@"yunbi_balance",
                   @"memberLevel"       :@"member_rank",
                   @"newMsgCount"       :@"new_msg_count",
                   @"coachLevel"        :@"coach_level",
                   @"starLevel"         :@"star_level",
                   @"timeSet"           :@"time_set",
                   @"todayOrderCount"   :@"today_order_count",
                   @"waitTeachCount"    :@"wait_teach_count",
                   @"waitconfirmCount"  :@"wait_confirm_count",
                   @"teachingMsgCount"  :@"teaching_msg_count"};
    });
    return mapper;
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic
{
    self.banlance /= 100;
    self.freezeTotal /= 100;
    self.badTotal /= 100;
    self.handingfee /= 100;
    self.couponTotal /= 100;
    self.yunbiBalance /= 100;
    
    self.avaliableBanlance = MAX(self.banlance, 0);
    
    return YES;
}

@end
