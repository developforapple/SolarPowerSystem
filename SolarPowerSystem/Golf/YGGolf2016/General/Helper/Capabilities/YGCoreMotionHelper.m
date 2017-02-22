//
//  YGCoreMotionHelper.m
//  123123123123123
//
//  Created by bo wang on 16/7/20.
//  Copyright © 2016年 bo wang. All rights reserved.
//

#import "YGCoreMotionHelper.h"
#import <CoreMotion/CoreMotion.h>

@interface YGCoreMotionHelper ()
@property (strong, nonatomic) CMMotionManager *manager;
@end

@implementation YGCoreMotionHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.orientation = UIDeviceOrientationUnknown;
        self->_sensitivity = 1.f;
    }
    return self;
}

- (void)setSensitivity:(NSTimeInterval)sensitivity
{
    _sensitivity = MAX(0, sensitivity);
    self.manager.deviceMotionUpdateInterval = _sensitivity;
}

- (CMMotionManager *)manager
{
    if (!_manager) {
        _manager = [[CMMotionManager alloc] init];
    }
    return _manager;
}

- (void)startMonitorOrientation
{
    __weak typeof(self) weakSelf = self;
    self.manager.deviceMotionUpdateInterval = _sensitivity;
    [self.manager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        double x = motion.gravity.x;
        double y = motion.gravity.y;
        
        if (self.logEnabled) {
            NSLog(@"x:%.2f y:%.2f",x,y);
        }
        
        if (fabs(x) < .2f && fabs(y) < .2f) {
            return;
        }
        
        UIDeviceOrientation orientation = UIDeviceOrientationUnknown;
        
        if (fabs(y) >= fabs(x)){
            orientation = y>=0?UIDeviceOrientationPortraitUpsideDown:UIDeviceOrientationPortrait;
            
            if (self.logEnabled) {
                if (y >= 0){
                    NSLog(@"PortraitUpsideDown");
                }else{
                    NSLog(@"Portrait");
                }
            }
        }else{
            orientation = x>=0?UIDeviceOrientationLandscapeRight:UIDeviceOrientationLandscapeLeft;
            if (self.logEnabled) {
                if (x >= 0){
                    NSLog(@"LandscapeRight");
                } else{
                    NSLog(@"LandscapeLeft");
                }
            }
        }
        if (strongSelf.orientation != orientation) {
            strongSelf.orientation = orientation;
            [strongSelf postNotification];
        }
    }];
}

- (void)endMonitorOrientation
{
    [self.manager stopDeviceMotionUpdates];
}

- (void)postNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kYGDeviceOrientationDidChangedNotification object:self];
}

@end

NSString *const kYGDeviceOrientationDidChangedNotification = @"YGDeviceOrientationDidChangedNotification";
