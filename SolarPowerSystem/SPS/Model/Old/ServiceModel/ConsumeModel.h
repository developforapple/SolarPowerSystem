//
//  ConsumeModel.h
//  Golf
//
//  Created by 黄希望 on 14-8-15.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConsumeModel : NSObject

@property (nonatomic) int tranId;
@property (nonatomic,copy) NSString *tranTime;
@property (nonatomic) int tranAmount;
@property (nonatomic) int currBalance;
@property (nonatomic) int tranType;
@property (nonatomic,copy) NSString *tranName;
@property (nonatomic,copy) NSString *description;
@property (nonatomic) int relativeType;
@property (nonatomic) int relativeId;

- (id)initWithDic:(id)data;

@end
