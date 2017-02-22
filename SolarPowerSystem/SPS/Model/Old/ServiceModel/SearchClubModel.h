//
//  searchClubModel.h
//  Golf
//
//  Created by 黄希望 on 12-7-25.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchClubModel : NSObject<NSCopying,NSCoding>

@property (nonatomic) int clubId;
@property (nonatomic) int cityId;
@property (nonatomic) int provinceId;
@property (nonatomic, copy) NSString *cityName;
@property (nonatomic, copy) NSString *clubName;
@property (nonatomic, copy) NSString *clubImage;
@property (nonatomic, copy) NSString *address;
@property (nonatomic,assign) double longitude;
@property (nonatomic,assign) double latitude;
@property (nonatomic,assign) double distance;

- (id)initWithDic:(id)data;

- (id)initWithClubId:(int)clubId clubName:(NSString *)clubName;

@end
