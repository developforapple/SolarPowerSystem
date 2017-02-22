//
//  SimpleCityModel.h
//  Golf
//
//  Created by user on 13-2-28.
//  Copyright (c) 2013年 大展. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimpleCityModel : NSObject

@property (nonatomic) int provinceId;
@property (nonatomic) int cityId;
@property (nonatomic,copy) NSString *pinYin;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *clubName;

- (id)initWithDic:(id)data;

@end
