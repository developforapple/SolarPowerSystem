//
//  YGRemoteNotificationHelper.m
//  Golf
//
//  Created by bo wang on 2016/9/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGRemoteNotificationHelper.h"
#import <UserNotifications/UserNotifications.h>
#import <PINCache/PINCache.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"

#define UNCenter [UNUserNotificationCenter currentNotificationCenter]

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wunused-function"
NS_INLINE UNAuthorizationOptions type_iOS10_And_Later(YGNotificaitonType type){
    return (UNAuthorizationOptions)type;
}
#pragma clang diagnostic pop

NS_INLINE UIUserNotificationType type_iOS8_And_iOS9(YGNotificaitonType type){
    return (UIUserNotificationType)type;
}

NS_INLINE UIRemoteNotificationType type_iOS7_And_Earlier(YGNotificaitonType type){
    return (UIRemoteNotificationType)type;
}

@interface YGRemoteNotificationHelper () <UNUserNotificationCenterDelegate>
{
    BOOL _registerRemoteNotificaitonsFlag;
}
@property (strong, readwrite, nonatomic) NSData *deviceToken;
@property (strong, readwrite, nonatomic) NSString *deviceTokenStr;
@property (strong, readwrite, nonatomic) NSError *error;

@property (copy, nonatomic) void (^didReceivedDeviceTokenCompletionHandler)(NSString *deviceTokenStr);
@property (copy, nonatomic) void (^didReceivedRemoteNotificationHandler)(NSDictionary *userInfo);
@property (copy, nonatomic) void (^didReceivedLocalNotificationHandler)(UILocalNotification *noti);
@end

@implementation YGRemoteNotificationHelper

+ (instancetype)shared
{
    static YGRemoteNotificationHelper *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [YGRemoteNotificationHelper new];
    });
    return instance;
}

- (void)setup:(NSDictionary *)launchOptions
{
    if (iOS10) {
        [UNCenter setDelegate:self];
    }
    
    if (launchOptions) {
        NSDictionary *remoteInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        UILocalNotification *localInfo = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
        
        if (remoteInfo) {
            [self didReceiveRemoteNotification:remoteInfo fetchCompletionHandler:nil];
        }
        if (localInfo) {
            [self didReceiveLocalNotification:localInfo];
        }
    }
}

- (void)setDeviceTokenDidReceivedCompletionHandler:(void (^)(NSString *str))completionHandler
{
    self.didReceivedDeviceTokenCompletionHandler = completionHandler;
}

- (void)setDidReceiveRemoteNotificationHandler:(nullable void (^)(NSDictionary *userInfo))handler
{
    self.didReceivedRemoteNotificationHandler = handler;
}

- (void)setDidReceiveLocalNotificationHandler:(void (^)(UILocalNotification *noti))handler
{
    self.didReceivedLocalNotificationHandler = handler;
}

#pragma mark - APNS
- (void)registerRemoteNotificaitons
{
    if (iOS8) {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    _registerRemoteNotificaitonsFlag = YES;
}

- (void)unregisterRemoteNotifications
{
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    _registerRemoteNotificaitonsFlag = NO;
}

- (void)didReceiveDeviceToken:(NSData *)data orError:(NSError *)error
{
    if (data) {
        self.deviceToken = data;
    
        const char *dataBytes = [data bytes];
        NSMutableString *string = [NSMutableString string];
        for (int i=0; i<data.length; i++) {
            [string appendFormat:@"%02.2hhx",dataBytes[i]];
        }
        self.deviceTokenStr = string;
        
        [[PINCache sharedCache] setObject:string forKey:WKDeviceTokenKey];
        
    }else{
        self.error = error;
    }
    if (self.didReceivedDeviceTokenCompletionHandler) {
        self.didReceivedDeviceTokenCompletionHandler(self.deviceTokenStr);
    }
}

- (BOOL)isRegisteredForRemoteNotifications
{
    return [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
}

#pragma mark - Settings
- (void)setIconBadgeNumber:(NSUInteger)number
{
    if (iOS8) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:number];
}

- (void)registerNotificationType:(YGNotificaitonType)type
{
    if (!_registerRemoteNotificaitonsFlag) {
        [self registerRemoteNotificaitons];
    }
    
    if (iOS10) {
        UNAuthorizationOptions options = 0;
        if (type & YGNotificaitonTypeBadge) {
            options |= UNAuthorizationOptionBadge;
        }
        if (type & YGNotificaitonTypeAlert) {
            options |= UNAuthorizationOptionAlert;
        }
        if (type & YGNotificaitonTypeSound) {
            options |= UNAuthorizationOptionSound;
        }
        [UNCenter requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError *error) {
            self.error = error;
        }];
    }else if (iOS8){
        UIUserNotificationType settingsType = type_iOS8_And_iOS9(type);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:settingsType categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }else{
        UIRemoteNotificationType remoteType = type_iOS7_And_Earlier(type);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:remoteType];
    }
}

- (void)isNotificationTypeEnabled:(YGNotificaitonType)type completion:(void(^)(BOOL enabled))completion
{
    if (!completion) return;
    
    if (iOS10) {
        [UNCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
            BOOL enabled = NO;
            switch (type) {
                case YGNotificaitonTypeNone:break;
                case YGNotificaitonTypeBadge: enabled = (settings.badgeSetting==UNNotificationSettingEnabled);break;
                case YGNotificaitonTypeSound: enabled = (settings.soundSetting==UNNotificationSettingEnabled);break;
                case YGNotificaitonTypeAlert: enabled = (settings.alertSetting==UNNotificationSettingEnabled);break;
            }
            completion(enabled);
        }];
    }else if(iOS8){
        UIUserNotificationSettings *settings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        BOOL enabled = NO;
        switch (type) {
            case YGNotificaitonTypeNone:break;
            case YGNotificaitonTypeBadge: enabled = (settings.types&UIUserNotificationTypeBadge);break;
            case YGNotificaitonTypeSound: enabled = (settings.types&UIUserNotificationTypeSound);break;
            case YGNotificaitonTypeAlert: enabled = (settings.types&UIUserNotificationTypeAlert);break;
        }
        completion(enabled);
    }else{
        UIRemoteNotificationType remoteType = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        BOOL enabled = NO;
        switch (type) {
            case YGNotificaitonTypeNone:break;
            case YGNotificaitonTypeBadge: enabled = (remoteType&UIRemoteNotificationTypeBadge);break;
            case YGNotificaitonTypeSound: enabled = (remoteType&UIRemoteNotificationTypeSound);break;
            case YGNotificaitonTypeAlert: enabled = (remoteType&UIRemoteNotificationTypeAlert);break;
        }
        completion(enabled);
    }
}

#pragma marl - Notification
- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nullable void (^)(UIBackgroundFetchResult))completionHandler
{
    if (self.didReceivedRemoteNotificationHandler) {
        self.didReceivedRemoteNotificationHandler(userInfo);
    }
    if (completionHandler) completionHandler(UIBackgroundFetchResultNewData);
}

- (void)didReceiveLocalNotification:(UILocalNotification *)noti
{
    if (self.didReceivedLocalNotificationHandler) {
        self.didReceivedLocalNotificationHandler(noti);
    }
}

#pragma mark - UNCenter Delegate
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler
{
    [[YGRemoteNotificationHelper shared] didReceiveRemoteNotification:response.notification.request.content.userInfo fetchCompletionHandler:^(UIBackgroundFetchResult result) {
        completionHandler();
    }];
}

@end

#pragma mark - AppDelegate
@implementation GolfAppDelegate (YGNotification)
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[YGRemoteNotificationHelper shared] didReceiveDeviceToken:deviceToken orError:nil];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [[YGRemoteNotificationHelper shared] didReceiveDeviceToken:nil orError:error];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[YGRemoteNotificationHelper shared] didReceiveRemoteNotification:userInfo fetchCompletionHandler:nil];
}

// iOS10开始，推送不调用这里
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [[YGRemoteNotificationHelper shared] didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [[YGRemoteNotificationHelper shared] didReceiveLocalNotification:notification];
}

@end

#pragma clang diagnostic pop
