//
//  CommodityCategory.m
//  Golf
//
//  Created by 黄希望 on 15/3/30.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CommodityCategory.h"
#import "SubCommodityCategory.h"

@implementation CommodityCategory

- (id)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if(self) {
        NSDictionary *dic = (NSDictionary *)data;
        if (dic[@"category_id"]) {
            self.categoryId = [dic[@"category_id"] intValue];
        }
        if (dic[@"category_name"]) {
            self.categoryName = dic[@"category_name"];
        }
        if (dic[@"relative_type"]) {
            self.relativeType = [dic[@"relative_type"] intValue];
        }
        if (dic[@"category_icon"]) {
            self.categoryIcon = dic[@"category_icon"];
        }
        if (dic[@"sub_category_list"]) {
            NSArray *list = dic[@"sub_category_list"];
            if (list.count>0) {
                NSMutableArray *mut = [NSMutableArray array];
                for (id obj in list) {
                    SubCommodityCategory *subCommodityCategory = [[SubCommodityCategory alloc] initWithDic:obj];
                    [mut addObject:subCommodityCategory];
                }
                self.subCategoryList = mut;
            }
        }
    }
    return self;
}

@end
