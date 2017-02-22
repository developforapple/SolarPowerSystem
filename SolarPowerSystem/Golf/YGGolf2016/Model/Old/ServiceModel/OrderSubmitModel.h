//
//  OrderSubmitModel.h
//  Golf
//
//  Created by user on 12-5-31.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import "OrderModel.h"

@interface OrderSubmitModel : NSObject{
    /** 订单ID **/
    int _orderId;
    
    /** 支付金额 **/
    int _payTotal;
    
    /** 支付方式 **/
    PayTypeEnum _payType;

    /** 银行支付单号，仅帐户支付不返回 **/
    int _tranId;

    /** 银行支付xml，仅帐户支付不返回 **/
    id _payXML;

    /** 订单创建时间 **/
    NSString *_orderCreateTime;
    
    /** 费用包括项目，用于显示 **/
    NSString *_priceContent;
}
@property(nonatomic) int orderId;
@property(nonatomic) int payTotal;
@property(nonatomic) PayTypeEnum payType;
@property(nonatomic) int tranId;
@property(nonatomic,copy) id payXML;
@property(nonatomic,copy) NSString *orderCreateTime;
@property(nonatomic,copy) NSString *priceContent;
@property(nonatomic) int orderState;

- (id)initWithDic:(id)data;

@end
