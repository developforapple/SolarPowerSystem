//
//  ServiceManager.m
//  Golf
//
//  Created by user on 13-8-12.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import "ServiceManager.h"
#import "SpecialOfferModel.h"
#import "ClubModel.h"
#import "ActivityModel.h"
#import "TeeTimeModel.h"
#import "TeeTimeAgentModel.h"
#import "PackageModel.h"
#import "ClubFairwayModel.h"
#import "DepositInfoModel.h"
#import "OrderDetailModel.h"
#import "UserCommentModel.h"
#import "CouponModel.h"
#import "SearchClubModel.h"
#import "TeachingCoachModel.h"
#import "CoachDetailCommentModel.h"
#import "MemberReservationModel.h"
#import "MemberClassModel.h"
#import "OrderCancelModel.h"
#import "CoachTimetable.h"
#import "BaseService.h"
#import "TrendsModel.h"
#import "TrendsMessageModel.h"
#import "PersonInAddressList.h"
#import "YGCacheDataHelper.h"
#import "YGUserRemarkCacheHelper.h"
#import "PackageDetailModel.h"
#import "WeatherModel.h"
#import "SearchProvinceModel.h"

Class object_getClass(id object);

@implementation ServiceManager

+ (ServiceManager*)serviceManagerInstance{
    ServiceManager *instance = [[ServiceManager alloc] init];
    return instance;
}

+ (ServiceManager*)serviceManagerWithDelegate:(id<ServiceManagerDelegate>)aDelegate{
    ServiceManager *serviceManagerInstance = [[ServiceManager alloc] init];
    serviceManagerInstance.delegate = aDelegate;
    serviceManagerInstance.orignalClass = [aDelegate class];
    return serviceManagerInstance;
}

- (void)dealloc{
    _delegate = nil;
}

// 公共课
- (void)getPublicListWithLo:(double)longitude
                         la:(double)latitude
                    keyWord:(NSString*)keyWord
                     cityId:(int)cityId
                     pageNo:(int)pageNo
                   pageSize:(int)pageSize{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (longitude != 0 && latitude != 0) {
        [params setObject:@(longitude) forKey:@"longitude"];
        [params setObject:@(latitude) forKey:@"latitude"];
    }else{
        [params setObject:@(114) forKey:@"longitude"];
        [params setObject:@(22) forKey:@"latitude"];
    }
    if (keyWord.length>0) {
        [params setObject:keyWord forKey:@"keyword"];
    }
    if (cityId > 0) {
        [params setObject:@(cityId) forKey:@"city_id"];
    }
    if (pageNo > 0) {
        [params setObject:@(pageNo) forKey:@"page_no"];
    }
    if (pageSize) {
        [params setObject:@(pageSize) forKey:@"page_size"];
    }
    self.needLoading = NO;
    [self asynchronousGet:@"teaching_public_class_info" params:params];
}

- (void)getSpecialOfferList:(int)cityId                 //***********************特价时段
                 provinceId:(int)provinceId
                  longitude:(float)longitude
                   latitude:(float)latitude
                    weekDay:(NSInteger)weekDay{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (cityId > 0) {
        [params setObject:[NSNumber numberWithInt:cityId] forKey:@"city_id"];
    }
    if (provinceId > 0) {
        [params setObject:[NSNumber numberWithInt:provinceId] forKey:@"province_id"];
    }
    if (longitude > 0) {
        [params setObject:[NSNumber numberWithFloat:longitude] forKey:@"longitude"];
    }
    if (latitude > 0) {
        [params setObject:[NSNumber numberWithFloat:latitude] forKey:@"latitude"];
    }
    [params setObject:[NSNumber numberWithInteger:weekDay] forKey:@"week_day"];
    [params setObject:[GolfAppDelegate shareAppDelegate].range forKey:@"range"];
    
    [self asynchronousGet:@"search_special_offer" params:params];
}

- (void)getActivityListByLongitude:(double)longitude latitude:(double)latitude putArea:(int)putArea  //投放区域 1：首页（缺省) 2：教学 3：入门 4: 订场 6.商品乐活动
             resolution:(int)resolution needGroup:(BOOL)needGroup preventError:(BOOL)preventError{ //分辩率 1：高 2:中（缺省) 3:低
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (longitude!=0 &&latitude!=0) {
        [params setObject:@(longitude) forKey:@"longitude"];
        [params setObject:@(latitude) forKey:@"latitude"];
    }
    if (putArea != 0) {
        [params setObject:@(putArea) forKey:@"put_area"];
    }
    if (resolution != 0) {
        [params setObject:@(resolution) forKey:@"resolution"];
    }

    [params setObject:needGroup ? @"1":@"0" forKey:@"need_group"];
    
    self.preventError = preventError;
    [self asynchronousGet:@"activity_list" params:params];
}

- (void)searchClubWithCondition:(ConditionModel *)condition
                       withPage:(int)page
                   withPageSize:(int)pageSize
                    withVersion:(NSString*)version
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if(condition){
        if(condition.provinceId > 0){
            [params setObject:@(condition.provinceId) forKey:@"province_id"];
        }
        if(condition.cityId > 0){
            [params setObject:@(condition.cityId) forKey:@"city_id"];
        }
        if(condition.longitude){
            [params setObject:@(condition.longitude) forKey:@"longitude"];
        }else{
            [params setObject:@(114) forKey:@"longitude"];
        }
        if(condition.latitude){
            [params setObject:@(condition.latitude) forKey:@"latitude"];
        }else{
            [params setObject:@(22) forKey:@"latitude"];
        }
        if(condition.range){
            [params setObject:condition.range forKey:@"range"];
        }
        if(condition.time){
            [params setObject:condition.time forKey:@"time"];
        }else{
            [params setObject:@"" forKey:@"time"];
        }
        if(condition.date){
            [params setObject:condition.date forKey:@"date"];
        }
        if (condition.clubName.length>0) {
            [params setObject:condition.clubName forKey:@"club_name"];
        }
        if (condition.clubIds) {
            [params setObject:condition.clubIds forKey:@"club_ids"];
        }
        if (condition.range.length == 0) {
            [params setObject:[GolfAppDelegate shareAppDelegate].range forKey:@"range"];
        }else{
            [params setObject:condition.range forKey:@"range"];
        }
    }
    if(page > 0){
        [params setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    }
    if(pageSize > 0){
        [params setObject:[NSNumber numberWithInt:pageSize] forKey:@"page_size"];
    }
    if(version){
        [params setObject:version forKey:@"version"];
    }
    
    [self asynchronousGet:@"search_club" params:params];
    
}

- (void) searchTeeTime:(int)clubId
           withAgentId:(int)agentId
              withDate:(NSString *)date
              withTime:(NSString *)time
           withVersion:(NSString*)version
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if(clubId>0){
        [params setObject:[NSNumber numberWithInt:clubId] forKey:@"club_id"];
    }
    // 商家Id
    [params setObject:[NSNumber numberWithInt:agentId] forKey:@"agent_id"];
    
    if(date){
        [params setObject:date forKey:@"date"];
    }
    if(time){
        [params setObject:time forKey:@"time"];
    }
    if(version){
        [params setObject:version forKey:@"version"];
    }
    [self asynchronousGet:@"search_teetime" params:params];
}

- (void)searchNewTeeTime:(int)clubId agentId:(int)agentId date:(NSString*)date time:(NSString*)time{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if(clubId>0){
        [params setObject:[NSNumber numberWithInt:clubId] forKey:@"club_id"];
    }
    if(agentId>0){
        [params setObject:[NSNumber numberWithInt:agentId] forKey:@"agent_id"];
    }
    if(date){
        [params setObject:date forKey:@"date"];
    }
    if(time){
        [params setObject:time forKey:@"time"];
    }
    [params setObject:@(4.4) forKey:@"version"];
    [self asynchronousGet:@"search_teetime2" params:params];
}

- (void)searchClubFreeTeetime:(int)clubId date:(NSString *)date{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if(clubId>0){
        [params setObject:[NSNumber numberWithInt:clubId] forKey:@"club_id"];
    }
    if(date){
        [params setObject:date forKey:@"date"];
    }
    [self asynchronousGet:@"club_free_teetime" params:params];
}

- (void)searchUser:(NSString *)session_id keyword:(NSString *)keyword{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (session_id) {
        [params setObject:session_id forKeyedSubscript:@"session_id"];
    }
    if(keyword){
        [params setObject:keyword forKey:@"keyword"];
    }
    [self asynchronousGet:@"user_search" params:params];
}

- (void)getAllClubs{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *lastUpdateTime = [[NSUserDefaults standardUserDefaults] objectForKey:kYGGolfClubLastUpdateTimeKey];
    
    [params setValue:lastUpdateTime forKey:@"last_update_time"];
    [self asynchronousGet:@"club_all_list" params:params];
}

- (void)getClubInfo:(int)clubId needPackage:(int)flag{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if(clubId > 0){
        [params setObject:@(clubId) forKey:@"club_id"];
    }
    
    [params setObject:[NSNumber numberWithInt:flag] forKey:@"need_package"];
    [params setObject:[NSNumber numberWithInt:0] forKey:@"need_topic"];
    
    [self asynchronousGet:@"club_info" params:params];
}

- (void)getClubSpecialOffList:(int)clubId weekDay:(NSInteger)weekDay date:(NSString*)date{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (clubId > 0) {
        [params setObject:@(clubId) forKey:@"club_id"];
    }
    [params setObject:@(weekDay) forKey:@"week_day"];
    if (date) {
        [params setObject:date forKey:@"date"];
    }
    
    [self asynchronousGet:@"club_special_offer" params:params];
}

- (void)getCityPackageListWithCityId:(int)cityId provinceId:(int)provinceId longitude:(float)longitude latitude:(float)latitude pageSize:(int)size pageNo:(int)pageNo{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (cityId > 0) {
        [params setObject:[NSNumber numberWithInt:cityId] forKey:@"city_id"];
    }
    if (provinceId > 0) {
        [params setObject:[NSNumber numberWithInt:provinceId] forKey:@"province_id"];
    }
    if (longitude > 0) {
        [params setObject:[NSNumber numberWithFloat:longitude] forKey:@"longitude"];
    }
    if (latitude > 0) {
        [params setObject:[NSNumber numberWithFloat:latitude] forKey:@"latitude"];
    }
    if(size > 0) {
        [params setObject:[NSNumber numberWithInt:size] forKey:@"page_size"];
    }
    if (pageNo > 0) {
        [params setObject:[NSNumber numberWithInt:pageNo] forKey:@"page_no"];
    }
    [params setObject:[GolfAppDelegate shareAppDelegate].range forKey:@"range"];
    
    [self asynchronousGet:@"city_package_list" params:params];
}

- (void)getClubPackageListWithClubId:(int)clubId{                           //球会套餐
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (clubId > 0) {
        [params setObject:[NSNumber numberWithInt:clubId] forKey:@"club_id"];
    }
    [self asynchronousGet:@"club_package_list" params:params];
}

- (void)getClubFairwayList:(int)clubId{                                     //球道集列表
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if(clubId){
        [params setObject:@(clubId) forKey:@"club_id"];
    }
    [self asynchronousGet:@"club_fairway_list" params:params];
}

- (void)getPackageDetailListWithPackageId:(int)packageId clubId:(int)clubId agentId:(int)agentId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (packageId > 0) {
        [params setObject:[NSNumber numberWithInt:packageId] forKey:@"package_id"];
    }
    if (clubId > 0) {
        [params setObject:[NSNumber numberWithInt:clubId] forKey:@"club_id"];
    }
    if (agentId > 0) {
        [params setObject:[NSNumber numberWithInt:agentId] forKey:@"agent_id"];
    }
    [self asynchronousGet:@"package_detail" params:params];
}

- (void)getWeatherInfoWithCityId:(int)cityId{     // *****************************天气预报
    self.preventError = YES;
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (cityId > 0) {
        [params setObject:[NSNumber numberWithInt:cityId] forKey:@"city_id"];
    }
    
    [self asynchronousGet:@"city_weather" params:params];
}

- (void)getOrderList:(NSString *)sessionId      // *******************************订单列表
          withStatus:(OrderStatusEnum)status
         withPayType:(PayTypeEnum)payType
            withPage:(int)page
        withPageSize:(int)pageSize
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if(sessionId){
        [params setObject:sessionId forKey:@"session_id"];
    }
    if(payType>0){
        [params setObject:[NSNumber numberWithInt:payType] forKey:@"pay_type"];
        if(status){
            [params setObject:[NSNumber numberWithInt:status] forKey:@"order_state"];
        }
    }
    if(page){
        [params setObject:[NSNumber numberWithInt:page] forKey:@"page_no"];
    }
    if(pageSize){
        [params setObject:[NSNumber numberWithInt:pageSize] forKey:@"page_size"];
    }
    

    [self asynchronousGet:@"order_list" params:params];
}

- (void)getDepositInfo:(NSString *)sessionId needCount:(int)needCount{     // **************获取保证金信息
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:0];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    if (needCount > 0) {
        [params setObject:@(needCount) forKey:@"need_count"];
    }
    
    [self asynchronousGet:@"deposit_info" params:params];
}

- (void)getDepositInfoData:(NSString *)sessionId callBack:(void(^)(DepositInfoModel *model))callBack{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:0];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [self get:@"deposit_info" params:params completion:^(id obj) {
        NSDictionary *resultDic = (NSDictionary *)obj;
        if (resultDic) {
            DepositInfoModel *info = [DepositInfoModel yy_modelWithJSON:resultDic];
            callBack (info);
        }
    }];
}

- (void)depositRechargeUnionpay:(NSString *)sessionId withMoney:(int)money isMobile:(int)isMobile payChannel:(NSString *)aPayChannel callBack:(void(^)(NSDictionary *data))callBack{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if(sessionId){
        [params setObject:sessionId forKey:@"session_id"];
    }
    if(money){
        [params setObject:[NSNumber numberWithInt:money * 100] forKey:@"money"];
    }
    [params setObject:[NSNumber numberWithInt:isMobile] forKey:@"is_mobile"];
    if (aPayChannel) {
        [params setObject:aPayChannel forKey:@"pay_channel"];
    }
    [self get:@"deposit_recharge_unionpay" params:params completion:^(id obj) {
        NSDictionary *resultDic = (NSDictionary *)obj;
        callBack (resultDic);
    }];
}

- (void) getOrderDetail:(NSString *)sessionId withOrderId:(int)orderId flag:(NSString*)flag{     // 订单详情
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if(sessionId){
        [params setObject:sessionId forKey:@"session_id"];
    }
    if(orderId){
        [params setObject:[NSNumber numberWithInt:orderId] forKey:@"order_id"];
    }
    
    if (Equal(flag, @"order_detail")) {
        
    }
    
    [self asynchronousGet:flag params:params];
}

- (void)getWaitPay:(NSString *)phone{                               // 待付款订单数
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if(phone){
        [params setObject:phone forKey:@"phone_num"];
    }
    
    [self asynchronousGet:@"get_waitpay" params:params];
}


- (void)getCouponListWithSessionId:(NSString*)sessionId status:(int)status{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [params setObject:@(status) forKey:@"coupon_status"];
    
    [self asynchronousGet:@"coupon_list" params:params];
}

- (void)getCouponListWithSessionId:(NSString*)sessionId
                            status:(int)status
                            pageNo:(int)pageNo
                          pageSize:(int)pageSize
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    
    [params setObject:@(status) forKey:@"coupon_status"];
    [params setObject:@(pageNo) forKey:@"page_no"];
    [params setObject:@(pageSize) forKey:@"page_size"];
    
    [self asynchronousGet:@"coupon_list" params:params];
}

- (void)getCommentListByPage:(int)page pageSize:(int)pageSize coachId:(int)coachId productId:(int)productId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(productId) forKey:@"product_id"];
    [params setObject:@(coachId) forKey:@"coach_id"];
    [params setObject:@(page) forKey:@"page_no"];
    [params setObject:@(pageSize) forKey:@"page_size"];
    
    [self asynchronousGet:@"teaching_comment_list" params:params];
}

- (void)getTeachingMemberByReservationStatus:(int)status pageNo:(int)pageNo pageSize:(int)pageSize sessionId:(NSString *)sessionId coachId:(int)coachId memberId:(int)memberId keyword:(NSString*)keyword{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    if (pageNo > 0) {
        [params setObject:@(pageNo) forKey:@"page_no"];
    }
    if (pageSize > 0) {
        [params setObject:@(pageSize) forKey:@"page_size"];
    }
    if (coachId>0) {
        [params setObject:@(coachId) forKey:@"coach_id"];
    }
    if (memberId>0) {
        [params setObject:@(memberId) forKey:@"member_id"];
    }
    [params setObject:@(status) forKey:@"reservation_status"];
    if (keyword) {
        [params setObject:keyword forKey:@"keyword"];
    }
    
    [self asynchronousGet:@"teaching_member_reservation_list" params:params];
}

- (void)getCoachListByPageNo:(int)pageNo pageSize:(int)pageSize withLongitude:(double)longitude latitude:(double)latitude cityId:(int)cityId orderBy:(int)orderBy date:(NSString *)date time:(NSString *)time keyword:(NSString *)keyword academyId:(int)academyId productId:(int)productId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(cityId) forKey:@"city_id"];
    if (longitude != 0 && latitude != 0) {
        [params setObject:@(longitude) forKey:@"longitude"];
        [params setObject:@(latitude) forKey:@"latitude"];
    }else{
        [params setObject:@(114) forKey:@"longitude"];
        [params setObject:@(22) forKey:@"latitude"];
    }
    [params setObject:@(pageNo) forKey:@"page_no"];
    [params setObject:@(pageSize) forKey:@"page_size"];
    [params setObject:@(orderBy) forKey:@"order_by"];
    [params setObject:@(productId) forKey:@"product_id"];
    if (date) {
        [params setObject:date forKey:@"date"];
    }
    if (time) {
        [params setObject:time forKey:@"time"];
    }
    if (academyId > 0) {
        [params setObject:@(academyId) forKey:@"academy_id"];
    }
    if (keyword) {
        [params setObject:keyword forKey:@"keyword"];
    }
    
    [self asynchronousGet:@"teaching_coach_info" params:params];
}

- (void)teachingMemberClassCancelByReservationId:(int)reservationId coachId:(int)coachId sessionId:(NSString *)sessionId periodId:(int) periodId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [params setObject:@(coachId) forKey:@"coach_id"];
    [params setObject:@(reservationId) forKey:@"reservation_id"];
    [params setObject:@(periodId) forKey:@"period_id"];
    
    [self asynchronousGet:@"teaching_member_reservation_cancel" params:params];
}



- (void)teachingMemberClassCancelByReservationId:(int)reservationId coachId:(int)coachId sessionId:(NSString *)sessionId
{
    [self teachingMemberClassCancelByReservationId:reservationId coachId:coachId sessionId:sessionId periodId:0];
}


- (void)teachingOrderCancelByOrderId:(int)orderId sessionId:(NSString *)sessionId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [params setObject:@(orderId) forKey:@"order_id"];
    [self asynchronousGet:@"teaching_order_cancel" params:params];
}

- (void)getTeachingMemberClassDetailByClassId:(int)classId orderId:(int)orderId sessionId:(NSString *)sessionId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [params setObject:@(classId) forKey:@"class_id"];
    [params setObject:@(orderId) forKey:@"order_id"];
    
    [self asynchronousGet:@"teaching_member_class_detail" params:params];
}

- (void)getTeachInfoDetailByReservationId:(int)reservationId sessionId:(NSString *)sessionId coachId:(int)coachId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [params setObject:@(coachId) forKey:@"coach_id"];
    [params setObject:@([LoginManager sharedManager].currLatitude) forKey:@"latitude"];
    [params setObject:@([LoginManager sharedManager].currLongitude) forKey:@"longitude"];
    [params setObject:@(reservationId) forKey:@"reservation_id"];
    if (coachId>0) {
        [params setObject:@(coachId) forKey:@"coach_id"];
    }
    
    [self asynchronousGet:@"teaching_member_reservation_detail" params:params];
}

- (void)teachingUpdateTimetableByCoachId:(int)coachId date:(NSString *)date time:(NSString *)time operation:(int)operation sessionId:(NSString *)sessionId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(coachId) forKey:@"coach_id"];
    if (date && date.length > 0) {
        [params setObject:date forKey:@"date"];
    }
    
    if (time && time.length > 0) {
        [params setObject:time forKey:@"time"];
    }
    
    [params setObject:@(operation) forKey:@"operation"];
    if (sessionId != nil && sessionId.length > 0) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    
    [self asynchronousGet:@"teaching_coach_update_timetable" params:params];
}

- (void)teachingCoachTimetableByCoachId:(int)coachId sessionId:(NSString *)sessionId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(coachId) forKey:@"coach_id"];
    
    [self asynchronousGet:@"teaching_coach_timetable" params:params];
}

- (void)teachingUpdateTimeSetByCoachId:(int)coachId timeSet:(NSString *)timeSet sessionId:(NSString *)sessionId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(coachId) forKey:@"coach_id"];
    [params setObject:timeSet forKey:@"time_set"];
    if (sessionId != nil && sessionId.length > 0) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    
    [self asynchronousGet:@"teaching_coach_update_timeset" params:params];
}

- (void)getCoachDetailByCoachId:(int)coachId longitude:(double)longitude latitude:(double)latitude sessionId:(NSString *)sessionId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(coachId) forKey:@"coach_id"];
    if (sessionId != nil && sessionId.length > 0) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [params setObject:@(longitude) forKey:@"longitude"];
    [params setObject:@(latitude) forKey:@"latitude"];
    
    [self asynchronousGet:@"teaching_coach_detail" params:params];
}

- (void)searchCoachWithLongitude:(double)longitude
                    withLatitude:(double)latitude
                   withCoachName:(NSString *)coachName
                          pageNo:(int)pageNo
                        pageSize:(int)pageSize{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(longitude) forKey:@"longitude"];
    [params setObject:@(latitude) forKey:@"latitude"];
    if (coachName) {
        [params setObject:coachName forKey:@"coach_name"];
    }
    [params setObject:@(pageNo) forKey:@"page_no"];
    [params setObject:@(pageSize) forKey:@"page_size"];
    [self asynchronousGet:@"search_coach" params:params];
}

- (void)getCoachDetailWithCoachId:(int)coachId imeiNum:(NSString *)imeiNum{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(coachId) forKey:@"coach_id"];
    if (imeiNum) {
        [params setObject:imeiNum forKey:@"imei_num"];
    }
    [params setObject:@(5) forKey:@"version"];
    [self asynchronousGet:@"coach_detail" params:params];
}

- (void)getTeachingMemberClassList:(NSString *)sessionId coachId:(int)coachId{
    if (sessionId) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:sessionId forKey:@"session_id"];
        [params setObject:@(coachId) forKey:@"coach_id"];
        
        [self asynchronousGet:@"teaching_member_class_list" params:params];
    }
}

- (void)getTeachingAcademyList:(double)longitude latitude:(double)latitude cityId:(int)cityId keyword:(NSString *)keyword pageNo:(int)pageNo pageSize:(int)pageSize{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];
    [params setObject:[NSNumber numberWithDouble:latitude] forKey:@"latitude"];
    if (keyword.length > 0) {
        [params setObject:keyword forKey:@"keyword"];
    }
    [params setObject:@(cityId) forKey:@"city_id"];
    [params setObject:@(pageNo) forKey:@"page_no"];
    [params setObject:@(pageSize) forKey:@"page_size"];
    
    [self asynchronousGet:@"teaching_academy_info" params:params];
}

- (void)getAcademyList:(double)longitude :(double)latitude keyWord:(NSString*)kw pageNo:(int)p_n pageSize:(int)p_s{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithDouble:longitude] forKey:@"longitude"];
    [params setObject:[NSNumber numberWithDouble:latitude] forKey:@"latitude"];
    if (kw.length>0) {
        [params setObject:kw forKey:@"keyword"];
    }
    [params setObject:@(p_n) forKey:@"page_no"];
    [params setObject:@(p_s) forKey:@"page_size"];
    if (!kw) {
        
    }
    [self asynchronousGet:@"search_academy" params:params];
}

- (void)drivingRangePosition:(int)drivingrangeId areaName:(NSString*)areaName{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(drivingrangeId) forKey:@"driving_range_id"];
    if (areaName) {
        [params setObject:areaName forKey:@"area_name"];
    }
    [self asynchronousGet:@"driving_range_position" params:params];
}

- (void)drivingRangePictureList:(int)drivingrangeId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(drivingrangeId) forKey:@"driving_range_id"];
    [self asynchronousGet:@"driving_range_picture_list" params:params];
}

- (void)getAcademyDetail:(int)academyId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(academyId) forKey:@"academy_id"];
    [self asynchronousGet:@"academy_detail" params:params];
}

- (void)getTeachingAcademyDetail:(int)academyId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(academyId) forKey:@"academy_id"];
    [params setObject:@([LoginManager sharedManager].currLatitude) forKey:@"latitude"];
    [params setObject:@([LoginManager sharedManager].currLongitude) forKey:@"longitude"];
    
    [self asynchronousGet:@"teaching_academy_detail" params:params];
}

- (void)getAcademyNameList{
    [self asynchronousGet:@"dict_academy" params:nil];
}

- (void)coachEditAlbumWithSessionId:(NSString*)sessionId coachId:(int)coachId imageDelete:(NSString*)imageDelete imageData:(NSString*)imageData{
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [params setObject:@(coachId) forKey:@"coach_id"];
    if (imageDelete) {
        [params setObject:imageDelete forKey:@"image_delete"];
    }
    if (imageData) {
        [params setObject:imageData forKey:@"image_data"];
    }
    
    [self post:@"coach_edit_album" params:params];
}

- (void)getClubPictureList:(int)clubId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(clubId) forKey:@"club_id"];
    [self asynchronousGet:@"club_picture_list" params:params];
}

- (void)getCitysData:(int)flag{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *golfVersion = flag > 0 ? @"GolfCitiesVersion" : @"GolfProvincesVersion";
    NSString *currentVersion = [[NSUserDefaults standardUserDefaults] objectForKey:golfVersion];
    if (currentVersion) {
        [params setObject:currentVersion forKey:@"version"];
    }
    else{
        [params setObject:@"" forKey:@"version"];
    }
    
    NSString *interfaceName = flag > 0 ? @"dict_city" : @"dict_province";
    [self asynchronousGet:interfaceName params:params];
}

- (void)addTeachingComment:(NSString *)txt commentLevel:(int)commentLevel reservationId:(int)reservationId sessionId:(NSString *)sessionId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    if(sessionId){
        [params setObject:sessionId forKey:@"session_id"];
    }
    [params setObject:@(reservationId) forKey:@"reservation_id"];
    [params setObject:@(commentLevel) forKey:@"comment_level"];
    if (txt) {
        [params setObject:txt forKey:@"comment_content"];
    }
    [self asynchronousGet:@"teaching_comment_add" params:params];
}

- (void)getCommodityCategoryData{
    
    [self asynchronousGet:@"commodity_category" params:nil];
}

- (void)getCommodityInfoList:(NSString *)aCategoryId brandId:(NSString *)brandId commodityIds:(NSString *)ids longitude:(double)alongitude latitude:(double)aLatitude{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (aCategoryId) {
        [params setObject:aCategoryId forKey:@"category_id"];
    }
    if (brandId) {
        [params setObject:brandId forKey:@"brand_id"];
    }
    if (ids) {
        [params setObject:ids forKey:@"commodity_ids"];
    }
    [params setObject:@(alongitude) forKey:@"longitude"];
    [params setObject:@(aLatitude) forKey:@"latitude"];
    [params setObject:@(20) forKey:@"page_size"];
    
    [self asynchronousGet:@"commodity_info" params:params];
}

- (void)getCommodityInfoList:(int)aCategoryId brandId:(int)brandId subCategoryId:(int)subCategoryId orderBy:(int)aOrderBy longitude:(double)alongitude latitude:(double)aLatitude keyWord:(NSString*)aKeyWord pageNo:(int)aNo{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(aCategoryId) forKey:@"category_id"];
    [params setObject:@(brandId) forKey:@"brand_id"];
    [params setObject:@(subCategoryId) forKey:@"sub_category_id"];
    [params setObject:@(aOrderBy) forKey:@"order_by"];
    [params setObject:@(alongitude) forKey:@"longitude"];
    [params setObject:@(aLatitude) forKey:@"latitude"];
    [params setObject:@(aNo) forKey:@"page_no"];
    [params setObject:@(20) forKey:@"page_size"];
    if (aKeyWord.length>0) {
        [params setObject:aKeyWord forKey:@"keyword"];
    }
    
    [self asynchronousGet:@"commodity_info" params:params];
}

- (void)getCommodityAuctionWithLongitude:(double)alongitude latitude:(double)aLatitude pageNo:(int)aNo pageSize:(int)aSize{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(alongitude) forKey:@"longitude"];
    [params setObject:@(aLatitude) forKey:@"latitude"];
    [params setObject:@(aNo) forKey:@"page_no"];
    [params setObject:@(aSize) forKey:@"page_size"];
    
    [self asynchronousGet:@"commodity_auction" params:params];
}

- (void)getCommodityDetail:(int)aCommodityId auctionId:(int)aAuctionId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(aCommodityId) forKey:@"commodity_id"];
    [params setObject:@(aAuctionId) forKey:@"auction_id"];
    
    [self asynchronousGet:@"commodity_detail" params:params];
}

- (void)getCommodityAuctionStatus:(int)auctionId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(auctionId) forKey:@"auction_id"];
    [params setObject:@(4.3) forKey:@"version"];
    
    [self asynchronousGet:@"commodity_auction_status" params:params];
}

- (void)commodityOrderSubmit:(CommodityParamModel *)model {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSMutableString *specidString = [NSMutableString string];
    NSMutableString *quantityString = [NSMutableString string];
    
    if (model.sessionId) {
        [params setObject:model.sessionId forKey:@"session_id"];
    }
    [params setObject:@(model.auctionId) forKey:@"auction_id"];
    [params setObject:@(model.commodityId) forKey:@"commodity_id"];
    [params setObject:@(model.price*100) forKey:@"price"];
    [params setObject:@(model.freight*100) forKey:@"freight"];
    [params setObject:@(model.isMobile) forKey:@"is_mobile"];
    if (model.linkMan) {
        [params setObject:model.linkMan forKey:@"link_man"];
    }
    if (model.linkPhone) {
        [params setObject:model.linkPhone forKey:@"link_phone"];
    }
    if (model.address) {
        [params setObject:model.address forKey:@"address"];
    }
    if (model.userMemo) {
        [params setObject:model.userMemo forKey:@"user_memo"];
    }
//    for (SoldModel *m in model.quantityList) {
//        [specidString appendFormat:@"%d,",m.specId];
//        [quantityString appendFormat:@"%d,",m.quantityAfterSelected];
//    }
    [params setObject:specidString forKey:@"spec_id"];
    [params setObject:quantityString forKey:@"quantity"];
    [self asynchronousGet:@"commodity_order_submit" params:params];
}

- (void)getDeliveryAddressList:(NSString*)sessionId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    

    [self asynchronousGet:@"delivery_address_list" params:params];
}

- (void)getCommodityCommentList:(int)commodityId level:(int)aLevel pageNo:(int)pageNo{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(commodityId) forKey:@"commodity_id"];
    [params setObject:@(aLevel) forKey:@"comment_level"];
    [params setObject:@(pageNo) forKey:@"page_no"];
    [params setObject:@(20) forKey:@"page_size"];
    [self asynchronousGet:@"commodity_comment_list" params:params];
}

- (void)CommodityCommentAdd:(NSString*)aSessionId orderId:(int)aOrderId level:(int)alevel content:(NSString*)aContent{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (aSessionId) {
        [params setObject:aSessionId forKey:@"session_id"];
    }
    [params setObject:@(aOrderId) forKey:@"order_id"];
    [params setObject:@(alevel) forKey:@"comment_level"];
    if (aContent) {
        [params setObject:aContent forKey:@"comment_content"];
    }
    [self asynchronousGet:@"commodity_comment_add" params:params];
}

//- (void)modifyDeliveryAddress:(NSString*)aSessionId operation:(int)operation addressInfo:(DeliveryAddressModel*)model{
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//    if (aSessionId) {
//        [params setObject:aSessionId forKey:@"session_id"];
//    }
//    [params setObject:@(operation) forKey:@"operation"];
//    [params setObject:@(model.addressId) forKey:@"address_id"];
//    if (model.linkMan) {
//        [params setObject:model.linkMan forKey:@"link_man"];
//    }
//    if (model.linkPhone) {
//        [params setObject:model.linkPhone forKey:@"link_phone"];
//    }
//    if (model.postCode) {
//        [params setObject:model.postCode forKey:@"post_code"];
//    }
//    if (model.province) {
//        [params setObject:model.province forKey:@"province_name"];
//    }
//    if (model.city) {
//        [params setObject:model.city forKey:@"city_name"];
//    }
//    if (model.district) {
//        [params setObject:model.district forKey:@"district_name"];
//    }
//    if (model.address) {
//        [params setObject:model.address forKey:@"address"];
//    }
//    
//
//    [self asynchronousGet:@"delivery_address_maintain" params:params];
//}

- (void)orderPay:(OrderSubmitParamsModel *)model flag:(NSString*)flag{
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
    [self asynchronousGet:flag params:params];
}

- (void)commodityOrderList:(NSString *)aSessionId orderState:(int)aState pageNo:(int)pageNo{
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    if(aSessionId){
        [params setObject:aSessionId forKey:@"session_id"];
    }
    [params setObject:[NSNumber numberWithInt:aState]  forKey:@"order_state"];
    [params setObject:@(pageNo) forKey:@"page_no"];
    [params setObject:@(20) forKey:@"page_size"];
    

    [self asynchronousGet:@"commodity_order_list" params:params];
}

- (void)addCommodityComment:(NSString*)aSessionId orderId:(int)aOrderId level:(int)aLevel content:(NSString*)aContent{
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    if(aSessionId){
        [params setObject:aSessionId forKey:@"session_id"];
    }
    [params setObject:@(aOrderId) forKey:@"order_id"];
    [params setObject:@(aLevel) forKey:@"comment_level"];
    if (aContent) {
        [params setObject:aContent forKey:@"comment_content"];
    }
    [self asynchronousGet:@"commodity_comment_add" params:params];
}

- (void)commodityOrderMaintain:(NSString*)aSessionId orderId:(int)aOrderId operation:(int)aOperation description:(NSString*)aDescription{
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    if(aSessionId){
        [params setObject:aSessionId forKey:@"session_id"];
    }
    [params setObject:@(aOrderId) forKey:@"order_id"];
    [params setObject:@(aOperation) forKey:@"operation"];
    if (aDescription) {
        [params setObject:aDescription forKey:@"description"];
    }
    [self asynchronousGet:@"commodity_order_maintain" params:params];
}

- (void)getDeviceInfo:(NSString*)imeiNum
           deviceName:(NSString*)deviceName
          deviceToken:(NSString*)deviceToken
               osName:(NSString*)osName
            osVersion:(NSString*)osVersion
            sessionId:(NSString*)sessionId
            longitude:(double)longitude
             latitude:(double)latitude{
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    if (imeiNum) {
        [params setObject:imeiNum forKey:@"imei_num"];
    }
    if (deviceName) {
        [params setObject:deviceName forKey:@"device_name"];
    }
    if (deviceToken) {
        [params setObject:deviceToken forKey:@"device_token"];
    }
    if (osName) {
        [params setObject:osName forKey:@"os_name"];
    }
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    if (osVersion) {
        [params setObject:osVersion forKey:@"os_version"];
    }
    [params setObject:@(longitude) forKey:@"longitude"];
    [params setObject:@(latitude) forKey:@"latitude"];
    
    [self asynchronousGet:@"device_info" params:params];
}

- (void)getPackageDetail:(int)aPackageId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithInt:aPackageId] forKey:@"package_id"];
    [self asynchronousGet:@"package_detail" params:params];
}

- (void)systemParamInfo:(NSString *)phone sessionID:(NSString *)sessionID{
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (phone && phone.length>0 && sessionID && sessionID.length > 0) {
        [params setObject:sessionID forKey:@"session_id"];
    }else{
        if(phone && phone.length>0){
            [params setObject:phone forKey:@"phone_num"];
        }
        if (sessionID && sessionID.length > 0) {
            [params setObject:sessionID forKey:@"session_id"];
        }
    }
    [self asynchronousGet:@"system_param" params:params];
}

- (void)UserEditInfo:(NSString*)sessionId
          memberName:(NSString*)memberName
            nickName:(NSString*)nickName
              gender:(int)gender
       headImageData:(NSString*)headImageData
      photoImageData:(NSString*)photoImageData
            birthday:(NSString*)birthday
           signature:(NSString*)signature
            location:(NSString*)location
            handicap:(int)handicap
         personalTag:(NSString*)personalTag
           academyId:(int)academyId
           seniority:(int)seniority
        introduction:(NSString*)introduction
   careerAchievement:(NSString*)careerAchievement
 teachingAchievement:(NSString*)teachingAchievement{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    if (memberName) {
        [params setObject:memberName forKey:@"member_name"];
    }
    if (nickName) {
        [params setObject:nickName forKey:@"nick_name"];
    }
    if (gender>-1 && gender < 2) {
        [params setObject:@(gender) forKey:@"gender"];
    }
    if (headImageData) {
        [params setObject:headImageData forKey:@"head_image_data"];
    }
    if (photoImageData) {
        [params setObject:photoImageData forKey:@"photo_image_data"];
    }
    if (birthday) {
        [params setObject:birthday forKey:@"birthday"];
    }
    if (signature) {
        [params setObject:signature forKey:@"signature"];
    }
    if (location) {
        [params setObject:location forKey:@"location"];
    }
    if (handicap>-100) {
        [params setObject:@(handicap) forKey:@"handicap"];
    }
    if (personalTag) {
        [params setObject:personalTag forKey:@"personal_tag"];
    }
    if (academyId) {
        [params setObject:@(academyId) forKey:@"academy_id"];
    }
    if (seniority) {
        [params setObject:@(seniority) forKey:@"seniority"];
    }
    if (introduction) {
        [params setObject:introduction forKey:@"introduction"];
    }
    if (careerAchievement) {
        [params setObject:careerAchievement forKey:@"career_achievement"];
    }
    if (teachingAchievement) {
        [params setObject:teachingAchievement forKey:@"teaching_achievement"];
    }
    
    [self post:@"user_edit_info" params:params];
}

- (void)activityDetail:(int)activityId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(activityId) forKey:@"activity_id"];
    [self asynchronousGet:@"activity_detail" params:params];
}

- (void)userWithdraw:(NSString *)sessionId amount:(int)amount{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [params setObject:@(amount*100) forKey:@"withdraw_amount"];
    [self asynchronousGet:@"user_withdraw" params:params];
}

- (void)commodityArrivalNotice:(int)commodityId specId:(int)specId deviceToken:(NSString*)deviceToken{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(commodityId) forKey:@"commodity_id"];
    [params setObject:@(specId) forKey:@"spec_id"];
    if (deviceToken) {
        [params setObject:deviceToken forKey:@"device_token"];
    }
    [self asynchronousGet:@"commodity_arrival_notice" params:params];
}

- (void)consumeAward:(NSString *)sessionId orderId:(int)orderId orderType:(NSString *)orderType{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [params setObject:@(orderId) forKey:@"order_id"];
    if (orderType) {
        [params setObject:orderType forKey:@"order_type"];
    }
    [self asynchronousGet:@"consume_award" params:params];
}

- (void)getClubCommentList:(int)clubId pageNo:(int)pageNo{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(clubId) forKey:@"club_id"];
    [params setObject:@(pageNo) forKey:@"page_no"];
    [params setObject:@(20) forKey:@"page_size"];
    [self asynchronousGet:@"club_comment_list" params:params];
}

- (void)accountConsumeList:(NSString*)aSessionId consumeType:(int)aType pageNo:(int)pageNo{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (aSessionId) {
        [params setObject:aSessionId forKey:@"session_id"];
    }
    [params setObject:@(aType) forKey:@"account_type"];
    [params setObject:@(pageNo) forKey:@"page_no"];
    [params setObject:@(20) forKey:@"page_size"];
    
    [self asynchronousGet:@"account_consume_list" params:params];
}

- (void)getRedPackeList:(NSString *)aSessionId type:(int)type pageNo:(int)pageNo pageSize:(int)pageSize{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (aSessionId) {
        [params setObject:aSessionId forKey:@"session_id"];
    }
    [params setObject:@(type) forKey:@"packet_type"];
    [params setObject:@(pageNo) forKey:@"page_no"];
    [params setObject:@(pageSize) forKey:@"page_size"];
    [self asynchronousGet:@"redpacket_list" params:params];
}

- (void)redPaperDetail:(NSString *)aSessionId Id:(int)redPaperId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (aSessionId) {
        [params setObject:aSessionId forKey:@"session_id"];
    }
    [params setObject:@(redPaperId) forKey:@"redpacket_id"];
    [self asynchronousGet:@"redpacket_detail" params:params];
}

- (void)articleCategory{
    [self asynchronousGet:@"article_category" params:nil];
}

- (void)articleInfo:(int)categoryId pageNo:(int)pageNo pageSize:(int)pageSize keyWord:(NSString*)keyWord{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(categoryId) forKey:@"category_id"];
    [params setObject:@(pageNo) forKey:@"page_no"];
    [params setObject:@(pageSize) forKey:@"page_size"];
    if (keyWord.length>0) {
        [params setObject:keyWord forKey:@"keyword"];
    }
    [self asynchronousGet:@"article_info" params:params];
}

- (void)articleDetail:(int)articleId imeiNum:(NSString*)imeiNum{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(articleId) forKey:@"article_id"];
    if (imeiNum) {
        [params setObject:imeiNum forKey:@"imei_num"];
    }
    [self asynchronousGet:@"article_detail" params:params];
}

- (void)articleCommentList:(int)articleId pageNo:(int)pageNo pageSize:(int)pageSize{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(articleId) forKey:@"article_id"];
    [params setObject:@(pageNo) forKey:@"page_no"];
    [params setObject:@(pageSize) forKey:@"page_size"];
    [self asynchronousGet:@"article_comment_list" params:params];
}

- (void)articleCommentAdd:(NSString*)aSessionId articleId:(int)articleId content:(NSString*)content{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (aSessionId) {
        [params setObject:aSessionId forKey:@"session_id"];
    }
    [params setObject:@(articleId) forKey:@"article_id"];
    if (content) {
        [params setObject:content forKey:@"comment_content"];
    }
    [self asynchronousGet:@"article_comment_add" params:params];
}

- (void)articlePraise:(int)articleId imeiNum:(NSString*)imeiNum{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(articleId) forKey:@"article_id"];
    if (imeiNum) {
        [params setObject:imeiNum forKey:@"imei_num"];
    }
    [self asynchronousGet:@"article_praise" params:params];
}

- (void)articleRank:(int)categoryId pageNo:(int)pageNo orderBy:(int)orderBy{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(categoryId) forKey:@"category_id"];
    [params setObject:@(pageNo) forKey:@"page_no"];
    [params setObject:@(20) forKey:@"page_size"];
    [params setObject:@(orderBy) forKey:@"order_by"];
    [self asynchronousGet:@"article_rank" params:params];
}

- (void)userDetail:(int)memberId mobilePhone:(NSString*)mobilePhone{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(memberId) forKey:@"member_id"];
    if (mobilePhone) {
        [params setObject:mobilePhone forKey:@"phone_num"];
    }
    
    [self asynchronousGet:@"user_detail" params:params];
}

- (void)userFollowAdd:(NSString*)sessionId toMemberId:(int)toMemberId nameRemark:(NSString *)nameRemark operation:(int)operation {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(toMemberId) forKey:@"to_member_id"];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [params setObject:@(operation) forKey:@"operation"];
    if (nameRemark) {
        [params setObject:nameRemark forKey:@"name_remark"];
    }
    
    [self asynchronousGet:@"user_follow_add" params:params];
}

- (void)userFollowList:(NSString*)sessionId
            followType:(int)followType
             longitude:(double)longitude
              latitude:(double)latitude
                pageNo:(int)pageNo pageSize:(int)pageSize{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [params setObject:@(followType) forKey:@"follow_type"];
    [params setObject:@(longitude) forKey:@"longitude"];
    [params setObject:@(latitude) forKey:@"latitude"];
    [params setObject:@(pageNo) forKey:@"page_no"];
    [params setObject:@(pageSize) forKey:@"page_size"];
    
    [self asynchronousGet:@"user_follow_list" params:params];
}

- (void)userMessageAdd:(NSString*)sessionId toMemberId:(int)toMemberId msgContent:(NSString*)msgContent{
    if (msgContent.length>100) {
        [SVProgressHUD showInfoWithStatus:@"您输入的文字太多"];
        return;
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [params setObject:@(toMemberId) forKey:@"to_member_id"];
    if (msgContent) {
        [params setObject:msgContent forKey:@"msg_content"];
    }
    
    [self asynchronousGet:@"user_message_add" params:params];
}

- (void)userMessageList:(NSString*)sessionId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [self asynchronousGet:@"user_message_list" params:params];
}

- (void)userMessageChat:(NSString*)sessionId toMemberId:(int)toMemberId pageNo:(int)pageNo{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [params setObject:@(toMemberId) forKey:@"to_member_id"];
    [params setObject:@(pageNo) forKey:@"page_no"];
    [params setObject:@(20) forKey:@"page_size"];
    [self asynchronousGet:@"user_message_chat" params:params];
}

- (void)userPlayedCourseEdit:(NSString*)sessionId addId:(NSString*)addIds deleteId:(NSString*)deleteIds{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    if (addIds&&addIds.length>0) {
        [params setObject:addIds forKey:@"add_id"];
    }
    if (deleteIds&&deleteIds.length>0) {
        [params setObject:deleteIds forKey:@"remove_id"];
    }
    [self asynchronousGet:@"user_played_club_edit" params:params];
}

- (void)userPlayedCourseList:(int)memberId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(memberId) forKey:@"member_id"];
    
    [self asynchronousGet:@"user_played_club_list" params:params];
}

- (void)userPlayedCourseAll{
    [self asynchronousGet:@"user_played_club_all" params:nil];
}

- (void)userEditAlbum:(NSString*)sessionId imageData:(NSString*)imageData imageDelete:(NSString*)imageDelete{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    if (imageData) {
        [params setObject:imageData forKey:@"image_data"];
    }
    if (imageDelete) {
        [params setObject:imageDelete forKey:@"image_delete"];
    }
    [self post:@"user_edit_album" params:params];
}

- (void)userTagAll{
    
    [self asynchronousGet:@"user_tag_all" params:nil];
}

- (void)userFindContracts:(NSString*)sessionId phoneNum:(NSString*)phoneNum{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    if (phoneNum) {
        [params setObject:phoneNum forKey:@"phone_num"];
    }
    [self post:@"user_find_contacts" params:params];
}



/**
 * 意见反馈
 *
 * @param session_id
 * @param contents
 * @return
 * @throws Exception
 */
- (void)feedBack:(NSString *)phoneNum withContents:(NSString *)contents callBack:(void(^)(BOOL boolen))callBack {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if(phoneNum){
        [params setObject:phoneNum forKey:@"phone_num"];
    }
    if(contents){
        [params setObject:contents forKey:@"contents"];
    }
    
    [self get:@"feedback" params:params completion:^(id obj) {
        NSDictionary *resultDic = (NSDictionary *)obj;
        BOOL boolen = [self getBoolValue:resultDic];
        callBack (boolen);
    }];
}

- (void)userRecommendTel:(NSString *)phone phoneList:(NSString *)phoneList callBack:(void(^)(NSDictionary *dic))callBack{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if(phone){
        [params setObject:phone forKey:@"phone_num"];
    }
    if (phoneList) {
        [params setObject:phoneList forKey:@"phone_list"];
    }
    [self get:@"user_recommend" params:params completion:^(id obj) {
        if (obj) {
            NSDictionary *dic = (NSDictionary*)obj;
            callBack (dic);
        }
    }];
}

- (void)joinActivityWithSessionId:(NSString *)sessionId activityCode:(NSString*)code callBack:(void(^)(NSString *callBackString))callBack{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if(sessionId){
        [params setObject:sessionId forKey:@"session_id"];
    }
    if (code) {
        [params setObject:code forKey:@"activity_code"];
    }
    [self get:@"join_activity" params:params completion:^(id obj) {
        if (obj) {
            NSDictionary *dic = (NSDictionary*)obj;
            callBack ([dic[@"extra_info"] description]);
        }
    }];
}


- (void)validateVip:(NSString *)sessionId withClubId:(NSString *)clubId withCardNo:(NSString*)cardNo withMemberName:(NSString *)memberName callBack:(void(^)(BOOL boolen))callBack{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    if (clubId) {
        [params setObject:clubId forKey:@"club_id"];
    }
    if (cardNo) {
        [params setObject:cardNo forKey:@"card_no"];
    }
    if (memberName) {
        [params setObject:memberName forKey:@"member_name"];
    }
    
    [self get:@"club_vip_add" params:params completion:^(id obj) {
        callBack (obj ? YES : NO);
    }];
}

// 话题列表接口

- (void)topicList:(NSString*)sessionId
            tagId:(int)tagId
          tagName:(NSString *)tagName
         memberId:(int)memberId
           clubId:(int)clubId
          topicId:(int)topicId
        topicType:(int)topicType
           pageNo:(int)pageNo
         pageSize:(int)pageSize
        longitude:(double)longitude
         latitude:(double)latitude{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    if (tagId) {
        [params setObject:@(tagId) forKey:@"tag_id"];
    }
    if (tagName) {
        [params setObject:tagName forKey:@"tag_name"];
    }
    if (memberId) {
        [params setObject:@(memberId) forKey:@"member_id"];
    }
    if (clubId) {
        [params setObject:@(clubId) forKey:@"club_id"];
    }
    if (topicId) {
        [params setObject:@(topicId) forKey:@"topic_id"];
    }
    [params setObject:@(topicType) forKey:@"topic_type"];
    [params setObject:@(pageNo) forKey:@"page_no"];
    [params setObject:@(pageSize) forKey:@"page_size"];
    [params setObject:@(longitude) forKey:@"longitude"];
    [params setObject:@(latitude) forKey:@"latitude"];

    [self asynchronousGet:@"topic_list" params:params];
}


- (void)topicCommentList:(int)topicId pageNo:(int)pageNo pageSize:(int)pageSize{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(topicId) forKey:@"topic_id"];
    [params setObject:@(pageNo) forKey:@"page_no"];
    [params setObject:@(pageSize) forKey:@"page_size"];
    
    [self asynchronousGet:@"topic_comment_list" params:params];
}

- (void)teachingPublicClassJoinList:(int)publicClassId pageNo:(int)pageNo pageSize:(int)pageSize{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(publicClassId) forKey:@"public_class_id"];
    [params setObject:@(pageNo) forKey:@"page_no"];
    [params setObject:@(pageSize) forKey:@"page_size"];
    [self asynchronousGet:@"teaching_public_class_join_list" params:params];
}

- (void)topicPraiseList:(int)topicId pageNo:(int)pageNo pageSize:(int)pageSize{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(topicId) forKey:@"topic_id"];
    [params setObject:@(pageNo) forKey:@"page_no"];
    [params setObject:@(pageSize) forKey:@"page_size"];
    [self asynchronousGet:@"topic_praise_list" params:params];
}

- (void)topicShareList:(int)topicId pageNo:(int)pageNo pageSize:(int)pageSize{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(topicId) forKey:@"topic_id"];
    [params setObject:@(pageNo) forKey:@"page_no"];
    [params setObject:@(pageSize) forKey:@"page_size"];
    [self asynchronousGet:@"topic_share_list" params:params];
}

- (void)topicMessageList:(NSString*)sessionId msgType:(int)msgType pageNo:(int)pageNo pageSize:(int)pageSize{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [params setObject:@(msgType) forKey:@"msg_type"];
    [params setObject:@(pageNo) forKey:@"page_no"];
    [params setObject:@(pageSize) forKey:@"page_size"];
    
    [self asynchronousGet:@"topic_message_list" params:params];
}


- (void)topicAdd:(NSString*)sessionId clubId:(int)clubId topicContent:(NSString*)topicContent images:(NSArray*)images videoPath:(NSString*)videoPath longitude:(double)longitude latitude:(double)latitude location:(NSString*)location{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    if (clubId>0) {
        [params setObject:@(clubId) forKey:@"club_id"];
    }
    if (topicContent) {
        [params setObject:topicContent forKey:@"topic_content"];
    }
    if (location) {
        [params setObject:location forKey:@"location"];
    }
    if (images&&images.count>0) {
        [params setObject:@(images.count) forKey:@"image_count"];
        for (int i=0; i<images.count; i++) {
            UIImage *image = images[i];
            NSString *imageData = [Utilities imageDataWithImage:image];
            [params setObject:imageData forKey:[NSString stringWithFormat:@"image_data%d",i]];
        }
    }
    if (videoPath&&videoPath.length>0) {
        NSString *videoData = [Utilities videoDataWithPath:videoPath];
        [params setObject:videoData forKey:@"video_data"];
    }
    [params setObject:@(longitude) forKey:@"longitude"];
    [params setObject:@(latitude) forKey:@"latitude"];
    
    [self post:@"topic_add" params:params];
}
//话题分享接口
- (void)topic_share_add:(NSString*)session_id topic_id:(int)topic_id share_type:(int)share_type{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (session_id) {
        [params setObject:session_id forKey:@"session_id"];
    }
    if (topic_id) {
        [params setObject:@(topic_id) forKey:@"topic_id"];
    }
    if (share_type) {
        [params setObject:@(share_type) forKeyedSubscript:@"share_type"];
    }
    [self asynchronousGet:@"topic_share_add" params:params];
}

- (void)footprintList:(NSString*)sessionId memberId:(int)memberId pageNo:(int)pageNo pageSize:(int)pageSize courseid:(int)courseid courseName:(NSString *)courseName{//lq 加 球场id 不用可传0
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (memberId == 0) {
        return;
    }
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    if (memberId) {
        [params setObject:@(memberId) forKey:@"member_id"];
    }
    [params setObject:@(pageNo) forKey:@"page_no"];
    [params setObject:@(pageSize) forKey:@"page_size"];
    [params setObject:@(courseid) forKey:@"courseid"];
    if (courseName) {
        [params setObject:courseName forKey:@"coursename"];
    }
    [self asynchronousGet:@"footprint_list" params:params];
}


- (void)topicPraiseAdd:(NSString*)sessionId topicId:(int)topicId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    if (topicId) {
        [params setObject:@(topicId) forKey:@"topic_id"];
    }
    
    [self asynchronousGet:@"topic_praise_add" params:params];
}

- (void)topicDelete:(NSString*)sessionId topicId:(int)topicId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    if (topicId) {
        [params setObject:@(topicId) forKey:@"topic_id"];
    }
    [self asynchronousGet:@"topic_delete" params:params];
}

- (void)topicCommentAdd:(NSString*)sessionId topicId:(int)topicId toMemberId:(int)toMemberId cmtCnt:(NSString*)cmtCnt{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    if (topicId) {
        [params setObject:@(topicId) forKey:@"topic_id"];
    }
    if (toMemberId) {
        [params setObject:@(toMemberId) forKey:@"to_member_id"];
    }
    if (cmtCnt) {
        [params setObject:cmtCnt forKey:@"comment_content"];
    }
    [self asynchronousGet:@"topic_comment_add" params:params];
}

- (void)topicCommentDelete:(NSString*)sessionId commentId:(int)commentId topicId:(int)topicId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    if (commentId) {
        [params setObject:@(commentId) forKey:@"comment_id"];
    }
    if (topicId) {
        [params setObject:@(topicId) forKey:@"topic_id"];
    }
    [self asynchronousGet:@"topic_comment_delete" params:params];
}




- (void)userPossibleFriendBySessionId:(NSString *)sessionId longitude:(double)longitude
                             latitude:(double)latitude{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [params setObject:@(longitude) forKey:@"longitude"];
    [params setObject:@(latitude) forKey:@"latitude"];
    
    [self post:@"user_possible_friend" params:params];
}


//添加足迹接口
- (void)footprintAdd:(NSString*)sessionId    //当前用户会话ID
              clubId:(int)clubId             //球场ID
             teeDate:(NSString*)teeDate      //打球日期
               gross:(int)gross              //总杆
          publicMode:(int)publicMode         //0:私密 1:公开
        publishTopic:(int)publishTopic       //0:不发布话题 1:发布到话题
         footprintId:(int)footprintId        //小于0:新增订单球场  等于0: 手动新增 大于0: 修改批量添加的足迹
        topicContent:(NSString*)topicContent //话题内容
              images:(NSArray*)images        //多张图片参数重复上传
              scores:(NSArray*)scores        //多张图片参数重复上传
           longitude:(double)longitude
            latitude:(double)latitude{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    if (clubId) {
        [params setObject:@(clubId) forKey:@"club_id"];
    }
    if (teeDate) {
        [params setObject:teeDate forKey:@"tee_date"];
    }
    [params setObject:@(gross) forKey:@"gross"];
    [params setObject:@(publicMode) forKey:@"public_mode"];
    [params setObject:@(publishTopic) forKey:@"publish_topic"];
    [params setObject:@(footprintId) forKey:@"footprint_id"];
    if (topicContent) {
        [params setObject:topicContent forKey:@"topic_content"];
    }
    if (images) {
        [params setObject:@(images.count) forKey:@"image_count"];
        for (int i=0; i<images.count; i++) {
            UIImage *image = images[i];
            NSString *imageData = [Utilities imageDataWithImage:image];
            [params setObject:imageData forKey:[NSString stringWithFormat:@"image_data%d",i]];
        }
    }
    if (scores) {
        [params setObject:@(scores.count) forKey:@"score_count"];
        for (int i=0; i<scores.count; i++) {
            UIImage *score = scores[i];
            NSString *imageData = [Utilities imageDataWithImage:score];
            [params setObject:imageData forKey:[NSString stringWithFormat:@"score_data%d",i]];
        }
    }
    [params setObject:@(longitude) forKey:@"longitude"];
    [params setObject:@(latitude) forKey:@"latitude"];
    [self post:@"footprint_add" params:params];
}


//删除足迹接口
- (void)footprintDelete:(NSString*)sessionId
            footprintId:(int)footprintId
                 clubId:(int)clubId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [params setObject:@(footprintId) forKey:@"footprint_id"];
    [params setObject:@(clubId) forKey:@"club_id"];
    [self asynchronousGet:@"footprint_delete" params:params];
}


//批量修改足迹接口
- (void)footprintBatchEdit:(NSString*)sessionId
                     addId:(NSString*)addId
                  removeId:(NSString*)removeId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    if (addId) {
        [params setObject:addId forKey:@"add_id"];
    }
    if (removeId) {
        [params setObject:removeId forKey:@"remove_id"];
    }
    [self asynchronousGet:@"footprint_batch_edit" params:params];
}

- (void)footprintBatchList:(NSString*)sessionId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [self asynchronousGet:@"footprint_batch_list" params:params];
}


- (void)topicMessageDelete:(NSString*)sessionId msgId:(int)msgId msgType:(int)msgType{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [params setObject:@(msgId) forKey:@"msg_id"];
    [params setObject:@(msgType) forKey:@"msg_type"];
    [self asynchronousGet:@"topic_message_delete" params:params];
}


// 球场订单删除

- (void)orderDelete:(NSString*)sessionId orderId:(int)orderId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [params setObject:@(orderId) forKey:@"order_id"];
    

    [self asynchronousGet:@"order_delete" params:params];
}


// 商品订单删除

- (void)commodityOrderDelete:(NSString*)sessionId orderId:(int)orderId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [params setObject:@(orderId) forKey:@"order_id"];
    

    [self asynchronousGet:@"commodity_order_delete" params:params];
}


// 获取手机验证码

- (void)publicValidateCode:(NSString*)phoneNum  // 电话号码
                 groupFlag:(NSString*)groupFlag // 分组标志 eweeks 表示e周汇用户
                     noMsg:(int)noMsg  // 不发送短信，缺省为0(发送)，若客户端可以自动获取到手机号码，则填写1
                  codeType:(int)codeType{  // 验证码类型 0: 短信 1:语音
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (phoneNum) {
        [params setObject:phoneNum forKey:@"phone_num"];
    }
    if (groupFlag) {
        [params setObject:groupFlag forKey:@"group_flag"];
    }
    [params setObject:@(noMsg) forKey:@"no_msg"];
    [params setObject:@(MIN(1, codeType)) forKey:@"code_type"];
    [self asynchronousGet:@"public_validate_code" params:params];
}

- (void)wechatUserInfo:(NSString*)groupFlag code:(NSString*)code callBack:(void(^)(id obj))callBack{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (groupFlag) {
        [params setObject:groupFlag forKey:@"group_flag"];
    }
    if (code) {
        [params setObject:code forKey:@"code"];
    }
    [self get:@"wechat_user_info" params:params completion:^(id obj) {
        callBack (obj);
    }];
}

// 用户绑定接口

- (void)userBound:(NSString*)groupFlag
        groupData:(NSString*)groupData
        sessionId:(NSString*)sessionId
         phoneNum:(NSString*)phoneNum
     validateCode:(NSString*)validateCode
         isMobile:(int)isMobile
         nickName:(NSString*)nickName
           gender:(int)gender
     headImageUrl:(NSString*)headImageUrl
         callBack:(void(^)(id obj))callBack{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (groupFlag) {
        [params setObject:groupFlag forKey:@"group_flag"];
    }
    if (groupData) {
        [params setObject:groupData forKey:@"group_data"];
    }
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    if (phoneNum) {
        [params setObject:phoneNum forKey:@"phone_num"];
    }
    if (validateCode) {
        [params setObject:validateCode forKey:@"validate_code"];
    }
    if (isMobile) {
        [params setObject:@(isMobile) forKey:@"is_mobile"];
    }
    if (nickName) {
        [params setObject:nickName forKey:@"nick_name"];
    }
    [params setObject:@(gender) forKey:@"gender"];
    if (headImageUrl) {
        [params setObject:headImageUrl forKey:@"head_image_url"];
    }
    [self get:@"user_bound" params:params completion:^(id obj) {
        callBack (obj);
    }];
}


// 获取备注列表
- (void)userFollowRemark:(NSString*)sessionId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [self asynchronousGet:@"user_follow_remark" params:params];
}


- (void)userMessageDelete:(NSString *)sessionId msgId:(int)msgId toMemberId:(int)toMemberId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    if (msgId > 0) {
        [params setObject:@(msgId) forKey:@"msg_id"];
    }
    if (toMemberId > 0) {
        [params setObject:@(toMemberId) forKey:@"to_member_id"];
    }
    [self asynchronousGet:@"user_message_delete" params:params];
}

- (void)userEditSwitch:(NSString*)sessionId
          noDisturbing:(int)noDisturbing
          memberFollow:(int)memberFollow
         memberMessage:(int)memberMessage
           topicPraise:(int)topicPraise
          topicComment:(int)topicComment
         yaoBallNotify:(int)yaoBallNotify{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [params setObject:@(noDisturbing) forKey:@"switch_no_disturbing"];
    [params setObject:@(memberFollow) forKey:@"switch_member_follow"];
    [params setObject:@(memberMessage) forKey:@"switch_member_message"];
    [params setObject:@(topicPraise) forKey:@"switch_topic_praise"];
    [params setObject:@(topicComment) forKey:@"switch_topic_comment"];
    [params setObject:@(yaoBallNotify) forKey:@"switch_yaoball_notify"];

    [self asynchronousGet:@"user_edit_switch" params:params];
}

- (void)userSwitchInfo:(NSString*)sessionId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    

    [self asynchronousGet:@"user_switch_info" params:params];
}

- (void)commodityBrandList{
    [self asynchronousGet:@"commodity_brand" params:nil];
}

- (void)commodityBrandCategory:(int)brandId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(brandId) forKey:@"brand_id"];
    [self asynchronousGet:@"commodity_brand_category" params:params];
}

- (void)getPublicDetailWithCourseId:(int)publicClassId
                          productId:(int)productId
                          longitude:(double)longitude
                           latitude:(double)latitude{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (publicClassId > 0) {
        [params setObject:@(publicClassId) forKey:@"public_class_id"];
    }else if (productId > 0){
        [params setObject:@(productId) forKey:@"product_id"];
    }
    if (longitude != 0 && latitude != 0) {
        [params setObject:@(longitude) forKey:@"longitude"];
        [params setObject:@(latitude) forKey:@"latitude"];
    }else{
        [params setObject:@(114) forKey:@"longitude"];
        [params setObject:@(22) forKey:@"latitude"];
    }
    [self asynchronousGet:@"teaching_public_class_detail" params:params];
}



// 教练产品时间表 classNo－－课程序号，团体课时上传
- (void)teachingCoachProductTime:(int)coachId productId:(int)productId classNo:(int)classNo{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(coachId) forKey:@"coach_id"];
    [params setObject:@(productId) forKey:@"product_id"];
    [params setObject:@(classNo) forKey:@"class_no"];
    [self asynchronousGet:@"teaching_coach_product_timetable" params:params];
}

// 教练产品明细
- (void)teachingProductDetail:(int)productId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(productId) forKey:@"product_id"];
    [self asynchronousGet:@"teaching_product_detail" params:params];
}

- (void)teachingProductInfoByIds:(NSString *)ids classType:(NSString *)classType{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (ids) {
        [params setObject:ids forKey:@"product_ids"];
    }
    if (classType) {
        [params setObject:classType forKey:@"class_type"];
    }
    
    [self asynchronousGet:@"teaching_product_info" params:params];
}

// 提交订单teaching_order_submit
- (void)teachingSubmitOrder:(NSString*)sessionId
              publicClassId:(int)publicClassId
                  productId:(int)productId
                    coachId:(int)coachId
                       date:(NSString*)date
                       time:(NSString*)time
                   phoneNum:(NSString*)phoneNum{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    if (publicClassId>0) {
        [params setObject:@(publicClassId) forKey:@"public_class_id"];
    }
    if (productId) {
        [params setObject:@(productId) forKey:@"product_id"];
    }
    if (coachId) {
        [params setObject:@(coachId) forKey:@"coach_id"];
    }
    if (date) {
        [params setObject:date forKey:@"date"];
    }
    if (time) {
        [params setObject:time forKey:@"time"];
    }
    if (phoneNum) {
        [params setObject:phoneNum forKey:@"link_phone"];
    }
    [self asynchronousGet:@"teaching_order_submit" params:params];
}

// 教学订单列表 teaching_order_list
- (void)teachingOrderList:(NSString *)sessionId
                  coachId:(int)coachId
                 memberId:(int)memberId
               orderState:(int)orderState
                   pageNo:(int)pageNo
                 pageSize:(int)pageSize
                  keyWord:(NSString*)keyWord{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    if (coachId>0) {
        [params setObject:@(coachId) forKey:@"coach_id"];
    }
    if (memberId>0) {
        [params setObject:@(memberId) forKey:@"member_id"];
    }
    [params setObject:@(orderState) forKey:@"order_state"];
    [params setObject:@(pageNo) forKey:@"page_no"];
    [params setObject:@(pageSize) forKey:@"page_size"] ;
    if (keyWord) {
        [params setObject:keyWord forKey:@"keyword"];
    }
    
    [self asynchronousGet:@"teaching_order_list" params:params];
}


// 教学订单详情teaching_order_detail
- (void)teachingOrderDetail:(NSString*)sessionId
                    orderId:(int)orderId
                    coachId:(int)coachId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [params setObject:@(orderId) forKey:@"order_id"];
    if (coachId) {
        [params setObject:@(coachId) forKey:@"coach_id"];
    }
    if ([LoginManager sharedManager].currLongitude != 0 && [LoginManager sharedManager].currLatitude != 0) {
        [params setObject:@([LoginManager sharedManager].currLongitude) forKey:@"longitude"];
        [params setObject:@([LoginManager sharedManager].currLatitude) forKey:@"latitude"];
    }else{
        [params setObject:@(114) forKey:@"longitude"];
        [params setObject:@(22) forKey:@"latitude"];
    }
    
    [self asynchronousGet:@"teaching_order_detail" params:params];
}

// 教学订单删除teaching_order_delete
- (void)teachingOrderDelete:(NSString*)sessionId
                    orderId:(int)orderId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [params setObject:@(orderId) forKey:@"order_id"];
    [self asynchronousGet:@"teaching_order_delete" params:params];
}

- (void)teachingMemberReservation:(NSString *)sessionId
                          classId:(int)classId
                             date:(NSString *)date
                             time:(NSString *)time
                        longitude:(double)longitude
                         latitude:(double)latitude
                        periodId:(int) periodId {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    if (date) {
        [params setObject:date forKey:@"date"];
    }
    if (time) {
        [params setObject:time forKey:@"time"];
    }
    [params setObject:@(classId) forKey:@"class_id"];
    if (longitude != 0 && latitude != 0) {
        [params setObject:@(longitude) forKey:@"longitude"];
        [params setObject:@(latitude) forKey:@"latitude"];
    }
    [params setObject:@(periodId) forKey:@"period_id"];
    [self asynchronousGet:@"teaching_member_reservation_add" params:params];
}

- (void)teachingMemberReservation:(NSString *)sessionId
                          classId:(int)classId
                             date:(NSString *)date
                             time:(NSString *)time
                        longitude:(double)longitude
                         latitude:(double)latitude
                        {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    if (date) {
        [params setObject:date forKey:@"date"];
    }
    if (time) {
        [params setObject:time forKey:@"time"];
    }
    [params setObject:@(classId) forKey:@"class_id"];
    if (longitude != 0 && latitude != 0) {
        [params setObject:@(longitude) forKey:@"longitude"];
        [params setObject:@(latitude) forKey:@"latitude"];
    }
    
    [self asynchronousGet:@"teaching_member_reservation_add" params:params];
}

- (void)teachingCommentReplyContent:(NSString *)content commentId:(int)commentId sessionId:(NSString *)sessionId{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [params setObject:@(commentId) forKey:@"comment_id"];
    [params setObject:content forKey:@"reply_content"];
    [self asynchronousGet:@"teaching_comment_reply" params:params];
}


- (void)teachingMemberClassPostpone:(NSString*)sessionId classId:(int)classId dayNum:(NSInteger)dayNum{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [params setObject:@(classId) forKey:@"class_id"];
    [params setObject:@(dayNum) forKey:@"day_num"];
    [self asynchronousGet:@"teaching_member_class_postpone" params:params];
}


// 教练消息列表teaching_coach_message_list
- (void)teachingCoachMessageList:(int)coachId pageNo:(int)pageNo pageSize:(int)pageSize{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(coachId) forKey:@"coach_id"];
    [params setObject:@(pageNo) forKey:@"page_no"];
    [params setObject:@(pageSize) forKey:@"page_size"];
    [self asynchronousGet:@"teaching_coach_message_list" params:params];
}

// 课程预约完成teaching_member_reservation_complete
- (void)teachingMemberReservationComplete:(NSString*)sessionId coachId:(int)coachId reservationId:(int)reservationId opteraton:(int)opteraton periodId:(int) periodId callBack:(void(^)(BOOL boolen))callBack{
    [[BaiduMobStat defaultStat] logEvent:@"btnTimetableTimeSet" eventLabel:@"设置教学时间按钮点击"];
    [MobClick event:@"btnTimetableTimeSet" label:@"设置教学时间按钮点击"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [params setObject:@(coachId) forKey:@"coach_id"];
    [params setObject:@(reservationId) forKey:@"reservation_id"];
    [params setObject:@(opteraton) forKey:@"operation"];
    [params setObject:@(periodId) forKey:@"period_id"];
    [self get:@"teaching_member_reservation_complete" params:params completion:^(id obj) {
        callBack (obj ? YES : NO);
    }];
}


- (void)teachingMemberReservationComplete:(NSString*)sessionId coachId:(int)coachId reservationId:(int)reservationId opteraton:(int)opteraton callBack:(void(^)(BOOL boolen))callBack
{
    [self teachingMemberReservationComplete:sessionId coachId:coachId reservationId:reservationId opteraton:opteraton periodId:0 callBack:callBack];
}

// 教练学员列表 teaching_coach_member_list
- (void)teachingCoachMemberList:(NSString*)sessionId coachId:(int)coachId memberId:(int)memberId pageNo:(int)pageNo pageSize:(int)pageSize keyWord:(NSString*)keyWord{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [params setObject:@(coachId) forKey:@"coach_id"];
    [params setObject:@(pageNo) forKey:@"page_no"];
    [params setObject:@(pageSize) forKey:@"page_size"];
    if (memberId) {
        [params setObject:@(memberId) forKey:@"member_id"];
    }
    if (keyWord) {
        [params setObject:keyWord forKey:@"keyword"];
    }
    [self asynchronousGet:@"teaching_coach_member_list" params:params];
}


// 教练数据报表teaching_coach_data_report
- (void)teachingCoachDataReport:(NSString*)sessionId coachId:(int)coachId dataType:(int)dataType{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [params setObject:@(coachId) forKey:@"coach_id"];
    [params setObject:@(dataType) forKey:@"data_type"];
    [self asynchronousGet:@"teaching_coach_data_report" params:params];
}


/*********************** handle data after finishedLoaded ************************/

- (void)newDataWithAsynchronousBS:(BaseService *)bs interfaceName:(NSString*)name{
    id data = bs.data;
    NSMutableArray *array = [NSMutableArray array];
    if ([data isKindOfClass:[NSArray class]]) {
        NSArray *resultArray = (NSArray *)data;
        if (Equal(name, @"search_special_offer")) {              //************* 特价时段
            if (resultArray && resultArray.count > 0) {
                for (id obj in resultArray){
                    SpecialOfferModel *model = [[SpecialOfferModel alloc] initWithDic:obj];
                    [array addObject:model];
                }
            }
        }
        else if (Equal(name, @"teaching_coach_update_timeset")){
            if (self.success) {
                [array addObject:@(1)];
            }else{
                [array addObject:@(0)];
            }
        }
        else if (Equal(name, @"teaching_coach_update_timetable")){
            if (self.success) {
                [array addObject:@(1)];
            }else{
                [array addObject:@(0)];
            }
        }
        else if (Equal(name, @"activity_list")) {                   //************* 活动列表
            if (self.preventError) {
                NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
                NSString *filename = [path stringByAppendingPathComponent:@"GolfActivityData.plist"];
                
                NSFileManager *defaultManager = [NSFileManager defaultManager];
                if([defaultManager fileExistsAtPath:filename]){
                    [defaultManager removeItemAtPath:filename error:nil];
                }

                if(resultArray && resultArray.count > 0) {
                    if (![[resultArray firstObject] isKindOfClass:[NSArray class]]) {
                        [resultArray writeToFile:filename atomically:YES];
                    }
                    
                    for (id obj in resultArray){
                        if ([obj isKindOfClass:[NSArray class]]) {
                            NSMutableArray *arr = [[NSMutableArray alloc] init];
                            for (id o in obj) {
                                ActivityModel *model = [[ActivityModel alloc] initWithDic:o];
                                [arr addObject:model];
                            }
                            [array addObject:arr];
                        }else{
                            ActivityModel *model = [[ActivityModel alloc] initWithDic:obj];
                            [array addObject:model];
                        }
                        
                    }
                }
            }else{
                for (id obj in resultArray){
                    if ([obj isKindOfClass:[NSArray class]]) {
                        NSMutableArray *arr = [[NSMutableArray alloc] init];
                        for (id o in obj) {
                            ActivityModel *model = [[ActivityModel alloc] initWithDic:o];
                            [arr addObject:model];
                        }
                        [array addObject:arr];
                    }else{
                        ActivityModel *model = [[ActivityModel alloc] initWithDic:obj];
                        [array addObject:model];
                    }
                    
                }
            }
        }
        else if (Equal(name, @"club_all_list")){
            NSMutableArray *mutArray = [NSMutableArray array];
            
            if (resultArray && resultArray.count > 0) {
                @autoreleasepool {
                    for (id obj in resultArray) {
                        SearchClubModel *model = [[SearchClubModel alloc] initWithDic:obj];
                        [mutArray addObject:model];
                    }
                }
                [[YGCacheDataHelper shared] cacheAllSearchClubModel:mutArray];
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *lastUpdateTime = [formatter stringFromDate:[NSDate date]];
                
                [[NSUserDefaults standardUserDefaults] setObject:lastUpdateTime forKey:kYGGolfClubLastUpdateTimeKey];
            }
            [array addObjectsFromArray:mutArray];
        }
        else if (Equal(name, @"search_club")) {                    //************* 球会搜索结果
            if (resultArray && resultArray.count > 0) {
                for(id obj in resultArray){
                    ClubModel *club = [[ClubModel alloc] initWithDic:obj];
                    [array addObject:club];
                }
            }
        }
        else if (Equal(name, @"search_teetime")) {                //************* teetime搜索结果
            if (resultArray && resultArray.count == 2) {
                NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
                NSArray *subArray=[resultArray objectAtIndex:0];
                if(subArray && subArray.count>0) {
                    NSMutableArray *teetimeClubArray = [NSMutableArray array];
                    for (id obj in subArray) {
                        TeeTimeModel *model = [[TeeTimeModel alloc] initWithDic:obj];
                        [teetimeClubArray addObject:model];
                    }
                    [resultDict setObject:teetimeClubArray forKey:@"clubTeeTime"];
                }
                
                subArray=[resultArray objectAtIndex:1];
                if(subArray && subArray.count>0) {
                    NSMutableArray *teetimeAgentArray = [NSMutableArray array];
                    for (id obj in subArray) {
                        TeeTimeAgentModel *model = [[TeeTimeAgentModel alloc] initWithDic:obj];
                        [teetimeAgentArray addObject:model];
                    }
                    [resultDict setObject:teetimeAgentArray forKey:@"agentTeeTime"];
                }
                
                if (self.teeTime) {
                    [resultDict setObject:self.teeTime forKey:@"teetime"];
                }
                [array addObject:resultDict];
            }
        }
        else if (Equal(name, @"user_search")) {
            if (resultArray && resultArray.count > 0) {
                for (id obj in resultArray){
                    UserFollowModel *model = [[UserFollowModel alloc] initWithDic:obj];
                    NSString *remarkName = [[YGUserRemarkCacheHelper shared] getUserRemarkName:model.memberId];
                    if ([remarkName isNotBlank]) {
                        model.displayName = remarkName;
                    }
                    [array addObject:model];
                }
            }
        }
        else if(Equal(name, @"user_possible_friend")){
            if (resultArray && resultArray.count > 0) {
                for (id obj in resultArray) {
                    UserFollowModel *model = [[UserFollowModel alloc] initWithDic:obj];
                    [array addObject:model];
                }
            }
        }
        else if (Equal(name, @"club_special_offer")) {               //球会特价时段
            NSArray *resultArray = (NSArray *)data;;
            if (resultArray && resultArray.count > 0) {
                for (id obj in resultArray){
                    SpecialOfferModel *model = [[SpecialOfferModel alloc] initWithDic:obj];
                    [array addObject:model];
                }
            }
        }
        else if (Equal(name, @"teaching_member_class_list")){
            NSArray *resultArray = (NSArray *)data;
            if (resultArray && resultArray.count > 0) {
                for (id obj in resultArray){
                    MemberClassModel *model = [[MemberClassModel alloc] initWithDic:obj];
                    [array addObject:model];
                }
            }
        }
        else if (Equal(name, @"article_teaching_type")){

        }
        else if (Equal(name, @"city_package_list")) {                   //当前城市的套餐
            NSArray *resultArray = (NSArray *)data;
            if (resultArray && resultArray.count > 0) {
                for (id obj in resultArray){
                    PackageModel *model = [[PackageModel alloc] initWithDic:obj];
                    [array addObject:model];
                }
            }
        }
        else if (Equal(name, @"club_package_list")) {                  //球会套餐
            NSArray *resultArray = (NSArray *)data;
            if (resultArray && resultArray.count > 0) {
                for (id obj in resultArray){
                    PackageModel *model = [[PackageModel alloc] initWithDic:obj];
                    [array addObject:model];
                }
            }
        }
        else if (Equal(name, @"club_fairway_list")) {                 //球道集列表
            NSArray *resultArray = (NSArray *)data;
            if (resultArray != nil && resultArray.count > 0) {
                for (NSDictionary *dic in resultArray){
                    NSString *imageUrl = dic[@"fairway_picture"];
                    //ClubFairwayModel *model = [[ClubFairwayModel alloc] initWithDic:obj];
                    [array addObject:imageUrl];
                }
            }
        }
//        else if (Equal(name, @"order_list")){//6.3改为字典类型
//            if (resultArray != nil && resultArray.count > 0) {
//                for (id obj in  resultArray){
//                    OrderModel *model = [[OrderModel alloc] initWithDic:obj];
//                    [array addObject:model];
//                }
//            }
//        }
        else if (Equal(name, @"get_waitpay")){
            if (resultArray != nil && resultArray.count > 0) {
                for (NSDictionary *dic in resultArray){
                    OrderModel *orderModel = [[OrderModel alloc] init];
                    orderModel.orderId = [[dic objectForKey:@"order_id"] intValue];
                    [array addObject:orderModel];
                }
            }
        }
        else if(Equal(name, @"tag_list")){
            if (resultArray != nil && resultArray.count > 0) {
                for (id obj in resultArray){
                    TagModel *model = [[TagModel alloc] initWithDic:obj];
                    [array addObject:model];
                }
            }
        }
        else if (Equal(name, @"coupon_list")){
            if (resultArray != nil && resultArray.count > 0) {
                for (id obj in resultArray){
                    CouponModel *model = [[CouponModel alloc] initWithDic:obj];
                    [array addObject:model];
                }
            }
        }
        else if (Equal(name, @"home/home_list")){
            
        }
        else if (Equal(name, @"home/column")){
            
        }
        else if (Equal(name, @"home/view_list?")){
            
        }
        else if (Equal(name, @"search_coach")){
            if (resultArray != nil && resultArray.count > 0) {
                for (id obj in resultArray) {
                    CoachModel *model = [[CoachModel alloc] initWithDic:obj];
                    [array addObject:model];
                }
            }
        }
        else if (Equal(name, @"teaching_comment_list")){
            if (resultArray != nil && resultArray.count > 0) {
                for (id obj in resultArray) {
                    CoachDetailCommentModel *model = [[CoachDetailCommentModel alloc] initWithDic:obj];
                    [array addObject:model];
                }
            }
        }
        else if (Equal(name, @"teaching_coach_info")){
            if (resultArray != nil && resultArray.count > 0) {
                for (id obj in resultArray) {
                    TeachingCoachModel *model = [[TeachingCoachModel alloc] initWithDic:obj];
                    [array addObject:model];
                }
            }
        }
        else if (Equal(name, @"teaching_academy_info")){
            if (resultArray != nil && resultArray.count > 0) {
                for (id obj in resultArray) {
                    AcademyModel *model = [[AcademyModel alloc] initWithDic:obj];
                    [array addObject:model];
                }
            }
        }
        else if (Equal(name, @"search_academy")){
            if (resultArray != nil && resultArray.count > 0) {
                for (id obj in resultArray) {
                    AcademyModel *model = [[AcademyModel alloc] initWithDic:obj];
                    [array addObject:model];
                }
            }
        }
        else if (Equal(name, @"search_driving_range")){
            
        }
        else if (Equal(name, @"driving_range_picture_list")){
            if (resultArray != nil && resultArray.count>0) {
                for (NSDictionary *dic in resultArray) {
                    [array addObject:[dic objectForKey:@"pic_url"]];
                }
            }
        }
        else if (Equal(name, @"driving_range_position")){
            if (resultArray != nil && resultArray.count>0) {
                [array addObjectsFromArray:resultArray];
            }
        }
        else if (Equal(name, @"dict_academy")){
            if (resultArray != nil && resultArray.count>0) {
                [array addObjectsFromArray:resultArray];
            }
        }
        else if (Equal(name, @"club_picture_list")){
            if (resultArray != nil && resultArray.count > 0){
                for (id obj in resultArray){
                    [array addObject:[obj objectForKey:@"pic_url"]];
                }
            }
        }
        else if (Equal(name, @"commodity_category")){
            if (resultArray != nil && resultArray.count > 0) {
                for (id obj in resultArray) {
                    CommodityCategory *category = [[CommodityCategory alloc] initWithDic:obj];
                    [array addObject:category];
                }
            }
        }
        else if (Equal(name, @"commodity_info")){
            if (resultArray != nil && resultArray.count > 0) {
                for (id obj in resultArray) {
                    CommodityInfoModel *model = [[CommodityInfoModel alloc] initWithDic:obj];
                    [array addObject:model];
                }
            }
        }
        else if (Equal(name, @"commodity_auction")){
            
        }
        else if (Equal(name, @"delivery_address_list")){
//            if (resultArray != nil && resultArray.count > 0){
//                for (id obj in resultArray) {
//                    DeliveryAddressModel *model = [[DeliveryAddressModel alloc] initWithDic:obj];
//                    if (model) {
//                        [array addObject:model];
//                    }
//                }
//            }
        }
        else if (Equal(name, @"account_consume_list")){
            if (resultArray != nil && resultArray.count > 0) {
                for (id obj in resultArray) {
                    ConsumeModel *model = [[ConsumeModel alloc] initWithDic:obj];
                    [array addObject:model];
                }
            }
        }else if (Equal(name, @"article_category")){
            
        }else if (Equal(name, @"article_info")){
            
        }else if (Equal(name, @"article_comment_list")){
            if (resultArray != nil && resultArray.count > 0) {
                for (id obj in resultArray) {
                    ArticleCommentModel *model = [[ArticleCommentModel alloc] initWithDic:obj];
                    NSString *remarkName = [[YGUserRemarkCacheHelper shared] getUserRemarkName:model.memberId];
                    if ([remarkName isNotBlank]) {
                        model.displayName = remarkName;
                    }
                    [array addObject:model];
                }
            }
        }else if (Equal(name, @"article_rank")){
            
        }else if (Equal(name, @"user_message_list")){
            BOOL isNeedStore = NO;
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            if (resultArray != nil && resultArray.count > 0) {
                isNeedStore = YES;
                // 循环做修改备注名
                for (id obj in resultArray) {
                    UserNewsModel *model = [[UserNewsModel alloc] initWithDic:obj];
                    NSString *remarkName = [[YGUserRemarkCacheHelper shared] getUserRemarkName:model.memberId];
                    if ([remarkName isNotBlank]) {
                        model.displayName = remarkName;
                    }
                    // 添加未读的新消息
                    [array addObject:model];
                }
            }
            
            NSString *userMemberId = [NSString stringWithFormat:@"%d",[LoginManager sharedManager].session.memberId];
            NSString *keyUserMessageList = [@"UserMessageList" stringByAppendingPathComponent:userMemberId];
            NSString *keyUseMessageMemberId = [@"UserMessageMemberId-" stringByAppendingString:userMemberId];
            
            NSString *path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
            NSString *filename = [path stringByAppendingPathComponent:keyUserMessageList];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:filename]) {// 如果文件存在
                NSMutableArray *memberIds = [[userDefault objectForKey:keyUseMessageMemberId] mutableCopy];
                
                // 存在本地的人
                if (memberIds.count > 0) {
                    NSData *data = [[NSMutableData alloc] initWithContentsOfFile:filename];
                    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
                    
                    for (UserNewsModel *mm in array) { // 循环服务器取得的数据
                        if ([memberIds containsObject:[@(mm.memberId) description]]) {
                            [memberIds removeObject:[@(mm.memberId) description]];
                        }
                    }
                    
                    for (id obj in memberIds) {
                        UserNewsModel *model = [unarchiver decodeObjectForKey:[obj description]];
                        if (model) {
                            model.newCount = 0;
                            [array addObject:model];
                        }
                    }
                    [unarchiver finishDecoding];
                }
            }
            
            if (isNeedStore) {
                NSMutableData *data = [NSMutableData data];
                NSKeyedArchiver *keyedarchiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
                NSMutableArray *memberIds = [NSMutableArray array];
                
                for (UserNewsModel *mmm in array) {
                    [memberIds addObject:[@(mmm.memberId) description]];
                    [keyedarchiver encodeObject:mmm forKey:[@(mmm.memberId) description]];
                }
                [keyedarchiver finishEncoding];
                
                BOOL isOK = [data writeToFile:filename atomically:YES];
                if (isOK) {
                    [userDefault setObject:memberIds forKey:keyUseMessageMemberId];
                }
            }
        }else if (Equal(name, @"user_message_chat")){
            if (resultArray != nil && resultArray.count > 0) {
                for (id obj in resultArray) {
                    UserNewsModel *model = [[UserNewsModel alloc] initWithDic:obj];
                    NSString *remarkName = [[YGUserRemarkCacheHelper shared] getUserRemarkName:model.memberId];
                    if ([remarkName isNotBlank]) {
                        model.displayName = remarkName;
                    }
                    [array addObject:model];
                }
            }
        }else if (Equal(name, @"user_played_club_all")){
            if (resultArray != nil && resultArray.count > 0) {
                for (id obj in resultArray) {
                    [array addObject:obj];
                }
            }
        }else if (Equal(name, @"user_tag_all")){
            if (resultArray != nil && resultArray.count > 0) {
                for (id obj in resultArray) {
                    [array addObject:obj];
                }
            }
        }else if (Equal(name, @"user_find_contacts")){
            if (resultArray != nil && resultArray.count > 0) {
                for (id obj in resultArray) {
                    PersonInAddressList *model = [[PersonInAddressList alloc] initWithDic:obj];
                    [array addObject:model];
                }
            }
        }else if (Equal(name, @"topic_list")){
            if (resultArray != nil && resultArray.count > 0) {
                NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                for (id obj in resultArray) {
                    TopicModel *model = [[TopicModel alloc] initWithDic:obj];
                    NSString *remarkName = [[YGUserRemarkCacheHelper shared] getUserRemarkName:model.memberId];
                    if ([remarkName isNotBlank]) {
                        model.displayName = remarkName;
                    }
                    [array addObject:model];
                    
                    NSString *filepath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%d",model.topicId]];
                    BOOL ok = [NSKeyedArchiver archiveRootObject:model toFile:filepath];
                    if (ok) {
                        //NSLog(@"***** 存储成功");
                    }
                }
            }
        }else if (Equal(name, @"topic_comment_list")){
            if (resultArray != nil && resultArray.count > 0) {
                for (id obj in resultArray) {
                    ArticleCommentModel *model = [[ArticleCommentModel alloc] initWithDic:obj];
                    [array addObject:model];
                }
            }
        }else if (Equal(name, @"topic_praise_list") || Equal(name, @"topic_share_list") || Equal(name, @"teaching_public_class_join_list")){
            if (resultArray != nil && resultArray.count > 0) {
                for (id obj in resultArray) {
                    TrendsPraiseModel *model = [[TrendsPraiseModel alloc] initWithDic:obj];
                    NSString *remarkName = [[YGUserRemarkCacheHelper shared] getUserRemarkName:model.memberId];
                    if ([remarkName isNotBlank]) {
                        model.displayName = remarkName;
                    }
                    [array addObject:model];
                }
            }
        }else if (Equal(name, @"topic_message_list")){
            if (resultArray != nil && resultArray.count > 0) {
                int count = [GolfAppDelegate shareAppDelegate].systemParamInfo.topicMsgCount;
                for (id obj in resultArray) {
                    TrendsMessageModel *model = [[TrendsMessageModel alloc] initWithDic:obj];
                    if (model.msgStatus == 0) {
                        count --;
                    }
                    NSString *remarkName = [[YGUserRemarkCacheHelper shared] getUserRemarkName:model.memberId];
                    if ([remarkName isNotBlank]) {
                        model.displayName = remarkName;
                    }
                    
                    [array addObject:model];
                }
                [GolfAppDelegate shareAppDelegate].systemParamInfo.topicMsgCount = MAX(count, 0);
            }
        }else if (Equal(name, @"footprint_list")){
            if (resultArray != nil && resultArray.count > 0) {
                for (id obj in resultArray) {
                    FootprintModel *model = [[FootprintModel alloc] initWithData:obj];
                    [array addObject:model];
                }
            }
        }else if (Equal(name, @"user_follow_remark")){
            
            if (resultArray != nil && resultArray.count > 0) {
                [array addObjectsFromArray:resultArray];
            }
            
            [LoginManager sharedManager].isloadedUserRemarks = YES;
            // 备注缓存起来
            [[YGUserRemarkCacheHelper shared] cacheUserAllRemarkNames:array];
            
        }else if (Equal(name, @"commodity_brand")){
            if (resultArray != nil && resultArray.count > 0) {
                NSArray *list = [NSArray yy_modelArrayWithClass:[YGMallBrandModel class] json:resultArray];
                [array addObjectsFromArray:list];
            }
        }else if (Equal(name, @"commodity_brand_category")){
            if (resultArray != nil && resultArray.count > 0) {
                for (id obj in resultArray) {
                    CommodityCategory *category = [[CommodityCategory alloc] initWithDic:obj];
                    [array addObject:category];
                }
            }
        }else if (Equal(name, @"teaching_public_class_info")){
            if (resultArray != nil && resultArray.count > 0) {
                for (id obj in resultArray) {
                    PublicCourseModel *publicCourse = [[PublicCourseModel alloc] initWithDic:obj];
                    [array addObject:publicCourse];
                }
            }
        }
        else if (Equal(name, @"teaching_coach_timetable")){
            if (resultArray != nil && resultArray.count > 0) {
                for (id obj in resultArray) {
                    CoachTimetable *model = [[CoachTimetable alloc] initWithDic:obj];
                    [array addObject:model];
                }
            }
        }else if (Equal(name, @"teaching_coach_member_list")){
            if (resultArray != nil && resultArray.count > 0) {
                for (id obj in resultArray) {
                    StudentModel *sm = [[StudentModel alloc] initWithDic:obj];
                    [array addObject:sm];
                }
            }
        }else if (Equal(name, @"teaching_coach_message_list")){
            if (resultArray != nil && resultArray.count > 0) {
                for (id obj in resultArray) {
                    CoachNoticeModel *sm = [[CoachNoticeModel alloc] initWithDic:obj];
                    [array addObject:sm];
                }
            }
        }else if (Equal(name, @"teaching_product_info")){
            if (resultArray != nil && resultArray.count > 0) {
                for (id obj in resultArray) {
                    TeachProductDetail *detail = [[TeachProductDetail alloc] initWithDic:obj];
                    [array addObject:detail];
                }
            }
        }
    }else if ([data isKindOfClass:[NSDictionary class]]){
        NSDictionary *resultDic = (NSDictionary*)data;
        if (Equal(name, @"club_info")) {                                 //*****球会信息
            ClubModel *club = [[ClubModel alloc] initWithDic:resultDic];
            [array addObject:club];
        }
        
        else if (Equal(name, @"package_detail")) {                             // 套餐详情
            PackageDetailModel *model = [[PackageDetailModel alloc] initWithDic:resultDic];
            [array addObject:model];
        }
        else if (Equal(name, @"city_weather")) {
            NSArray *resultArray = [WeatherModel arrayWithDic:resultDic];   // 天气预报
            if (resultArray && resultArray.count > 0) {
                for (id obj in resultArray){
                    [array addObject:obj];
                }
            }
        }
        else if (Equal(name, @"topic_list")){
            TrendsModel *model = [[TrendsModel alloc] initWithDic:resultDic];
            [array addObject:model];
        }
        else if (Equal(name, @"deposit_info")){
            DepositInfoModel *model = [DepositInfoModel yy_modelWithJSON:resultDic];
            [array addObject:model];
        }
        else if (Equal(name, @"order_detail")){
            OrderDetailModel *model = [[OrderDetailModel alloc] initWithDic:resultDic];
            [array addObject:model];
        }
        else if (Equal(name, @"commodity_order_detail")){
            if (resultDic) {
               
            }
        }
        else if (Equal(name, @"search_teetime2")){
            if (resultDic) {
                NSMutableDictionary *mutDic = [NSMutableDictionary dictionary];
                NSArray *teetimes = (NSArray*)[resultDic objectForKey:@"data_list"];
                if (teetimes&&teetimes.count > 0) {
                    NSMutableArray *teetimeArray = [NSMutableArray array];
                    for (id obj in teetimes){
                        TTModel *model = [[TTModel alloc] initWithDic:obj];
                        [teetimeArray addObject:model];
                    }
                    [mutDic setObject:teetimeArray forKey:@"teetime_list"];
                }
                
                NSString *teeTime = [resultDic objectForKey:@"teetime"];
                NSString *errorInfo = [resultDic objectForKey:@"error_info"];
                NSString *clubPhone = [resultDic objectForKey:@"club_phone"];
                NSString *topsize = [resultDic objectForKey:@"top_size"];
                
                int timeMinPrice = [[resultDic objectForKey:@"time_min_price"] intValue]/100;
                NSString *timeStartTime = [resultDic objectForKey:@"time_start_time"];
                NSString *timeEndTime = [resultDic objectForKey:@"time_end_time"];
                
                [mutDic setObject:teeTime?teeTime:@"" forKey:@"teetime"];
                [mutDic setObject:errorInfo?errorInfo:@"" forKey:@"error_info"];
                [mutDic setObject:clubPhone?clubPhone:@"" forKey:@"club_phone"];
                [mutDic setObject:topsize?topsize:@"" forKey:@"top_size"];
                
                [mutDic setObject:timeStartTime?timeStartTime:@"" forKey:@"time_start_time"];
                [mutDic setObject:timeEndTime?timeEndTime:@"" forKey:@"time_end_time"];
                [mutDic setObject:@(timeMinPrice) forKey:@"time_min_price"];
                [array addObject:mutDic];
            }
        }
        else if (Equal(name, @"club_free_teetime")){
            if (resultDic) {
                [array addObject:resultDic];
            }
        }
        else if (Equal(name, @"home/view?")){
            
        }
        else if (Equal(name, @"article_teaching_info")){

        }
        else if (Equal(name, @"coach_detail")){
            if (resultDic) {
                CoachDetailModel *model = [[CoachDetailModel alloc] initWithDic:resultDic];
                [array addObject:model];
            }
        }
        
        else if (Equal(name,@"teaching_coach_detail")){
            if (resultDic) {
                TeachingCoachModel *model = [[TeachingCoachModel alloc] initWithDic:resultDic];
                [array addObject:model];
            }
        }
        else if (Equal(name,@"teaching_member_class_detail")){
            if (resultDic) {
                MemberClassModel *model = [[MemberClassModel alloc] initWithDic:resultDic];
                [array addObject:model];
            }
        }
        else if (Equal(name,@"teaching_member_reservation_cancel")){
            if (resultDic) {
                [array addObject:@(1)];
            }
        }
        else if (Equal(name,@"teaching_order_cancel")){
            if (resultDic) {
                OrderCancelModel *model = [[OrderCancelModel alloc] initWithDic:resultDic];
                [array addObject:model];
            }
        }
        else if (Equal(name,@"teaching_member_reservation_detail")){
            if (resultDic) {
                ReservationModel *model = [[ReservationModel alloc] initWithDic:resultDic];
                [array addObject:model];
            }
        }
        else if (Equal(name, @"academy_detail")){
            if (resultDic) {
                AcademyModel *model = [[AcademyModel alloc] initWithDic:resultDic];
                [array addObject:model];
            }
        }else if (Equal(name, @"teaching_academy_detail")){
            if (resultDic) {
                AcademyModel *model = [[AcademyModel alloc] initWithDic:resultDic];
                [array addObject:model];
            }
        }
        else if (Equal(name, @"driving_range_detail")){
            
        }
        else if (Equal(name, @"coach_edit_info")){
            if (resultDic) {
                [array addObject:resultDic];
            }
        }
        else if (Equal(name, @"coach_edit_album")){
            if (resultDic) {
                [array addObject:resultDic];
            }
        }
        else if (Equal(name, @"dict_city")){
            NSString *path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
            NSString *filename=[path stringByAppendingPathComponent:@"GolfCityInfo.plist"];
            
            if (data) {
                NSString *version = [resultDic objectForKey:@"version"];
                
                if (version) {
                    [[NSUserDefaults standardUserDefaults] setObject:version forKey:@"GolfCitiesVersion"];
                }
                
                //更新数据库
                NSArray *resultArray = [resultDic objectForKey:@"city_list"];
                if (resultArray != nil && resultArray.count > 0) {
                    [resultArray writeToFile:filename atomically:YES];
                    for (id obj in resultArray) {
                        SearchCityModel *model = [[SearchCityModel alloc] initWithDic:obj];
                        [array addObject:model];
                    }
                }
            }
        }
        else if (Equal(name, @"dict_province")){
            NSString *path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
            NSString *filename=[path stringByAppendingPathComponent:@"GolfProvinceInfo.plist"];
            
            if (data) {
                NSString *version = [resultDic objectForKey:@"version"];
                
                if (version) {
                    [[NSUserDefaults standardUserDefaults] setObject:version forKey:@"GolfProvincesVersion"];
                }
                
                //更新数据库
                NSArray *resultArray = [resultDic objectForKey:@"province_list"];
                if (resultArray != nil && resultArray.count > 0) {
                    [resultArray writeToFile:filename atomically:YES];
                    for (id obj in resultArray) {
                        SearchProvinceModel *model = [[SearchProvinceModel alloc] initWithDic:obj];
                        [array addObject:model];
                    }
                }
            }
        }
        else if (Equal(name, @"commodity_detail")){
            if (resultDic) {
                CommodityInfoModel *model = [[CommodityInfoModel alloc] initWithDic:resultDic];
                [array addObject:model];
            }
        }
        else if (Equal(name, @"commodity_auction_status")){
            if (resultDic) {
                [array addObject:resultDic];
            }
        }
        else if (Equal(name, @"commodity_order_submit")){
            if (resultDic) {
                [array addObject:resultDic];
            }
        }
        else if (Equal(name, @"commodity_comment_list")){
            if (resultDic) {
                [array addObject:resultDic];
            }
        }else if (Equal(name, @"delivery_address_maintain")){
            if (resultDic) {
                [array addObject:resultDic];
            }
        }else if (Equal(name, @"order_pay_unionpay") || Equal(name, @"commodity_order_pay") || Equal(name, @"teaching_order_pay") || Equal(name, @"virtual_course_order_pay")){
            if (resultDic) {
                OrderPayModel *model = [[OrderPayModel alloc] initWithDic:resultDic];
                [array addObject:model];
            }
        }else if (Equal(name, @"order_list")){//6.3改为字典类型
            if (resultDic) {
                [array addObject:resultDic];
            }
        }else if (Equal(name, @"teaching_order_list")){//6.3改为字典类型
            if (resultDic) {
                [array addObject:resultDic];
            }
        }else if (Equal(name, @"commodity_order_list")){
            if (resultDic) {
                [array addObject:resultDic];
            }
        }else if (Equal(name, @"commodity_order_maintain")){
            if (resultDic) {
                [array addObject:resultDic];
            }
        }else if (Equal(name, @"package_detail")){
            if (resultDic) {
                PackageDetailModel *model = [[PackageDetailModel alloc] initWithDic:resultDic];
                [array addObject:model];
            }
        }else if (Equal(name, @"system_param")){
            if (resultDic) {
                SystemParamInfo *model = [[SystemParamInfo alloc] initWithDic:resultDic];
                [array addObject:model];
            }
        }else if (Equal(name, @"user_edit_info")){
            if (resultDic) {
                [array addObject:resultDic];
            }
        }else if (Equal(name, @"activity_detail")){
            if (resultDic) {
                ActivityModel *model = [[ActivityModel alloc] initWithDic:resultDic];
                [array addObject:model];
            }
        }else if (Equal(name, @"teaching_member_reservation_list")){
            if (resultDic) {
                MemberReservationModel *model = [[MemberReservationModel alloc] initWithDic:resultDic];
                [array addObject:model];
            }
        }else if (Equal(name, @"user_withdraw")){
            if (resultDic) {
                [array addObject:resultDic];
            }
        }else if (Equal(name, @"club_comment_list")){
            if (resultDic) {
                TotalCommentModel *model = [[TotalCommentModel alloc] initWithDic:resultDic];
                [array addObject:model];
            }
        }else if (Equal(name, @"redpacket_list")){
            if (resultDic) {
                [array addObject:resultDic];
            }
        }else if (Equal(name, @"redpacket_detail")){
            if (resultDic) {
                RedPaperModel *model = [[RedPaperModel alloc] initWithDic:resultDic];
                [array addObject:model];
            }
        }else if (Equal(name, @"article_detail")){
            
        }else if (Equal(name, @"article_comment_add")){
            if (resultDic) {
                [array addObject:resultDic];
            }
        }else if (Equal(name, @"article_praise")){
            if (resultDic) {
                [array addObject:resultDic];
            }
        }else if (Equal(name, @"user_detail")){
            if (resultDic) {
                UserDetailModel *model = [[UserDetailModel alloc] initWithDic:resultDic];
                [array addObject:model];
            }
        }else if (Equal(name, @"user_message_add")){
            if (resultDic) {
                UserNewsModel *model = [[UserNewsModel alloc] initWithDic:resultDic];
                NSString *remarkName = [[YGUserRemarkCacheHelper shared] getUserRemarkName:model.memberId];
                if ([remarkName isNotBlank]) {
                    model.displayName = remarkName;
                }
                [array addObject:model];
            }
        }else if (Equal(name, @"user_follow_list")){
            if (resultDic) {
                [array addObject:resultDic];
            }
        }else if (Equal(name, @"user_follow_add")){
            if (resultDic) {
                [array addObject:resultDic];
            }
        }else if (Equal(name, @"user_edit_album")){
            if (resultDic) {
                [array addObject:resultDic];
            }
        }else if (Equal(name, @"user_played_club_list")){
            if (resultDic) {
                [array addObject:resultDic];
            }
        }else if (Equal(name, @"user_played_club_edit")){
            if (resultDic) {
                [array addObject:resultDic];
            }
        }else if (Equal(name, @"topic_add")){
            if (resultDic) {
                [array addObject:resultDic];
            }
        }else if (Equal(name, @"topic_praise_add")){
            if (resultDic) {
                [array addObject:resultDic];
            }
        }else if (Equal(name, @"footprint_add")){
            if (resultDic) {
                [array addObject:resultDic];
            }
        }else if (Equal(name, @"footprint_batch_list")){
            if (resultDic) {
                [array addObject:resultDic];
            }
        }else if (Equal(name, @"footprint_batch_edit")){
            if (resultDic) {
                [array addObject:resultDic];
            }
        }else if (Equal(name, @"public_validate_code")){
            if (resultDic) {
                [array addObject:resultDic];
            }
        }else if (Equal(name, @"user_switch_info")){
            if (resultDic) {
                NSMutableDictionary *md = [NSMutableDictionary dictionary];
                [md setObject:resultDic[@"switch_topic_praise"] forKey:@"key_0"];
                [md setObject:resultDic[@"switch_topic_comment"] forKey:@"key_1"];
                [md setObject:resultDic[@"switch_member_follow"] forKey:@"key_2"];
                [md setObject:resultDic[@"switch_member_message"] forKey:@"key_3"];
                [md setObject:resultDic[@"switch_no_disturbing"] forKey:@"key_4"];
                [[NSUserDefaults standardUserDefaults] setObject:md forKey:@"MessageNotificateSetting"];
                [array addObject:resultDic];
            }
        }else if (Equal(name, @"consume_award")){
            if (resultDic) {
                [array addObject:resultDic];
            }
        }else if (Equal(name, @"teaching_public_class_detail")){
            if (resultDic) {
                PublicCourseDetail *detail = [[PublicCourseDetail alloc] initWithDic:resultDic];
                [array addObject:detail];
            }
        }else if (Equal(name, @"teaching_product_detail")){
            if (resultDic) {
                TeachProductDetail *detail = [[TeachProductDetail alloc] initWithDic:resultDic];
                [array addObject:detail];
            }
        }else if (Equal(name, @"teaching_coach_product_timetable")){
            if (resultDic) {
                [array addObject:resultDic];
            }
        }else if (Equal(name, @"teaching_order_submit")){
            if (resultDic) {
                TeachingSubmitInfo *submitInfo = [[TeachingSubmitInfo alloc] initWithDic:resultDic];
                [array addObject:submitInfo];
            }
        }else if (Equal(name, @"teaching_order_pay")){
            if (resultDic) {
                TeachingTranModel *teachingTran = [[TeachingTranModel alloc] initWithDic:resultDic];
                [array addObject:teachingTran];
            }
        }else if (Equal(name, @"teaching_order_detail")){
            if (resultDic) {
                TeachingOrderDetailModel *teachingDetail = [[TeachingOrderDetailModel alloc] initWithDic:resultDic];
                [array addObject:teachingDetail];
            }
        }else if (Equal(name, @"teaching_member_reservation_add")){
            if (resultDic) {
                ReservationModel *model = [[ReservationModel alloc] initWithDic:resultDic];
                [array addObject:model];
            }
        }else if (Equal(name, @"teaching_comment_add")){
            if (self.success == YES) {
                [array addObject:@(1)];
            }else{
                [array addObject:@(0)];
            }
        }else if (Equal(name, @"teaching_comment_reply")){
            if (self.success == YES) {
                [array addObject:@(1)];
            }else{
                [array addObject:@(0)];
            }
        }else if (Equal(name, @"teaching_member_class_postpone")){
            if (resultDic) {
                [array addObject:resultDic];
            }
        }else if (Equal(name, @"teaching_coach_data_report")){
            if (resultDic) {
                CoachDataRpt *rpt = [[CoachDataRpt alloc] initWithDic:resultDic];
                [array addObject:rpt];
            }
        }else if (Equal(name, @"topic_share_add")){
            if (resultDic.count!=0) {
                [array addObject:resultDic];
            }
        }
        
    }else{
        if (Equal(name, @"dict_city")){
            NSString *path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
            NSString *filename=[path stringByAppendingPathComponent:@"GolfCityInfo.plist"];
            
            if (!data) {
                NSArray *localArray = [NSArray arrayWithContentsOfFile:filename];
                for (id obj in localArray) {
                    SearchCityModel *model = [[SearchCityModel alloc] initWithDic:obj];
                    [array addObject:model];
                }
            }
        }
        else if (Equal(name, @"dict_province")){
            NSString *path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
            NSString *filename=[path stringByAppendingPathComponent:@"GolfProvinceInfo.plist"];
            
            if (!data) {
                NSArray *localArray = [NSArray arrayWithContentsOfFile:filename];
                for (id obj in localArray) {
                    SearchProvinceModel *model = [[SearchProvinceModel alloc] initWithDic:obj];
                    [array addObject:model];
                }
            }
        }else if (Equal(name, @"commodity_comment_add")){
            if (self.success == YES) {
                [array addObject:@(1)];
            }else{
                [array addObject:@(0)];
            }
        }else if (Equal(name, @"commodity_arrival_notice")){
            if (self.success == YES) {
                [array addObject:@(1)];
            }else{
                [array addObject:@(0)];
            }
        }
        
        // doNothing..........
    }
    
    if ([self.delegate isKindOfClass:self.orignalClass]) {
        if ([self.delegate respondsToSelector:@selector(serviceResult:Data:flag:)]) {
            [self.delegate serviceResult:self Data:array flag:name];
        }
        if ([self.delegate respondsToSelector:@selector(serviceResult:BS:Data:flag:)]) {
            [self.delegate serviceResult:self BS:bs Data:array flag:name];
        }
    }
    self.orignalClass = nil;
    self.delegate = nil;
}

- (void)post:(NSString *)mode params:(NSDictionary *)params {
    self.interfaceName = mode;
    
    __weak ServiceManager *sm = self;
    [BaseService BSPost:mode parameters:params encrypt:YES needLoading:self.needLoading success:^(BaseService *BS) {
        if (BS.success) {
            self.success = YES;
            [sm newDataWithAsynchronousBS:BS interfaceName:self.interfaceName];
        }
    } failure:^(id error) {
        sm.success = NO;
        [sm newDataWithAsynchronousBS:nil interfaceName:self.interfaceName];
    }];

}

- (void)get:(NSString *)mode params:(id)params withMD5:(BOOL)amd5 completion:(void(^)(id obj))completion{
    self.interfaceName = mode;
    [BaseService BSGet:mode
            parameters:params
               encrypt:YES
           needLoading:self.needLoading
               success:^(BaseService *BS) {
                   if (BS.success) {
                       id obj = BS.data;
                       completion (obj);
                   }
               } failure:^(id error) {
                   
               }];
    
}

- (void)get:(NSString *)mode params:(id)params completion:(void(^)(id obj))completion{
    return [self get:mode params:params withMD5:YES completion:completion];
}


- (BOOL)getBoolValue:(NSDictionary *)value {
    return [[value objectForKey:@"flag"] boolValue];
}

- (void)asynchronousGet:(NSString *)mode params:(id)params withMD5:(BOOL)amd5{
    self.interfaceName = mode;
    
    __weak ServiceManager *sm = self;
    [BaseService BSGet:mode parameters:params encrypt:amd5 needLoading:self.needLoading success:^(BaseService *BS) {
        sm.success = YES;
        [sm newDataWithAsynchronousBS:BS interfaceName:self.interfaceName];
    } failure:^(id error) {
        sm.success = NO;
        [sm newDataWithAsynchronousBS:nil interfaceName:self.interfaceName];
    }];
}

- (void)asynchronousGet:(NSString *)mode params:(id)params{
    [self asynchronousGet:mode params:params withMD5:YES];
}

@end
