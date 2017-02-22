//
//  PublicCourseModel.m
//  Golf
//
//  Created by 黄希望 on 15/5/8.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "PublicCourseModel.h"

@implementation PublicCourseModel

- (id)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    
    self = [self init];
    if (self) {
        NSDictionary *dic = (NSDictionary*)data;
        if (dic[@"public_class_id"]) {
            self.publicClassId = [dic[@"public_class_id"] intValue];
        }
        if (dic[@"product_id"]) {
            self.productId = [dic[@"product_id"] intValue];
        }
        if (dic[@"class_status"]) {
            self.classStatus = [dic[@"class_status"] intValue];
        }
        if (dic[@"product_name"]) {
            self.productName = dic[@"product_name"];
        }
        if (dic[@"product_image"]) {
            self.productImage = dic[@"product_image"];
        }
        if (dic[@"distance"]) {
            self.distance = [dic[@"distance"] doubleValue];
        }
        if (dic[@"teaching_site"]) {
            self.teachingSite = dic[@"teaching_site"] ;
        }
        if (dic[@"short_address"]) {
            self.shortAddress = dic[@"short_address"];
        }
        if (dic[@"open_date"]) {
            self.openDate = dic[@"open_date"];
        }
        if (dic[@"open_time"]) {
            self.openTime = dic[@"open_time"];
        }
        if (dic[@"block_time"]) {
            self.blockTime = dic[@"block_time"];
        }
        if (dic[@"selling_price"]) {
            self.sellingPrice = [dic[@"selling_price"] intValue] / 100;
        }
        if (dic[@"person_limit"]) {
            self.personLimit = [dic[@"person_limit"] intValue];
        }
        if (dic[@"person_join"]) {
            self.personJoin = [dic[@"person_join"] intValue];
        }
    }
    return self;
}

@end
