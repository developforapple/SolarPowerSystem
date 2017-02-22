//
//  CommodityParamModel.h
//  Golf
//
//  Created by 黄希望 on 14-5-28.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommodityParamModel : NSObject

@property (nonatomic) int auctionId;
@property (nonatomic) int commodityId;
@property (nonatomic) float price;
@property (nonatomic) float freight;
@property (nonatomic) int isMobile;
@property (nonatomic,copy) NSString *linkMan;
@property (nonatomic,copy) NSString *linkPhone;
@property (nonatomic,copy) NSString *address;
@property (nonatomic,copy) NSString *userMemo;
@property (nonatomic,copy) NSString *sessionId;
@property (nonatomic,strong) NSMutableArray *quantityList;

@end
