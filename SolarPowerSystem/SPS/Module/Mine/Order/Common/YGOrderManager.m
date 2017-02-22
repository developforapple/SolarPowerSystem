//
//  YGOrderManager.m
//  Golf
//
//  Created by bo wang on 2016/12/9.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGOrderManager.h"
#import "YGMallOrderModel.h"
#import "YGThriftRequestManager.h"
#import "YGOrderHandler.h"
#import "YGThrift+TourPackage.h"

#define PageSize 5

@interface YGOrderManager ()
@property (strong, readwrite, nonatomic) NSArray<YGOrdersSummaryItem *> *items;
@property (strong, readwrite, nonatomic) NSMutableArray<id<YGOrderModel>> *orderList;
@property (strong, nonatomic) NSMutableIndexSet *notNeverLoadTypes;
@property (assign, readwrite, nonatomic) BOOL noMore;
@property (assign, nonatomic) NSInteger lastOrderId;
@end

@implementation YGOrderManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.notNeverLoadTypes = [NSMutableIndexSet indexSet];
        self.items = [YGOrdersSummaryItem defaultSummaryItems];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivedOrderDidDeletedNotification:) name:kYGOrderDidDeletedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivedOrderDidChangedNotification:) name:kYGOrderDidChangedNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (YGOrdersSummaryItem *)itemOfType:(YGOrderType)type
{
    for (YGOrdersSummaryItem *item in self.items) {
        if (item.type == type) {
            return item;
        }
    }
    return nil;
}

- (void)reload
{
    [self loadDataV2:NO];
//    [self loadData:YGOrderTypeCourse];
//    [self loadData:YGOrderTypeMall];
//    [self loadData:YGOrderTypeTeaching];
//    [self loadData:YGOrderTypeTeachBooking];
}

- (void)loadMore
{
    [self loadDataV2:YES];
}

- (void)loadDataV2:(BOOL)isMore
{
    NSInteger lastOrderId = isMore?self.lastOrderId:0;
    
    [ServerService fetchRecentOrders:0 lastOrderId:lastOrderId pageSize:20 callBack:^(NSDictionary *obj) {

        NSInteger lastOrderId = [obj[@"max_order_id"] integerValue];
        NSArray *datalist = obj[@"data_list"];
        
        NSMutableArray *orders = [NSMutableArray array];
        
        for (NSDictionary *data in datalist) {
            
            NSDictionary *orderDic = data[@"data"];
            YGOrderType type = [data[@"type"] integerValue];
            
            id order;
            switch (type) {
                case YGOrderTypeMall:{
                    order = [YGMallOrderModel yy_modelWithJSON:orderDic];
                }   break;
                case YGOrderTypeCourse:{
                    order = [[OrderModel alloc] initWithDic:orderDic]; 
                }   break;
                case YGOrderTypeTeaching:{
                    order = [[TeachingOrderModel alloc] initWithDic:orderDic];
                }   break;
                case YGOrderTypeTeachBooking:{
                    order = [VirtualCourseOrderBean yy_modelWithJSON:orderDic];
                }   break;
            }
            
            if (order) {
                [orders addObject:order];
            }
        }
        
        self.noMore = orders.count<20;
        
        if (isMore) {
            [_orderList addObjectsFromArray:orders];
        }else{
            _orderList = orders;
        }
        
        self.lastOrderId = lastOrderId;
        if (self.didLoadDataBlock) {
            self.didLoadDataBlock(YES,isMore);
        }
        
    } failure:^(id error) {
        if (self.didLoadDataBlock) {
            self.didLoadDataBlock(NO,isMore);
        }
    }];
}

/*  V2接口出现之前的获取数据方法

- (void)loadData:(YGOrderType)type
{
    switch (type) {
        case YGOrderTypeCourse:[self loadCourseOrderData];break;
        case YGOrderTypeMall:[self loadMallOrderData];break;
        case YGOrderTypeTeaching:[self loadTeachOrderData];break;
        case YGOrderTypeTeachBooking:[self loadTeachBookingOrderData];break;
    }
}

- (void)loadCourseOrderData
{
    [ServerService fetchCourseOrderList:0 payType:0 page:1 pageSize:PageSize callBack:^(NSDictionary *data) {
        if (!data || ![data isKindOfClass:[NSDictionary class]]) return;
        
        NSArray *orderData = data[@"data_list"];
        NSMutableArray *orders = [NSMutableArray array];
        for (NSDictionary *aOrderDic in orderData) {
            OrderModel *order = [[OrderModel alloc] initWithDic:aOrderDic];
            if (order) [orders addObject:order];
        }
        
        NSArray *amountData = data[@"total_list"];
        NSInteger amount = 0;
        NSInteger unpaiedAmount = 0;
        for (NSDictionary *aAmountData in amountData) {
            NSInteger state = [aAmountData[@"order_state"] integerValue];
            NSInteger aAmount = [aAmountData[@"order_count"] integerValue];
            amount += aAmount;
            if (state == OrderStatusWaitPay) {
                unpaiedAmount = aAmount;
            }
        }
        
        [self didLoadData:orders totalAmount:amount waitPayAmount:unpaiedAmount type:YGOrderTypeCourse];
    } failure:^(id error) {
        [self failLoad:YGOrderTypeCourse];
    }];
}

- (void)loadMallOrderData
{
    [ServerService fetchMallOrderList:0 pageNo:1 pageSize:PageSize callBack:^(NSDictionary *data) {
        if (!data || ![data isKindOfClass:[NSDictionary class]]) return;
    
        NSArray *orderData = data[@"data_list"];
        NSMutableArray *orders = [NSMutableArray arrayWithArray:[NSArray yy_modelArrayWithClass:[YGMallOrderModel class] json:orderData]];
        
        NSArray *amountData = data[@"total_list"];
        NSInteger amount = 0;
        NSInteger unpaiedAmount = 0;
        for (NSDictionary *aAmountData in amountData) {
            NSInteger state = [aAmountData[@"order_state"] integerValue];
            NSInteger aAmount = [aAmountData[@"order_count"] integerValue];
            amount += aAmount;
            if (state == YGMallOrderStatusUnpaid) {
                unpaiedAmount = aAmount;
            }
        }
        [self didLoadData:orders totalAmount:amount waitPayAmount:unpaiedAmount type:YGOrderTypeMall];
    } failure:^(id error) {
        [self failLoad:YGOrderTypeMall];
    }];
}

- (void)loadTeachOrderData
{
    [ServerService fetchTeachOrderList:0 coachId:0 memberId:[LoginManager sharedManager].session.memberId keywords:nil page:1 pageSize:PageSize callBack:^(NSDictionary *data) {
        if (!data || ![data isKindOfClass:[NSDictionary class]]) return;
        
        NSArray *orderData = data[@"data_list"];
        NSMutableArray *orders = [NSMutableArray array];
        for (NSDictionary *aOrderDic in orderData) {
            TeachingOrderModel *order = [[TeachingOrderModel alloc] initWithDic:aOrderDic];
            if (order)[orders addObject:order];
        }
        
        NSArray *amountData = data[@"total_list"];
        NSInteger amount = 0;
        NSInteger unpaiedAmount = 0;
        for (NSDictionary *aAmountData in amountData) {
            NSInteger state = [aAmountData[@"order_state"] integerValue];
            NSInteger aAmount = [aAmountData[@"order_count"] integerValue];
            amount += aAmount;
            if (state == YGTeachingOrderStatusTypeWaitPay) {
                unpaiedAmount = aAmount;
            }
        }
        [self didLoadData:orders totalAmount:amount waitPayAmount:unpaiedAmount type:YGOrderTypeTeaching];
    } failure:^(id error) {
        [self failLoad:YGOrderTypeTeaching];
    }];
}

- (void)loadTeachBookingOrderData
{
    [YGRequest fetchTeachingOrderList:@0 pageNo:@1 pageSize:@(PageSize) success:^(BOOL suc, id object) {
        VirtualCourseOrderList *list = object;
        NSInteger amount = list.totalCount;
        NSInteger waitpay = list.waitPayCount;
        [self didLoadData:list.orderList totalAmount:amount waitPayAmount:waitpay type:YGOrderTypeTeachBooking];
    } failure:^(Error *err) {
        [self failLoad:YGOrderTypeTeachBooking];
    }];
}

#pragma mark - Completed
- (void)didLoadData:(NSMutableArray *)data totalAmount:(NSInteger)amount waitPayAmount:(NSInteger)waitpay type:(YGOrderType)type
{
    [self.notNeverLoadTypes addIndex:type];
    YGOrdersSummaryItem *item = [self itemOfType:type];
    item.orders = data;
    item.amount = amount;
    item.waitpayAmount = waitpay;
    [self callDidLoadDataCallbackIfNeed];
}

- (void)failLoad:(YGOrderType)type
{
    [self.notNeverLoadTypes addIndex:type];
    [self callDidLoadDataCallbackIfNeed];
}

- (void)callDidLoadDataCallbackIfNeed
{
    if (self.notNeverLoadTypes.count == self.items.count && self.didLoadDataBlock) {
        [self updateOrderList];
        self.didLoadDataBlock();
    }
}

- (void)updateOrderList
{
    NSMutableArray<id<YGOrderModel>> *allOrders = [NSMutableArray array];
    for (YGOrdersSummaryItem *item in self.items) {
        [allOrders addObjectsFromArray:item.orders];
    }
    [allOrders sortUsingComparator:^NSComparisonResult(id<YGOrderModel> obj1, id<YGOrderModel> obj2) {
        return [@([obj2 gp_timestamp]) compare:@([obj1 gp_timestamp])]; //从大到小排序
    }];
    NSArray *result = [allOrders subarrayWithRange:NSMakeRange(0, MIN(5, allOrders.count))];
    self.orderList = result;
}


*/

#pragma mark - Noti
- (void)didReceivedOrderDidDeletedNotification:(NSNotification *)noti
{
    id<YGOrderModel> order = noti.object;
    YGOrderType type = typeOfOrder(order);
    if (isValidOrderType(type)) {
        NSInteger orderid = [order gp_orderId];
        NSInteger idx = [self.orderList indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return isValidOrderWithType(obj, type) && [obj gp_orderId] == orderid;
        }];
        if (idx != NSNotFound) {
            [_orderList removeObjectAtIndex:idx];
        }
        if (self.didLoadDataBlock) {
            self.didLoadDataBlock(YES,NO);
        }
    }
    
    /*
    id<YGOrderModel> order = noti.object;
    YGOrderType type = typeOfOrder(order);
    if (isValidOrderType(type)) {
        NSInteger orderid = [order gp_orderId];
        YGOrdersSummaryItem *item = [self itemOfType:type];
        NSInteger idx = [item.orders indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id<YGOrderModel> obj, NSUInteger idx, BOOL *stop) {
            return orderid == [obj gp_orderId];
        }];
        if (idx != NSNotFound) {
            [item.orders removeObjectAtIndex:idx];
            item.amount = MAX(0, item.amount-1);
        }
        [self callDidLoadDataCallbackIfNeed];
    }
     */
}

- (void)didReceivedOrderDidChangedNotification:(NSNotification *)noti
{
    id<YGOrderModel> order = noti.object;
    YGOrderType type = typeOfOrder(order);
    if (isValidOrderType(type)) {
        NSInteger orderid = [order gp_orderId];
        NSInteger idx = [self.orderList indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) { 
            return isValidOrderWithType(obj, type) && [obj gp_orderId] == orderid;
        }];
        if (idx != NSNotFound) {
            if ([order isKindOfClass:[TravelPackageOrder class]]) {
                OrderModel *oldOrder = _orderList[idx];
                oldOrder.orderStatus = [(TravelPackageOrder *)order orderStatus];
                order = oldOrder;
            }
            [_orderList replaceObjectAtIndex:idx withObject:order];
        }
        if (self.didLoadDataBlock) {
            self.didLoadDataBlock(YES,NO);
        }
    }
    
    /*
    id<YGOrderModel> order = noti.object;
    YGOrderType type = typeOfOrder(order);
    if (isValidOrderType(type)) {
        NSInteger orderid = [order gp_orderId];
        YGOrdersSummaryItem *item = [self itemOfType:type];
        NSInteger idx = [item.orders indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id<YGOrderModel> obj, NSUInteger idx, BOOL *stop) {
            return orderid == [obj gp_orderId];
        }];
        if (idx != NSNotFound) {
            [item.orders replaceObjectAtIndex:idx withObject:order];
        }
        [self callDidLoadDataCallbackIfNeed];
    }
     */
}

@end

@implementation YGOrdersSummaryItem
- (instancetype)initWithType:(YGOrderType)type
{
    self = [super init];
    if (self) {
        self.type = type;
        self.amount = 0;
        self.orders = [NSMutableArray array];
        switch (type) {
            case YGOrderTypeMall:{
                self.title = @"商城订单";
                self.iconName = @"icon_order_decorate_mall";
            }   break;
            case YGOrderTypeCourse:{
                self.title = @"球场订单";
                self.iconName = @"icon_order_decorate_course";
            }   break;
            case YGOrderTypeTeaching:{
                self.title = @"教学订单";
                self.iconName = @"icon_order_decorate_teaching";
            }   break;
            case YGOrderTypeTeachBooking:{
                self.title = @"练习场订单";
                self.iconName = @"icon_order_decorate_teachbooking";
            }   break;
        }
    }
    return self;
}

- (NSInteger)waitpayAmount
{
    DepositInfoModel *info = [LoginManager sharedManager].myDepositInfo;
    NSInteger amount = 0;
    switch (self.type) {
        case YGOrderTypeCourse:amount = info.waitPayCount;break;
        case YGOrderTypeMall:amount = info.waitPayCount2;break;
        case YGOrderTypeTeaching:amount = info.waitPayCount3;break;
        case YGOrderTypeTeachBooking:amount = info.waitPayCount4;break;
    }
    return amount;
}

+ (NSArray<YGOrdersSummaryItem *> *)defaultSummaryItems
{
    return @[[[YGOrdersSummaryItem alloc] initWithType:YGOrderTypeCourse],
             [[YGOrdersSummaryItem alloc] initWithType:YGOrderTypeMall],
             [[YGOrdersSummaryItem alloc] initWithType:YGOrderTypeTeaching],
             [[YGOrdersSummaryItem alloc] initWithType:YGOrderTypeTeachBooking]];
}
@end
