//
//  ConditionModel.m
//  Golf
//
//  Created by Dejohn Dong on 12-1-31.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import "ConditionModel.h"

@implementation ConditionModel

- (id)copyWithZone:(NSZone *)zone {
    ConditionModel *clone = [[ConditionModel allocWithZone:zone] init];
    clone.price = _price;
    clone.prepayAmount = _prepayAmount;
    clone.cityId = _cityId;
    clone.provinceId = _provinceId;
    clone.latitude = _latitude;
    clone.longitude = _longitude;
    clone.people = _people;
    clone.clubId = _clubId;
    clone.weekDay = _weekDay;
    clone.isOfficial = _isOfficial;
    clone.payType = _payType;

    clone.time = [_time copy];
    clone.date = [_date copy];
    clone.range = [_range copy];
    clone.clubName = [_clubName copy];
    clone.address = [_address copy];
    clone.supplier = [_supplier copy];
    clone.personName = [_personName copy];
    clone.personPhone = [_personPhone copy];
    clone.cityName = [_cityName copy];
    clone.clubIds = [_clubIds copy];
    return clone;    
}

@end
