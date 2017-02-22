//
//  YGMallOrderModel.h
//  Golf
//
//  Created by bo wang on 2016/10/20.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>

@class YGMallOrderCommodity;
@class YGMallCartGroup;
@class YGMallOrderEvidence;
@class CouponModel;

typedef NS_ENUM(NSUInteger, YGMallOrderStatus) {
    
    // 正常购物流程
    YGMallOrderStatusUnpaid = 6,            //订单已生成，等待用户支付
    YGMallOrderStatusPaid = 5,              //用户已支付，等待商家发货
    YGMallOrderStatusShipped = 3,           //商家已发货，等待用户收货
    YGMallOrderStatusReceived = 1,          //用户已收货，用户未评价
    YGMallOrderStatusReviewed = 2,          //用户已评价商品，完成交易
    
    // 其他状态
    YGMallOrderStatusClosed = 4,            //订单已关闭。订单已经生成待支付，用户支付超时或者手动取消了订单
    YGMallOrderStatusApplyRefund = 7,       //用户申请了退款
    YGMallOrderStatusRefunded = 8,          //已退款给用户
    
    // 临时状态，服务器未定义
    YGMallOrderStatusCreating = 100,    //用户正在创建订单
    YGMallOrderStatusCreatingRefund = 101,    //用户正在创建退款申请
};


/**
 新的商城订单模型。
 */
@interface YGMallOrderModel : NSObject <NSCoding, NSCopying, YYModel>

// 订单id
@property (assign, nonatomic)   NSInteger order_id;
// 订单状态
@property (assign, nonatomic)   YGMallOrderStatus order_state;
// 0 普通订单 1 子订单 2 父订单
@property (assign, nonatomic)   NSInteger orderType;
// 父订单id
@property (assign, nonatomic)   NSInteger parentOrderId;
// 订单时间描述
@property (strong, nonatomic)   NSString *order_time;
// 订单时间戳 秒
@property (assign, nonatomic)   NSTimeInterval orderTime;

// 子订单列表。
@property (strong, nonatomic)   NSArray<YGMallOrderModel *> *order;
// 商品列表。
@property (strong, nonatomic)   NSArray<YGMallOrderCommodity *> *commodity;
// 虚拟物品内容列表
// 商家名
@property (copy,   nonatomic)   NSString *agentName;
// 商品数量。订单下全部商品及配置的种类。
@property (assign, nonatomic)   NSInteger quantity;

// 优惠券减免额，单位 分
@property (assign, nonatomic)   NSInteger couponPayAmount;
// 全部商品总价，包括运费。没减去优惠券，单位 分
@property (assign, nonatomic)   NSInteger order_total;
// 返云币额度。，单位 分
@property (assign, nonatomic)   NSInteger give_yunbi;
// 运费，单位 分。包含子订单时，为子订单运费之和。不包含子订单时，为商品运费最大值。
@property (assign, nonatomic)   NSInteger freight;

// 收货地址
@property (strong, nonatomic)   NSString *address;
// 联系人
@property (copy,   nonatomic)   NSString *link_man;
// 联系电话
@property (copy,   nonatomic)   NSString *link_phone;
// 用户留言
@property (copy,   nonatomic)   NSString *user_memo;
// 快递单号
@property (copy,   nonatomic)   NSString *delivery_number;
// 快递公司名
@property (copy,   nonatomic)   NSString *delivery_company_name;
// 快递公司id
@property (assign, nonatomic)   NSInteger delivery_company_id;


// 0 可以单独退款 1 使用父订单退款
@property (assign, nonatomic)   NSInteger opera_status;
// 退款原因
@property (copy,   nonatomic)   NSString *return_memo;

// 临时属性
@property (assign, nonatomic) YGMallOrderStatus tempStatus; //订单所处临时状态。可能和 order_state 不一致。
@property (assign, nonatomic) NSInteger tempOrderId;//订单临时id，未确认的订单取一个时间戳作为id
@property (strong, nonatomic) CouponModel *coupon;  //订单所使用的的优惠券
@property (assign, nonatomic) BOOL noValidCoupon;   //存不存在可用的优惠券

// 根据groups内的商品内容创建一个订单模型
+ (instancetype)createOrderModelInGroups:(NSArray<YGMallCartGroup *> *)groups;
// 直接购买商品时生成订单模型的方式
+ (instancetype)createOrderModelWithCommodity:(CommodityInfoModel *)cim sku:(CommoditySpecSKUModel *)sku quantity:(NSInteger)quantity;

// 返回商品的id列表
- (NSSet *)commodityIdSets;
// 返回商品的分类id列表
- (NSSet *)commodityCategoryIdSets;
// 返回商品的品牌id列表
- (NSSet *)commodityBrandIdSets;

// 返回当前订单是否是虚拟商品订单
- (BOOL)isVirtualOrder;
// 返回当前订单是否是一个父订单。
- (BOOL)isCombinedOrder;
// 返回当前订单是否是在一个父订单中
- (BOOL)isInCombinedOrder;

// 商品列表中商品数量大于1即为YES
- (BOOL)isMultiCommodityOrder;
// 商品列表。
- (NSArray<YGMallOrderCommodity *> *)commodityList;

// 价格单位分
- (NSInteger)couponAmount;    //优惠券抵扣
// 价格单位分
- (NSInteger)needToPayAmount; //实际支付

// 准备提交订单的数据
- (NSDictionary *)prepareSubmitData;

// 是否是正在创建订单
- (BOOL)isInOrderCreating;
// 是否是正在创建申请退款
- (BOOL)isInRefundCreating;
// 是否显示优惠券
- (BOOL)isCouponVisible;
// 是否显示物流信息
- (BOOL)isLogisticsVisible;
// 是否显示云币信息
- (BOOL)isYunbiVisible;
// 能否删除订单
- (BOOL)canDeleteOrder;
// 能否修改用户留言
- (BOOL)canEditUserMemo;
// 能否提交退款申请
- (BOOL)canApplyRefund;
// 能否取消退款申请
- (BOOL)canCancelApplyRefund;
// 当前是否是提交取消退款申请
- (BOOL)isCreatingCancelRefund;
// 当前是否是创建退款申请
- (BOOL)isCreatingRefund;

// 待付款 实付款 待退款 已退款 合计
- (NSString *)paymentTitle;

// 未评价的商品数量
- (NSInteger)unreviewedCommodityAmount;

@end

/**
 订单商品
 */
@interface YGMallOrderCommodity : NSObject <NSCoding, NSCopying, YYModel>
@property (copy,   nonatomic)   NSString *spec_name; //规格描述字符串
@property (assign, nonatomic)   NSInteger sku_id; //规格id
@property (assign, nonatomic)   NSInteger price; //单位 分
@property (copy,   nonatomic)   NSString *photo_image;
@property (assign, nonatomic)   NSInteger quantity;
@property (copy,   nonatomic)   NSString *commodity_name;
@property (assign, nonatomic)   NSInteger commodity_id;
@property (assign, nonatomic)   NSInteger commodity_type;//1实物 2虚拟 3现金券
@property (assign, nonatomic)   NSInteger give_yunbi;   //返云币 单位 分
@property (assign, nonatomic)   BOOL comment_status;    //商品评价状态 0未评价 1已评价
@property (strong, nonatomic)   NSArray<YGMallOrderEvidence *> *evidence_list;//兑换券信息
@property (assign, nonatomic)   NSInteger brand_id; //非服务器字段
@property (assign, nonatomic)   NSInteger category_id;//非服务器字段

// 从普通商品模型转为订单中的商品模型
+ (instancetype)createWithCommodity:(CommodityModel *)commodity;
// 从普通商品详情模型转为订单中的商品模型
+ (instancetype)createWithCommodityInfo:(CommodityInfoModel *)commodity;

- (CGFloat)evidenceHeight:(CGFloat)unitH spacing:(CGFloat)spacing;

@end

typedef NS_ENUM(NSUInteger, YGMallOrderEvidenceStatus) {
    YGMallOrderEvidenceStatusUnuse = 1,
    YGMallOrderEvidenceStatusUsed = 2,
    YGMallOrderEvidenceStatusExpired = 3,
};

@interface YGMallOrderEvidence : NSObject <NSCoding,NSCopying,YYModel>
@property (copy,   nonatomic) NSString *evidence_code;//兑换码
@property (assign, nonatomic) YGMallOrderEvidenceStatus evidence_state;//兑换码状态
@property (strong, nonatomic) NSString *expire_date; //过期时间
@end
