//
//  SubCommodityCategory.m
//  Golf
//
//  Created by 黄希望 on 15/3/30.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "SubCommodityCategory.h"

@implementation SubCommodityCategory

- (id)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if (self) {
        NSDictionary *dic = (NSDictionary *)data;
        if (dic[@"sub_category_id"]) {
            self.subCategoryId = [dic[@"sub_category_id"] intValue];
        }
        if (dic[@"sub_category_name"]) {
            self.subCategoryName = dic[@"sub_category_name"];
        }
    }
    return self;
}

@end
