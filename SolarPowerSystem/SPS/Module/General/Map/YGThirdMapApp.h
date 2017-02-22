//
//  YGThirdMapApp.h
//  Golf
//
//  Created by bo wang on 2016/12/21.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, YGMapAppType) {
    YGMapAppTypeGoogle,       //谷歌地图。
    YGMapAppTypeGaode,        //高德地图
    YGMapAppTypeBaidu,        //百度地图
    YGMapAppTypeApple,        //apple地图
    YGMapAppTypeTencent,      //腾讯地图
};

@interface YGThirdMapApp : NSObject

@property (assign, nonatomic) YGMapAppType mapType;
@property (copy, nonatomic) NSString *name;     //app名称

@property (copy, nonatomic) NSString *naviURI;

// 返回第三方地图列表。谷歌地图 不在这列表里
+ (NSArray<YGThirdMapApp *> *)defaultMapApps;

//是否安装
- (BOOL)installed;

// 开始导航。params数组的数据个数，必须和numberOfNaviParams一致
- (BOOL)beginNavigate:(NSDictionary *)params;


@end

// 坐标  object: NSValue of CLLocationCoordinate2D
FOUNDATION_EXTERN NSString *const kYGThirdMapAppParamCoordinateKey;

// MKAnnotation 协议对象 object: id<MKAnnotation>
FOUNDATION_EXTERN NSString *const kYGThirdMapAppParamAnnotationKey;
