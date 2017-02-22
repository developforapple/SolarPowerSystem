//
//  RedPaperModel.h
//  Golf
//
//  Created by 黄希望 on 14-8-25.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RedPaperSubModel : NSObject

@property (nonatomic,copy) NSString *phoneNum;
@property (nonatomic,copy) NSString *createTime;
@property (nonatomic) int couponAmount;

- (id)initWithDic:(id)data;
@end

@interface RedPaperModel : NSObject
@property (nonatomic) int redPacketId;
@property (nonatomic,copy) NSString *expireDate;
@property (nonatomic,copy) NSString *beginDate;
@property (nonatomic) int totalAmount;
@property (nonatomic) int totalQuantity;
@property (nonatomic) int usedQuantity;
@property (nonatomic) int usedAmount;
@property (nonatomic,copy) NSString *shareTitle;
@property (nonatomic,copy) NSString *shareContent;
@property (nonatomic,copy) NSString *shareUrl;
@property (nonatomic,strong) NSArray *usedList;

- (id)initWithDic:(id)data;

@end
