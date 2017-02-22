//
//  LoginService.m
//  Golf
//
//  Created by 青 叶 on 11-11-26.
//  Copyright (c) 2011年 大展. All rights reserved.
//

#import "LoginService.h"
#import "OpenUDID.h"
#import "BaseService.h"
#import "IMNotificationDefine.h"


@implementation LoginService

+ (void)publicLogin:(LoginParamsModel *)loginParams
        needLoading:(BOOL)needLoading
            success:(void (^)(UserSessionModel *userSession))success
            failure:(void (^)(id error))failure{

    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if(loginParams.phoneNum){
        [params setObject:loginParams.phoneNum forKey:@"phone_num"];
    }
    if(loginParams.osVersion){
        [params setObject:loginParams.osVersion forKey:@"os_version"];
    }
    if(loginParams.osName){
        [params setObject:loginParams.osName forKey:@"os_name"];
    }
    if(loginParams.latitude){
        [params setObject:[NSNumber numberWithFloat:loginParams.latitude] forKey:@"latitude"];
    }
    if(loginParams.longitude){
        [params setObject:[NSNumber numberWithFloat:loginParams.longitude] forKey:@"longitude"];
    }
    if(loginParams.password){
        [params setObject:[loginParams.password md5String] forKey:@"password"];
    }
    if(loginParams.imeiNum){
        [params setObject:loginParams.imeiNum forKey:@"imei_num"];
    }
    if(loginParams.deviceName){
        [params setObject:loginParams.deviceName forKey:@"device_name"];
    }
    if(loginParams.deviceToken){
        [params setObject:loginParams.deviceToken forKey:@"device_token"];
    }
    if (loginParams.groupFlag) {
        [params setObject:loginParams.groupFlag forKey:@"group_flag"];
    }
    if (loginParams.groupData) {
        [params setObject:loginParams.groupData forKey:@"group_data"];
    }
    if (loginParams.activationCode) {
        [params setObject:loginParams.activationCode forKey:@"validate_code"];
    }
    if (loginParams.contryCode) {
        [params setObject:loginParams.contryCode forKey:@"country_code"];
    }
    [BaseService BSGet:@"public_login" parameters:params encrypt:YES needLoading:needLoading success:^(BaseService *BS) {
    
        if (BS.success && BS.data) {
            NSDictionary *resultDic = (NSDictionary*)BS.data;
            if(resultDic){
                UserSessionModel *model = [[UserSessionModel alloc] initWithDic:[resultDic objectForKey:@"login"]];
                NSLog(@"-----------public_login-----------%@",model.sessionId);
                [MobClick profileSignInWithPUID:[NSString stringWithFormat:@"%d",model.memberId]];
               
                success (model);
                NSMutableDictionary *nd = [NSMutableDictionary new];
                [nd setObject:[NSString stringWithFormat:@"%d",model.memberId] forKey:IMUsername];
                if (loginParams.password.length > 0) {
                    [nd setObject:[loginParams.password md5String] forKey:IMPassword];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGIN_SUCCESSED" object:nd];
            }
        }
    } failure:^(id error) {
        
        if (failure && error) {
            failure(error);
        }
    }];
}


/**
 * 用户注销。 服务器注销后客户端的session_id将无法使用
 * @param session_id
 * @return
 * @throws Exception
 */

+ (void)publicLogout:(NSString *)sessionId
             success:(void (^)(BOOL boolen))success
             failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if(sessionId){
        [params setObject:sessionId forKey:@"session_id"];
    }
    [BaseService BSGet:@"public_logout" parameters:params encrypt:YES needLoading:YES success:^(BaseService *BS) {
        success (BS.success ? YES : NO);
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}

/**
 * 修改用户密码
 * @param session_id
 * @param old_password
 * @param new_password
 * @return
 * @throws Exception
 */

+ (void)passwordModify:(NSString *)sessionId
       withOldPassword:(NSString *)oldPassword
       withNewPassword:(NSString *)newPassword
               success:(void (^)(BOOL boolen))success
               failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if(sessionId){
        [params setObject:sessionId forKey:@"session_id"];
    }
    if(oldPassword){
        [params setObject:[oldPassword md5String] forKey:@"old_password"];
    }
    if(newPassword){
        [params setObject:[newPassword md5String] forKey:@"new_password"];
    }
    [BaseService BSGet:@"password_modify" parameters:params encrypt:YES needLoading:YES success:^(BaseService *BS) {
        success (BS.success ? YES : NO);
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}


/**
 * 用户注册
 * @param phone_num
 * @param password
 * @param validate_code验证码
 * @return
 * @throws Exception
 */

+ (void)userRegist:(NSString *)phoneNum
      withPassword:(NSString *)password
     withLongitude:(float)longitude
      withLatitude:(float)latitude
  withValidateCode:(NSString *)validateCode
   withDeviceToken:(NSString *)deviceToken
        withOsName:(NSString *)osName
    withDeviceName:(NSString *)deviceName
     withOsVersion:(NSString *)osVersion
withActivationCode:(NSString *)activationCode
     withGroupData:(NSString *)groupData
   withCountryCode:(NSString *)countryCode
           success:(void (^)(UserSessionModel *userSession))success
           failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *imeiNum = [OpenUDID value];
    if (imeiNum) {
        [params setObject:imeiNum forKey:@"imei_num"];
    }
    if(phoneNum){
        [params setObject:phoneNum forKey:@"phone_num"];
    }
    if(password){
        [params setObject:[password md5String] forKey:@"password"];
    }
    if(longitude){
        [params setObject:[NSNumber numberWithFloat:longitude] forKey:@"longitude"];
    }
    if(latitude){
        [params setObject:[NSNumber numberWithFloat:latitude] forKey:@"latitude"];
    }
    if(validateCode){
        [params setObject:validateCode forKey:@"validate_code"];
    }
    if(deviceToken) {
        [params setObject:deviceToken forKey:@"device_token"];
    }
    if(osVersion){
        [params setObject:osVersion forKey:@"os_version"];
    }
    if(osName){
        [params setObject:osName forKey:@"os_name"];
    }
    if (deviceName) {
        [params setObject:deviceName forKey:@"device_name"];
    }
    if(activationCode){
        [params setObject:activationCode forKey:@"activation_code"];
    }
    if (groupData) {
        [params setObject:groupData forKey:@"group_data"];
    }
    
    if (countryCode) {
        [params setObject:countryCode forKey:@"country_code"];
    }
    
    [BaseService BSGet:@"user_regist" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success && BS.data) {
            NSDictionary *resultDic = (NSDictionary*)BS.data;
            if(resultDic){
                UserSessionModel *model = [[UserSessionModel alloc] initWithDic:BS.data];
                [MobClick profileSignInWithPUID:[NSString stringWithFormat:@"%d",model.memberId]];
                success (model);
                NSMutableDictionary *nd = [NSMutableDictionary new];
                [nd setObject:[NSString stringWithFormat:@"%d",model.memberId] forKey:IMUsername];
                if (password.length > 0) {
                    [nd setObject:[password md5String] forKey:IMPassword];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGIN_SUCCESSED" object:nd];
            }
        }
        
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}

/**
 * 获取手机验证码
 * @param phone_num
 * @return
 * @throws Exception
 */
+ (void)getValidateCode:(NSString *)phoneNum
                  noMsg:(int)noMsg
                success:(void (^)(NSString *code))success
                failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if(phoneNum){
        [params setObject:phoneNum forKey:@"phone_num"];
    }
    [params setObject:[NSNumber numberWithInt:noMsg] forKey:@"no_msg"];
    
    [BaseService BSGet:@"public_validate_code" parameters:params encrypt:YES needLoading:YES success:^(BaseService *BS) {
        if (BS.success && BS.data) {
            NSDictionary *dic = (NSDictionary*)BS.data;
            success ([dic[@"code"] description]);
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}

/**
 * 找回密码
 * @param phone_num
 * @param validate_code
 * @param new_password
 * @return
 * @throws Exception
 */

+ (void)getPasswordBack:(NSString *)phoneNum
       withValidateCode:(NSString *)validateCode
        withNewPassword:(NSString *)newPassword
                success:(void (^)(BOOL boolen))success
                failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if(phoneNum){
        [params setObject:phoneNum forKey:@"phone_num"];
    }
    if(validateCode){
        [params setObject:validateCode forKey:@"validate_code"];
    }
    if(newPassword){
        [params setObject:[newPassword md5String] forKey:@"new_password"];
    }
    
    [BaseService BSGet:@"password_get_back" parameters:params encrypt:YES needLoading:YES success:^(BaseService *BS) {
        if (BS.success && BS.data) {
            NSDictionary *dic = (NSDictionary*)BS.data;
            success ([[dic objectForKey:@"flag"] boolValue]);
        }else{
            success (NO);
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}



/**
 * 判断手机号码是否注册
 * 
 * @param phone_num
 * @return
 * @throws Exception
 */
+ (void)checkPhoneNumber:(NSString *)phone_num
                 success:(void (^)(NSDictionary *dic))success
                 failure:(void (^)(id error))failure{
    NSString *openUdid = [OpenUDID value];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if(phone_num){
        [params setObject:phone_num forKey:@"phone_num"];
    }
    if (openUdid) {
        [params setObject:openUdid forKey:@"imei_num"];
    }
    
    [BaseService BSGet:@"phone_num_existed" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success && BS.data) {
            NSDictionary *dic = (NSDictionary*)BS.data;
            success (dic);
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}

@end
