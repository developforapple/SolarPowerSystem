//
//  SearchService.h
//  Golf
//
//  Created by Vincent on 11-11-26.
//  Copyright (c) 2011年 Achievo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderSubmitModel.h"
#import "OrderDetailModel.h"
#import "OrderSubmitParamsModel.h"
#import "tranEndModel.h"
#import "YGPaymentResult.h"

@interface OrderService : NSObject


/**
 * 提交订单
 * 
 * @param OrderSubmitParamsModel
 * @return OrderModel
 * @throws Exception
 */

+ (void)orderSubmitUnionpay:(OrderSubmitParamsModel *)model
                    success:(void (^)(OrderSubmitModel *osm))success
                    failure:(void (^)(id error))failure;



+ (void)orderPayUnionpay:(OrderSubmitParamsModel *)model
                 success:(void (^)(OrderSubmitModel *osm))success
                 failure:(void (^)(id error))failure;



+ (void)endTransantionUnionpay:(tranEndModel *)model
                       success:(void (^)(id obj))success
                       failure:(void (^)(id error))failure;

// 7.2 新增接口实现。完成支付
+ (void)endPay:(YGPaymentResult *)result
       success:(void (^)(id obj))success
       failure:(void (^)(id error))failure;



/**
 * 取消订单
 * 
 * @param session_id
 * @param order_id
 * @return
 * @throws Exception
 */
+ (void)orderCancel:(NSString *)sessionId
        withOrderId:(int)orderId
            operation:(int)operation
            success:(void (^)(BOOL boolen))success
            failure:(void (^)(id error))failure;


@end
