//
//  VIPClubModel.m
//  Golf
//
//  Created by 黄希望 on 12-7-25.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import "VIPClubModel.h"

@implementation VIPClubModel
@synthesize clubId = _clubId,clubName = _clubName,clubNo = _clubNo,vipStatus = _vipStatus,cityId = _cityId,address = _address;


- (id)initWithDic:(id)data{
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }

    NSDictionary *dic = (NSDictionary *)data;
    if([dic objectForKey:@"club_id"]){
        self.clubId = [[dic objectForKey:@"club_id"] intValue];
    }
    if([dic objectForKey:@"club_name"]){
        self.clubName = [dic objectForKey:@"club_name"];
    }
    if ([dic objectForKey:@"club_no"]) {
        self.clubNo = [dic objectForKey:@"club_no"];
    }
    if ([dic objectForKey:@"address"]) {
        self.address = [dic objectForKey:@"address"];
    }
    if ([dic objectForKey:@"vip_status"]) {
        self.vipStatus = [[dic objectForKey:@"vip_status"] intValue];
    }
    if([dic objectForKey:@"city_id"]){
        self.cityId = [[dic objectForKey:@"city_id"] intValue];
    }
    return self;

}

@end
