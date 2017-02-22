//
//  SystemParamInfo.h
//  Golf
//
//  Created by 黄希望 on 14-6-17.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SystemParamInfo : NSObject

@property (nonatomic) int auctionAhead;
@property (nonatomic) int auctionDuration;
@property (nonatomic) int accountMsgCount;
@property (nonatomic) int topicMsgCount;
@property (nonatomic) int footprintMsgCount;
@property (nonatomic) int shoppingCartQuantity;
@property (nonatomic) int topicMemberFollow;
@property (nonatomic,copy) NSString *auctionTime;
@property (nonatomic,copy) NSString *bookSuccessUrl;
@property (nonatomic,copy) NSString *bookSuccessInfo;
@property (nonatomic,copy) NSString *servicePhone;
@property (nonatomic,copy) NSString *shareTopicNote;
@property (nonatomic) int shareTopicYunbi;
@property (nonatomic) int inviteNewUserYunbi;
@property (nonatomic,copy) NSString *inviteNewUserNote;
@property (nonatomic,copy) NSString *spreeNote;
@property (nonatomic,copy) NSString *hotClubKeyword;
@property (nonatomic,copy) NSString *teetimebookSubtitle;
@property (nonatomic) int mapRange;
@property (nonatomic) BOOL isProduction;
@property (nonatomic,strong) NSDictionary *kefuTeetime; //订场客服
@property (nonatomic,strong) NSDictionary *kefuCommodity;//在线商城客服
@property (nonatomic,strong) NSDictionary *kefuTeaching;//在线教学客服
@property (nonatomic,strong) NSDictionary *kefuOther; //在线其他客服
@property (nonatomic,strong) NSDictionary *kefuFeedback; //在线意见反馈

@property (strong, nonatomic) NSString *defaultSearchKey;   //默认搜索词

@property (nonatomic,assign) int bindWeixin;//是否绑定微信 0 未绑定微信 1 已绑定微信

@property (nonatomic,assign) int isGuideAlert;//是否弹评价窗口 0-不许弹窗  1-需要弹窗
- (id)initWithDic:(id)data;

@end
