//
//  OrderPayModel.h
//  Golf
//
//  Created by 黄希望 on 14-6-3.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

// 传给后台支付方式
typedef enum {
    /**会籍(正会员)**/
    PayTypeVip = 1,
    /**前台支付(保证金)**/
    PayTypeDeposit = 2,
    /**全额支付(信用卡)**/
    PayTypeOnline = 3,
    /**部分预付**/
    PayTypeOnlinePart = 4,
} PayTypeEnum;

FOUNDATION_EXTERN NSString *PayTypeString(PayTypeEnum type);

@interface OrderPayModel : NSObject

@property(nonatomic) int orderId;
@property(nonatomic) int payTotal;
@property(nonatomic) PayTypeEnum payType;
@property(nonatomic) int tranId;
@property(nonatomic,copy) id payXML;
@property(nonatomic,copy) NSString *orderCreateTime;
@property(nonatomic,copy) NSString *priceContent;
@property(nonatomic) int orderState;

@property(nonatomic,assign) int autoConfirm;

@property(nonatomic,strong) NSString *shareTitle;
@property(nonatomic,strong) NSString *shareContent;
@property(nonatomic,strong) NSString *shareImage;
@property(nonatomic,strong) NSString *shareUrl;

- (id)initWithDic:(id)data;

@end
