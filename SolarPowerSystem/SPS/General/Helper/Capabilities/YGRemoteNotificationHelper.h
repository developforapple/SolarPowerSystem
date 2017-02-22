//
//  YGRemoteNotificationHelper.h
//  Golf
//
//  Created by bo wang on 2016/9/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, YGNotificaitonType) {
    YGNotificaitonTypeNone = 0,
    YGNotificaitonTypeBadge = 1 << 0,
    YGNotificaitonTypeSound = 1 << 1,
    YGNotificaitonTypeAlert = 1 << 2,
};
#define YGNotificationTypeAll (YGNotificaitonTypeBadge | YGNotificaitonTypeSound | YGNotificaitonTypeAlert)

// 兼容iOS7~iOS10的远程通知单例
@interface YGRemoteNotificationHelper : NSObject

+ (instancetype)shared;

// 需要在 applicationDidFinishLaunching: 返回之前做一些设置
- (void)setup:(nullable NSDictionary *)launchOptions;

// 设置接收到deviceToken时的操作
- (void)setDeviceTokenDidReceivedCompletionHandler:(nullable void (^)(NSString *_Nullable str))completionHandler;
// 收到远程通知时的处理操作。
- (void)setDidReceiveRemoteNotificationHandler:(nullable void (^)(NSDictionary *_Nullable userInfo))handler;
// 收到本地通知时的处理操作
- (void)setDidReceiveLocalNotificationHandler:(void (^)(UILocalNotification *noti))handler;

@property (strong, nullable, readonly, nonatomic) NSData *deviceToken;
@property (strong, nullable, readonly, nonatomic) NSString *deviceTokenStr;
@property (strong, nullable, readonly, nonatomic) NSError *error;

#pragma mark - APNS
// 向APNS注册远程通知，获取DeviceToken。在iOS7下，获取deviceToken将会在registerNotificationType中进行。
- (void)registerRemoteNotificaitons;
// 向APNS取消注册远程通知
- (void)unregisterRemoteNotifications;
// APNS返回了deviceToken或者失败时调用
- (void)didReceiveDeviceToken:(nullable NSData *)data orError:(nullable NSError *)error;
// 是否已向APNS注册了远程通知
- (BOOL)isRegisteredForRemoteNotifications;

#pragma mark - Settings
// 设置应用Icon的角标数字。0为隐藏。在iOS8以后需要注册settings来修改数字
- (void)setIconBadgeNumber:(NSUInteger)number;
// 注册通知类型。如果没有向APNS注册过，将自动向APNS注册。
- (void)registerNotificationType:(YGNotificaitonType)type;
// 单种通知类型是否可用。如果未注册过或者未取得权限，返回不可用。iOS10之前block同步调用，iOS10及以后block异步调用
- (void)isNotificationTypeEnabled:(YGNotificaitonType)type completion:(void(^)(BOOL enabled))completion;

#pragma mark - Notification
// 接收到远程通知
- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nullable void (^)(UIBackgroundFetchResult))completionHandler;

@end

@interface GolfAppDelegate (YGNotification)
@end

NS_ASSUME_NONNULL_END
