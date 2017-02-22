//
//  TeachingSubmitInfo.h
//  Golf
//
//  Created by 黄希望 on 15/5/13.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TeachingSubmitInfo : NSObject

@property (nonatomic,assign) int orderId;
@property (nonatomic,strong) NSString *orderTime;
@property (nonatomic,assign) int orderState;
@property (nonatomic,assign) int orderTotal;
@property (nonatomic,assign) int productId;
@property (nonatomic,assign) int academyId;
@property (nonatomic,assign) int classType;

- (id)initWithDic:(id)data;

@end
