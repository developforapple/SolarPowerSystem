//
//  Constants.m
//  Golf
//
//  Created by Dejohn Dong on 11-11-14.
//  Copyright (c) 2011年 Achievo. All rights reserved.
//

#import "Constants.h"

const BOOL kProductionEnvironment = ProductionEnvironment;

#if ProductionEnvironment

//生产
#define __URL_SHARE__           @"https://touch.bookingtee.com/"           //普通分享的url
#define __URL_SHARE_YUEDU__     @"https://www1.bookingtee.com/h5/yuedu"    //悦读分享的url
#define __API_OLD__             @"https://www.bookingtee.com/api/?"
#define __API_THRIFT__          @"https://www.bookingtee.com/golfapi2/apic.do"          //thrift 新协议的接口
#define __API_THRIFT_YUEDU__    @"https://www1.bookingtee.com/golfapi/apic.do"          //悦读api
#define __API_THRIFT_TEACHING__ @"https://www1.bookingtee.com/golfapi/teachingapic.do"  //教学订场api
#define __API_THRIFT_PACKAGE__  @""

#else

//测试
#define __URL_SHARE__           @"https://test2.bookingtee.com/golfwap/"
#define __URL_SHARE_YUEDU__     @"https://test.bookingtee.com/yg_h5/yuedu"          //悦读分享的url
#define __API_OLD__             @"https://test2.bookingtee.com/api/?"
#define __API_THRIFT__          @"https://test2.bookingtee.com/golfapi2/apic.do"    //thrift 新协议的接口
#define __API_THRIFT_YUEDU__    @"https://yg-test.bookingtee.com/yg_golfapi/apic.do"//悦读api
#define __API_THRIFT_TEACHING__ @"https://yg-test.bookingtee.com/yg_golfapi/teachingapic.do" //教学订场api
#define __API_THRIFT_PACKAGE__  @"https://yg-test.bookingtee.com/yg_golfapi/packageapic.do"

#endif

//生产
NSString *const URL_SHARE = __URL_SHARE__;
NSString *const URL_SHARE_YUEDU = __URL_SHARE_YUEDU__;    //悦读分享的url
NSString *const API_OLD = __API_OLD__;
NSString *const API_THRIFT = __API_THRIFT__; //thrift 新协议的接口
NSString *const API_THRIFT_YUEDU = __API_THRIFT_YUEDU__; //悦读api
NSString *const API_THRIFT_TEACHING = __API_THRIFT_TEACHING__; //教学订场api
NSString *const API_THRIFT_PACKAGE = __API_THRIFT_PACKAGE__;

#if InHouseVersion
NSString *const kUMengAppKey = @"589ab1e0e88bad5b40000a99"; //企业版
#else
NSString *const kUMengAppKey = @"5707a37567e58e969c0002b9"; //AppStore版
#endif
NSString *const kWeiboAppKey = @"2911809260";
NSString *const kWechatAppKey = @"wxb4f02e0ddf46579a";
NSString *const kBeaconAppKey = @"1JY29RFMJE1B70ZT";

const NSArray<NSString *> *OrderStatus;
const NSArray<NSString *> *CommodityOrderStatus;
const NSArray<NSString *> *PayType;

NSString *const SCHEMA_GOLF = @"yungaogolf://golfapi/?";
NSString *const API_KEY = @"d26fd1beee9729cbd2b0c4bc304b9d75";
NSString *const WKDeviceTokenKey = @"K_DEVICE_TOKEN";
NSString *const K_SELECTED_CITY_MODEL = @"selectedCityModel";
NSString *const K_LAST_CANCEL_DATE = @"LAST_CANCEL_DATE";
NSInteger const kGolfAppStoreId = 514525561;
NSString *const kGolfAppStoreIdStr = @"514525561";
NSString *const kClientServicePhone = @"400-085-9939";

NSString *const KGolfSessionPhone = @"GolfSessionPhone";
NSString *const KGolfAreaCode = @"GolfAreaCode";
NSString *const KGolfUserPassword = @"GolfUserPassword";
NSString *const KLastPersonPhone = @"LastPersonPhone";
NSString *const KContactsPerson = @"ContactsPerson";
NSString *const KGroupData = @"group_data";
NSString *const PLACE_SELECTED_INDEX = @"PLACE_SELECTED_INDEX";

UIColor * MainTintColor;
UIColor * MainHighlightColor;
UIColor * MainDarkHighlightColor;
UIColor * MainGrayLineColor;

UIColor *kYGStatusGrayColor;       //灰色状态 #BBBBBB 187 187 187 1
UIColor *kYGStatusOrangeColor;     //橙色状态 #FF9312 255 147 18 1
UIColor *kYGStatusBlueColor;       //蓝色状态 #249DF3 36 157 243 1
UIColor *kYGStatusRedColor;        //红色状态 #F3243A 243 36 58 1

@interface Constants : NSObject
@end

@implementation Constants

+ (void)load
{
    OrderStatus = @[@"完成预订",
                    @"完成消费",
                    @"未到场",
                    @"已取消",
                    @"等待确认",
                    @"等待支付",
                    @"申请撤销",
                    @"已经撤销"];
    
    CommodityOrderStatus = @[@"交易成功",
                             @"交易成功",
                             @"等待收货",
                             @"已取消",
                             @"等待发货",
                             @"等待支付",
                             @"退款申请中",
                             @"已经退款"];
    
    PayType = @[@"默认",
                @"会员主场",
                @"球场现付",
                @"全额预付",
                @"部分预付"];
    
    MainTintColor = RGBColor(102, 102, 102, 1);
    MainHighlightColor = RGBColor(36, 157, 243, 1);
    MainDarkHighlightColor = RGBColor(29, 124, 191, 1);
    MainGrayLineColor = RGBColor(230, 230, 230, 1);
    
    kYGStatusGrayColor = RGBColor(187, 187, 187, 1);
    kYGStatusOrangeColor = RGBColor(255, 147, 18, 1);
    kYGStatusBlueColor = MainHighlightColor;
    kYGStatusRedColor = RGBColor(243, 36, 58, 1);
}

@end
