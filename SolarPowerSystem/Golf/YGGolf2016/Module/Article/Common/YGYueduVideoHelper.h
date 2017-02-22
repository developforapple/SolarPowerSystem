//
//  YGYueduVideoHelper.h
//  Golf
//
//  Created by bo wang on 16/8/10.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YGYueduVideoHelper : NSObject

/*!
 *  @brief 播放悦读的视频链接
 *
 *  @param videoURL   视频链接
 *  @param isWebURL   这个链接是否是一个网页
 *  @param vc         打开视频的控制器
 *  @param completion 回调。suc,操作是否完成。msg，成功时为url，失败时为错误信息。
 */
+ (void)playVideo:(NSString *)videoURL
         isWebURL:(BOOL)isWebURL
fromViewController:(__weak UIViewController *)vc
       completion:(void (^)(BOOL suc,NSString *msg))completion;

@end
