//
//  TeeTimeModel.m
//  Golf
//
//  Created by 青 叶 on 11-11-26.
//  Copyright (c) 2011年 大展. All rights reserved.
//

#import "TeeTimeModel.h"

@implementation TeeTimeModel
@synthesize isOnlyCreditCard = _isOnlyCreditCard;
@synthesize depositEachMan = _depositEachMan;
@synthesize teetime = _teetime;
@synthesize price = _price;
@synthesize mans = _mans;
@synthesize courseName = _courseName;
@synthesize courseId = _courseId;
@synthesize isSearchTeetime = _isSearchTeetime;
@synthesize phone = _phone;
@synthesize holidayCancelBookHours = _holidayCancelBookHours;
@synthesize normalCancelBookHours = _normalCancelBookHours;
@synthesize priceContent = _priceContent;
@synthesize isOnlyVip = _isOnlyVip;
@synthesize payType = _payType;
@synthesize description = _description;


- (id)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }

    NSDictionary *dic = (NSDictionary *)data;
    if([dic objectForKey:@"only_creditcard"]) {
        self.isOnlyCreditCard = [[dic objectForKey:@"only_creditcard"] boolValue];
    }
    if([dic objectForKey:@"only_vip"]) {
        self.isOnlyVip = [[dic objectForKey:@"only_vip"] boolValue];
    }
    if([dic objectForKey:@"deposit_each_man"]) {
        self.depositEachMan = [[dic objectForKey:@"deposit_each_man"] intValue]/100;
    }
    if([dic objectForKey:@"course_id"]){
        self.courseId = [[dic objectForKey:@"course_id"] intValue];
    }
    if([dic objectForKey:@"course_name"]){
        self.courseName = [dic objectForKey:@"course_name"];
    }
    if([dic objectForKey:@"teetime"]){
        self.teetime = [dic objectForKey:@"teetime"];
    }
    if([dic objectForKey:@"price"]){
        self.price = [[dic objectForKey:@"price"] intValue]/100;
    }
    if([dic objectForKey:@"mans"]){
        self.mans = [[dic objectForKey:@"mans"] intValue];
    }
    if([dic objectForKey:@"pay_type"]){
        self.payType = [[dic objectForKey:@"pay_type"] intValue];
    }
    if([dic objectForKey:@"is_search_teetime"]){
        self.isSearchTeetime = [[dic objectForKey:@"is_search_teetime"] boolValue];
    }
    if([dic objectForKey:@"phone"]){
        self.phone = [dic objectForKey:@"phone"];
    }
    if([dic objectForKey:@"description"]){
        self.description = [dic objectForKey:@"description"];
    }
    if([dic objectForKey:@"price_content"]){
        self.priceContent = [dic objectForKey:@"price_content"];
    }
    if([dic objectForKey:@"normal_cancel_book_hours"]){
        self.normalCancelBookHours = [[dic objectForKey:@"normal_cancel_book_hours"] intValue];
    }
    if([dic objectForKey:@"holiday_cancel_book_hours"]){
        self.holidayCancelBookHours = [[dic objectForKey:@"holiday_cancel_book_hours"] intValue];
    }
    return self;
}

@end
