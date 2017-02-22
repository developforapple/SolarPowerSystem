//
//  GetLastVersionModel.m
//  Golf
//
//  Created by liangqing on 16/9/6.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "GetLastVersionModel.h"

@implementation GetLastVersionModel
- (instancetype)initWithDic:(id)data
{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    NSDictionary *dic = (NSDictionary *)data;
    if ([dic objectForKey:@"version_name"]) {
        self.versionName = [dic objectForKey:@"version_name"];
    }
    if ([dic objectForKey:@"version_number"]) {
        self.versionNumber = [[dic objectForKey:@"version_number"] floatValue];
    }
    if ([dic objectForKey:@"version_desc"]) {
        self.versionDesc = [dic objectForKey:@"version_desc"];
    }
    return self;
}
@end
