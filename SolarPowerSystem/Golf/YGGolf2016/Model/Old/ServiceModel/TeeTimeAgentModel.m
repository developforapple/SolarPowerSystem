//
//  TeeTimeAgentModel.m
//  Golf
//
//  Created by 黄希望 on 12-7-26.
//

#import "TeeTimeAgentModel.h"

@implementation TeeTimeAgentModel
@synthesize agentId = _agentId;
@synthesize agentName = _agentName;
@synthesize agentPhone = _agentPhone;
@synthesize teetime = _teetime;
@synthesize price = _price;
@synthesize normalCancelBookHours = _normalCancelBookHours;
@synthesize holidayCancelBookHours = _holidayCancelBookHours;
@synthesize description = _description;
@synthesize orderId = _orderId;
@synthesize priceContent = _priceContent;
@synthesize depositEachMan = _depositEachMan;
@synthesize isOnlyCreditCard = _isOnlyCreditCard;
@synthesize payType = _payType;


- (id)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }

    NSDictionary *dic = (NSDictionary *)data;
    if([dic objectForKey:@"agent_id"]) {
        self.agentId = [[dic objectForKey:@"agent_id"] intValue];
    }
    if([dic objectForKey:@"pay_type"]) {
        self.payType = [[dic objectForKey:@"pay_type"] intValue];
    }
    if([dic objectForKey:@"deposit_each_man"]) {
        self.depositEachMan = [[dic objectForKey:@"deposit_each_man"] intValue]/100;
    }
    if([dic objectForKey:@"only_creditcard"]) {
        self.isOnlyCreditCard = [[dic objectForKey:@"only_creditcard"] boolValue];
    }
    if([dic objectForKey:@"agent_name"]) {
        self.agentName = [dic objectForKey:@"agent_name"];
    }
    if([dic objectForKey:@"agent_phone"]){
        self.agentPhone = [dic objectForKey:@"agent_phone"];
    }
    if([dic objectForKey:@"teetime"]){
        self.teetime = [dic objectForKey:@"teetime"];
    }
    if([dic objectForKey:@"price_content"]){
        self.priceContent = [dic objectForKey:@"price_content"];
    }
    if([dic objectForKey:@"description"]){
        self.description = [dic objectForKey:@"description"];
    }
    if([dic objectForKey:@"price"]){
        self.price = [[dic objectForKey:@"price"] intValue]/100;
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
