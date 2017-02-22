//
//  CoachDetailCommentModel.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/13.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoachDetailCommentModel : NSObject

@property (nonatomic) int commentId;
@property (nonatomic) int memberId;
@property (nonatomic,copy) NSString *displayName;
@property (nonatomic) int memberRank;
@property (nonatomic) float starLevel;
@property (nonatomic) int classId;
@property (nonatomic,copy) NSString *headImage;
@property (nonatomic,copy) NSString *commentContent;
@property (nonatomic,copy) NSString *commentTime;
@property (nonatomic,copy) NSString *replyContent;
@property (nonatomic,copy) NSString *replyTime;
@property (nonatomic) int reservationId;
@property (nonatomic,copy) NSString *reservationTime;
@property (nonatomic,copy) NSString *reservationDate;
@property (nonatomic,copy) NSString *reservationWeekname;
//@property (nonatomic) CGFloat cellHeight;

- (id)initWithDic:(id)data;

-(CGFloat)contentSize:(CGSize)rect addReply:(BOOL)flag isCoach:(BOOL)isCoach;
@end
