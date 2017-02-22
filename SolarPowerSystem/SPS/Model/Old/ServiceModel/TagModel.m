//
//  TagModel.m
//  Golf
//
//  Created by 黄希望 on 15/8/20.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "TagModel.h"

@implementation TagModel

- (id)initWithDic:(id)data{
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    
    NSDictionary *dic = (NSDictionary *)data;
    if (dic[@"tag_id"]) {
        self.tagId = [dic[@"tag_id"] intValue];
    }
    if (dic[@"tag_name"]) {
        self.tagName = [dic[@"tag_name"] stringByReplacingOccurrencesOfString:@"#" withString:@""];
        self.tagName = [NSString stringWithFormat:@"#%@#",self.tagName];
    }
    if (dic[@"tag_image"]) {
        self.tagImage = dic[@"tag_image"];
    }
    if (dic[@"tag_description"]) {
        self.tagDescription = dic[@"tag_description"];
    }
    if (dic[@"hot_rank"]) {
        self.hotRank = [dic[@"hot_rank"] intValue];
    }
    if (dic[@"display_order"]) {
        self.displayOrder = [dic[@"display_order"] intValue];
    }
    if (dic[@"tag_subtitle"]) {
        self.tagSubtitle = dic[@"tag_subtitle"];
    }
    return self;
}

@end
