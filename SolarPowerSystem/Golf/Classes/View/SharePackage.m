//
//  SharePackage.m
//  Eweek
//
//  Created by user on 13-9-17.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import "SharePackage.h"
#import "Share.h"
#import "ServiceManager.h"
#import "YGShareViewCtrl.h"
#import "DDSocialPlatform.h"
#import "YGShareSMSViewCtrl.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>

static int lockShare = 1;

@interface SharePackage()<YGLoginViewCtrlDelegate,ServiceManagerDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate>
@property (nonatomic)int loginTag;
@property (copy, nonatomic) void (^shareActioCallback)(DDShareType type);

@end

@implementation SharePackage

- (id)initWithTitle:(NSString*)title content:(NSString*)content img:(UIImage*)img url:(NSString*)url{
    self = [super init];
    if (self) {
        if (img) {
            img = [Utilities scaleToSize:img size:CGSizeMake(100, 100)];
        }
        self.shareTitle = title;
        self.shareContent = content;
        self.shareImg = img;
        self.shareUrl = url;
        self.isShowView = NO;
    }
    return self;
}

- (void)setIsShowCommuty:(BOOL)isShowCommuty{
    if (isShowCommuty) {
        UIButton *communty = (UIButton*)[sharePanal viewWithTag:7];
        communty.hidden = NO;
        
        UILabel *com = (UILabel*)[sharePanal viewWithTag:77];
        com.hidden = NO;
    }
}

- (void)loginButtonPressed:(id)sender{
    if (self.loginTag==1) {
        self.loginTag=0;
        [self shareInfoForView:nil];
    }
}

- (void)shareInfoForView:(UIView*)view
{
    [self shareInfoForView:view callback:nil];
}

- (void)shareInfoForView:(UIView *)view callback:(void (^)(DDShareType))callback
{
    self.shareActioCallback = callback;
    
    if (![LoginManager sharedManager].loginState&&[GolfAppDelegate shareAppDelegate].autoLogIn) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *groupData = [userDefault objectForKey:KGroupData];
        if ((groupData&&groupData.length>0) || ([userDefault objectForKey:KGolfSessionPhone]&&[userDefault objectForKey:KGolfUserPassword])) {
            self.loginTag=1;
//            [[LoginManager sharedManager] autoLoginInBackground:self completion:nil];
            [[LoginManager sharedManager] autoLoginInBackground:self success:nil failure:nil];
            return;
        }
    }
    
    ygweakify(self);
    
    NSArray *units = [DDShareUnit createBuildInUnits:^(DDShareType type) {
        ygstrongify(self);
        [self handleShareActionOfType:type];
    }];
    
    YGShareViewCtrl *vc = [YGShareViewCtrl instanceFromStoryboard];
    [vc setBlurReferView:view.window];
    [vc setShareUnits:units];
    
    if (self.isInviteNewUser) {
        self.inviteNewUserYunbi = [GolfAppDelegate shareAppDelegate].systemParamInfo.inviteNewUserYunbi;
        if (self.inviteNewUserYunbi > 0){
            self.inviteNewUserNote = [GolfAppDelegate shareAppDelegate].systemParamInfo.inviteNewUserNote;
            self.shareUrlTem = self.shareUrl;
            
            YGShareNoteInfo *noteInfo = [[YGShareNoteInfo alloc] initWithType:YGShareNoteTypeInvite desc:self.inviteNewUserNote];
            vc.noteInfo = noteInfo;
        }
    }else if ([self isActivities]){
        YGShareNoteType type = self.isInviteFriend?YGShareNoteTypeInvite:YGShareNoteTypeShare;
        YGShareNoteInfo *noteInfo = [[YGShareNoteInfo alloc] initWithType:type desc:self.shareTopicNote];
        vc.noteInfo = noteInfo;
    }
    
    [vc show];
}


- (void)handleShareActionOfType:(DDShareType)type
{
    //分享埋点
    [[API shareInstance] statisticalNewWithBuriedpoint:20 objectID:[NSString stringWithFormat:@"%d",_activityID] Success:nil failure:nil];
    
    if (self.shareActioCallback) {
        self.shareActioCallback(type);
    }
    
    if (isSocialSharing(type)) {
        
        DDSocialSharedContent *content = [[DDSocialSharedContent alloc] init];
        content.type = self.type;
        
        if (type == DDShareTypeWechatTimeline) {
            NSString *stringC;
            NSString *stringT;
            if (!_isInviteFriend && !_isInviteNewUser) {
                if (_circleOfFriendsString.length > 0) {
                    stringT = @" ";
                    stringC = _circleOfFriendsString;
                } else {
                    stringT=_shareTitle;
                    stringC=_shareContent;
                }
            }else{
                if (_circleOfFriendsString.length > 0) {
                    stringT = @" ";
                    stringC = _circleOfFriendsString;
                } else {
                    stringC=@" ";
                    stringT=[NSString stringWithFormat:@"分享高尔夫话题：%@",_shareTitle];
                }
            }
            content.title = stringT;
            content.content = stringC;
            content.image = _shareImg;
            content.url = _shareUrl?:_shareUrlTem;
            content.isSplit = self.isSplit;
        }else{
            content.title = _shareTitle;
            content.content = _shareContent;
            content.image = _shareImg;
            content.url = _shareUrl?:_shareUrlTem;
        }
        
        [DDSocialPlatform shareContentToPlatform:type content:content];
        
    }else{
        switch (type) {
            case DDShareTypeWechatSession:{break;}
            case DDShareTypeWechatTimeline:{break;}
            case DDShareTypeQzone:{break;}
            case DDShareTypeQQFriend:{break;}
            case DDShareTypeWeibo:{break;}
            case DDShareTypeEmail: {
                [self displayMailComposerSheet];
                break;
            }
            case DDShareTypeSMS: {
                [self sendSMS];
                break;
            }
            case DDShareActionCopy: {
                if (self.shareUrlTem.length > 0) {
                    [[UIPasteboard generalPasteboard] setString:self.shareUrlTem];
                    [SVProgressHUD showSuccessWithStatus:@"复制成功!"];
                }else if (self.shareContent.length > 0){
                    [[UIPasteboard generalPasteboard] setString:self.shareContent];
                    [SVProgressHUD showSuccessWithStatus:@"复制成功!"];
                }
                break;
            }
        }
    }
    
    if (type <= DDShareTypeSMS && self.willSendToBackground) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(topicShareOver:) name:@"topicShareOver" object:nil];
    }
    if (self.isInviteNewUser) {
        [GolfAppDelegate shareAppDelegate].isInviteNewUser = YES;
    }
}

- (void)sendSMS
{
    NSString *body = nil;
    if (self.shareTitle.length>0) {
        body = self.shareUrlTem ? [NSString stringWithFormat:@"%@.%@.详情请点击:%@",self.shareTitle,self.shareContent,self.shareUrlTem] : [NSString stringWithFormat:@"%@%.@",self.shareTitle,self.shareContent];
    }else{
        body = self.shareUrlTem ? [NSString stringWithFormat:@"%@.详情请点击:%@",self.shareContent,self.shareUrlTem] : self.shareContent;
    }
    if ([MFMessageComposeViewController canSendText]) {
        if (self.isNeedAddressBook) {
            YGShareSMSViewCtrl *shortMessage = [YGShareSMSViewCtrl instanceFromStoryboard];
            shortMessage.title = @"选择收件人";
            shortMessage.body = body;
            [[GolfAppDelegate shareAppDelegate].naviController pushViewController:shortMessage animated:YES];
        }else{
            MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
            picker.messageComposeDelegate = self;
            if (_phoneNumber.length > 0) {
                picker.recipients = @[_phoneNumber];
            }
            picker.body = body;
            picker.navigationBar.tintColor= [UIColor blackColor];
            [[GolfAppDelegate shareAppDelegate].naviController presentViewController:picker animated:YES completion:nil];
        }
    } else {
        [[GolfAppDelegate shareAppDelegate] alert:nil message:@"设备没有短信功能"];
    }
}

// Unuseable
- (void)shareEvent:(UIButton*)button
{
    [self disappear];
    NSInteger tag = button.tag;
    int flag=0;
    if (tag == 1) { // 微信好友
        Share *share = [[Share alloc] initWithTitle:_shareTitle content:_shareContent image:_shareImg url:_shareUrlTem scene:WXSceneSession];
        share.type = self.type;
        flag=1;
        [share sendMsgToWX];
    }else if (tag == 2){    //朋友圈
        NSString *stringC;
        NSString *stringT;
        if (!_isInviteFriend && !_isInviteNewUser) {
            if (_circleOfFriendsString.length > 0) {
                stringT = @" ";
                stringC = _circleOfFriendsString;
            } else {
                stringT=_shareTitle;
                stringC=_shareContent;
            }
        }else{
            if (_circleOfFriendsString.length > 0) {
                stringT = @" ";
                stringC = _circleOfFriendsString;
            } else {
                stringC=@" ";
                stringT=[NSString stringWithFormat:@"分享高尔夫话题：%@",_shareTitle];
            }
        }
        Share *share = [[Share alloc] initWithTitle:stringT content:stringC image:_shareImg url:_shareUrlTem scene:WXSceneTimeline];
        share.type = self.type;
        share.isSplit = _isSplit;
        flag=1;
        [share sendMsgToWX];
    }else if (tag == 3){    //微博
        Share *share = [[Share alloc] initWithTitle:_shareTitle content:_shareContent image:_shareImg url:_shareUrlTem scene:WXSceneSession];
        flag=1;
        [share sendMsgToWB];
    }else if (tag == 4){    //信息
        NSString *body = nil;
        if (self.shareTitle.length>0) {
            body = self.shareUrlTem ? [NSString stringWithFormat:@"%@.%@.详情请点击:%@",self.shareTitle,self.shareContent,self.shareUrlTem] : [NSString stringWithFormat:@"%@%.@",self.shareTitle,self.shareContent];
        }else{
            body = self.shareUrlTem ? [NSString stringWithFormat:@"%@.详情请点击:%@",self.shareContent,self.shareUrlTem] : self.shareContent;
        }
        Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
        if (messageClass != nil) {
            if ([messageClass canSendText]) {
                if (self.isNeedAddressBook) {
                    YGShareSMSViewCtrl *shortMessage = [YGShareSMSViewCtrl instanceFromStoryboard];
                    shortMessage.title = @"选择收件人";
                    shortMessage.body = body;
                    [[GolfAppDelegate shareAppDelegate].currentController pushViewController:shortMessage title:@"选择收件人" hide:YES];
                }else{
                    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
                    picker.messageComposeDelegate = self;
                    if (_phoneNumber.length > 0) {
                        picker.recipients = @[_phoneNumber];
                    }
                    picker.body = body;
                    picker.navigationBar.tintColor= [UIColor blackColor];
                    [[GolfAppDelegate shareAppDelegate].currentController presentViewController:picker animated:YES completion:nil];
                }
                flag=1;
            } else {
                [[GolfAppDelegate shareAppDelegate] alert:nil message:@"设备没有短信功能"];
            }
        } else {
            [[GolfAppDelegate shareAppDelegate] alert:nil message:@"iOS版本过低，iOS4.0以上才支持程序内发送短信"];
        }
    }else if (tag == 5){    //邮件
        [self displayMailComposerSheet];
    }else if (tag == 6){    //复制链接
        if (self.shareUrlTem.length > 0) {
            [[UIPasteboard generalPasteboard] setString:self.shareUrlTem];
            [SVProgressHUD showSuccessWithStatus:@"复制成功!"];
        }else if (self.shareContent.length > 0){
            [[UIPasteboard generalPasteboard] setString:self.shareContent];
            [SVProgressHUD showSuccessWithStatus:@"复制成功!"];
        }
    }
    if (flag==1&&self.willSendToBackground) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(topicShareOver:) name:@"topicShareOver" object:nil];
    }
    if (self.isInviteNewUser) {
        [GolfAppDelegate shareAppDelegate].isInviteNewUser = YES;
    }
}

-(void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    lockShare = 1;
    if (serviceManager.success) {
        NSArray *arr = (NSArray *)data;
        if (arr.count!=0) {
            JudgeShareImageBlock judgeBlock = ^(NSArray *array,int userID){
                NSString *string = [NSString stringWithFormat:@"/%d/",userID];
                for (NSDictionary *dictionary in array) {
                    NSString *theString = dictionary[@"head_image"];
                    NSRange range = [theString rangeOfString:string];
                    if (range.location != NSNotFound) {
                        return YES;
                    }
                }
                return NO;
            };
            if ([self.delegate respondsToSelector:@selector(SharePackageRefreshTableviewCellShareImage:judge:)]) {
                [self.delegate SharePackageRefreshTableviewCellShareImage:arr[0] judge:judgeBlock];
            }
        }
    }
}


- (BOOL)isActivities {//有没有搞活动、登录
    self.shareTopicNote=[GolfAppDelegate shareAppDelegate].systemParamInfo.shareTopicNote;
    self.shareTopicYunbi=[GolfAppDelegate shareAppDelegate].systemParamInfo.shareTopicYunbi;
    if (!self.shareUrl) {
        return NO;
    }
    NSRange range=[self.shareUrl rangeOfString:@"/topic.html"];
    if ((![self judgeInviteFriend] && range.location==NSNotFound) || (![LoginManager sharedManager].loginState)) {
        self.shareUrlTem = self.shareUrl;
        return NO;
    }else{
        self.willSendToBackground=YES;
        NSRange range1 = [self.shareUrl rangeOfString:@"?"];
        if (range1.location == NSNotFound) {
            self.shareUrlTem = [NSString stringWithFormat:@"%@?shareMemberId=%d",self.shareUrl,[[LoginManager sharedManager] getUserId]];
        }else{
            self.shareUrlTem = [NSString stringWithFormat:@"%@&shareMemberId=%d",self.shareUrl,[[LoginManager sharedManager] getUserId]];
        }
    }

    if (self.shareTopicYunbi<=0) {
        return NO;
    }
    return YES;
}

- (BOOL)judgeInviteFriend {
    NSRange range=[self.shareUrl rangeOfString:@"/tagTopic.html"];
    if (range.location==NSNotFound) {
        self.isInviteFriend=NO;
        return NO;
    }else{
        self.isInviteFriend=YES;
        return YES;
    }
}

- (void)topicShareOver:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"topicShareOver" object:nil];
    NSDictionary *info = [notification object];
    int a=[info[@"flag"] intValue];
    if (a==0) {
        return;
    }
    if (lockShare == 1) {
        lockShare = 0;
        if (self.isInviteFriend) {
            [[ServiceManager serviceManagerWithDelegate:self] topic_share_add:[[LoginManager sharedManager] getSessionId] topic_id:0 share_type:a];
        }else{
            [[ServiceManager serviceManagerWithDelegate:self] topic_share_add:[[LoginManager sharedManager] getSessionId] topic_id:self.topicID share_type:a];
        }
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
    int flag=0;
    switch (result) {
        case MessageComposeResultCancelled:
            flag=0;
            break;
        case MessageComposeResultSent:{
            flag=4;
            [SVProgressHUD showSuccessWithStatus:@"发送成功"];
        }
            break;
        case MessageComposeResultFailed:{
            flag=0;
            [SVProgressHUD showErrorWithStatus:@"发送失败"];
        }
            break;
        default:
            break;
    }
    NSDictionary *dictionary=[NSDictionary dictionaryWithObject:@(flag) forKey:@"flag"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"topicShareOver" object:dictionary];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

-(void)displayMailComposerSheet
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    
    if (!picker) {
        return;
    }
    
    picker.mailComposeDelegate =self;
    [picker setSubject:self.shareTitle];
    
    // Fill out the email body text
    NSString *body = self.shareUrlTem ? [NSString stringWithFormat:@"%@详情请点击:%@",self.shareContent,self.shareUrlTem] : self.shareContent;
    [picker setMessageBody:body isHTML:YES];
    [[GolfAppDelegate shareAppDelegate].currentController presentViewController:picker animated:YES completion:nil];
    if (self.willSendToBackground) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(topicShareOver:) name:@"topicShareOver" object:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    NSString *msg = nil;
    NSDictionary *dictionary;
    if (result == MFMailComposeResultSent) {
        msg = @"邮件已发送";
        dictionary=[NSDictionary dictionaryWithObject:@5 forKey:@"flag"];
    }else{
        dictionary=[NSDictionary dictionaryWithObject:@0 forKey:@"flag"];
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"topicShareOver" object:dictionary];
    [[GolfAppDelegate shareAppDelegate].currentController dismissViewControllerAnimated:YES completion:nil];
    if (msg) {
        [SVProgressHUD showInfoWithStatus:msg];
    }
}

- (void)disappear{
    self.isShowView = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        [sharePanal setFrame:CGRectMake(0, Device_Height, Device_Width, 232)];
    } completion:^(BOOL finished) {
        if (sharePanal) {
            [sharePanal removeFromSuperview];
            sharePanal = nil;
        }
        
        if (control) {
            [control removeFromSuperview];
            control = nil;
        }
    }];
}


@end
