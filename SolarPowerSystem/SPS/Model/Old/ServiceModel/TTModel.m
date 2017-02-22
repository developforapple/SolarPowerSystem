//
//  TTModel.m
//  Golf
//
//  Created by 黄希望 on 13-12-30.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import "TTModel.h"

@implementation TTModel

@synthesize courseId = _courseId;
@synthesize courseName = _courseName;
@synthesize agentId = _agentId;
@synthesize agentName = _agentName;
@synthesize depositEachMan = _depositEachMan;
@synthesize teetime = _teetime;
@synthesize price = _price;
@synthesize mans = _mans;
@synthesize payType = _payType;
@synthesize phone = _phone;
@synthesize priceContent = _priceContent;
@synthesize description = _description;
@synthesize cancelNote = _cancelNote;
@synthesize bookNote = _bookNote;
@synthesize canBook = _canBook;
@synthesize yunbi = _yunbi;


- (id)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }

    NSDictionary *dic = (NSDictionary *)data;
    if ([dic objectForKey:@"prepay_amount"]) {
        self.depositEachMan = [[dic objectForKey:@"prepay_amount"] intValue]/100;
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
    if([dic objectForKey:@"give_yunbi"]){
        self.yunbi = [[dic objectForKey:@"give_yunbi"] intValue]/100;
    }
    if([dic objectForKey:@"mans"]){
        self.mans = [[dic objectForKey:@"mans"] intValue];
    }
    if([dic objectForKey:@"pay_type"]){
        self.payType = [[dic objectForKey:@"pay_type"] intValue];
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
    if([dic objectForKey:@"agent_id"]) {
        self.agentId = [[dic objectForKey:@"agent_id"] intValue];
        
        // 这只是为了控制界面上的人数加减，实际中介没有剩余人数的概念
        if (self.agentId > 0) {
            self.mans = 40;
        }
    }
    if ([dic objectForKey:@"recommend_flag"]) {
        self.recommendFlag = [[dic objectForKey:@"recommend_flag"] intValue] > 0 ? YES:NO;
    }
    if([dic objectForKey:@"agent_name"]) {
        self.agentName = [dic objectForKey:@"agent_name"];
    }
    if ([dic objectForKey:@"cancel_note"]) {
        self.cancelNote = [dic objectForKey:@"cancel_note"];
    }
    if ([dic objectForKey:@"book_note"]) {
        self.bookNote = [dic objectForKey:@"book_note"];
    }
    if ([dic objectForKey:@"can_book"]) {
        self.canBook = [[dic objectForKey:@"can_book"] intValue];
    }
    if (dic[@"has_invoice"]) {
        self.hasInvoice = [dic[@"has_invoice"] integerValue];
    }
    if (dic[@"min_buy_quantity"]) {
        self.minBuyQuantity = [dic[@"min_buy_quantity"] intValue];
    }
    return self;
}

@end
