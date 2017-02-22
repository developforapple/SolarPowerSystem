//
//  TeachProductDetail.m
//  Golf
//
//  Created by 黄希望 on 15/5/12.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "TeachProductDetail.h"

@implementation TeachProductDetail

- (id)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [self init];
    if (self) {
        NSDictionary *dic = (NSDictionary*)data;
        if (dic[@"product_id"]) {
            self.productId = [dic[@"product_id"] intValue];
        }
        if (dic[@"product_name"]) {
            self.productName = dic[@"product_name"];
        }
        if (dic[@"product_intro"]) {
            self.productIntro = dic[@"product_intro"];
        }
        if (dic[@"selling_price"]) {
            self.sellingPrice = [dic[@"selling_price"] intValue]/100;
        }
        if (dic[@"original_price"]) {
            self.originalPrice = [dic[@"original_price"] intValue]/100;
        }
        if (dic[@"class_hour"]) {
            self.classHour = [dic[@"class_hour"] intValue];
        }
        if (dic[@"person_limit"]) {
            self.personLimit = [dic[@"person_limit"] intValue];
        }
        if (dic[@"product_image"]) {
            self.productImage = dic[@"product_image"] ;
        }
        if (dic[@"product_detail"]) {
            self.productDetail = dic[@"product_detail"];
        }
        if (dic[@"valid_days"]) {
            self.validDays = [dic[@"valid_days"] intValue];
        }
        if (dic[@"buy_guide"]) {
            self.buyGuide = dic[@"buy_guide"];
        }
        if (dic[@"class_type"]) {
            self.classType = [dic[@"class_type"] intValue];
        }
        if ([dic objectForKey:@"give_yunbi"]) {
            self.giveYunbi = [[dic objectForKey:@"give_yunbi"] intValue] / 100;
        }
    }
    return self;
}

@end
