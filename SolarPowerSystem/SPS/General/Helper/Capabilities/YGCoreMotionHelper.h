//
//  YGCoreMotionHelper.h
//  123123123123123
//
//  Created by bo wang on 16/7/20.
//  Copyright © 2016年 bo wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YGCoreMotionHelper : NSObject

// 监听的灵敏度。越小越灵敏。默认为 1.s
@property (assign, nonatomic) NSTimeInterval sensitivity;

// 当前设备的真实方向。不支持UIDeviceOrientationFaceUp和UIDeviceOrientationFaceDown
@property (assign, nonatomic) UIDeviceOrientation orientation;

// 打开Log
@property (assign, nonatomic) BOOL logEnabled;

// 开始监听设备方向变化。不管设备旋转锁是否锁定，在设备真实方向发生变化时都将发出通知
- (void)startMonitorOrientation;

// 停止监听设备方向变化
- (void)endMonitorOrientation;

@end


// object: YGCoreMotionHelper userInfo: nil
FOUNDATION_EXTERN NSString *const kYGDeviceOrientationDidChangedNotification;