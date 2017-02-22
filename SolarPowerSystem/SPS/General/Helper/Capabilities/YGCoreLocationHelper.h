//
//  YGCoreLocationHelper.h
//  Golf
//
//  Created by bo wang on 16/8/15.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface YGCoreLocationHelper : NSObject

/*!
 *  @brief App是否可以使用定位服务。定位关闭、权限受限、权限被拒绝都会导致定位服务不可用。返回NO。 权限未定、可用时，返回YES。
 *
 *  @return
 */
+ (BOOL)isLocationServiceUsable;

/*!
 *  @brief 当App无法定位时弹出提示信息。
 */
+ (void)alertWhenLocationDisabled;

/*!
 *  @brief 设置提示信息的最小时间间隔。默认为 600 秒
 *
 *  @param interval 间隔时间
 */
+ (void)setMinimumAlertInterval:(NSTimeInterval )interval;

+ (instancetype)shared;

/*!
 *  @brief 最大定位精度。大于这个精度的值忽略不计。默认为 kCLLocationAccuracyHundredMeters
 */
@property (assign, nonatomic) CLLocationAccuracy maximumAccuracy;

/*!
 *  @brief 最小定位刷新间隔。默认300秒
 */
@property (assign, nonatomic) NSTimeInterval minimumUpdateInterval;

/*!
 *  @brief 定位manager
 */
@property (strong, readonly, nonatomic) CLLocationManager *manager;

/*!
 *  @brief 是否有定位数据
 */
@property (assign, readonly, nonatomic) BOOL hasLocation;

/*!
 *  @brief GCJ经纬度。
 */
@property (assign, readonly, nonatomic) CLLocationCoordinate2D coordinate;

/*!
 *  @brief 当前纬度精度
 */
@property (assign, readonly, nonatomic) CLLocationAccuracy latitudeAccuracy;

/*!
 *  @brief 当前经度的精度
 */
@property (assign, readonly, nonatomic) CLLocationAccuracy longitudeAccuracy;

/*!
 *  @brief 地址字典
 */
@property (strong, readonly, nonatomic) NSDictionary *address;

/*!
 *  @brief 城市
 */
@property (strong, readonly, nonatomic) NSString *locality;

- (void)updateLocation:(void (^)(BOOL suc))completion;

@end
