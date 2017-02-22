//
//  OrderCancelModel.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/26.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "OrderCancelModel.h"

@implementation OrderCancelModel

- (id)initWithDic:(id)data{
    if (!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    
    NSDictionary *dic = (NSDictionary *)data;
    
    if ([dic objectForKey:@"order_id"]) {
        self.orderId = [[dic objectForKey:@"order_id"] intValue];
    }
    if ([dic objectForKey:@"order_state"]) {
        self.orderState = [[dic objectForKey:@"order_state"] intValue];
    }

    return self;
}

@end
