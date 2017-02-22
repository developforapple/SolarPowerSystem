//
//  OrderCancelModel.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/26.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderCancelModel : NSObject

@property (nonatomic) int orderId;
@property (nonatomic) int orderState;


- (id)initWithDic:(id)data;
@end
