//
//  YGFlashSaleModel.h
//  Golf
//
//  Created by bo wang on 2016/11/21.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, YGFlashSaleState) {
    YGFlashSaleStateAuction,       //当前正在抢购，而且有库存
    YGFlashSaleStateBuy,           //无库存只能原价购买
    YGFlashSaleStateAlert,         //未开始抢购，没有提醒
    YGFlashSaleStateCancelAlert,   //未开始抢购，有提醒
    YGFlashSaleStateSellout        //没有库存
};

typedef NS_ENUM(NSUInteger, YGFlashSaleStatus) {
    YGFlashSaleStatusWaiting,   //未开始
    YGFlashSaleStatusStarted,   //已开始
    YGFlashSaleStatusEnd,       //已结束
};

@interface YGFlashSaleModel : NSObject <NSCoding,NSCopying>

@property (assign, nonatomic) NSInteger selling_price; //现价，单位：元
@property (assign, nonatomic) NSInteger quantity;   //库存
@property (assign, nonatomic) NSTimeInterval flash_time; //开始时间戳，秒
@property (assign, nonatomic) NSTimeInterval end_time;   //结束时间戳，秒
@property (assign, nonatomic) NSTimeInterval server_time; //服务器时间戳，秒。 如果没有返回这个值，取当前时间
@property (assign, nonatomic) NSInteger flash_id;   //抢购id
@property (assign, nonatomic) NSInteger flash_price; //抢购价，单位：元
@property (assign, nonatomic) YGFlashSaleState flash_status;//服务器返回的限时抢购列表中的按钮状态。
@property (copy, nonatomic) NSString *flash_text;
@property (assign, nonatomic) BOOL flash_notice;

- (id)initWithDic:(id)data;


/**
 当前抢购的状态
 */
- (YGFlashSaleStatus)flashSaleStatus;

/**
 是否可以抢购。抢购已开始且库存大于0时才可以抢购。
 */
- (BOOL)canAuction;

@end
