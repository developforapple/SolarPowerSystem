//
//  DDSocialSharing.h
//  QuizUp
//
//  Created by Normal on 16/4/18.
//  Copyright © 2016年 zhenailab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDShareCommon.h"

@class DDSocialSharedContent;

// 处理社交平台分享
@interface DDSocialPlatform : NSObject

/*!
 *  @author bo wang, 16-05-30 18:05:53
 *
 *  @brief 分享内容到社交平台
 *
 *  @param type       平台类型
 *  @param content    内容
 *
 *  @since 6.50
 */
+ (void)shareContentToPlatform:(DDShareType)type
                       content:(DDSocialSharedContent *)content;

@end


@interface DDSocialSharedContent : NSObject
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *url;

// 我也不知道代表什么意思
@property (assign, nonatomic) int type;
@property (assign, nonatomic) BOOL isSplit;
@end