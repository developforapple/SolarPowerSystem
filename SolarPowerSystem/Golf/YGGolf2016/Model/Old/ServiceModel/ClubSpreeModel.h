//
//  ClubSpreeModel.h
//  Golf
//
//  Created by 黄希望 on 15/10/12.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClubSpreeModel : NSObject

@property (nonatomic,assign) int spreeId; //抢购ID
@property (nonatomic,strong) NSString *spreeName; //抢购名称
@property (nonatomic,assign) int cityId; //城市ID，用于查询天气预报
@property (nonatomic,assign) int clubId; //球场ID(对应中心courseId)
@property (nonatomic,strong) NSString *clubName;
@property (nonatomic,strong) NSString *clubPhoto;
@property (nonatomic,assign) float remote;
@property (nonatomic,assign) double longitude;
@property (nonatomic,assign) double latitude;
@property (nonatomic,assign) int originalPrice; //原价,单位:分
@property (nonatomic,assign) int currentPrice; //现价,单位:分
@property (nonatomic,assign) int stockQuantity;
@property (nonatomic,assign) int soldQuantity;
@property (nonatomic,assign) int minBuyQuantity; //起订人数
@property (nonatomic,assign) int payType;
@property (nonatomic,assign) int prepayAmount;
@property (nonatomic,strong) NSString *spreeTime;
@property (nonatomic,strong) NSString *teeDate;
@property (nonatomic,strong) NSString *startTime;
@property (nonatomic,strong) NSString *endTime;
@property (nonatomic,assign) int giveYunbi;
@property (nonatomic,strong) NSString *priceContent; // 抢购须知
@property (nonatomic,strong) NSString *description_; //”价格备注信息”
@property (nonatomic,strong) NSString *cancelNote;
@property (nonatomic,assign) int agentId; //商家ID，-1:电话预订　0:官方　大于0:中介
@property (nonatomic,strong) NSString *agentName;
@property (nonatomic,assign) NSInteger hasInvoice; //1 :可提供发票 0：不提供发票
@property (nonatomic,assign) BOOL hasSetted;

- (id)initWithDic:(id)dic;

@end
