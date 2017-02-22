//
//  PackageConditionModel.h
//  Golf
//
//  Created by user on 12-12-20.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PriceSpecModel.h"

@interface PackageConditionModel : NSObject

@property (nonatomic) int clubId;
@property (nonatomic) int packageId;
@property (nonatomic) int agentId;
@property (nonatomic) int people;
@property (nonatomic) int price;
@property (nonatomic) int prepayAmount;
@property (nonatomic) int specId;
@property (nonatomic) int bookConfirm;
@property (nonatomic) int payType;
@property (nonatomic,strong) NSString *clubName;
@property (nonatomic,strong) NSString *agentName;
@property (nonatomic,strong) NSString *packageType;
@property (nonatomic,strong) NSString *arriveDate;
@property (nonatomic,strong) NSString *packageName;
@property (nonatomic,strong) NSString *memberName;
@property (nonatomic,strong) NSString *memberPhone;
@property (nonatomic,strong) NSString *suppler;
@property (nonatomic,strong) NSString *noteInfo;
@property (nonatomic,strong) NSString *startDate;
@property (nonatomic,strong) NSString *endDate;
@property (nonatomic) int giveYunbi;
@end
