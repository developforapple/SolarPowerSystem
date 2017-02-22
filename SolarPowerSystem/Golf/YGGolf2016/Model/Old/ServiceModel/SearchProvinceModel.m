//
//  SearchProvinceModel.m
//  Golf
//
//  Created by user on 13-2-25.
//  Copyright (c) 2013年 大展. All rights reserved.
//

#import "SearchProvinceModel.h"

@implementation SearchProvinceModel

- (id)initWithDic:(id)data{
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    
    NSDictionary* dic = (NSDictionary*) data;
    if([dic objectForKey:@"province_id"]){
        self.provinceId = [[dic objectForKey:@"province_id"] intValue];
    }
    if([dic objectForKey:@"international"]){
        self.international = [[dic objectForKey:@"international"] intValue];
    }
    if([dic objectForKey:@"province_name"]){
        self.provinceName = [dic objectForKey:@"province_name"];
    }
    if ([dic objectForKey:@"club_count"]) {
        self.clubCount = [[dic objectForKey:@"club_count"] intValue];
    }
    return self;
}

+ (SearchProvinceModel *)getProvinceModelWithProvinceId:(int)provinceId{
    NSString *path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString *filename=[path stringByAppendingPathComponent:@"GolfProvinceInfo.plist"];
    NSArray *localArray = [NSArray arrayWithContentsOfFile:filename];
    if (localArray) {
        for (id obj in localArray) {
            SearchProvinceModel *model = [[SearchProvinceModel alloc] initWithDic:obj];
            if (model.provinceId == provinceId) {
                return model;
            }
        }
    }
    return nil;
}

@end
