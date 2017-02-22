//
//  DDSocialSharing.m
//  QuizUp
//
//  Created by Normal on 16/4/18.
//  Copyright © 2016年 zhenailab. All rights reserved.
//

#import "DDSocialPlatform.h"
#import "Share.h"

@implementation DDSocialPlatform

+ (void)shareContentToPlatform:(DDShareType)type
                       content:(DDSocialSharedContent *)content
{
    switch (type) {
        case DDShareTypeWechatSession: {
            Share *share = [[Share alloc] initWithTitle:content.title content:content.content image:content.image url:content.url scene:WXSceneSession];
            share.type = content.type;
            [share sendMsgToWX];
            break;
        }
        case DDShareTypeWechatTimeline: {
            Share *share = [[Share alloc] initWithTitle:content.title content:content.content image:content.image url:content.url scene:WXSceneTimeline];
            share.type = content.type;
            share.isSplit = content.isSplit;
            [share sendMsgToWX];
            break;
        }
        case DDShareTypeQzone: {
            
            break;
        }
        case DDShareTypeQQFriend: {
            
            break;
        }
        case DDShareTypeWeibo: {
            Share *share = [Share new];
            share.title = content.title;
            share.content = content.content;
            share.image = content.image;
            share.url = content.url;
            
            // 采用下面的方法会缩放图片。导致分享到微博的图片不清楚。
//            Share *share = [[Share alloc] initWithTitle:content.title content:content.content image:content.image url:content.url scene:kNilOptions];
            [share sendMsgToWB];
            break;
        }
        default:break;
    }
}

@end

@implementation DDSocialSharedContent
@end
