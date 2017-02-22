//
//  UserCommentModel.h
//  Golf
//
//  Created by user on 13-6-20.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserCommentModel : NSObject
@property (nonatomic) int clubId;
@property (nonatomic) int orderId;
@property (nonatomic) int commentCount;
@property (nonatomic) int totalLevel;
@property (nonatomic) int grassLevel;
@property (nonatomic) int serviceLevel;
@property (nonatomic) int difficultyLevel;
@property (nonatomic) int sceneryLevel;
@property (nonatomic,copy) NSString *mobilePhone;
@property (nonatomic,copy) NSString *commentDate;
@property (nonatomic,copy) NSString *clubName;
@property (nonatomic,copy) NSString *commentContent;
@property (nonatomic,copy) NSString *teetimeDate;

- (id)initWithDic:(id)data;
@end
