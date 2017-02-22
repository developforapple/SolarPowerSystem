//
//  CommodityCommentModel.h
//  Golf
//
//  Created by 黄希望 on 14-5-29.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommodityCommentModel : NSObject

@property (nonatomic) int memberId;
@property (nonatomic) int memberLevel;
@property (nonatomic,copy) NSString *displayName;
@property (nonatomic,copy) NSString *headImage;

@property (nonatomic,copy) NSString *mobilePhone;
@property (nonatomic,copy) NSString *commentDate;
@property (nonatomic) int commentLevel;
@property (nonatomic,copy) NSString *commentContent;

- (id)initWithDic:(id)data;

@end
