//
//  LoginParamsModel.h
//  Golf
//
//  Created by Dejohn Dong on 12-2-2.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginParamsModel : NSObject{
    NSString *_phoneNum;
    NSString *_imeiNum;
    NSString *_deviceName;
    NSString *_osName;
    NSString *_osVersion;
    NSString *_password;
    NSString *_deviceToken;
    float _longitude;
    float _latitude;
    NSString *_activationCode;
    NSString *_contryCode;
}

@property(nonatomic,copy) NSString *phoneNum;
@property(nonatomic,copy) NSString *imeiNum;
@property(nonatomic,copy) NSString *deviceName;
@property(nonatomic,copy) NSString *osName;
@property(nonatomic,copy) NSString *osVersion;
@property(nonatomic,copy) NSString *password;
@property(nonatomic,copy) NSString *deviceToken;
@property(nonatomic) float longitude;
@property(nonatomic) float latitude;
@property(nonatomic,copy) NSString *groupFlag;
@property(nonatomic,copy) NSString *groupData;
@property(nonatomic,copy) NSString *activationCode;
@property(nonatomic,copy) NSString *contryCode;
@end
