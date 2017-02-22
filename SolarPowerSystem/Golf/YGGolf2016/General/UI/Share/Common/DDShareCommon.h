//
//  DDShareCommon.h
//  QuizUp
//
//  Created by Normal on 16/4/18.
//  Copyright © 2016年 zhenailab. All rights reserved.
//

#ifndef DDShareCommon_h
#define DDShareCommon_h

// 内置的分享单元类型
typedef NS_ENUM(NSUInteger, DDShareType) {
    // SocialSharing
    DDShareTypeWechatSession,       //微信好友
    DDShareTypeWechatTimeline,      //微信朋友圈
    DDShareTypeQzone,               //QQ空间
    DDShareTypeQQFriend,            //QQ好友
    DDShareTypeWeibo,               //微博
    
    // Message
    DDShareTypeEmail,               //邮件
    DDShareTypeSMS,                 //信息
    
    // ShareActions
    DDShareActionCopy = 100,        //复制
};

NS_INLINE BOOL isSocialSharing(DDShareType type){
    return  type <= DDShareTypeWeibo;
}

@protocol DDShareContentProtocol <NSObject>
@required
- (NSURL *)dd_shareURL;
- (NSString *)dd_shareTitle;
- (NSString *)dd_shareContent;
- (UIImage *)dd_shareImage;
@end

#endif /* DDShareCommon_h */
