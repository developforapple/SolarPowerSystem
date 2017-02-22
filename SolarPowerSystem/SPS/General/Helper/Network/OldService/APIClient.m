//
//  APIClient.m
//  Golf
//
//  Created by 黄希望 on 15/7/6.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "APIClient.h"

@implementation APIClient

+ (instancetype)sharedClient{
    static APIClient *_sharedClient = nil;
    static dispatch_once_t onceToken = 0.;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[APIClient alloc] init];
        _sharedClient.requestSerializer.timeoutInterval = 60.0f;
        _sharedClient.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"text/plain", @"charset=UTF-8", @"application/json", nil];
        
    });
    return _sharedClient;

}

// 抛出错误
+ (HttpErroCodeModel *)errorWithAFHTTPRequestOperation:(NSDictionary *)responseObject error:(NSError *)error{
    NSString *errorMsg = error.userInfo[@"NSLocalizedDescription"];
    
    if (error.code == -1009 || error.code == -1003) {
        errorMsg = @"当前网络不可用";
        [SVProgressHUD showErrorWithStatus:errorMsg];
        return nil;
    }
    
    if (errorMsg.length > 0) {
        HttpErroCodeModel *errorModel = [[HttpErroCodeModel alloc] init];
        errorModel.errorMsg = errorMsg;
        errorModel.code = error.code;
        return errorModel;
    }
    
    if((__bridge CFNullRef)[responseObject objectForKey:@"errormessage"]!= kCFNull && (__bridge CFNullRef)[responseObject objectForKey:@"errormessage"]!= kCFNull){
        return [[HttpErroCodeModel alloc] initWithDic:responseObject];
    }
    return nil;
}


// 生成MD5加密串 
+ (NSString *)md5ParamsWithMode:(NSString*)mode params:(NSDictionary *)params{
    //加密串
    NSMutableString *checkCodeStr = [NSMutableString stringWithString:mode];
    //得到参数对象
    NSMutableDictionary *myParams = [NSMutableDictionary dictionaryWithDictionary:params];
    //获取当前的app版本
    NSString *currVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if (currVersion.length>0) {
        [myParams setValue:currVersion forKey:@"version"];
    }
    [myParams setValue:mode forKey:@"mode"];
    
    if (myParams) {
        NSDictionary *dic = (NSDictionary *)myParams;
        NSArray *keyArray = [dic allKeys];
        keyArray = [keyArray sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        for (id key in keyArray) {
            NSString *sValue = [NSString stringWithFormat:@"%@",[dic objectForKey:key]];
            [checkCodeStr appendFormat:@"%@%@",[NSString stringWithFormat:@"%@",key],[NSString stringWithFormat:@"%@",sValue]];
        }
        [checkCodeStr appendString:API_KEY];
    }
    return [checkCodeStr md5String];
}

// 生成urlstring
+ (NSString *)urlStringWithMode:(NSString*)mode params:(NSDictionary *)params{
    NSMutableString *urlString = [NSMutableString stringWithString:API_OLD];
    NSString *currVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSMutableDictionary *myParams = [NSMutableDictionary dictionaryWithDictionary:params];
    myParams[@"mode"] = mode;
    myParams[@"version"] = currVersion;
    if (myParams) {
        NSDictionary *dic = (NSDictionary *)myParams;
        NSArray *keyArray = [dic allKeys];
        keyArray = [keyArray sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        for (id key in keyArray) {
            NSString *sValue = [NSString stringWithFormat:@"%@",[dic objectForKey:key]];
            NSString *eValue = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)sValue,NULL,CFSTR("!*'();:@&=+$,/?%#[]"),kCFStringEncodingUTF8));
            [urlString appendFormat:@"%@=%@&",[NSString stringWithFormat:@"%@",key],[NSString stringWithFormat:@"%@",eValue]];
        }
    }
    return urlString;
}


@end
