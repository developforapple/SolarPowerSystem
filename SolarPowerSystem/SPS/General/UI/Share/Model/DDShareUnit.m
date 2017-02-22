//
//  DDShareUnit.m
//  QuizUp
//
//  Created by Normal on 16/4/18.
//  Copyright © 2016年 zhenailab. All rights reserved.
//

#import "DDShareUnit.h"

@implementation DDShareUnit

+ (instancetype)unitWithType:(DDShareType)type callback:(DDShareCallback)callback
{
    DDShareUnit *unit = [DDShareUnit new];
    unit->_type = type;
    unit->_callback = callback;
    
    switch (type) {
        case DDShareTypeWechatSession: {
            unit->_title = @"微信好友";
            unit->_image = [UIImage imageNamed:@"icon_share_wechat"];
            break;
        }
        case DDShareTypeWechatTimeline: {
            unit->_title = @"朋友圈";
            unit->_image = [UIImage imageNamed:@"icon_share_circle"];
            break;
        }
        case DDShareTypeQzone: {
            unit->_title = @"QQ空间";
            unit->_image = [UIImage imageNamed:@"icon_share_qzone"];
            break;
        }
        case DDShareTypeQQFriend: {
            unit->_title = @"QQ";
            unit->_image = [UIImage imageNamed:@"icon_share_qq"];
            break;
        }
        case DDShareTypeWeibo: {
            unit->_title = @"微博";
            unit->_image = [UIImage imageNamed:@"icon_share_weibo"];
            break;
        }
        case DDShareTypeEmail: {
            unit->_title = @"邮件";
            unit->_image = [UIImage imageNamed:@"icon_share_mail"];
            break;
        }
        case DDShareTypeSMS: {
            unit->_title = @"短信息";
            unit->_image = [UIImage imageNamed:@"icon_share_message"];
            break;
        }
        case DDShareActionCopy: {
            unit->_title = @"复制链接";
            unit->_image = [UIImage imageNamed:@"icon_share_link"];
            break;
        }
        
    }
    return unit;
}

+ (instancetype)unitWithTitle:(NSString *)title
                        image:(UIImage *)image
               highlightImage:(UIImage *)highlightImage
                     callback:(DDShareCallback)callback
{
    DDShareUnit *unit = [DDShareUnit new];
    unit->_title = title;
    unit->_image = image;
    unit->_highlightImage = highlightImage;
    unit->_callback = callback;
    return unit;
}

@end

@implementation DDShareUnit (BuildIn)

+ (NSArray<DDShareUnit *> *)createBuildInUnits:(DDShareBuildInUnitCallback)unitCallback
{
    static NSArray *units;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        units = @[[self unitWithType:DDShareTypeWechatSession callback:nil],
                  [self unitWithType:DDShareTypeWechatTimeline callback:nil],
//                  [self unitWithType:DDShareTypeQQFriend callback:nil],
                  [self unitWithType:DDShareTypeWeibo callback:nil],
                  [self unitWithType:DDShareTypeEmail callback:nil],
                  [self unitWithType:DDShareTypeSMS callback:nil],
                  [self unitWithType:DDShareActionCopy callback:nil]];
    });
    for (DDShareUnit *unit in units) {
        DDShareType type = unit.type;
        [unit setCallback:^{
            unitCallback?unitCallback(type):0;
        }];
    }
    return units;
}

@end
