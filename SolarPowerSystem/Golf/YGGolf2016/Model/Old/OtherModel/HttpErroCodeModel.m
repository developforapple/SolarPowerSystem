//
//  HttpErroCodeModel.m
//  Golf
//
//  Created by Dejohn Dong on 12-2-15.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import "HttpErroCodeModel.h"

@implementation HttpErroCodeModel

- (instancetype)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    NSDictionary *dic = (NSDictionary *)data;
    self.code = [dic[@"errorcode"] integerValue];
    self.errorMsg = dic[@"errormessage"];
    return self;
}

@end
