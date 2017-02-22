//
//  YGOrderDataProvider.m
//  Golf
//
//  Created by bo wang on 16/9/20.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGOrderDataProvider.h"
#import "YGThrift+Teaching.h"
#import "YGThriftRequestManager.h"
#import "YGMallOrderModel.h"
#import "YGOrderHandler.h"

@interface YGOrderDataProvider ()
@property (assign, readwrite, nonatomic) YGOrderType orderType;
@property (strong, readwrite, nonatomic) NSArray<NSString *> *titles;
@property (strong, readwrite, nonatomic) NSArray<NSNumber *> *countes;
@property (strong, readwrite, nonatomic) NSArray<NSNumber *> *statues;
@property (strong, readwrite, nonatomic) NSArray<id<YGOrderModel>> *orderList;
@property (strong, readwrite, nonatomic) NSMutableDictionary<NSNumber *,NSMutableArray<id<YGOrderModel>> *> *orderData;
@property (assign, readwrite, nonatomic) NSUInteger curStatus;
@end

@implementation YGOrderDataProvider

- (instancetype)init
{
    return [self initWithType:YGOrderTypeTeachBooking];
}

- (instancetype)initWithType:(YGOrderType)type
{
    self = [super init];
    if (self) {
        self.curStatus = 0;
        self.orderType = type;
        self.orderData = [NSMutableDictionary dictionary];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivedOrderDidDeletedNotification:) name:kYGOrderDidDeletedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivedOrderDidChangedNotification:) name:kYGOrderDidChangedNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceivedOrderDidDeletedNotification:(NSNotification *)noti
{
    [self deleteOrder:noti.object];
}

- (void)didReceivedOrderDidChangedNotification:(NSNotification *)noti
{
    [self updateOrder:noti.object];
}

#pragma mark
- (void)fetchDataOfStatus:(NSUInteger)status
{
    if (self.orderData[@(status)]) {
        self.curStatus = status;
        self.orderList = self.orderData[@(status)];
        [self callback:YES :NO :nil];
    }else if([self isValidStatus:status]){
        switch (self.orderType) {
            case YGOrderTypeTeachBooking:
                [self fetchTeachBookingOrder:(enum OrderStatus)status isMore:NO];
                break;
            case YGOrderTypeMall:
                [self fetchMallOrder:status isMore:NO];
                break;
            case YGOrderTypeCourse:{
                [self fetchCourseOrder:status isMore:NO];
            }   break;
            case YGOrderTypeTeaching:{
                [self fetchTeachingOrder:status isMore:NO];
            }   break;
        }
    }
}

- (void)refresh
{
    switch (self.orderType) {
        case YGOrderTypeTeachBooking:
            [self fetchTeachBookingOrder:(enum OrderStatus)self.curStatus isMore:NO];
            break;
        case YGOrderTypeMall:
            [self fetchMallOrder:self.curStatus isMore:NO];
            break;
        case YGOrderTypeCourse:{
            [self fetchCourseOrder:self.curStatus isMore:NO];
        }   break;
        case YGOrderTypeTeaching:{
            [self fetchTeachingOrder:self.curStatus isMore:NO];
        }   break;
    }
}

- (void)loadMore
{
    switch (self.orderType) {
        case YGOrderTypeTeachBooking:
            [self fetchTeachBookingOrder:(enum OrderStatus)self.curStatus isMore:YES];
            break;
        case YGOrderTypeMall:
            [self fetchMallOrder:self.curStatus isMore:YES];
            break;
        case YGOrderTypeCourse:{
            [self fetchCourseOrder:self.curStatus isMore:YES];
        }   break;
        case YGOrderTypeTeaching:{
            [self fetchTeachingOrder:self.curStatus isMore:YES];
        }   break;
    }
}

- (BOOL)hasMoreDataOfStatus:(NSUInteger)status
{
    if (![self isValidStatus:status]) {
        return NO;
    }
    NSArray *list = self.orderData[@(status)];
    return list.count % kDefaultPageSize == 0;
}

- (BOOL)isValidStatus:(NSUInteger)status
{
    if (status == 0) return YES;
    
    BOOL valid = NO;
    switch (self.orderType) {
        case YGOrderTypeTeachBooking:{
            switch (status) {
                case OrderStatus_WAIT_COMPLETE:
                case OrderStatus_COMPLETED:
                case OrderStatus_CLOSED:
                case OrderStatus_WAIT_PAY:
                case OrderStatus_RETURNED: valid = YES; break;
            }
        }   break;
        case YGOrderTypeMall:{
            switch (status) {
                case YGMallOrderStatusUnpaid:
                case YGMallOrderStatusPaid:
                case YGMallOrderStatusShipped:
                case YGMallOrderStatusReceived:
                case YGMallOrderStatusReviewed:
                case YGMallOrderStatusClosed:
                case YGMallOrderStatusApplyRefund:
                case YGMallOrderStatusRefunded:
                case YGMallOrderStatusCreating:
                case YGMallOrderStatusCreatingRefund: valid = YES;break;
            }
        }   break;
        case YGOrderTypeCourse:{
            switch (status) {
                case OrderStatusNew:
                case OrderStatusSuccess:
                case OrderStatusNotPresent:
                case OrderStatusCancel:
                case OrderStatusWaitEnsure:
                case OrderStatusWaitPay:
                case OrderStatusSendRepeal:
                case OrderStatusRepeal: valid = YES;break;
            }
        }   break;
        case YGOrderTypeTeaching:{
            switch (status) {
                case YGTeachingOrderStatusTypeExpired:
                case YGTeachingOrderStatusTypeWaitPay:
                case YGTeachingOrderStatusTypeCanceled:
                case YGTeachingOrderStatusTypeTeaching:
                case YGTeachingOrderStatusTypeCompleted:valid = YES;break;break;
            }
        }   break;
    }
    return valid;
}

- (id)orderAtIndex:(NSUInteger)index
{
    if (index < self.orderList.count) {
        return self.orderList[index];
    }
    return nil;
}

- (NSInteger)firstIdxOfOrder:(NSInteger)orderId inArray:(NSArray<id<YGOrderModel>> *)list
{
    NSInteger idx = [list indexOfObjectPassingTest:^BOOL(id<YGOrderModel> obj, NSUInteger idx, BOOL *stop) {
        return [obj gp_orderId] == orderId;
    }];
    return idx;
}

- (void)updateOrder:(id<YGOrderModel>)order
{
    if (!order || !isValidOrderWithType(order, self.orderType)) return;
    
    for (NSNumber *k in self.orderData) {
        NSMutableArray<id<YGOrderModel>> *list = self.orderData[k];
        NSInteger idx = [self firstIdxOfOrder:[order gp_orderId] inArray:list];
        if (idx != NSNotFound) {
            if ([order isKindOfClass:[TravelPackageOrder class]]) {
                OrderModel *oldOrder = list[idx];
                oldOrder.orderStatus = [(TravelPackageOrder *)order orderStatus];
                order = oldOrder;
            }
            [list replaceObjectAtIndex:idx withObject:order];
        }
    }
    [self callback:YES :NO :nil];
}

- (void)deleteOrder:(id)order
{
    if (!order || !isValidOrderWithType(order, self.orderType)) return;
    
    for (NSNumber *k in self.orderData) {
        NSMutableArray *list = self.orderData[k];
        NSInteger idx = [self firstIdxOfOrder:[order gp_orderId] inArray:list];
        if (idx != NSNotFound) {
            [list removeObjectAtIndex:idx];
        }
    }
    [self callback:YES :NO :nil];
}

#pragma mark - Callback
- (void)callback:(BOOL)suc :(BOOL)isMore :(NSString *)err
{
    self.lastErrorMessage = err;
    if (self.updateCallback) {
        self.updateCallback(suc,isMore);
    }
}

#pragma mark - Fetch
- (void)fetchTeachBookingOrder:(enum OrderStatus)status isMore:(BOOL)isMore
{
    NSUInteger page = 1;
    if (isMore) {
        NSArray *existData = self.orderData[@(status)];
        NSUInteger count = existData.count;
        page = count/kDefaultPageSize+1;
    }
                                        
    [YGRequest fetchTeachingOrderList:@(status) pageNo:@(page) pageSize:@(kDefaultPageSize) success:^(BOOL suc, id object) {
        VirtualCourseOrderList *result = object;
        
        if (suc) {
            
            NSMutableArray *list = self.orderData[@(status)];
            if (!list) {
                list = [NSMutableArray array];
            }
            
            NSMutableArray *orderList = result.orderList;
            if (isMore) {
                [list addObjectsFromArray:orderList];
            }else{
                list = orderList;
            }
            
            self.orderData[@(status)] = list;
            self.orderList = list;
            
            if (status == 0 && !isMore) {
                self.titles = @[@"全部",@"待付款",@"待使用",@"已完成"];
                self.countes = @[@(result.totalCount),@(result.waitPayCount),@(result.waitCompleteCount),@(result.completedCount)];
                self.statues = @[@0,@(OrderStatus_WAIT_PAY),@(OrderStatus_WAIT_COMPLETE),@(OrderStatus_COMPLETED)];
            }

            self.curStatus = status;
        }
        
        [self callback:suc :isMore :result.err.errorMsg];
    } failure:^(Error *err) {
        [self callback:NO :isMore :@"当前网络不可用"];
    }];
}

- (void)fetchCourseOrder:(OrderStatusEnum)status isMore:(BOOL)isMore
{
    NSUInteger page = 1;
    if (isMore) {
        NSArray *existData = self.orderData[@(status)];
        NSUInteger count = existData.count;
        page = count/kDefaultPageSize+1;
    }
    [ServerService fetchCourseOrderList:status payType:0 page:page pageSize:kDefaultPageSize callBack:^(id obj) {
        if (!obj) {
            [self callback:NO :isMore :@"当前网络不可用"];
        }else{
            
            NSMutableArray *list = self.orderData[@(status)];
            if (!list) {
                list = [NSMutableArray array];
            }
            NSArray *datalist = obj[@"data_list"];
            NSMutableArray *orderList = [NSMutableArray array];
            for (NSDictionary *dic in datalist) {
                OrderModel *om = [[OrderModel alloc] initWithDic:dic];
                om?[orderList addObject:om]:nil;
            }
            
            if (isMore) {
                [list addObjectsFromArray:orderList];
            }else{
                list = orderList;
            }
            
            self.orderData[@(status)] = list;
            self.orderList = list;
            
            if (status == 0 || !isMore) {
                self.titles = @[@"全部",@"待确认",@"待付款",@"已完成"];
                self.statues = @[@0,@(OrderStatusWaitEnsure),@(OrderStatusWaitPay),@(OrderStatusSuccess)];
                
                NSInteger totalCount = 0,waitEnsureCount = 0,waitPayCount = 0,successCount = 0;
                NSMutableArray *countList = obj[@"total_list"];
                for (NSDictionary *aCount in countList) {
                    OrderStatusEnum status = [aCount[@"order_state"] intValue];
                    NSInteger count = [aCount[@"order_count"] integerValue];
                    totalCount += count;
                    
                    if (status == OrderStatusWaitEnsure) {
                        waitEnsureCount += count;
                    }else if (status == OrderStatusWaitPay){
                        waitPayCount += count;
                    }else if (status == OrderStatusSuccess){
                        successCount += count;
                    }
                }
                self.countes = @[@(totalCount),@(waitEnsureCount),@(waitPayCount),@(successCount)];
            }
            self.curStatus = status;
            [self callback:YES :isMore :nil];
        }
    } failure:^(id error) {
        [self callback:NO :isMore :@"当前网络不可用"];
    }];
}

- (void)fetchMallOrder:(YGMallOrderStatus)status isMore:(BOOL)isMore
{
    NSUInteger page = 1;
    if (isMore) {
        NSArray *existData = self.orderData[@(status)];
        NSUInteger count = existData.count;
        page = count/kDefaultPageSize+1;
    }
    
    [ServerService fetchMallOrderList:status pageNo:page pageSize:kDefaultPageSize callBack:^(NSDictionary *obj) {
        if (!obj) {
            [self callback:NO :isMore :@"当前网络不可用"];
        }else{
            NSMutableArray *list = self.orderData[@(status)];
            if (!list) {
                list = [NSMutableArray array];
            }
            
            NSMutableArray *orderList = [NSMutableArray arrayWithArray:[NSArray yy_modelArrayWithClass:[YGMallOrderModel class] json:obj[@"data_list"]]];
            
            if (isMore) {
                [list addObjectsFromArray:orderList];
            }else{
                list = orderList;
            }
            
            self.orderData[@(status)] = list;
            self.orderList = list;
            
            if (status == 0 && !isMore) {
                self.titles = @[@"全部",@"待付款",@"待发货",@"待收货",@"已完成"];
                self.statues = @[@0,@(YGMallOrderStatusUnpaid),@(YGMallOrderStatusPaid),@(YGMallOrderStatusShipped),@(YGMallOrderStatusReviewed)];
                
                NSInteger totalCont = 0;
                NSInteger unpaidCount = 0;
                NSInteger paidCount = 0;
                NSInteger shippedCount = 0;
                NSInteger finishedCount = 0;
                
                NSMutableArray *countList = obj[@"total_list"];
                for (NSDictionary *aCount in countList) {
                    YGMallOrderStatus order_state = [aCount[@"order_state"] integerValue];
                    NSInteger count = [aCount[@"order_count"] integerValue];
                    totalCont += count;
                    
                    if (order_state == YGMallOrderStatusUnpaid) {
                        unpaidCount += count;
                    }else if (order_state == YGMallOrderStatusPaid){
                        paidCount += count;
                    }else if (order_state == YGMallOrderStatusShipped){
                        shippedCount += count;
                    }else if (order_state == YGMallOrderStatusReviewed){
                        finishedCount += count;
                    }
                }
                self.countes = @[@(totalCont),@(unpaidCount),@(paidCount),@(shippedCount),@(finishedCount)];
            }
            
            self.curStatus = status;
            
            [self callback:YES :isMore :nil];
        }
        
    } failure:^(id error) {
        [self callback:NO :isMore :@"当前网络不可用"];
    }];
}

- (void)fetchTeachingOrder:(YGTeachingOrderStatusType)status isMore:(BOOL)isMore
{
    NSUInteger page = 1;
    if (isMore) {
        NSArray *existData = self.orderData[@(status)];
        NSUInteger count = existData.count;
        page = count/kDefaultPageSize+1;
    }
    
    [ServerService fetchTeachOrderList:status coachId:0 memberId:0 keywords:nil page:page pageSize:kDefaultPageSize callBack:^(id obj) {
        if (!obj || ![obj isKindOfClass:[NSDictionary class]]) {
            [self callback:NO :isMore :@"当前网络不可用"];
            return;
        }
        
        NSMutableArray *list = self.orderData[@(status)];
        if (!list) {
            list = [NSMutableArray array];
        }
        NSArray *datalist = obj[@"data_list"];
        NSMutableArray *orderList = [NSMutableArray array];
        for (NSDictionary *dic in datalist) {
            TeachingOrderModel *tom = [[TeachingOrderModel alloc] initWithDic:dic];
            tom?[orderList addObject:tom]:0;
        }
        if (isMore) {
            [list addObjectsFromArray:orderList];
        }else{
            list = orderList;
        }
        self.orderData[@(status)] = list;
        self.orderList = list;
        
        if (status == 0 || !isMore) {
            self.titles = @[@"全部",@"待付款",@"教学中",@"已完成"];
            self.statues = @[@0,@(YGTeachingOrderStatusTypeWaitPay),@(YGTeachingOrderStatusTypeTeaching),@(YGTeachingOrderStatusTypeCompleted)];
            
            NSInteger totalCount = 0,waitPayCount = 0,teachingCount = 0,completedCount = 0;
            
            NSArray *countList = obj[@"total_list"];
            for (NSDictionary *aCount in countList) {
                YGTeachingOrderStatusType status = [aCount[@"order_state"] intValue];
                NSInteger count = [aCount[@"order_count"] integerValue];
                
                totalCount += count;
                
                if (status == YGTeachingOrderStatusTypeWaitPay) {
                    waitPayCount += count;
                }else if (status == YGTeachingOrderStatusTypeTeaching){
                    teachingCount += count;
                }else if (status == YGTeachingOrderStatusTypeCompleted){
                    completedCount += count;
                }
            }
            self.countes = @[@(totalCount),@(waitPayCount),@(teachingCount),@(completedCount)];
        }
        self.curStatus = status;
        [self callback:YES :isMore :nil];
        
    } failure:^(id error) {
        [self callback:NO :isMore :@"当前网络不可用"];
    }];
}

@end
