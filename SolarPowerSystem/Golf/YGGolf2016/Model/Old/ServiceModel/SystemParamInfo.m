//
//  SystemParamInfo.m
//  Golf
//
//  Created by 黄希望 on 14-6-17.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "SystemParamInfo.h"

@implementation SystemParamInfo

- (id)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }

    NSDictionary *dic = (NSDictionary *)data;
    if ([dic objectForKey:@"auction_time"]) {
        self.auctionTime = [dic objectForKey:@"auction_time"];
    }
    if ([dic objectForKey:@"auction_ahead"]) {
        self.auctionAhead = [[dic objectForKey:@"auction_ahead"] intValue];
    }
    if ([dic objectForKey:@"auction_duration"]) {
        self.auctionDuration = [[dic objectForKey:@"auction_duration"] intValue];
    }
    if ([dic objectForKey:@"account_msg_count"]) {
        self.accountMsgCount = [[dic objectForKey:@"account_msg_count"] intValue];
    }
    if ([dic objectForKey:@"topic_msg_count"]) {
        self.topicMsgCount = [[dic objectForKey:@"topic_msg_count"] intValue];
    }
    if ([dic objectForKey:@"footprint_msg_count"]) {
        self.footprintMsgCount = [[dic objectForKey:@"footprint_msg_count"] intValue];
    }
    if ([dic objectForKey:@"topic_member_follow"]) {
        self.topicMemberFollow = [[dic objectForKey:@"topic_member_follow"] intValue];
    }
    if ([dic objectForKey:@"shopping_cart_quantity"]) {
        self.shoppingCartQuantity = [[dic objectForKey:@"shopping_cart_quantity"] intValue];
    }
    if ([dic objectForKey:@"book_success_info"]) {
        self.bookSuccessInfo = [dic objectForKey:@"book_success_info"];
    }
    if ([dic objectForKey:@"book_success_url"]) {
        self.bookSuccessUrl = [dic objectForKey:@"book_success_url"];
    }
    if ([dic objectForKey:@"service_phone"]) {
        self.servicePhone = [dic objectForKey:@"service_phone"];
    }
    if ([dic objectForKey:@"share_topic_yunbi"]) {
        self.shareTopicYunbi=[[dic objectForKey:@"share_topic_yunbi"] intValue];
    }
    if ([dic objectForKey:@"share_topic_note"]) {
        self.shareTopicNote=[dic objectForKey:@"share_topic_note"];
    }
    if ([dic objectForKey:@"invite_new_user_yunbi"]) {
        self.inviteNewUserYunbi=[[dic objectForKey:@"invite_new_user_yunbi"] intValue];
    }
    if ([dic objectForKey:@"invite_new_user_note"]) {
        self.inviteNewUserNote=[dic objectForKey:@"invite_new_user_note"];
    }
    if ([dic objectForKey:@"spree_note"]) {
        self.spreeNote = [dic objectForKey:@"spree_note"];
    }
    if ([dic objectForKey:@"hot_club_keyword"]) {
        self.hotClubKeyword = [dic objectForKey:@"hot_club_keyword"];
    }
    if ([dic objectForKey:@"teetimebook_subtitle"]) {
        self.teetimebookSubtitle = [dic objectForKey:@"teetimebook_subtitle"];
    }
    if ([dic objectForKey:@"is_production"]){
        self.isProduction = [[dic objectForKey:@"is_production"] intValue] == 1 ? YES:NO;
    }
    if ([dic objectForKey:@"kefu_teetime"]) {
        self.kefuTeetime = [dic objectForKey:@"kefu_teetime"];
    }
    if ([dic objectForKey:@"kefu_commodity"]) {
        self.kefuCommodity = [dic objectForKey:@"kefu_commodity"];
    }
    if ([dic objectForKey:@"kefu_teaching"]) {
        self.kefuTeaching = [dic objectForKey:@"kefu_teaching"];
    }
    if ([dic objectForKey:@"kefu_other"]) {
        self.kefuOther = [dic objectForKey:@"kefu_other"];
    }
    if ([dic objectForKey:@"kefu_feedback"]) {
        self.kefuFeedback = [dic objectForKey:@"kefu_feedback"];
    }
    if ([dic objectForKey:@"map_range"]) {
        self.mapRange = [[dic objectForKey:@"map_range"] intValue];
    }
    
    self.defaultSearchKey = dic[@"default_search_key"];
    
    if ([dic objectForKey:@"bind_weixin"]) {
        self.bindWeixin = [dic[@"bind_weixin"] intValue];
    }
    if ([dic objectForKey:@"isGuideAlert"]) {
        self.isGuideAlert = [[dic objectForKey:@"isGuideAlert"] intValue];
    }
    return self;
}

- (void)setAccountMsgCount:(int)accountMsgCount{
    _accountMsgCount = accountMsgCount;
    [[NSUserDefaults standardUserDefaults] setObject:@(_accountMsgCount) forKey:@"account_msg_count"];
}

- (void)setTopicMsgCount:(int)topicMsgCount{
    _topicMsgCount = topicMsgCount;
    [[NSUserDefaults standardUserDefaults] setObject:@(_topicMsgCount) forKey:@"topic_msg_count"];
}

- (void)setFootprintMsgCount:(int)footprintMsgCount{
    _footprintMsgCount = footprintMsgCount;
    [[NSUserDefaults standardUserDefaults] setObject:@(_footprintMsgCount) forKey:@"footprint_msg_count"];
}

- (void)setTopicMemberFollow:(int)topicMemberFollow{
    _topicMemberFollow = topicMemberFollow;
    [[NSUserDefaults standardUserDefaults] setObject:@(_topicMemberFollow) forKey:@"topic_member_follow"];
}

@end
