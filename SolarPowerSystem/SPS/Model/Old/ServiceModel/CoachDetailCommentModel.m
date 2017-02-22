//
//  CoachDetailCommentModel.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/13.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CoachDetailCommentModel.h"
#import "YGUserRemarkCacheHelper.h"

@implementation CoachDetailCommentModel

-(id)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    NSDictionary *dic = (NSDictionary *)data;
    if ([dic objectForKey:@"comment_id"]) {
        self.commentId = [[dic objectForKey:@"comment_id"] intValue];
    }
    if ([dic objectForKey:@"member_id"]) {
        self.memberId = [[dic objectForKey:@"member_id"] intValue];
    }
    if ([dic objectForKey:@"display_name"]) {
        self.displayName = [dic objectForKey:@"display_name"];
    }
    // 用户名称备注
    NSString *remarkName = [[YGUserRemarkCacheHelper shared] getUserRemarkName:self.memberId];
    if ([remarkName isNotBlank]) {
        self.displayName = remarkName;
    }
    
    if ([dic objectForKey:@"member_rank"]) {
        self.memberRank = [[dic objectForKey:@"member_rank"] intValue];
    }
    if ([dic objectForKey:@"head_image"]) {
        self.headImage = [dic objectForKey:@"head_image"];
    }
    if ([dic objectForKey:@"star_level"]) {
        self.starLevel = [[dic objectForKey:@"star_level"] floatValue];
    }
    if ([dic objectForKey:@"class_id"]) {
        self.classId = [[dic objectForKey:@"class_id"] intValue];
    }
    if ([dic objectForKey:@"comment_content"]) {
        self.commentContent = [dic objectForKey:@"comment_content"];
    }
    if ([dic objectForKey:@"comment_time"]) {
        self.commentTime = [dic objectForKey:@"comment_time"];
    }
    if ([dic objectForKey:@"reply_content"]) {
        self.replyContent = [dic objectForKey:@"reply_content"];
    }
    if ([dic objectForKey:@"reply_time"]) {
        self.replyTime = [dic objectForKey:@"reply_time"];
    }
    if ([dic objectForKey:@"reservation_id"]) {
        self.reservationId = [[dic objectForKey:@"reservation_id"] intValue];
    }
    if ([dic objectForKey:@"reservation_time"]) {
        self.reservationTime = [dic objectForKey:@"reservation_time"];
    }
    if ([dic objectForKey:@"reservation_date"]) {
        self.reservationDate = [dic objectForKey:@"reservation_date"];
    }
    if ([dic objectForKey:@"reservation_weekname"]) {
        self.reservationWeekname = [dic objectForKey:@"reservation_weekname"];
    }
    
    return self;
}

-(CGFloat)contentSize:(CGSize)rect addReply:(BOOL)flag isCoach:(BOOL)isCoach{
    CGFloat s = 0;
    
    if ([_commentContent respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        s = [_commentContent boundingRectWithSize:rect
                                          options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                       attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0]}
                                          context:nil].size.height;
    }

    if (flag) {
        s += [[NSString stringWithFormat:@"[回复]%@",_replyContent] boundingRectWithSize:rect options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0]} context:nil].size.height;
        s += 10;
    
    }
    
    if (isCoach) {
        if (flag) {
            s += 25;
        }else{
            s+= 35;
        }
    }
    
    return s + 72;
}


@end
