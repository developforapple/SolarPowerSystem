//
//  ConditionModel.h
//  Golf
//
//  Created by Dejohn Dong on 12-1-31.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConditionModel : NSObject <NSCopying>

@property(nonatomic) int provinceId;
@property(nonatomic) int cityId;
@property(nonatomic) double longitude;
@property(nonatomic) double latitude;
@property(nonatomic) int people;
@property(nonatomic) int price;
@property(nonatomic) int prepayAmount;
@property(nonatomic) int clubId;
@property(nonatomic) int agentId;
@property(nonatomic) int isOfficial;
@property(nonatomic) int weekDay;
@property(nonatomic) int payType;
@property(nonatomic,copy) NSString *range;
@property(nonatomic,copy) NSString *date;
@property(nonatomic,copy) NSString *time;
@property(nonatomic,copy) NSString *address;
@property(nonatomic,copy) NSString *supplier;
@property(nonatomic,copy) NSString *clubName;
@property(nonatomic,copy) NSString *shortName;
@property(nonatomic,copy) NSString *personName;
@property(nonatomic,copy) NSString *personPhone;
@property(nonatomic,copy) NSString *cityName;
@property(nonatomic,copy) NSString *clubIds;

@end
