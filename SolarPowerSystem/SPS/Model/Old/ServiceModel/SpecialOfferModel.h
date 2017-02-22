//
//  SpecialOfferModel.h
//  Golf
//
//  Created by user on 13-1-17.
//  Copyright (c) 2013年 大展. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpecialOfferModel : NSObject

@property (nonatomic) int clubId;
@property (nonatomic) int originalPrice;
@property (nonatomic) int currentPrice;
@property (nonatomic) int weekDay;
@property (nonatomic) int isOfficial;
@property (nonatomic) int payType;
@property (nonatomic,copy) NSString *clubName;
@property (nonatomic,copy) NSString *beginDate;
@property (nonatomic,copy) NSString *endDate;
@property (nonatomic,copy) NSString *beginTime;
@property (nonatomic,copy) NSString *endTime;
@property (nonatomic,copy) NSString *shortName;

- (id)initWithDic:(id)data;
+ (NSString *)stringwithObject:(SpecialOfferModel *)model index:(NSInteger)index;

@end
