//
//  OrderDetailModel.m
//  Golf
//
//  Created by 青 叶 on 11-11-27.
//  Copyright (c) 2011年 大展. All rights reserved.
//

#import "OrderDetailModel.h"

@implementation OrderDetailModel
@synthesize courseName = _courseName;
@synthesize payState = _payState;
@synthesize normalCancelBookHours = _normalCancelBookHours;
@synthesize holidayCancelBookHours = _holidayCancelBookHours;
@synthesize isAllowCancel = _isAllowCancel;
@synthesize linkPhone = _linkPhone;
@synthesize agentName = _agentName;
@synthesize memberName = _memberName;
@synthesize mobilePhone = _mobilePhone;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize address = _address;
@synthesize payTime = _payTime;
@synthesize priceContent = _priceContent;
@synthesize specName = _specName;
@synthesize description = _description;
@synthesize trafficGuid = _trafficGuid;
@synthesize userMemo = _userMemo;
@synthesize absentNum = _absentNum;
@synthesize returnAmount = _returnAmount;


- (id)initWithDic: (id) data {
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    
    NSDictionary* dic = (NSDictionary*) data;
    if([dic objectForKey:@"order_id"]){
        self.orderId = [[dic objectForKey:@"order_id"] intValue];
    }
    if([dic objectForKey:@"order_create_time"]){
        self.orderCreateTime = [dic objectForKey:@"order_create_time"];
    }
    if([dic objectForKey:@"pay_type"]){
        self.payType = (PayTypeEnum)[[dic objectForKey:@"pay_type"] intValue];
    }
    if([dic objectForKey:@"order_total"]){
        self.payTotal = [[dic objectForKey:@"order_total"] intValue]/100;
    }
    if ([dic objectForKey:@"return_amount"]) {
        self.returnAmount = [[dic objectForKey:@"return_amount"] intValue] / 100;
    }
    if ([dic objectForKey:@"absent_num"]) {
        self.absentNum = [[dic objectForKey:@"absent_num"] intValue];
    }
    if([dic objectForKey:@"give_yunbi"]){
        self.yunbi = [[dic objectForKey:@"give_yunbi"] intValue]/100;
    }
    if([dic objectForKey:@"order_state"]){
        self.orderStatus = (OrderStatusEnum)[[dic objectForKey:@"order_state"] intValue];
    }
    if([dic objectForKey:@"pay_state"]){
        self.payState = [dic objectForKey:@"pay_state"];
    }
    if([dic objectForKey:@"normal_cancel_book_hours"]){
        self.normalCancelBookHours = [[dic objectForKey:@"normal_cancel_book_hours"] intValue];
    }
    if([dic objectForKey:@"holiday_cancel_book_hours"]){
        self.holidayCancelBookHours = [[dic objectForKey:@"holiday_cancel_book_hours"] intValue];
    }
    if([dic objectForKey:@"is_allow_cancel"]){
        self.isAllowCancel = [[dic objectForKey:@"is_allow_cancel"] boolValue];
    }
    if ([dic objectForKey:@"agent_id"]) {
        self.agentId = [[dic objectForKey:@"agent_id"] intValue];
    }
    if ([dic objectForKey:@"agent_name"]) {
        self.agentName = [dic objectForKey:@"agent_name"];
    }
    if ([dic objectForKey:@"member_name"]) {
        self.memberName = [dic objectForKey:@"member_name"];
    }
    if ([dic objectForKey:@"mobile_phone"]) {
        self.mobilePhone = [dic objectForKey:@"mobile_phone"];
    }
    if ([dic objectForKey:@"address"]) {
        self.address = [dic objectForKey:@"address"];
    }
    if ([dic objectForKey:@"latitude"]) {
        self.latitude = [[dic objectForKey:@"latitude"] floatValue];
    }
    if ([dic objectForKey:@"longitude"]) {
        self.longitude = [[dic objectForKey:@"longitude"] floatValue];
    }
    if ([dic objectForKey:@"pay_time"]) {
        self.payTime = [dic objectForKey:@"pay_time"];
    }
    if ([dic objectForKey:@"package_id"]) {
        self.packageId = [[dic objectForKey:@"package_id"] intValue];
    }
    if ([dic objectForKey:@"package_name"]) {
        self.packageName = [dic objectForKey:@"package_name"];
    }
    if ([dic objectForKey:@"spec_name"]) {
        self.specName = [dic objectForKey:@"spec_name"];
    }
    if ([dic objectForKey:@"description"]) {
        self.description = [dic objectForKey:@"description"];
    }
    if ([dic objectForKey:@"user_memo"]) {
        self.userMemo = [dic objectForKey:@"user_memo"];
    }
    if ([dic objectForKey:@"price_content"]) {
        self.priceContent = [dic objectForKey:@"price_content"];
    }
    if ([dic objectForKey:@"traffic_guid"]) {
        self.trafficGuid = [dic objectForKey:@"traffic_guid"];
    }
    if([dic objectForKey:@"order_x"]){
        
        NSDictionary *orderXDic = [(NSArray *)[dic objectForKey:@"order_x"] objectAtIndex:0];

        if([orderXDic objectForKey:@"club_id"]){
            self.clubId = [[orderXDic objectForKey:@"club_id"] intValue];
        }
        if([orderXDic objectForKey:@"club_name"]){
            self.clubName = [orderXDic objectForKey:@"club_name"];
        }
        if([orderXDic objectForKey:@"teetime_time"]){
            self.teetimeTime = [orderXDic objectForKey:@"teetime_time"];
        }
        if([orderXDic objectForKey:@"teetime_date"]){
            self.teetimeDate = [orderXDic objectForKey:@"teetime_date"];
        }
        if([orderXDic objectForKey:@"member_num"]){
            self.memberNum = [[orderXDic objectForKey:@"member_num"] intValue];
        }
        if([orderXDic objectForKey:@"orderx_price"]){
            self.realPrice = [[orderXDic objectForKey:@"orderx_price"] intValue]/100;
        }
        if([orderXDic objectForKey:@"course_name"]){
            self.courseName = [orderXDic objectForKey:@"course_name"];
        }
        if([orderXDic objectForKey:@"linkPhone"]){
            self.linkPhone = [orderXDic objectForKey:@"linkPhone"];
        }
        self.orderTotal = self.memberNum * self.realPrice;
    }
    self.yunbi *= self.memberNum - self.absentNum;
    
    return self;
}

@end
