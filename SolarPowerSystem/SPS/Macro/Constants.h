//
//  Constants.h
//  Golf
//
//  Created by 黄希望 on 12-12-13.
//  Copyright (c) 2012年 云高科技. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#define ProductionEnvironment 0 //0为测试环境 非0为生产环境
#define InHouseVersion 1 //0为AppStore版 1为企业版

@class NSArray;
@class NSString;
@class UIColor;

// YES: 生产环境 NO：测试环境
FOUNDATION_EXTERN const BOOL kProductionEnvironment;

// Third-Parties
FOUNDATION_EXTERN NSString *const kUMengAppKey;
FOUNDATION_EXTERN NSString *const kWeiboAppKey;
FOUNDATION_EXTERN NSString *const kWechatAppKey;
FOUNDATION_EXTERN NSString *const kBeaconAppKey;

// 旧的常量
FOUNDATION_EXTERN const NSArray<NSString *> *OrderStatus;
FOUNDATION_EXTERN const NSArray<NSString *> *CommodityOrderStatus;
FOUNDATION_EXTERN const NSArray<NSString *> *PayType;

//
FOUNDATION_EXTERN NSString *const SCHEMA_GOLF;
FOUNDATION_EXTERN NSString *const API_KEY;
FOUNDATION_EXTERN NSString *const WKDeviceTokenKey;
FOUNDATION_EXTERN NSString *const K_SELECTED_CITY_MODEL;
FOUNDATION_EXTERN NSString *const K_LAST_CANCEL_DATE;
FOUNDATION_EXTERN NSInteger const kGolfAppStoreId;
FOUNDATION_EXTERN NSString *const kGolfAppStoreIdStr;
FOUNDATION_EXTERN NSString *const kClientServicePhone;

// 用户相关的key
FOUNDATION_EXTERN NSString *const KGolfSessionPhone;
FOUNDATION_EXTERN NSString *const KGolfAreaCode;
FOUNDATION_EXTERN NSString *const KGolfUserPassword;
FOUNDATION_EXTERN NSString *const KLastPersonPhone;
FOUNDATION_EXTERN NSString *const KContactsPerson;
FOUNDATION_EXTERN NSString *const KGroupData;
FOUNDATION_EXTERN NSString *const PLACE_SELECTED_INDEX;

// API地址
FOUNDATION_EXTERN NSString *const URL_SHARE;
FOUNDATION_EXTERN NSString *const URL_SHARE_YUEDU;// 悦读的分享URL
FOUNDATION_EXTERN NSString *const API_OLD;
FOUNDATION_EXTERN NSString *const API_THRIFT;
FOUNDATION_EXTERN NSString *const API_THRIFT_PACKAGE; //旅游套餐API
FOUNDATION_EXTERN NSString *const API_THRIFT_YUEDU; // 悦读的api接口
FOUNDATION_EXTERN NSString *const API_THRIFT_TEACHING; // 教学订场的api接口

UIKIT_EXTERN UIColor *MainTintColor; //102 102 102
UIKIT_EXTERN UIColor *MainHighlightColor;//36 157 243  #249DF3  高亮蓝色
UIKIT_EXTERN UIColor *MainDarkHighlightColor; // 29 124 191  #1d7cbf 暗色蓝色
UIKIT_EXTERN UIColor *MainGrayLineColor; //230 230 230 #E6E6E6 淡色灰色

UIKIT_EXTERN UIColor *kYGStatusGrayColor;       //灰色状态 #BBBBBB 187 187 187 1
UIKIT_EXTERN UIColor *kYGStatusOrangeColor;     //橙色状态 #FF9312 255 147 18 1
UIKIT_EXTERN UIColor *kYGStatusBlueColor;       //蓝色状态 #249DF3 36 157 243 1
UIKIT_EXTERN UIColor *kYGStatusRedColor;        //红色状态 #F3243A 243 36 58 1

#endif
