//
//  PackageDetailModel.h
//  Golf
//
//  Created by user on 12-12-14.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PackageModel.h"

@interface PackageDetailModel : PackageModel

@property (nonatomic) int cityId;
@property (nonatomic) int minPrice;
@property (nonatomic) int maxPrice;
@property (nonatomic) int prepayAmount;
@property (nonatomic) int bookConfirm;
@property (nonatomic) int payType;
@property (nonatomic,copy) NSString *packagePicture;
@property (nonatomic,copy) NSString *tourNote;
@property (nonatomic,copy) NSString *priceInclude;
@property (nonatomic,copy) NSString *priceExclude;
@property (nonatomic,copy) NSString *description;
@property (nonatomic,copy) NSString *linkPhone;
@property (nonatomic,strong) NSArray *clubList;
@property (nonatomic,strong) NSArray *specList;
@property (nonatomic) int giveYunbi;

- (id)initWithDic:(id)data;

@end
