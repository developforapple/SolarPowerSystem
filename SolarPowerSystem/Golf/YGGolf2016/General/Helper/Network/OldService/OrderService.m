//
//  OrderService.m
//  Golf
//
//  Created by 青 叶 on 11-11-26.
//  Copyright (c) 2011年 大展. All rights reserved.
//

#import "OrderService.h"
#import "NSMutableDictionary+Util.h"


@implementation OrderService

+ (void)orderSubmitUnionpay:(OrderSubmitParamsModel *)model
                    success:(void (^)(OrderSubmitModel *osm))success
                    failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    if(model.sessionId){
        [params setObject:model.sessionId forKey:@"session_id"];
    }
    if(model.memberNum){
        [params setObject:[NSNumber numberWithInt:model.memberNum]  forKey:@"member_num"];
    }
    if(model.imeiNum){
        [params setObject:model.imeiNum  forKey:@"imei_num"];
    }
    if(model.clubId){
        [params setObject:[NSNumber numberWithInt:model.clubId] forKey:@"club_id"];
    }
    if(model.delayPay){
        [params setObject:[NSNumber numberWithInt:model.delayPay] forKey:@"delay_pay"];
    }
    if(model.courseId){
        [params setObject:[NSNumber numberWithInt:model.courseId] forKey:@"course_id"];
    }
    if(model.teeTimeDate){
        [params setObject:model.teeTimeDate  forKey:@"teetime_date"];
    }
    if(model.teeTimeTime){
        [params setObject:model.teeTimeTime  forKey:@"teetime_time"];
    }
    //if(model.payAmount){
    [params setObject:[NSNumber numberWithInt:model.payAmount*100]  forKey:@"pay_amount"];
    //}
    if(model.payType){
        [params setObject:[NSNumber numberWithInt:model.payType]  forKey:@"pay_type"];
    }
    if(model.serialNo){
        [params setObject:[NSNumber numberWithInt:model.serialNo] forKey:@"serial_no"];
    }
    if(model.agentId){
        [params setObject:[NSNumber numberWithInt:model.agentId]  forKey:@"agent_id"];
    }
    if(model.useAccount){
        [params setObject:[NSNumber numberWithInt:model.useAccount] forKey:@"use_account"];
    }
    if(model.couponId){
        [params setObject:[NSNumber numberWithInt:model.couponId] forKey:@"coupon_id"];
    }
    if(model.memberName){
        [params setObject:model.memberName  forKey:@"member_name"];
    }
    if(model.mobilePhone){
        [params setObject:model.mobilePhone  forKey:@"mobile_phone"];
    }
    if(model.description){
        [params setObject:model.description  forKey:@"user_memo"];
    }
    if(model.packageId){
        [params setObject:[NSNumber numberWithInt:model.packageId]  forKey:@"package_id"];
    }
    if(model.specId){
        [params setObject:[NSNumber numberWithInt:model.specId]  forKey:@"spec_id"];
    }
    [params setObject:[NSNumber numberWithInt:model.isMobile]  forKey:@"is_mobile"];
    [params setObject:@(model.onlySubmit) forKey:@"only_submit"];
    if (model.payChannel) {
        [params setObject:model.payChannel forKey:@"pay_channel"];
    }
    if (model.needInvoice>0) {
        [params setObject:@(model.needInvoice) forKey:@"need_invoice"];
        [params setObjectPassNil:model.invoiceTitle forKey:@"invoice_title"];
        [params setObjectPassNil:model.linkPhone forKey:@"link_phone"];
        [params setObjectPassNil:model.linkMan forKey:@"link_man"];
        [params setObjectPassNil:model.address forKey:@"address"];
    }
    [BaseService BSGet:@"order_submit_unionpay" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success && success) {
            OrderSubmitModel *osmodel = [[OrderSubmitModel alloc] initWithDic: BS.data];
            success (osmodel);
        }else{
            success (nil);
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}


+ (void)orderPayUnionpay:(OrderSubmitParamsModel *)model
                 success:(void (^)(OrderSubmitModel *osm))success
                 failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    if(model.sessionId){
        [params setObject:model.sessionId forKey:@"session_id"];
    }
    if(model.orderId){
        [params setObject:[NSNumber numberWithInt:model.orderId]  forKey:@"order_id"];
    }
    if(model.useAccount){
        [params setObject:[NSNumber numberWithInt:model.useAccount] forKey:@"use_account"];
    }
    if (model.couponId) {
        [params setObject:[NSNumber numberWithInt:model.couponId] forKey:@"coupon_id"];
    }
    [params setObject:[NSNumber numberWithInt:model.delayPay] forKey:@"delay_pay"];
    [params setObject:[NSNumber numberWithInt:model.isMobile]  forKey:@"is_mobile"];
    if (model.payChannel) {
        [params setObject:model.payChannel forKey:@"pay_channel"];
    }
    
    [BaseService BSGet:@"order_pay_unionpay" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success && success) {
            OrderSubmitModel *osmodel = [[OrderSubmitModel alloc] initWithDic: BS.data];
            success (osmodel);
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}



+ (void)endTransantionUnionpay:(tranEndModel *)model
                       success:(void (^)(id obj))success
                       failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (model.sessionId) {
        [params setObject:model.sessionId forKey:@"session_id"];
    }
    [params setObject:[NSNumber numberWithInt:model.tranId] forKey:@"tran_id"];
    [params setObject:[NSNumber numberWithInt:model.tranStatus] forKey:@"tran_status"];
    [BaseService BSGet:@"end_transaction_unionpay" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success && success) {
            success (BS.data);
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}

+ (void)endPay:(YGPaymentResult *)result
       success:(void (^)(id obj))success
       failure:(void (^)(id error))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"session_id"] = result.sessionId;
    params[@"tran_id"] = @(result.tranId);
    params[@"tran_status"] = @(result.status);
    [BaseService BSGet:@"end_transaction_unionpay" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success && success) {
            success (BS.data);
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}


+ (void)orderCancel:(NSString *)sessionId withOrderId:(int)orderId
            operation:(int)operation
            success:(void (^)(BOOL boolen))success
            failure:(void (^)(id error))failure{
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if(sessionId){
        [params setObject:sessionId forKey:@"session_id"];
    }
    if(orderId){
        [params setObject:[NSNumber numberWithInt:operation] forKey:@"operation"];
    }
    [params setObject:[NSNumber numberWithInt:orderId] forKey:@"order_id"];
    
    [BaseService BSGet:@"cancel_order" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        BOOL boolen = NO;
        if (BS.success && success) {
            boolen = [[ServiceManager serviceManagerInstance] getBoolValue:BS.data];
        }
        success (boolen);
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}


@end
