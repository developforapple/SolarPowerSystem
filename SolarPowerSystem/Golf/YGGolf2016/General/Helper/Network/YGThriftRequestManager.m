//
//  YGThriftRequestManager.m
//  Golf
//
//  Created by wwwbbat on 16/5/27.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGThriftRequestManager.h"
#import "TTransport.h"
#import "TFramedTransport.h"
#import "TProtocol.h"
#import "TBinaryProtocol.h"
#import "THTTPClient.h"
#import "TCompactProtocol.h"
#import "TNSStreamTransport.h"

/*!
 *  @brief 请求失败时的回调
 *
 *  @param ex      异常信息
 *  @param failure 回调block
 */
void CallFailure(NSException *ex,YGRequestFailure failure);

/*!
 *  @brief 请求成功时的回调
 *
 *  @param suc     数据是否OK
 *  @param object  数据
 *  @param success 回调block
 */
void CallSuccess(BOOL suc,id object,YGRequestSuccess success);

/*!
 *  @brief 正确的pageSize
 */
NS_INLINE int32_t GetPageSize(NSNumber *p){return p.intValue<=0?kDefaultPageSize:p.intValue;}

#pragma mark - General
@interface API (General)
@property (strong, readonly, nonatomic) NSOperationQueue *myQueue;
- (void)operation:(void(^)(void))block :(YGRequestFailure)fail;
@end
@implementation API (General)
- (NSOperationQueue *)myQueue
{
    static NSOperationQueue *myQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        myQueue = [[NSOperationQueue alloc] init];
        myQueue.maxConcurrentOperationCount = 10;
    });
    return myQueue;
}

/**
 将block中内容添加到队列中执行。自动处理失败
 
 @param block 执行的代码块
 @param fail  失败的回调block
 */
- (void)operation:(void(^)(void))block :(YGRequestFailure)fail{
    [self.myQueue addOperationWithBlock:^{
        @try{
            block?block():0;
        }
        @catch(NSException *exception){
            CallFailure(exception,(fail));
        }
    }];
}


/**
 另外一种方式将code添加到队列中执行。自动处理结果和失败。

 @param block 执行的代码块。返回值需要带有err属性
 @param suc   成功的回调block
 @param fail  失败的回调block
 */
- (void)operation:(id(^)(void))block suc:(YGRequestSuccess)suc fail:(YGRequestFailure)fail
{
    if (!block) return;
    
    static Error *(^getErr)(id result);
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        getErr = ^Error *(id result){
            if ([result respondsToSelector:@selector(err)]) {
                return [result performSelector:@selector(err)];
            }
            if ([result respondsToSelector:@selector(error)]) {
                return [result performSelector:@selector(error)];
            }
            return nil;
        };
    });
    [self.mainQueue addOperationWithBlock:^{
        @try {
            id result = block();
            Error *err = getErr(result);
            CallSuccess(!err, result, suc);
        } @catch (NSException *exception) {
            CallFailure(exception, fail);
        }
    }];
}

@end


#pragma mark - Callback
void CallFailure(NSException *ex,YGRequestFailure failure){
    if (failure) {
        Error *error = [Error new];
        error.errorMsg = ex.reason;
        RunOnMainQueue(^{
            failure(error);
        });
    }
}

void CallSuccess(BOOL suc,id object,YGRequestSuccess success){
    if (success) {
        RunOnMainQueue(^{
            success(suc,object);
        });
    }
}


#pragma mark - ----------------------------------------悦读模块----------------------------------------
@implementation API (YueDu)

#pragma mark Client

#define YueduClient [self yueduClient]
- (YueduIServicesClient *)yueduClient{
    return [[YueduIServicesClient alloc] initWithProtocol:[[TCompactProtocol alloc] initWithTransport:[[YGThriftClient alloc] initWithURL:[NSURL URLWithString:API_THRIFT_YUEDU]]]];
}

#pragma mark 悦读API
- (void)fetchYueDuCategories:(YGRequestSuccess)success
                     failure:(YGRequestFailure)failure{
    [self operation:^id{
        return [YueduClient getAllCategory:[self getHeadBean]];
    } suc:success fail:failure];
}

- (void)fetchArticleListInColumn:(NSNumber *)columnId
                        category:(NSNumber *)categoryId
                         albumId:(NSNumber *)albumId
                     lastArticle:(NSNumber *)lastArticleId
                        pageSize:(NSNumber *)pageSize
                         success:(YGRequestSuccess)success
                         failure:(YGRequestFailure)failure{
    [self operation:^{
        YueduArticleList *result = [YueduClient getArticleList:[self getHeadBean]
                                                 columnId:[columnId intValue]
                                               categoryId:[categoryId intValue]
                                                  albumId:[albumId intValue]
                                            lastArticleId:[lastArticleId intValue]
                                                    count:GetPageSize(pageSize)];
        CallSuccess(!result.err, result, success);
    } :failure];
}

- (void)fetchArticleDetail:(NSNumber *)articleId
                   success:(YGRequestSuccess)success
                   failure:(YGRequestFailure)failure{
    [self operation:^{
        YueduArticleDetail *result = [YueduClient getArticleDetail:[self getHeadBean] articleId:[articleId intValue]];
        CallSuccess(!result.err, result, success);
    } :failure];
}

- (void)fetchAlbumDetail:(NSNumber *)albumId
                 success:(YGRequestSuccess)success
                 failure:(YGRequestFailure)failure{
    [self operation:^{
        YueduAlbumDetail *result = [YueduClient getAlbumDetail:[self getHeadBean]
                                                  albumId:albumId.intValue];
        CallSuccess(!result.err, result, success);
    } :failure];
}

- (void)fetchAlbumList:(NSNumber *)categoryId
             lastAlbum:(NSNumber *)lastAlbumId
              pageSize:(NSNumber *)pageSize
               success:(YGRequestSuccess)success
               failure:(YGRequestFailure)failure{
    [self operation:^{
        YueduAlbumList *result =[YueduClient getAlbumList:[self getHeadBean]
                                          categoryId:categoryId.intValue
                                         lastAlbumId:lastAlbumId.intValue
                                               count:GetPageSize(pageSize)];
        CallSuccess(!result.err, result, success);
    } :failure];
}

- (void)fetchRelationArticles:(NSNumber *)articleId
                      lastOne:(NSNumber *)lastArticleId
                     pageSize:(NSNumber *)pageSize
                      success:(YGRequestSuccess)success
                      failure:(YGRequestFailure)failure{
    [self operation:^{
        YueduArticleList *result = [YueduClient relationArticleList:[self getHeadBean]
                                                     articleId:articleId.intValue
                                                 lastArticleId:lastArticleId.intValue
                                                         count:GetPageSize(pageSize)];
        CallSuccess(!result.err, result, success);
    } :failure];
}

- (void)fetchArticleHotKeywords:(YGRequestSuccess)success
                        failure:(YGRequestFailure)failure{
    [self operation:^{
        YueduHotTopicList *result = [YueduClient getHotTopics:[self getHeadBean]];
        CallSuccess(!result.err, result, success);
    } :failure];
}

- (void)yueduSearch:(NSString *)keywords
               type:(NSNumber *)type
             pageNo:(NSNumber *)pageNo
           pageSize:(NSNumber *)pageSize
            success:(YGRequestSuccess)success
            failure:(YGRequestFailure)failure{
    [self operation:^{
        YueduSearchResult *result = [YueduClient search:[self getHeadBean]
                                                keyword:keywords
                                                   type:type.intValue
                                                 pageNo:pageNo.intValue
                                               pageSize:GetPageSize(pageSize)];
        CallSuccess(!result.err, result, success);
    } :failure];
}

- (void)yueduExecuteLike:(BOOL)like
               toArticle:(NSNumber *)articleId
                 success:(YGRequestSuccess)success
                 failure:(YGRequestFailure)failure{
    [self operation:^{
        AckBean *result;
        if (like) {
            result = [YueduClient likeArticle:[self getHeadBean] articleId:articleId.intValue];
        }else{
            result = [YueduClient dislikeArticle:[self getHeadBean] articleId:articleId.intValue];
        }
        CallSuccess(!result.err, result, success);
    } :failure];
}

- (void)yueduExecuteLike:(BOOL)like
                 toAlbum:(NSNumber *)albumId
                 success:(YGRequestSuccess)success
                 failure:(YGRequestFailure)failure{
    [self operation:^{
        AckBean *result;
        if (like) {
            result = [YueduClient likeAlbum:[self getHeadBean] albumId:albumId.intValue];
        }else{
            result = [YueduClient dislikeAlbum:[self getHeadBean] albumId:albumId.intValue];
        }
        CallSuccess(!result.err, result, success);
    } :failure];
}

- (void)fetchLikedArticles:(NSNumber *)lastArticleId
                  pageSize:(NSNumber *)pageSize
                   success:(YGRequestSuccess)success
                   failure:(YGRequestFailure)failure{
    [self operation:^{
        YueduArticleList *result = [YueduClient getLikeArticleList:[self getHeadBean]
                                                     lastArticleId:lastArticleId.intValue
                                                             count:GetPageSize(pageSize)];
        CallSuccess(!result.err, result, success);
    } :failure];
}

- (void)fetchLikedAlbums:(NSNumber *)lastAlbumId
                pageSize:(NSNumber *)pageSize
                 success:(YGRequestSuccess)success
                 failure:(YGRequestFailure)failure{
    [self operation:^{
        YueduAlbumList *result = [YueduClient getLikeAlbumList:[self getHeadBean]
                                                   lastAlbumId:lastAlbumId.intValue
                                                         count:GetPageSize(pageSize)];
        CallSuccess(!result.err, result, success);
    } :failure];
}

- (void)postYueduToFeed:(NSNumber *)articleId
                orAlbum:(NSNumber *)albumId
                content:(NSString *)content
               location:(Location *)location
                 clubid:(NSNumber *)clubid
                success:(YGRequestSuccess)success
                failure:(YGRequestFailure)failure{
    [self operation:^{
        AckBean *result = [YueduClient shareYueduToTopic:[self getHeadBean]
                                                location:location
                                               articleId:articleId.intValue
                                                 albumId:albumId.intValue
                                                 content:content
                                                  clubId:clubid.intValue];
        CallSuccess(!result.err, result, success);
    } :failure];
}

@end

#pragma mark - ----------------------------------------教学预定----------------------------------------
@implementation API (Teaching)

#pragma mark Client

#define TeachingClient [self teachingClient]
- (TeachingIServicesClient *)teachingClient{
    return [[TeachingIServicesClient alloc] initWithProtocol:[[TCompactProtocol alloc] initWithTransport:[[YGThriftClient alloc] initWithURL:[NSURL URLWithString:API_THRIFT_TEACHING]]]];
}

#pragma mark 教学练习场
- (void)fetchSeatSpecList:(NSNumber *)courseId
                     date:(BookingDateBean *)dateBean
                  success:(YGRequestSuccess)success
                  failure:(YGRequestFailure)failure{
    [self operation:^{
        VirtualSeatSpecList *list = [TeachingClient getSeatSpecList:[self getHeadBean]
                                                           courseId:courseId.intValue
                                                           dateBean:dateBean];
        CallSuccess(!list.err, list, success);
    } :failure];
}

- (void)confirmTeachingOrder:(NSArray<VirtualSeatSpecBean *> *)seatSpecs
                      course:(NSNumber *)courseId
                     success:(YGRequestSuccess)success
                     failure:(YGRequestFailure)failure{
    [self operation:^{
        VirtualCourseOrderDetail *result = [TeachingClient confirmVirtualCourseOrder:[self getHeadBean]
                                                                            courseId:[courseId intValue]
                                                                            specList:seatSpecs.mutableCopy];
        CallSuccess(!result.err, result, success);
    } :failure];
}

- (void)submitTeachingOrder:(VirtualCourseOrderBean *)order
                    success:(YGRequestSuccess)success
                    failure:(YGRequestFailure)failure{
    [self operation:^{
        VirtualCourseOrderDetail *result = [TeachingClient submitVirtualCourseOrder:[self getHeadBean]
                                                                          orderBean:order];
        CallSuccess(!result.err, result, success);
    } :failure];
}

- (void)fetchTeachingOrderList:(NSNumber *)status
                        pageNo:(NSNumber *)pageNo
                      pageSize:(NSNumber *)size
                       success:(YGRequestSuccess)success
                       failure:(YGRequestFailure)failure{
    [self operation:^id{
        return [TeachingClient virtualCourseOrderList:[self getHeadBean]
                                               status:status.intValue
                                               pageNo:pageNo.intValue
                                             pageSize:GetPageSize(size)];
    } suc:success fail:failure];
}

- (void)submitTeachingOrderRefund:(NSNumber *)orderId
                          success:(YGRequestSuccess)success
                          failure:(YGRequestFailure)failure{
    [self operation:^id{
        return [TeachingClient virtualCourseOrderReturnMoney:[self getHeadBean] orderId:orderId.intValue];
    } suc:success fail:failure];
}

- (void)cancelTeachingOrder:(NSNumber *)orderId
                    success:(YGRequestSuccess)success
                    failure:(YGRequestFailure)failure{
    [self operation:^id{
        return [TeachingClient cancelVirtualCourseOrder:[self getHeadBean] orderId:orderId.intValue];
    } suc:success fail:failure];
}

- (void)deleteTeachingOrder:(NSNumber *)orderId
                    success:(YGRequestSuccess)success
                    failure:(YGRequestFailure)failure{
    [self operation:^id{
        return [TeachingClient delVirtualCourseOrder:[self getHeadBean] orderId:orderId.intValue];
    } suc:success fail:failure];
}

- (void)fetchTeachingOrderDetail:(NSNumber *)orderId
                         success:(YGRequestSuccess)success
                         failure:(YGRequestFailure)failure{
    [self operation:^id{
        return [TeachingClient getVirtualCourseOrderDetail:[self getHeadBean] orderId:orderId.intValue];
    } suc:success fail:failure];
}

#pragma mark 教学档案
- (void)fetchTeachingMemberClassList:(NSNumber *) classStatus
                        lastClassId:(NSNumber *) lastClassId
                              count:(NSNumber *) count
                            success:(YGRequestSuccess)success
                            failure:(YGRequestFailure)failure{
    [self operation:^{
        TeachingMemberClassList *result = [TeachingClient getTeachingMemberClassList:[self getHeadBean] classStatus:[classStatus intValue] lastClassId:[lastClassId intValue] count:GetPageSize(count)];
        CallSuccess(!result.err, result, success);
    } :failure];
}

- (void)fetchTeachingMemberClassPeriodList:(NSNumber *)classId
                        classPeriodStatus:(NSNumber *) classPeriodStatus
                             lastPeriodId:(NSNumber *) lastPeriodId count:(NSNumber *) count
                                  success:(YGRequestSuccess)success
                                  failure:(YGRequestFailure)failure{
    [self operation:^{
        TeachingMemberClassPeriodList *result = [TeachingClient getTeachingMemberClassPeriodList:[self getHeadBean] classId:[classId intValue] classPeriodStatus:[classPeriodStatus intValue] lastPeriodId:[lastPeriodId intValue] count:GetPageSize(count)];
        CallSuccess(!result.err, result, success);
    } :failure];
}

- (void)fetchTeachingMemberClassInfoDetail:(NSNumber *) classId
                                  success:(YGRequestSuccess)success
                                  failure:(YGRequestFailure)failure{
    [self operation:^{
        TeachingMemberClassInfoDetail *result = [TeachingClient getTeachingMemberClassInfoDetail:[self getHeadBean] classId:[classId intValue]];
        CallSuccess(!result.err, result, success);
    } :failure];
}

- (void)fetchTeachingMemberClassPeriodDetail:(NSNumber *) periodId
                                   location:(Location *) location
                                    success:(YGRequestSuccess)success
                                    failure:(YGRequestFailure)failure{
    [self operation:^{
        TeachingMemberClassPeriodDetail *result = [TeachingClient getTeachingMemberClassPeriodDetail:[self getHeadBean] periodId:[periodId intValue] location:location];
        CallSuccess(!result.err, result, success);
        
    } :failure];
        
}

- (void)fetchTeachingMemberPeriodArchiveList:(NSNumber *) periodId
                                     lastId:(NSNumber *) lastId
                                      count:(NSNumber *) count
                                    success:(YGRequestSuccess)success
                                    failure:(YGRequestFailure)failure{
    [self operation:^{
        
        TeachingMemberPeriodArchivePageList *result = [TeachingClient getTeachingMemberPeriodArchiveList:[self getHeadBean] lastId:[lastId intValue] count:GetPageSize(count) periodId:[periodId intValue]];
        CallSuccess(!result.err, result, success);
        
    } :failure];
}

- (void)publishOrEditTeachingMemberPeriodArchive:(TeachingMemberPeriodArchiveBean *) archiveBean
                                    publishTopic: (NSNumber *) publishTopic
                                        location: (Location *) location
                                         success:(YGRequestSuccess)success
                                         failure:(YGRequestFailure)failure{
    [self operation:^{
        TeachingMemberPeriodArchiveDetail *result = [TeachingClient editTeachingMemberPeriodArchive:[self getHeadBean] archiveBean:archiveBean publishTopic:[publishTopic intValue] location:location];
        CallSuccess(!result.err, result, success);
        
    } :failure];
    
}

- (void)deleteTeachingMemberPeriodArchive:(NSNumber *) archiveId
                                  success:(YGRequestSuccess)success
                                  failure:(YGRequestFailure)failure{
    [self operation:^{
        AckBean *result = [TeachingClient deleteTeachingMemberPeriodArchive:[self getHeadBean] archiveId:[archiveId intValue]];
        CallSuccess(!result.err, result, success);
        
    } :failure];
    
}

- (void)fetchTeachingCoachTodayPeriodList:(YGRequestSuccess)success
                                  failure:(YGRequestFailure)failure{
    [self operation:^{
        TeachingMemberClassPeriodList *result = [TeachingClient getTeachingCoachTodayPeriodList:[self getHeadBean]];
        CallSuccess(!result.err, result, success);
        
    } :failure];
}

- (void)fetchCoachReservationPeriodListByStatus:(NSNumber *) reservationStatus
                                         lastId:(NSNumber *) lastId
                                          count:(NSNumber *) count
                                        keyword:(NSString *) keyword
                                        success:(YGRequestSuccess)success
                                        failure:(YGRequestFailure)failure{
    [self operation:^{
        TeachingMemberClassPeriodList *result = [TeachingClient coachReservationPeriodListByStatus:[self getHeadBean] reservationStatus:[reservationStatus intValue] lastId:[lastId intValue] count:GetPageSize(count) keyword:keyword];
        CallSuccess(!result.err, result, success);
        
    } :failure];
}

- (void)fetchCoachGetMemberDetail:(NSNumber *) studentId
                           lastId:(NSNumber *) lastId
                            count:(NSNumber *) count
                          success:(YGRequestSuccess)success
                          failure:(YGRequestFailure)failure{
    [self operation:^{
        TeachingCoachMemberDetail *result = [TeachingClient coachGetMemberDetail:[self getHeadBean] studentId:[studentId intValue] lastId:[lastId intValue] count:[count intValue]];
        CallSuccess(!result.err, result, success);
        
    } :failure];
}

- (void)coachCommentMemberPeriod:(NSNumber *) periodId
                         content:(NSString *) content
                         success:(YGRequestSuccess)success
                         failure:(YGRequestFailure)failure{
    [self operation:^{
        AckBean *result = [TeachingClient coachCommentMemberPeriod:[self getHeadBean] periodId:[periodId intValue] content:content];
        CallSuccess(!result.err, result, success);
        
    } :failure];
}

- (void)teachingMemberCommentClassCoach:(NSNumber *) classId
                              starLevel:(NSNumber *) starLevel
                                content:(NSString *) content
                                success:(YGRequestSuccess)success
                                failure:(YGRequestFailure)failure{
    [self operation:^{
        AckBean *result = [TeachingClient teachingMemberCommentClassCoach:[self getHeadBean] classId:[classId intValue] starLevel:[starLevel doubleValue] content:content];
        CallSuccess(!result.err, result, success);
        
    } :failure];
}

- (void)editClassPeriodName:(NSNumber *) classId
                   periodId:(NSNumber *) periodId
                  specialId:(NSNumber *) specialId
                    success:(YGRequestSuccess)success
                    failure:(YGRequestFailure)failure{
    [self operation:^{
        AckBean *result = [TeachingClient editClassPeriodName:[self getHeadBean] classId:[classId intValue] periodId:[periodId intValue] specialId:[specialId intValue]];
        CallSuccess(!result.err, result, success);
        
    } :failure];
}

- (void)fetchClassSpecialList:(NSNumber *) classId
                      success:(YGRequestSuccess)success
                      failure:(YGRequestFailure)failure{
    [self operation:^{
        TeachingProductSpecialList *result = [TeachingClient getClassSpecialList:[self getHeadBean] classId:[classId intValue]];
        CallSuccess(!result.err, result, success);
        
    } :failure];
}

@end

#pragma mark - ----------------------------------------全局搜索----------------------------------------
@implementation API (Search)

#pragma mark Client
#define GeneralSearchClient [self generalSearchClient]
- (IServicesClient *)generalSearchClient{
    return [[IServicesClient alloc] initWithProtocol:[[TCompactProtocol alloc] initWithTransport:[[YGThriftClient alloc] initWithURL:[NSURL URLWithString:API_THRIFT]]]];
}

#pragma mark 搜索API
- (void)generalSearch:(NSString *)keywords
                 type:(NSNumber *)type
                 page:(NSNumber *)pageNo
            longitude:(CGFloat)longitude
             latitude:(CGFloat)latitude
              success:(YGRequestSuccess)success
              failure:(YGRequestFailure)failure{
    [self operation:^{
        SearchBean *searchBean = [[SearchBean alloc] initWithKeyword:keywords
                                                          searchType:type.intValue
                                                           longitude:[NSString stringWithFormat:@"%.2f",longitude]
                                                            latitude:[NSString stringWithFormat:@"%.2f",latitude]
                                                         currentPage:pageNo.intValue];
        SearchResultList *result = [GeneralSearchClient searchAll:[self getHeadBean]
                                                       searchBean:searchBean];
        CallSuccess(!result.err, result, success);
    } :failure];
}

- (void)changeMobileSearchStatus:(BOOL)canSearchByMobile
                         success:(YGRequestSuccess)success
                         failure:(YGRequestFailure)failure{
    [self operation:^{
        AckBean *ackBean = [GeneralSearchClient changeMobileSearchStatus:[self getHeadBean] canSearchByMobile:canSearchByMobile?1:0];
        CallSuccess(!ackBean.err, ackBean, success);
    } :failure];
}

@end

#pragma mark - ----------------------------------------旅游套餐----------------------------------------

@implementation API (Package)

#pragma mark Client
#define GeneralPackageClient [self generalPackageClient]
- (TravelPackageIServicesClient *)generalPackageClient{
    return [[TravelPackageIServicesClient alloc] initWithProtocol:[[TCompactProtocol alloc] initWithTransport:[[YGThriftClient alloc] initWithURL:[NSURL URLWithString:API_THRIFT_PACKAGE]]]];
}

- (void)getTravelPackageHomePageWithLocation:(Location *)location success:(YGRequestSuccess)success
                                failure:(YGRequestFailure)failure{
    ygweakify(self)
    [self operation:^{
        ygstrongify(self)
        TravelPackageHomePage *result = [GeneralPackageClient getTravelPackageHomePage:[self getHeadBean] location:location];
        CallSuccess(!result.err, result, success);
    } :failure];
}

- (void)getTravelPackageRecommendByAreaEnum:(enum PackageAreaEnum)areaEnum location:(Location *)location success:(YGRequestSuccess)success failure:(YGRequestFailure)failure{
    ygweakify(self)
    [self operation:^{
        ygstrongify(self)
        TravelPackageAreaRecommend *result = [GeneralPackageClient getTravelPackageRecommend:[self getHeadBean] areaEnum:areaEnum location:location];
        CallSuccess(!result.err, result, success);
    } :failure];
}

- (void)getAreaTravelPackageListByAreaEnum:(enum PackageAreaEnum)areaEnum locatioin:(Location *)location categoryEnum:(enum PackageCategoryEnum)categoryEnum pageBean:(PageBean *)pageBean success:(YGRequestSuccess)success failure:(YGRequestFailure)failure{
    ygweakify(self)
    [self operation:^{
        ygstrongify(self)
        TravelPackageList *result = [GeneralPackageClient getAreaTravelPackageList:[self getHeadBean] areaEnum:areaEnum location:location categoryEnum:categoryEnum pageBean:pageBean];
        CallSuccess(!result.err, result, success);
    } :failure];
}

- (void)getCityTravelPackageListByCityBean:(CityBean *)cityBean sortEnum:(enum PackageSortEnum)sortEnum pageBean:(PageBean *)pageBean success:(YGRequestSuccess)success failure:(YGRequestFailure)failure{
    ygweakify(self)
    [self operation:^{
        ygstrongify(self)
        TravelPackageList *result = [GeneralPackageClient getCityTravelPackageList:[self getHeadBean] cityBean:cityBean sortEnum:sortEnum pageBean:pageBean];
        CallSuccess(!result.err, result, success);
    } :failure];
}

- (void)getTravelPackageDetailWithPackageId:(int) packageId success:(YGRequestSuccess)success failure:(YGRequestFailure)failure{
    ygweakify(self)
    [self operation:^{
        ygstrongify(self)
        TravelPackageDetail *result = [GeneralPackageClient getTravelPackageDetail:[self getHeadBean] packageId:packageId];
        CallSuccess(!result.err, result, success);
    } :failure];
}

- (void)searchTravelPackageListWithKeyword:(NSString *)keyword sortEnum:(enum PackageSortEnum)sortEnum pageBean:(PageBean *)pageBean success:(YGRequestSuccess)success failure:(YGRequestFailure)failure{
    ygweakify(self)
    [self operation:^{
        ygstrongify(self)
        TravelPackageList *result = [GeneralPackageClient searchTravelPackageList:[self getHeadBean] keyword:keyword sortEnum:sortEnum pageBean:pageBean];
        CallSuccess(!result.err, result, success);
    } :failure];
}

- (void)submitCustomizedPackageWithCityName:(NSString *)cityName personCount:(int)personCount memo:(NSString *)memo success:(YGRequestSuccess)success failure:(YGRequestFailure)failure{
    ygweakify(self)
    [self operation:^{
        ygstrongify(self)
        AckBean *ackBean = [GeneralPackageClient submitCustomizedPackage:[self getHeadBean] cityName:cityName personCount:personCount memo:memo];
        CallSuccess(!ackBean.err, ackBean, success);
    } :failure];

}

- (void)submitOrderWithTravelPackageOrder:(TravelPackageOrder *)order success:(YGRequestSuccess)success failure:(YGRequestFailure)failure{
    [self operation:^{
        TravelPackageOrderDetail *result = [GeneralPackageClient submitOrder:[self getHeadBean] order:order];
        CallSuccess(!result.err, result, success);
    } :failure];
}

- (void)getOrderDetailWithOrderID:(int)orderID success:(YGRequestSuccess)success failure:(YGRequestFailure)failure{
    [self operation:^{
        TravelPackageOrderDetail *result = [GeneralPackageClient getOrderDetail:[self getHeadBean] orderId:orderID];
        CallSuccess(!result.err, result, success);
    } :failure];
}

- (void)getIndexTravelPackageList:(Location *)location
                          success:(YGRequestSuccess)success
                          failure:(YGRequestFailure)failure
{
    [self operation:^id{
        return [GeneralPackageClient getIndexTravelPackageList:[self getHeadBean] location:location];
    } suc:success fail:failure];
}

@end







