//
//  YGThirdMapApp.m
//  Golf
//
//  Created by bo wang on 2016/12/21.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGThirdMapApp.h"
#import <MapKit/MapKit.h>

@interface YGThirdMapApp ()
@property (copy, nonatomic) NSString *scheme;
@end

@implementation YGThirdMapApp

- (instancetype)initWithType:(YGMapAppType)type
{
    self = [super init];
    if (self) {
        
        NSString *name;
        NSString *scheme;
        NSString *navigateURI;
        
        switch (type) {
            case YGMapAppTypeGoogle:{
                // 文档地址 https://developers.google.com/maps/documentation/ios-sdk/urlscheme
                name = @"Google 地图";
                scheme = @"comgooglemaps://";
                navigateURI = @"comgooglemaps://x-source=golf&x-success=yungaogolf&daddr=%f,%f&directionsmode=driving&views=traffic&mapmode=standard";
            }   break;
            case YGMapAppTypeGaode:{
                // 文档地址 http://lbs.amap.com/api/uri-api/guide/ios-uri-explain/navi/
                name = @"高德地图";
                scheme = @"iosamap://";
                navigateURI = @"iosamap://navi?sourceApplication=golf&backScheme=yungaogolf&lat=%f&lon=%f&dev=0&style=2";
            }   break;
            case YGMapAppTypeBaidu:{
                // 文档地址 http://lbsyun.baidu.com/index.php?title=uri/api/ios
                name = @"百度地图";
                scheme = @"baidumap://";
                navigateURI = @"baidumap://map/navi?location=%f,%f&coord_type=gcj02&src=webapp.com.cgit.golf";
//                navigateURI = @"baidumap://map/direction?origin=%f,%f&destination=%f,%f&mode=driving&coord_type=gcj02&src=com.cgit.golf";
            }   break;
            case YGMapAppTypeApple:{
                name = @"苹果地图";
                scheme = @"";
            }   break;
            case YGMapAppTypeTencent:{
                name = @"腾讯地图";
                scheme = @"qqmap://";
                navigateURI = @"qqmap://map/routeplan?type=drive&from=我的位置&tocoord=%f,%f&to=%@&referer=golf";
            }   break;
        }
        self.mapType = type;
        self.name = name;
        self.scheme = scheme;
        self.naviURI = navigateURI;
    }
    return self;
}

- (BOOL)installed
{
    return self.scheme.length==0?YES:[[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:self.scheme]];
}

+ (NSArray<YGThirdMapApp *> *)defaultMapApps
{
    static NSArray *apps;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        apps = @[
//                 [[YGThirdMapApp alloc] initWithType:YGMapAppTypeGoogle],
                 [[YGThirdMapApp alloc] initWithType:YGMapAppTypeGaode],
                 [[YGThirdMapApp alloc] initWithType:YGMapAppTypeBaidu],
                 [[YGThirdMapApp alloc] initWithType:YGMapAppTypeApple],
                 [[YGThirdMapApp alloc] initWithType:YGMapAppTypeTencent]
                 ];
    });
    return apps;
}

- (BOOL)beginNavigate:(NSDictionary *)params
{
    NSValue *coordinateValue = params[kYGThirdMapAppParamCoordinateKey];
    id<MKAnnotation> annotation = params[kYGThirdMapAppParamAnnotationKey];
    
    CLLocationCoordinate2D coordinate = kCLLocationCoordinate2DInvalid;
    if (coordinateValue) {
        coordinate = [coordinateValue MKCoordinateValue];
    }
    if (annotation && !CLLocationCoordinate2DIsValid(coordinate)) {
        coordinate = [annotation coordinate];
    }
    if (!CLLocationCoordinate2DIsValid(coordinate)) {
        NSLog(@"坐标无效！！！");
        return NO;
    }
    
    switch (self.mapType) {
        case YGMapAppTypeGoogle:
        case YGMapAppTypeGaode:
        case YGMapAppTypeBaidu:{
            NSString *url = [NSString stringWithFormat:self.naviURI,coordinate.latitude,coordinate.longitude];
            NSURL *URL = [NSURL URLWithString:url];
            return [[UIApplication sharedApplication] openURL:URL];
        }   break;
        case YGMapAppTypeApple:{
            
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
            MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
            if (annotation) {
                mapItem.name = [annotation title];
            }
            
            NSDictionary *options = @{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving, //驾车导航
                                      MKLaunchOptionsMapTypeKey:@(MKMapTypeStandard),       //标准地图
                                      MKLaunchOptionsShowsTrafficKey:@YES};                 //显示交通状况
            return [mapItem openInMapsWithLaunchOptions:options];
            
        }   break;
        case YGMapAppTypeTencent:{
            NSString *title = annotation?[annotation title]:@"";
            NSString *url = [[NSString stringWithFormat:self.naviURI,coordinate.latitude,coordinate.longitude,title] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL *URL = [NSURL URLWithString:url];
            return [[UIApplication sharedApplication] openURL:URL];
            
        }   break;
    }
    return NO;
}

@end

NSString *const kYGThirdMapAppParamCoordinateKey = @"coordinate";
NSString *const kYGThirdMapAppParamAnnotationKey = @"annotation";
