//
//  TotalCommentModel.h
//  Golf
//
//  Created by user on 13-6-4.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TotalCommentModel : NSObject

@property (nonatomic) int commentCount;
@property (nonatomic) int totalLevel;
@property (nonatomic) int grassLevel;
@property (nonatomic) int serviceLevel;
@property (nonatomic) int difficultyLevel;
@property (nonatomic) int sceneryLevel;
@property (nonatomic,strong) NSArray *commentList;

- (id)initWithDic:(id)data;

@end
