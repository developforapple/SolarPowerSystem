//
//  LoginService.h
//  Golf
//
//  Created by 青 叶 on 11-11-26.
//  Copyright (c) 2011年 大展. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserSessionModel.h"
#import "ClubModel.h"
#import "LoginParamsModel.h"

@interface LoginService : NSObject

/**
 * 用户登录
 * @param loginParamsModel
 * @return UserSessionModel
 * @throws Exception
 */
+ (void)publicLogin:(LoginParamsModel *)loginParams
        needLoading:(BOOL)needLoading
            success:(void (^)(UserSessionModel *userSession))success
            failure:(void (^)(id error))failure;

/**
 * 用户注销。 服务器注销后客户端的session_id将无法使用
 * @param session_id
 * @return YES/NO
 * @throws Exception
 */
+ (void)publicLogout:(NSString *)sessionId
             success:(void (^)(BOOL boolen))success
             failure:(void (^)(id error))failure;


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
               failure:(void (^)(id error))failure;

/**
 * 用户注册
 * @param phone_num
 * @param password
 * @param longitude
 * @param latitude
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
           failure:(void (^)(id error))failure;

/**
 * 获取手机验证码
 * @param phone_num
 * @return
 * @throws Exception
 */
+ (void)getValidateCode:(NSString *)phoneNum
                  noMsg:(int)noMsg
                success:(void (^)(NSString *code))success
                failure:(void (^)(id error))failure;

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
                failure:(void (^)(id error))failure;


/**
 * 判断手机号码是否注册
 * 
 * @param phone_num
 * @return
 * @throws Exception
 */

+ (void)checkPhoneNumber:(NSString *)phone_num
                 success:(void (^)(NSDictionary *dic))success
                 failure:(void (^)(id error))failure;

@end
