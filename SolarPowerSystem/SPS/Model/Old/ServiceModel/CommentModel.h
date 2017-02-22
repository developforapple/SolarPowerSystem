//
//  CommentModel.h
//  Golf
//
//  Created by user on 13-6-4.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentModel : NSObject

@property (nonatomic) int totalLevel;
@property (nonatomic) int grassLevel;
@property (nonatomic) int serviceLevel;
@property (nonatomic) int difficultyLevel;
@property (nonatomic) int sceneryLevel;
@property (nonatomic) int memberId;
@property (nonatomic) int memberLevel;
@property (nonatomic,copy) NSString *headImage;
@property (nonatomic,copy) NSString *displayName;
@property (nonatomic,copy) NSString *mobilePhone;
@property (nonatomic,copy) NSString *commentDate;
@property (nonatomic,copy) NSString *commentContent;

- (id)initWithDic:(id)data;

@end
