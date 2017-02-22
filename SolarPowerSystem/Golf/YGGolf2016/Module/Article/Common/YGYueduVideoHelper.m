//
//  YGYueduVideoHelper.m
//  Golf
//
//  Created by bo wang on 16/8/10.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGYueduVideoHelper.h"
#import "DDWebInspector.h"
#import "Player.h"

@implementation YGYueduVideoHelper

+ (void)playVideo:(NSString *)videoURL
         isWebURL:(BOOL)isWebURL
fromViewController:(__weak UIViewController *)vc
       completion:(void (^)(BOOL suc,NSString *msg))completion
{
    void (^startPlay)(NSString *url) = ^(NSString *url){
        if (!url || url.length == 0) return;
        // 使用应用原来的播放器
        Player *player = [Player playWithUrl:url rt:CGRectMake(0, 0, Device_Width, 160) supportSlowed:YES supportCircle:NO vc:nil completion:nil];
        player.modalTransitionStyle = UIModalTransitionStyleCrossDissolve; //这个效果比较柔和。
        [vc presentViewController:player animated:YES completion:nil];
    };
    
    if (isWebURL) {
        [self getVideoPlayableRemoteURL:videoURL completion:^(BOOL suc, NSString *url) {
            if (suc) {
                startPlay(url);
            }
            completion?completion(suc,url):0;
        }];
    }else{
        startPlay(videoURL);
        completion?completion(YES,nil):0;
    }
}

+ (void)getVideoPlayableRemoteURL:(NSString *)originURL
                       completion:(void (^)(BOOL,NSString *))completion
{
    if (!completion)return;
    
    NSString *jsCode = @"document.querySelector(\"video\").src";
    [[DDWebInspector shared] inspectionURL:originURL
                              infuseJSCode:jsCode
                               executeCode:nil
                                completion:^(BOOL suc, id object) {
                                    BOOL success = suc;
                                    NSString *content = object;
                                    if (success) {
                                        if (![object isKindOfClass:[NSString class]] || [object length] == 0) {
                                            success = NO;
                                            content = @"网络连接失败，请重新加载";
                                        }else{
                                            NSURL *URL = [NSURL URLWithString:object];
                                            if (!URL || ![[UIApplication sharedApplication] canOpenURL:URL]) {
                                                success = NO;
                                                content = @"无效的链接";
                                            }
                                        }
                                    }
                                    completion(success,content);
                                }];
}

@end
