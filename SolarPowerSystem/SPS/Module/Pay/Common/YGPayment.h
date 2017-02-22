//
//  YGPayment.h
//  Golf
//
//  Created by bo wang on 2016/10/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGPaymentResult.h"
#import "YGPayPlatformItem.h"

typedef NS_ENUM(NSUInteger, YGPaymentScene) {
    YGPaymentSceneTeetime = 1,      //预定球场
    YGPaymentSceneMall = 2,         //商城订单
    YGPaymentSceneTeaching = 3,     //教学订单
    YGPaymentScenePublicCourse = 4, //教学公开课
    YGPaymentSceneTeachBooking = 5, //教学场馆预定打位
};

/**
 支付场景对应的字符串类型
 @param scene 场景
 @return 字符串类型
 */
FOUNDATION_EXTERN NSString *PaySceneType(YGPaymentScene scene);

/**
 支付场景对应的API接口
 @param scene 场景
 @return 接口名
 */
FOUNDATION_EXTERN NSString *PayServiceAPI(YGPaymentScene scene);

@interface YGPayment : NSObject

/**
 生成待支付模型

 @param scene   支付场景
 @param orderId 订单id
 @param amount  支付额，单位 元

 @return 实例
 */
- (instancetype)initWithScene:(YGPaymentScene)scene
                      orderId:(NSInteger)orderId
                    payAmount:(NSInteger)amount;

@property (strong, nonatomic) NSNumber *couponId;//优惠券id

@property (strong, nonatomic) DepositInfoModel *deposit; //我的资金情况

@property (assign, readonly, nonatomic) YGPaymentScene scene;//支付场景
@property (assign, readonly, nonatomic) NSInteger orderId;//支付订单的id
@property (assign, readonly, nonatomic) NSInteger amount; //总数 单位：元
@property (assign, readonly, nonatomic) NSInteger yunbi;  //云币支付量 >0 表示使用云币
@property (assign, readonly, nonatomic) NSInteger balance;//余额支付量 >0 表示使用余额
@property (assign, readonly, nonatomic) NSInteger advance;//云高垫付金额 >0 表示使用垫付
@property (assign, readonly, nonatomic) NSInteger thirdPlatform;//第三方支付量
@property (assign, readonly, nonatomic) BOOL canUseYunbi; //能否使用云币
@property (assign, readonly, nonatomic) BOOL canUseBalance;//能否使用余额
@property (assign, readonly, nonatomic) BOOL canUseAdvance;//能否使用垫付
@property (assign, readonly, nonatomic) BOOL isUseYunbi;
@property (assign, readonly, nonatomic) BOOL isUseBalance;
@property (assign, readonly, nonatomic) BOOL isUseAdvance;
@property (assign, nonatomic) YGPaymentPlatform platform; //支付平台类型。默认为内部支付

// 选择支付方式，可能会失败
// 支付优先级：云币 > 余额 > （垫付 = 第三方支付）
- (void)useYunbi:(BOOL)useYunbi;// 使用云币支付，将会自动调整余额支付和其他支付金额
- (void)useBalance:(BOOL)useBalance;//使用余额支付
- (void)useAdvance:(BOOL)useAdvance;//使用垫付

// 付款选项发生了变化时的回调
@property (copy, nonatomic) void (^paymentDidChanged)(void);


#pragma mark - Pay

// 生成本次待支付的数据，提交给服务器
- (OrderSubmitParamsModel *)createSubmitModel;

// 向服务器确认即将开始这次支付后，服务器返回的支付数据模型
@property (strong, nonatomic) OrderPayModel *payModel;
// 支付的结果
@property (strong, nonatomic) YGPaymentResult *payResult;

@end



