//
//  YGCoreLocationHelper.m
//  Golf
//
//  Created by bo wang on 16/8/15.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGCoreLocationHelper.h"
#import "TQLocationConverter.h"

@interface _YGSettingSegue : NSObject <UIAlertViewDelegate>
- (void)openLocationServiceSetting;
@end

@implementation _YGSettingSegue
- (void)openLocationServiceSetting
{
    NSURL *url = [NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"];
    if (!iOS8) {
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }else{
            // 经过测试 iOS7中可以打开定位设置
        }
    }else{
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }else{
            url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self openLocationServiceSetting];
    }
}

@end

static NSTimeInterval kAlertInterval = 600.f;

@interface YGCoreLocationHelper ()<CLLocationManagerDelegate>

@property (strong, readwrite, nonatomic) CLLocationManager *manager;
@property (assign, readwrite, nonatomic) BOOL hasLocation;
@property (assign, readwrite, nonatomic) CLLocationCoordinate2D coordinate;
@property (strong, readwrite, nonatomic) NSDictionary *address;
@property (strong, readwrite, nonatomic) NSString *locality;

@property (assign, nonatomic) NSTimeInterval lastUpdateTime;
@property (copy, nonatomic) void (^updateLocationCompletion)(BOOL suc);

@end

@implementation YGCoreLocationHelper

#pragma mark - Available
+ (BOOL)isLocationServiceUsable
{
    BOOL enabled = [CLLocationManager locationServicesEnabled];
    if (enabled) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        enabled = status!=kCLAuthorizationStatusRestricted && status != kCLAuthorizationStatusDenied;
    }
    return enabled;
}

+ (void)alertWhenLocationDisabled
{
    static NSTimeInterval lastAlertTime = -1;
    NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
    
    if (fabs(curTime-lastAlertTime) > kAlertInterval) {
        lastAlertTime = curTime;
    }else{
        return;
    }
    
    static _YGSettingSegue *alertDelegate;
    if (!alertDelegate) {
        alertDelegate = [_YGSettingSegue new];
    }
    
    NSString *alertStriing = @"云高需要获取您的位置，以提供更优质的服务。请开启你的定位服务。";
    if (iOS8) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:alertStriing preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"前往设置" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [alertDelegate openLocationServiceSetting];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:alertStriing delegate:alertDelegate cancelButtonTitle:@"取消" otherButtonTitles:@"前往设置", nil];
        [alertView show];
    }
}

+ (void)setMinimumAlertInterval:(NSTimeInterval )interval
{
    kAlertInterval = interval;
}

#pragma mark - Instance
+ (instancetype)shared
{
    static YGCoreLocationHelper *helper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[YGCoreLocationHelper alloc] init];
        helper.manager = [[CLLocationManager alloc] init];
        helper.manager.desiredAccuracy = kCLLocationAccuracyBest;
        helper.manager.distanceFilter = 10.f;
        helper.manager.delegate = helper;
        helper.minimumUpdateInterval = 300.f;
        helper.maximumAccuracy = kCLLocationAccuracyHundredMeters;
        helper.lastUpdateTime = -1;
    });
    return helper;
}

- (void)updateLocation:(void (^)(BOOL suc))completion
{
    NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
    if (fabs(curTime-self.lastUpdateTime) > self.minimumUpdateInterval) {
        self.lastUpdateTime = curTime;
    }else{
        return;
    }
    
    self.updateLocationCompletion = completion;
    if ([YGCoreLocationHelper isLocationServiceUsable]) {
        [self startUpdatingLocation];
        return;
    }
    BOOL notDetermined = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined;
    if (!notDetermined) {
        [YGCoreLocationHelper alertWhenLocationDisabled];
    }else if(iOS8){
        [self.manager requestWhenInUseAuthorization];
    }else{
        [self startUpdatingLocation];
    }
}

- (void)startUpdatingLocation
{
    [self.manager startUpdatingLocation];
}

#pragma mark - Delegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if ([YGCoreLocationHelper isLocationServiceUsable]) {
        [self startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *curLocation = [locations lastObject];
    if (!curLocation) return;
    
    // 百米以外的为不合格的位置
    if (curLocation.horizontalAccuracy > self.maximumAccuracy ||
        curLocation.verticalAccuracy > self.maximumAccuracy) {
        return;
    }
    
    CLGeocoder *curGeocoder = [[CLGeocoder alloc] init];
    [curGeocoder reverseGeocodeLocation:curLocation completionHandler:^(NSArray<CLPlacemark *> *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks firstObject];
        if (placemark) {
            self.address = placemark.addressDictionary;
            self.locality = placemark.locality;
        }
    }];
    
    CLLocationCoordinate2D coordinate = curLocation.coordinate;
    self.coordinate = [TQLocationConverter transformFromWGSToGCJ:coordinate];
    self.hasLocation = YES;
    
    if (self.updateLocationCompletion) {
        self.updateLocationCompletion(YES);
    }
    [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    self.hasLocation = NO;
    if (self.updateLocationCompletion) {
        self.updateLocationCompletion(NO);
    }
    [manager stopUpdatingLocation];
}

@end

