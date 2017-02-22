//
//  SearchCityModel.h
//  Golf
//
//  Created by Dejohn Dong on 12-1-30.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchCityModel : NSObject<NSCoding>

@property(nonatomic) int cityId;
@property(nonatomic) int provinceId;
@property(nonatomic,copy) NSString *cityName;
@property(nonatomic,copy) NSString *firstLetter;
@property(nonatomic) BOOL isHotCity;
@property(nonatomic,copy) NSString *simplePin;
@property(nonatomic,copy) NSString *pinYin;
@property(nonatomic) float longitude;
@property(nonatomic) float latitude;
@property(nonatomic) int supportCoach;
@property(nonatomic) int supportPackage;
@property(nonatomic,copy) NSString *tempCityName;
@property(nonatomic) int clubCount;

- (id)initWithDic:(id)data;
+ (SearchCityModel *)getCityModelWithCityId:(int)cityId; //根据城市id搜索model

@end
