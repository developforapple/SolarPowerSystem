//
//  AwardModel.h
//  Golf
//
//  Created by 黄希望 on 14-7-21.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AwardModel : NSObject

@property (nonatomic) int awardType;
@property (nonatomic) int totalAmount;
@property (nonatomic) int totalQuantity;
@property (nonatomic,copy) NSString *awardTitle;
@property (nonatomic,copy) NSString *awardContent;
@property (nonatomic,copy) NSString *awardUrl;

- (id)initWithDic:(id)data;

@end
