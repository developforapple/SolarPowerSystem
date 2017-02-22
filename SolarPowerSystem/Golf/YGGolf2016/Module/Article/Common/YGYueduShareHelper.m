//
//  YGYueduShareHelper.m
//  Golf
//
//  Created by bo wang on 16/6/24.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGYueduShareHelper.h"
#import "YGYueduCommon.h"
#import "DDShareCommon.h"
#import "YGShareViewCtrl.h"
#import "YGArticlePostEditingViewCtrl.h"
#import "DDSocialPlatform.h"
#import "YYWebImage.h"
#import "UIImage+YYAdd.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>

typedef NS_ENUM(NSUInteger, _YGShareComposeResult) {
    _YGShareComposeResultCancel,    //取消
    _YGShareComposeResultSuccess,   //成功
    _YGShareComposeResultFailed,    //失败
    _YGShareComposeResultSaved,     //已保存。用于邮件。
};

typedef void(^_YGShareComposeCallback)(_YGShareComposeResult result);

@interface _YGShareDelegate : NSObject<MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate>
+ (instancetype)instance;
+ (instancetype)instanceWithCallback:(_YGShareComposeCallback)callback;
@property (copy, nonatomic) _YGShareComposeCallback callback;
@end

@implementation _YGShareDelegate
+ (instancetype)instance
{
    static _YGShareDelegate *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [_YGShareDelegate new];
    });
    return instance;
}

+ (instancetype)instanceWithCallback:(_YGShareComposeCallback)callback
{
    _YGShareDelegate *instance = [self instance];
    instance.callback = callback;
    return instance;
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    if (self.callback) {
        switch (result) {
            case MessageComposeResultCancelled: {
                [SVProgressHUD showImage:nil status:@"已取消"];
                self.callback(_YGShareComposeResultCancel);
                break;
            }
            case MessageComposeResultSent: {
                [SVProgressHUD showImage:nil status:@"已发送"];
                self.callback(_YGShareComposeResultSuccess);
                break;
            }
            case MessageComposeResultFailed: {
                [SVProgressHUD showImage:nil status:@"发送失败"];
                self.callback(_YGShareComposeResultFailed);
                break;
            }
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    if (self.callback) {
        switch (result) {
            case MFMailComposeResultCancelled: {
                [SVProgressHUD showImage:nil status:@"已取消"];
                self.callback(_YGShareComposeResultCancel);
                break;
            }
            case MFMailComposeResultSaved: {
                [SVProgressHUD showImage:nil status:@"已保存到草稿"];
                self.callback(_YGShareComposeResultSaved);
                break;
            }
            case MFMailComposeResultSent: {
                [SVProgressHUD showImage:nil status:@"已发送"];
                self.callback(_YGShareComposeResultSuccess);
                break;
            }
            case MFMailComposeResultFailed: {
                [SVProgressHUD showImage:nil status:@"发送失败"];
                self.callback(_YGShareComposeResultFailed);
                break;
            }
        }
    }
}

@end

@implementation YGYueduShareHelper

+ (void)shareArticle:(YueduArticleBean *)article
             content:(NSString *)content
  fromViewController:(UIViewController *)vc
{
    NSArray *units = [DDShareUnit createBuildInUnits:^(DDShareType type) {
        
        YueduArticleBean *articleBean = article;
        
        YueduArticleImageBean *imageBean = [articleBean.pictures firstObject];
        UIImage *cachedImage = [[YYImageCache sharedCache] getImageForKey:[[YYWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:imageBean.name]]];
        if (!cachedImage) {
            cachedImage = [UIImage imageNamed:@"AppIcon"];//默认图片
        }
        
        NSString *shareURL = [NSString stringWithFormat:@"%@/article?articleId=%@",URL_SHARE_YUEDU,articleBean.idStr];
        
        NSString *shareContentText = content.length==0?@"连接高尔夫的一切":content;
        
        switch (type) {
            case DDShareTypeWechatSession:
            case DDShareTypeWechatTimeline:
            case DDShareTypeQzone:
            case DDShareTypeQQFriend:
            case DDShareTypeWeibo: {
                DDSocialSharedContent *shareContent = [DDSocialSharedContent new];
                shareContent.title = articleBean.name;
                shareContent.content = shareContentText;
                shareContent.image = cachedImage;
                shareContent.url = shareURL;
                [DDSocialPlatform shareContentToPlatform:type content:shareContent];
                break;
            }
            case DDShareTypeEmail: {
                if (![MFMailComposeViewController canSendMail]) {
                    [SVProgressHUD showInfoWithStatus:@"无法发送邮件"];
                }else{
                    NSString *body = [NSString stringWithFormat:@"%@  详情请点击：%@",shareContentText,shareURL];
                    MFMailComposeViewController *emailVC = [[MFMailComposeViewController alloc] init];
                    emailVC.mailComposeDelegate = [_YGShareDelegate instanceWithCallback:^(_YGShareComposeResult result) {
                        
                    }];
                    [emailVC setSubject:articleBean.name];
                    [emailVC setMessageBody:body isHTML:YES];
                    [vc presentViewController:emailVC animated:YES completion:nil];
                }
                break;
            }
            case DDShareTypeSMS: {
                if (![MFMessageComposeViewController canSendText]) {
                    [SVProgressHUD showInfoWithStatus:@"无法发送短信"];
                }else{
                    NSString *body = [NSString stringWithFormat:@"【云高头条Golf】%@  详情请点击：%@",articleBean.name,shareURL];
                    MFMessageComposeViewController *msgVC = [[MFMessageComposeViewController alloc] init];
                    msgVC.body = body;
                    msgVC.messageComposeDelegate = [_YGShareDelegate instanceWithCallback:^(_YGShareComposeResult result) {
                        
                    }];
                    [vc presentViewController:msgVC animated:YES completion:nil];
                }
                break;
            }
            case DDShareActionCopy: {
                [[UIPasteboard generalPasteboard] setURL:[NSURL URLWithString:shareURL]];
                [SVProgressHUD showInfoWithStatus:@"链接已复制"];
                break;
            }
        }
        // 分享的埋点统计
        YGPostBuriedPoint(YGYueduStatistics_ShareSocial);
        YGRecordEvent(YueduEvent_ShareSocial,nil);
    }];
    
    YGShareViewCtrl *shareVC = [YGShareViewCtrl instanceFromStoryboard];
    [shareVC setBlurReferView:vc.view.window];
    shareVC.shareUnits = units;
    [shareVC setYungaoCommunityVisible:YES callback:^{
        
        void (^begin)(void) = ^{
            YGArticlePostEditingViewCtrl *post = [YGArticlePostEditingViewCtrl instanceFromStoryboard];
            post.article = article;
            [vc.navigationController pushViewController:post animated:YES];
            YGRecordEvent(YueduEvent_ShareFeed, nil);
        };
        
        // 发布动态需要登录
        if (![LoginManager sharedManager].loginState) {
            [[LoginManager sharedManager] loginWithDelegate:nil controller:vc animate:YES blockRetrun:^(id data) {
                begin();
            }];
        }else{
            begin();
        }
    }];
    [shareVC show];
}

+ (void)shareAlbum:(YueduAlbumBean *)album
           content:(NSString *)content
fromViewController:(UIViewController *)vc
{
    NSArray *units = [DDShareUnit createBuildInUnits:^(DDShareType type) {
        
        NSString *shareURL = [NSString stringWithFormat:@"%@/album?albumId=%@",URL_SHARE_YUEDU,album.idStr];
        
        switch (type) {
            case DDShareTypeWechatSession:
            case DDShareTypeWechatTimeline:
            case DDShareTypeQzone:
            case DDShareTypeQQFriend: 
            case DDShareTypeWeibo: {
                UIImage *cachedImage = [[YYImageCache sharedCache] getImageForKey:[[YYWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:album.cover.name]]];
                if (!cachedImage) {
                    cachedImage = [UIImage imageNamed:@"logo"];
                }
                DDSocialSharedContent *shareContent = [DDSocialSharedContent new];
                shareContent.title = [NSString stringWithFormat:@"专题：%@",album.name];
                shareContent.content = content?:album.des;
                shareContent.image = cachedImage;
                shareContent.url = shareURL;
                [DDSocialPlatform shareContentToPlatform:type content:shareContent];
                break;
            }
            case DDShareTypeEmail: {
                if (![MFMailComposeViewController canSendMail]) {
                    [SVProgressHUD showInfoWithStatus:@"无法发送邮件"];
                }else{
                    NSString *body = [NSString stringWithFormat:@"%@  详情请点击：%@",content?:album.des?:@"",shareURL];
                    MFMailComposeViewController *emailVC = [[MFMailComposeViewController alloc] init];
                    emailVC.mailComposeDelegate = [_YGShareDelegate instanceWithCallback:^(_YGShareComposeResult result) {
                        
                    }];
                    [emailVC setSubject:album.name];
                    [emailVC setMessageBody:body isHTML:YES];
                    [vc presentViewController:emailVC animated:YES completion:nil];
                }
                break;
            }
            case DDShareTypeSMS: {
                if (![MFMessageComposeViewController canSendText]) {
                    [SVProgressHUD showInfoWithStatus:@"无法发送短信"];
                }else{
                    NSString *body = [NSString stringWithFormat:@"【云高头条Golf】%@  详情请点击：%@",content?:album.name,shareURL];
                    MFMessageComposeViewController *msgVC = [[MFMessageComposeViewController alloc] init];
                    msgVC.body = body;
                    msgVC.messageComposeDelegate = [_YGShareDelegate instanceWithCallback:^(_YGShareComposeResult result) {
                        
                    }];
                    [vc presentViewController:msgVC animated:YES completion:nil];
                }
                break;
            }
            case DDShareActionCopy: {
                [[UIPasteboard generalPasteboard] setURL:[NSURL URLWithString:shareURL]];
                [SVProgressHUD showInfoWithStatus:@"链接已复制"];
                break;
            }
        }
        
    }];
    
    YGShareViewCtrl *shareVC = [YGShareViewCtrl instanceFromStoryboard];
    [shareVC setBlurReferView:vc.view.window];
    shareVC.shareUnits = units;
    [shareVC setYungaoCommunityVisible:YES callback:^{
        
        void (^begin)(void) = ^{
            YGArticlePostEditingViewCtrl *post = [YGArticlePostEditingViewCtrl instanceFromStoryboard];
            post.album = album;
            [vc.navigationController pushViewController:post animated:YES];
            YGRecordEvent(YueduEvent_ShareFeed, nil);
        };
        
        // 发布动态需要登录
        if (![LoginManager sharedManager].loginState) {
            [[LoginManager sharedManager] loginWithDelegate:nil controller:vc animate:YES blockRetrun:^(id data) {
                begin();
            }];
        }else{
            begin();
        }
    }];
    [shareVC show];
}

@end
