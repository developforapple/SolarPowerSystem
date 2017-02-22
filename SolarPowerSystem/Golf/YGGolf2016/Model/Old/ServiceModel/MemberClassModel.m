//
//  MemberClassModel.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/21.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "MemberClassModel.h"
#import "ReservationModel.h"

@implementation MemberClassModel

- (id)initWithDic:(id)data{
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    
    NSDictionary *dic = (NSDictionary *)data;
    
    if ([dic objectForKey:@"class_id"]) {
        self.classId = [[dic objectForKey:@"class_id"] intValue];
    }
    if ([dic objectForKey:@"coach_id"]) {
        self.coachId = [[dic objectForKey:@"coach_id"] intValue];
    }
    if ([dic objectForKey:@"nick_name"]) {
        self.nickName = [dic objectForKey:@"nick_name"];
    }
    if ([dic objectForKey:@"head_image"]) {
        self.headImage = [dic objectForKey:@"head_image"];
    }
    if ([dic objectForKey:@"class_hour"]) {
        self.classHour = [[dic objectForKey:@"class_hour"] intValue];
    }
    if ([dic objectForKey:@"remain_hour"]) {
        self.remainHour = [[dic objectForKey:@"remain_hour"] intValue];
    }
    if ([dic objectForKey:@"product_id"]) {
        self.productId = [[dic objectForKey:@"product_id"] intValue];
    }
    if ([dic objectForKey:@"product_name"]) {
        self.productName = [dic objectForKey:@"product_name"];
    }
    if ([dic objectForKey:@"order_time"]) {
        self.orderTime = [dic objectForKey:@"order_time"];
    }
    if ([dic objectForKey:@"public_class_id"]) {
        self.publicClassId = [[dic objectForKey:@"public_class_id"] intValue];
    }
    if ([dic objectForKey:@"order_state"]) {
        self.orderState = [[dic objectForKey:@"order_state"] intValue];
    }
    if ([dic objectForKey:@"expire_date"]) {
        self.expireDate = [dic objectForKey:@"expire_date"];
    }
    if ([dic objectForKey:@"teaching_site"]) {
        self.teachingSite = [dic objectForKey:@"teaching_site"];
    }
    if ([dic objectForKey:@"mobile_phone"]) {
        self.mobilePhone = [dic objectForKey:@"mobile_phone"];
    }
    if (dic[@"price"]) {
        self.price = [dic[@"price"] intValue] / 100;
    }
    if (dic[@"class_type"]) {
        self.classType = [dic[@"class_type"] intValue];
    }
    if ([dic objectForKey:@"reservation_list"]) {
        NSArray *arr = [dic objectForKey:@"reservation_list"];
        if (arr && arr.count > 0) {
            NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:arr.count];
            for (id obj in arr) {
                ReservationModel *m = [[ReservationModel alloc] initWithDic:obj];
                [list addObject:m];
            }
            self.reservationList = list;
        }
    }
    return self;
}

@end
