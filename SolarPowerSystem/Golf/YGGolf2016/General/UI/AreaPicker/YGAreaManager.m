//
//  YGAreaManager.m
//  Golf
//
//  Created by bo wang on 2016/11/30.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGAreaManager.h"

#pragma mark - Data Implementation
@implementation YGAreaManager
+ (instancetype)areaManager
{
    static YGAreaManager *areaManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"chinesearea" ofType:@"plist"];
        NSArray *data = [NSArray arrayWithContentsOfFile:path];
        
        NSArray *provinces = [NSArray yy_modelArrayWithClass:[YGAreaProvince class] json:data];
        areaManager = [YGAreaManager new];
        areaManager.provinces = provinces;
    });
    return areaManager;
}

+ (YGArea *)areaWithProvince:(NSString *)provinceName
                        city:(NSString *)cityName
                    district:(NSString *)districtName
{
    YGAreaProvince *province;
    YGAreaCity *city;
    YGAreaDistrict *district;
    YGAreaManager *manager = [YGAreaManager areaManager];
    for (YGAreaProvince *aProvince in manager.provinces) {
        if ([aProvince.province isEqualToString:provinceName]) {
            province = aProvince;
            break;
        }
    }
    for (YGAreaCity *aCity in province.cities) {
        if ([aCity.city isEqualToString:cityName]) {
            city = aCity;
            break;
        }
    }
    for (YGAreaDistrict *aDistrict in city.districts) {
        if ([aDistrict isEqualToString:districtName]) {
            district = aDistrict;
            break;
        }
    }
    YGArea *area = [YGArea new];
    area.province = province;
    area.city = city;
    area.district = district;
    return area;
}

@end

@implementation YGArea

- (NSDictionary *)areaDictionary
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[kYGAreaProvinceKey] = self.province.province;
    dic[kYGAreaCityKey] = self.city.city;
    dic[kYGAreaDistrictKey] = self.district;
    return dic;
}

+ (instancetype)areaWithDictionary:(NSDictionary *)areaDict
{
    return [YGAreaManager areaWithProvince:areaDict[kYGAreaProvinceKey] city:areaDict[kYGAreaCityKey] district:areaDict[kYGAreaDistrictKey]];
}

@end

@implementation YGAreaProvince
+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper
{
    return @{@"province":@"state"};
}

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass
{
    return @{@"cities":[YGAreaCity class]};
}
YYModelDefaultCode
@end

@implementation YGAreaCity

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper
{
    return @{@"districts":@"areas"};
}

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass
{
    return @{@"districts":[YGAreaDistrict class]};
}

YYModelDefaultCode
@end

NSString *const kYGAreaProvinceKey = @"province";
NSString *const kYGAreaCityKey = @"city";
NSString *const kYGAreaDistrictKey = @"district";
