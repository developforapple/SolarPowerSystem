//
//  YGAreaManager.h
//  Golf
//
//  Created by bo wang on 2016/11/30.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>

@class YGAreaProvince;
@class YGAreaCity;
@class YGArea;

typedef NSString YGAreaDistrict;

@interface YGAreaProvince : NSObject <NSCoding,NSCopying,YYModel>
@property (copy, nonatomic) NSString *province;
@property (strong, nonatomic) NSArray<YGAreaCity *> *cities;
@end

@interface YGAreaCity : NSObject <NSCoding,NSCopying,YYModel>
@property (copy, nonatomic) NSString *city;
@property (strong, nonatomic) NSArray<YGAreaDistrict *> *districts;
@end

#pragma mark - Data Interface
@interface YGAreaManager : NSObject

+ (instancetype)areaManager;

@property (strong, nonatomic) NSArray<YGAreaProvince *> *provinces;

+ (YGArea *)areaWithProvince:(NSString *)provinceName
                        city:(NSString *)cityName
                    district:(NSString *)districtName;
@end

@interface YGArea : NSObject
@property (strong, nonatomic) YGAreaProvince *province;
@property (strong, nonatomic) YGAreaCity *city;
@property (strong, nonatomic) YGAreaDistrict *district;

// key 在下方列出
- (NSDictionary *)areaDictionary;
+ (instancetype)areaWithDictionary:(NSDictionary *)areaDict;

@end

FOUNDATION_EXTERN NSString *const kYGAreaProvinceKey;
FOUNDATION_EXTERN NSString *const kYGAreaCityKey;
FOUNDATION_EXTERN NSString *const kYGAreaDistrictKey;
