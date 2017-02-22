//
//  SearchProvinceModel.h
//  Golf
//
//  Created by user on 13-2-25.
//  Copyright (c) 2013年 大展. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchProvinceModel : NSObject

@property (nonatomic) int provinceId;
@property (nonatomic) int international;
@property (nonatomic,copy) NSString *provinceName;
@property (nonatomic) int clubCount;
@property (nonatomic,strong) NSMutableArray *citys;

- (id)initWithDic:(id)data;
+ (SearchProvinceModel *)getProvinceModelWithProvinceId:(int)provinceId;

@end
