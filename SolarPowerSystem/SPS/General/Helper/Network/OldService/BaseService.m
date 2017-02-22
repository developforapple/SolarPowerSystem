//
//  BaseService.m
//  Golf
//
//  Created by 黄希望 on 15/7/6.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "BaseService.h"
#import "APIClient.h"
#import "NSDictionary+LinqExtensions.h"

static NSString *modeString;//lyf 加 调用退出登录时，如果已经被踢下线，则不用发通知

@implementation BaseService

- (void)setDataWithNSDictionary:(NSDictionary *)data
{
    if ([data isKindOfClass:[NSDictionary class]]) {
        _data = (NSDictionary *)data;
    } else {
        _data = nil;
    }
}


+ (HttpErroCodeModel *)getErrorDescription:(NSError *)error requestOption:(NSDictionary *)requestOperation stopLoading:(BOOL)needLoading{
    if (needLoading) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [SVProgressHUD setDefaultMaskType:(SVProgressHUDMaskTypeNone)];
        });
    }
    HttpErroCodeModel *errorModel = [APIClient errorWithAFHTTPRequestOperation:requestOperation error:error];
    if ([modeString isEqualToString:@"public_logout"] && (errorModel.code == 100005 || errorModel.code == 100006)) {
        NSLog(@"lyf 是再已经被踢下线后调退出登录接口\"public_logout\"，不用处理");
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"checkHttpError" object:errorModel];
    }
    
    return errorModel;
}

+ (void)BSGet:(NSString*)mode
   parameters:(id)parameters
      encrypt:(BOOL)encrypt
  needLoading:(BOOL)needLoading
      success:(void (^)(BaseService *BS))success
      failure:(void (^)(id error))failure{
    if ([[GolfAppDelegate shareAppDelegate] networkReachability]) {
        modeString = mode;//lyf 加
        
        if (!parameters) {
            parameters = [NSMutableDictionary dictionary];
        }
        NSString *urlString = [APIClient urlStringWithMode:mode params:parameters];
        
        if (encrypt) {
            NSString *checkCode = [APIClient md5ParamsWithMode:mode params:parameters];
            [parameters setObject:checkCode forKey:@"check_code"];
            NSLog(@"GET Method URL = %@",[NSString stringWithFormat:@"%@check_code=%@",urlString,checkCode]);
        }
        
        if (needLoading) {
            [SVProgressHUD setDefaultMaskType:(SVProgressHUDMaskTypeGradient)];
            [SVProgressHUD show];
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[APIClient sharedClient] POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                if (needLoading) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                        [SVProgressHUD setDefaultMaskType:(SVProgressHUDMaskTypeNone)];
                    });
                }
                
                
                NSError *error;
                BaseService *bs = [[BaseService alloc] initWithDictionary:responseObject error:&error];
                bs.parameters = parameters;
                if (!bs.data && responseObject && bs.success) {
                    if ([responseObject isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *resp = (NSDictionary*)responseObject;
                        id obj = [resp objectForKey:@"data"];
                        if (obj && (__bridge CFNullRef)obj!=kCFNull) {
                            bs.data = obj;
                        }
                    }
                }
                if (error) {
                    if (failure) {
                        failure(error);
                    }
                }else{
                    if (bs.success) {
                        if (success) {
                            success(bs);
                        }
                    }else{
                        HttpErroCodeModel *errorModel = [BaseService getErrorDescription:error requestOption:responseObject stopLoading:needLoading];
                        if (failure) {
                            failure(errorModel);
                        }
                    }
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                HttpErroCodeModel *errorModel = [BaseService getErrorDescription:error requestOption:nil stopLoading:needLoading];
                if (failure){
                    failure(errorModel);
                }
                if (needLoading) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                        [SVProgressHUD setDefaultMaskType:(SVProgressHUDMaskTypeNone)];
                    });
                }
                
            }];
        });
    }else{
        NSError *error;
        error = [[NSError alloc] initWithDomain:@"www.cgit.com.cn" code:-1009 userInfo:[NSDictionary dictionaryWithObject:@"当前网络不可用" forKey:NSLocalizedDescriptionKey]];
        HttpErroCodeModel *errorModel = [BaseService getErrorDescription:error requestOption:nil stopLoading:needLoading];
        if (failure) {
            failure(errorModel);
        }
    }
}

+ (void)BSPost:(NSString*)mode
    parameters:(id)parameters
       encrypt:(BOOL)encrypt
   needLoading:(BOOL)needLoading
       success:(void (^)(BaseService *BS))success
       failure:(void (^)(id error))failure{
    if ([[GolfAppDelegate shareAppDelegate] networkReachability]) {
        
        NSString *urlString = [NSString stringWithFormat:@"%@",API_OLD];
        urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        if (encrypt) {
            NSString *checkCode = [APIClient md5ParamsWithMode:mode params:parameters];
            [parameters setObject:checkCode forKey:@"check_code"];
            NSLog(@"POST Method URL = %@",[NSString stringWithFormat:@"%@check_code=%@",urlString,checkCode]);
        }
        NSString *currVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        if (currVersion.length>0) {
            [parameters setValue:currVersion forKey:@"version"];
        }
        [parameters setValue:mode forKey:@"mode"];
        
        if (needLoading) {
            [SVProgressHUD setDefaultMaskType:(SVProgressHUDMaskTypeGradient)];
            [SVProgressHUD show];
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[APIClient sharedClient] POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (needLoading) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                        [SVProgressHUD setDefaultMaskType:(SVProgressHUDMaskTypeNone)];
                    });
                }
                
                NSError *error;
                BaseService *bs = [[BaseService alloc] initWithDictionary:responseObject error:&error];
                if (!bs.data && responseObject && bs.success) {
                    if ([responseObject isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *resp = (NSDictionary*)responseObject;
                        id obj = [resp objectForKey:@"data"];
                        if (obj && (__bridge CFNullRef)obj != kCFNull) {
                            bs.data = obj;
                        }
                    }
                }
                if (error) {
                    if (failure) {
                        failure(error);
                    }
                }else{
                    if (bs.success) {
                        if (success) {
                            success(bs);
                        }
                    }else{
                        HttpErroCodeModel *errorModel = [BaseService getErrorDescription:error requestOption:responseObject stopLoading:needLoading];
                        if (failure) {
                            failure(errorModel);
                        }
                    }
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                HttpErroCodeModel *errorModel = [BaseService getErrorDescription:error requestOption:nil stopLoading:needLoading];
                if (failure) {
                    failure(errorModel);
                }
            }];
        });
        
        
    }else{
        NSError *error;
        error = [[NSError alloc] initWithDomain:@"www.cgit.com.cn" code:-1009 userInfo:[NSDictionary dictionaryWithObject:@"当前网络不可用" forKey:NSLocalizedDescriptionKey]];
        HttpErroCodeModel *errorModel = [BaseService getErrorDescription:error requestOption:nil stopLoading:needLoading];
        if (failure) {
            failure(errorModel);
        }
    }
    
}


@end
