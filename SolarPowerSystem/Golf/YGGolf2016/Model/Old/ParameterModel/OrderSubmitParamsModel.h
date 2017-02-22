//
//  OrderSubmitParamsModel.h
//  Golf
//
//  Created by Dejohn Dong on 12-2-16.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderSubmitParamsModel : NSObject{
    /** TeeTime 开球日期 **/
    NSString *_teeTimeDate;
    /** TeeTime 开球时间 **/
    NSString *_teeTimeTime;
    /** 球会id **/
    int _clubId;
    /** 分区id **/
    int _courseId;
    /** 预订人数 **/
    int _memeberNum;
    /** 设备终端号 **/
    NSString *_imeiNum;
    /** 登录用户session **/
    NSString *_sessionId;
    /** 支付金额 **/
    int _payAmount;
    /** 支付类型 **/
    int _payType;
    /** 信用卡支付验证码 **/
//    NSString *_validateCode;
    /** 约球id **/
    int _appointmentId;
    /** 流水号 **/
    int _serialNo;
    /** 中介id **/
    int _agentId;
    /** 帐户扣费 **/
    int _useAccount;
    /** 联系人姓名 **/
    NSString *_memberName;
    /** 联系人电话 **/
    NSString *_mobilePhone;
    int _orderId;
    int _packageId;
    int _specId;
    NSString *_description;
    int _couponId;
    int _delayPay;
    int _isMobile;
}

@property(nonatomic,copy) NSString *teeTimeDate;
@property(nonatomic,copy) NSString *teeTimeTime;
@property(nonatomic) int clubId;
@property(nonatomic) int courseId;
@property(nonatomic) int memberNum;
@property(nonatomic,copy) NSString *imeiNum;
@property(nonatomic,copy) NSString *sessionId;
@property(nonatomic) int payAmount;
@property(nonatomic) int payType;
@property(nonatomic) int appointmentId;
@property(nonatomic) int serialNo;
@property(nonatomic) int agentId;
@property(nonatomic) int useAccount;
@property(nonatomic,copy) NSString *memberName;
@property(nonatomic,copy) NSString *mobilePhone;
@property(nonatomic) int orderId;
@property(nonatomic) int packageId;
@property(nonatomic) int specId;
@property(nonatomic,strong) NSString *description;
@property(nonatomic) int couponId;
@property(nonatomic) int delayPay;
@property(nonatomic) int isMobile;
@property(nonatomic,copy) NSString *payChannel;
@property(nonatomic) int onlySubmit;
@property(nonatomic) int needInvoice; // 需要发票
@property(nonatomic,strong) NSString *invoiceTitle; // 发票抬头,need_invoice=1时填写
@property(nonatomic,strong) NSString *linkMan; // 联系人
@property(nonatomic,strong) NSString *linkPhone; // 联系电话
@property(nonatomic,strong) NSString *address; // 地址

@end
