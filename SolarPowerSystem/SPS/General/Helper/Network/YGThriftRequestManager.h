//
//  YGThriftRequestManager.h
//  Golf
//
//  Created by wwwbbat on 16/5/27.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "API.h"
#import "YGThriftClient.h"
#import "YGThriftInclude.h"
#import "YGCommon.h"


#define kDefaultPageSize 20

#define YGRequest [API shareInstance]

/*!
 *  @brief 请求成功时的回调
 *
 *  @param suc    数据是否正常
 *  @param object 具体数据
 */
typedef void (^YGRequestSuccess)(BOOL suc, id object);

/*!
 *  @brief 请求失败时的回调
 *
 *  @param err 失败信息
 */
typedef void (^YGRequestFailure)(Error *err);

#pragma mark - 悦读头条
@interface API (YueDu)

/*!
 *  @brief 悦读分类标题
 *
 *  @param success success description
 *  @param failure failure description
 */
- (void)fetchYueDuCategories:(YGRequestSuccess)success
                     failure:(YGRequestFailure)failure;

/*!
 *  @author bo wang, 16-06-04 15:06:18
 *
 *  @brief 悦读文章列表
 *
 *  @param columnId      所属专栏
 *  @param categoryId    所属分类
 *  @param lastArticleId 加载更多时的最后一个文章id
 *  @param pageSize      每次请求的数据量
 *  @param success       success description
 *  @param failure       failure description
 *
 *  @since 6.50
 */
- (void)fetchArticleListInColumn:(NSNumber *)columnId
                        category:(NSNumber *)categoryId
                         albumId:(NSNumber *)albumId
                     lastArticle:(NSNumber *)lastArticleId
                        pageSize:(NSNumber *)pageSize
                         success:(YGRequestSuccess)success
                         failure:(YGRequestFailure)failure;
/*!
 *  @brief 悦读文章详情
 *
 *  @param articleId 文章id
 *  @param success   success description
 *  @param failure   failure description
 */
- (void)fetchArticleDetail:(NSNumber *)articleId
                   success:(YGRequestSuccess)success
                   failure:(YGRequestFailure)failure;
/*!
 *  @brief 悦读专题详情
 *
 *  @param albumId 专题id
 *  @param success success description
 *  @param failure failure description
 */
- (void)fetchAlbumDetail:(NSNumber *)albumId
                 success:(YGRequestSuccess)success
                 failure:(YGRequestFailure)failure;

/*!
 *  @brief 悦读专题列表
 *
 *  @param categoryId  专题所属分类
 *  @param lastAlbumId 获取更多时的最后一个专题id
 *  @param pageSize    获取的数据量大小
 *  @param success     success description
 *  @param failure     failure description
 */
- (void)fetchAlbumList:(NSNumber *)categoryId
             lastAlbum:(NSNumber *)lastAlbumId
              pageSize:(NSNumber *)pageSize
               success:(YGRequestSuccess)success
               failure:(YGRequestFailure)failure;

/*!
 *  @brief 悦读文章相关推荐
 *
 *  @param articleId 文章id
 *  @param lastArticleId 拉去更多时的最后一个id
 *  @param pageSize  每次获取的数据量
 *  @param success   success description
 *  @param failure   failure description
 */
- (void)fetchRelationArticles:(NSNumber *)articleId
                      lastOne:(NSNumber *)lastArticleId
                     pageSize:(NSNumber *)pageSize
                      success:(YGRequestSuccess)success
                      failure:(YGRequestFailure)failure;

/*!
 *  @brief 悦读文章热点词
 *
 *  @param success success description
 *  @param failure failure description
 */
- (void)fetchArticleHotKeywords:(YGRequestSuccess)success
                        failure:(YGRequestFailure)failure;

/*!
 *  @brief 悦读内的搜索
 *
 *  @param keywords 关键词
 *  @param type     搜索内容类型。0：全部。1：仅文章、2：仅专题
 *  @param pageNo   分页
 *  @param pageSize 每次获取的数据量
 *  @param success  success description
 *  @param failure  failure description
 */
- (void)yueduSearch:(NSString *)keywords
               type:(NSNumber *)type
             pageNo:(NSNumber *)pageNo
           pageSize:(NSNumber *)pageSize
            success:(YGRequestSuccess)success
            failure:(YGRequestFailure)failure;

/*!
 *  @brief like或者dislike一篇文章
 *
 *  @param like
 *  @param articleId 文章id
 *  @param success   success description
 *  @param failure   failure description
 */
- (void)yueduExecuteLike:(BOOL)like
               toArticle:(NSNumber *)articleId
                 success:(YGRequestSuccess)success
                 failure:(YGRequestFailure)failure;

/*!
 *  @brief like或者dislike一个专题
 *
 *  @param like
 *  @param albumId 专题id
 *  @param success success description
 *  @param failure failure description
 */
- (void)yueduExecuteLike:(BOOL)like
                 toAlbum:(NSNumber *)albumId
                 success:(YGRequestSuccess)success
                 failure:(YGRequestFailure)failure;

/*!
 *  @brief 我标记为like的文章列表
 *
 *  @param lastArticleId 分页时的最后一个文章id
 *  @param pageSize      每次获取的数据量
 *  @param success       success description
 *  @param failure       failure description
 */
- (void)fetchLikedArticles:(NSNumber *)lastArticleId
                  pageSize:(NSNumber *)pageSize
                   success:(YGRequestSuccess)success
                   failure:(YGRequestFailure)failure;
/*!
 *  @brief 我标记为like的专题列表
 *
 *  @param lastAlbumId 分页时的最后一个专题id
 *  @param pageSize    每次获取的数据量
 *  @param success     success description
 *  @param failure     failure description
 */
- (void)fetchLikedAlbums:(NSNumber *)lastAlbumId
                pageSize:(NSNumber *)pageSize
                 success:(YGRequestSuccess)success
                 failure:(YGRequestFailure)failure;

/*!
 *  @brief 分享一个文章到动态流中
 *
 *  @param articleId 文章id
 *  @param albumId   专题id
 *  @param content   用户填写的内容
 *  @param location  位置信息
 *  @param clubid    位置所处的球场
 *  @param success   success description
 *  @param failure   failure description
 */
- (void)postYueduToFeed:(NSNumber *)articleId
                orAlbum:(NSNumber *)albumId
                content:(NSString *)content
               location:(Location *)location
                 clubid:(NSNumber *)clubid
                success:(YGRequestSuccess)success
                failure:(YGRequestFailure)failure;
@end

#pragma mark - 教学预定
@class BookingDateBean,VirtualSeatSpecBean,VirtualCourseOrderBean,TeachingMemberPeriodArchiveBean;

@interface API (Teaching)

#pragma mark 练习场预定
/*!
 *  @brief 获取打位列表
 *
 *  @param courseId   场馆id
 *  @param dateBean   日期参数。首次请求时传入nil，返回当天的列表。其中包含了之后7天的日期列表。
 *  @param success    success description
 *  @param failure    failure description
 */
- (void)fetchSeatSpecList:(NSNumber *)courseId
                     date:(BookingDateBean *)dateBean
                  success:(YGRequestSuccess)success
                  failure:(YGRequestFailure)failure;

/*!
 *  @brief 教学练习场馆预定订单的确认
 *
 *  @param seatSpecs 待预定的打位列表
 *  @param success   success description
 *  @param failure   failure description
 */
- (void)confirmTeachingOrder:(NSArray<VirtualSeatSpecBean *> *)seatSpecs
                      course:(NSNumber *)courseId
                     success:(YGRequestSuccess)success
                     failure:(YGRequestFailure)failure;

/*!
 *  @brief 教学练习场馆预定订单的提交
 *
 *  @param order   订单
 *  @param success success description
 *  @param failure failure description
 */
- (void)submitTeachingOrder:(VirtualCourseOrderBean *)order
                    success:(YGRequestSuccess)success
                    failure:(YGRequestFailure)failure;

/**
 请求练习场预定的订单列表

 @param status  订单状态
 @param pageNo  页码
 @param success success description
 @param failure failure description
 */
- (void)fetchTeachingOrderList:(NSNumber *)status
                        pageNo:(NSNumber *)pageNo
                      pageSize:(NSNumber *)size
                       success:(YGRequestSuccess)success
                       failure:(YGRequestFailure)failure;

/**
 练习场订单申请退款

 @param orderId 订单id
 @param success success description
 @param failure failure description
 */
- (void)submitTeachingOrderRefund:(NSNumber *)orderId
                          success:(YGRequestSuccess)success
                          failure:(YGRequestFailure)failure;

/**
 取消练习场订单

 @param orderId 订单id
 @param success success description
 @param failure failure description
 */
- (void)cancelTeachingOrder:(NSNumber *)orderId
                    success:(YGRequestSuccess)success
                    failure:(YGRequestFailure)failure;

/**
 删除练习场订单

 @param orderId 订单id
 @param success success description
 @param failure failure description
 */
- (void)deleteTeachingOrder:(NSNumber *)orderId
                    success:(YGRequestSuccess)success
                    failure:(YGRequestFailure)failure;

/**
 请求练习场订单详情
 
 @param orderId 订单id
 @param success success description
 @param failure failure description
 */
- (void)fetchTeachingOrderDetail:(NSNumber *)orderId
                         success:(YGRequestSuccess)success
                         failure:(YGRequestFailure)failure;

#pragma mark 教学档案

/**
 *  我的教学档案 获取课程列表
 *
 *  @param classStatus 0 全部 1 教学中 2 已完成 3 已过期
 *  @param lastClassId 获取列表的开始Id
 *  @param count       获取的数量
 *  @param success     成功
 *  @param failure     失败
 */
- (void)fetchTeachingMemberClassList:(NSNumber *) classStatus
                         lastClassId:(NSNumber *) lastClassId
                               count:(NSNumber *) count
                             success:(YGRequestSuccess)success
                             failure:(YGRequestFailure)failure;

/**
 *  我的教学档案 获取课程的课时列表
 *
 *  @param classId           课程
 *  @param classPeriodStatus 0 获取全部
 *  @param lastPeriodId      获取列表的开始Id
 *  @param count             获取的数量
 *  @param success           成功
 *  @param failure           失败
 */
- (void)fetchTeachingMemberClassPeriodList:(NSNumber *)classId
                         classPeriodStatus:(NSNumber *) classPeriodStatus
                              lastPeriodId:(NSNumber *) lastPeriodId count:(NSNumber *) count
                                   success:(YGRequestSuccess)success
                                   failure:(YGRequestFailure)failure;

/**
 *  我的教学档案 获取课程详情
 *
 *  @param classId 课程Id
 */
- (void)fetchTeachingMemberClassInfoDetail:(NSNumber *) classId
                                   success:(YGRequestSuccess)success
                                   failure:(YGRequestFailure)failure;

/**
 *  我的教学档案 获取课时详情
 *
 *  @param periodId 课时Id
 *  @param location 地理位置信息
 *  @param success  成功
 *  @param failure  失败
 */
- (void)fetchTeachingMemberClassPeriodDetail:(NSNumber *) periodId
                                    location:(Location *) location
                                     success:(YGRequestSuccess)success
                                     failure:(YGRequestFailure)failure;

/**
 *  我的教学档案 获取课时详情的档案列表
 *
 *  @param periodId 课时Id
 *  @param lastId   获取的开始Id
 *  @param count    获取的数量
 *  @param success  成功
 *  @param failure  失败
 */
- (void)fetchTeachingMemberPeriodArchiveList:(NSNumber *) periodId
                                      lastId:(NSNumber *) lastId
                                       count:(NSNumber *) count
                                     success:(YGRequestSuccess)success
                                     failure:(YGRequestFailure)failure;
/**
 *  我的教学档案 发布教学档案【发布或者编辑 统一接口】
 *
 *  @param archiveBean  发布的数据对象
 *  @param publishTopic 是否同步到社区 1 同步到社区 0 不同步到社区
 *  @param location     地理位置信息
 *  @param success      成功
 *  @param failure      失败
 */
- (void)publishOrEditTeachingMemberPeriodArchive:(TeachingMemberPeriodArchiveBean *) archiveBean
                                    publishTopic: (NSNumber *) publishTopic
                                        location: (Location *) location
                                         success:(YGRequestSuccess)success
                                         failure:(YGRequestFailure)failure;

/**
 我的教学档案 删除课时动态

 @param archiveId 档案Id
 @param success   成功
 @param failure   失败
 */
- (void)deleteTeachingMemberPeriodArchive:(NSNumber *) archiveId
                                  success:(YGRequestSuccess)success
                                  failure:(YGRequestFailure)failure;

/**
 *  我的教学档案 教练端教练的今日教学课时列表
 *
 *  @param success 成功
 *  @param failure 失败
 */
- (void)fetchTeachingCoachTodayPeriodList:(YGRequestSuccess)success
                                  failure:(YGRequestFailure)failure;

/**
 我的教学档案 教练端预约管理课时列表

 @param reservationStatus 获取的状态 0 全部 1 待上课 2 已完成 3 未到场 4 已取消 5 待确认 6 待评论
 @param lastId            获取的开始Id
 @param count             获取的数量
 @param keyword           关键字
 @param success           成功
 @param failure           失败
 */
- (void)fetchCoachReservationPeriodListByStatus:(NSNumber *) reservationStatus
                                         lastId:(NSNumber *) lastId
                                          count:(NSNumber *) count
                                        keyword:(NSString *) keyword
                                        success:(YGRequestSuccess)success
                                        failure:(YGRequestFailure)failure;

/**
 我的教学档案 教练端 教练获取学员详情 lastId为0时，返回用户信息与课时列表，lastId>0时，仅返回课时列表

 @param studentId 学员Id
 @param lastId    获取的开始Id
 @param count     获取的数量
 @param success   成功
 @param failure   失败
 */
- (void)fetchCoachGetMemberDetail:(NSNumber *) studentId
                           lastId:(NSNumber *) lastId
                            count:(NSNumber *) count
                          success:(YGRequestSuccess)success
                          failure:(YGRequestFailure)failure;

/**
 我的教学档案 教练端 课时详情 教练发布课时点评

 @param periodId 课时Id
 @param content  评论内容
 @param success  成功
 @param failure  失败
 */
- (void)coachCommentMemberPeriod:(NSNumber *) periodId
                         content:(NSString *) content
                         success:(YGRequestSuccess)success
                         failure:(YGRequestFailure)failure;

/**
 我的教学档案 课程详情 学员给教练评价

 @param classId   课程Id
 @param starLevel 评分等级【double类型】
 @param content   评论内容
 @param success   成功
 @param failure   失败
 */
- (void)teachingMemberCommentClassCoach:(NSNumber *) classId
                              starLevel:(NSNumber *) starLevel
                                content:(NSString *) content
                                success:(YGRequestSuccess)success
                                failure:(YGRequestFailure)failure;

/**
 我的教学档案 教练端 教练更改专项课

 @param classId   课程Id
 @param periodId  课时Id
 @param specialId 专项课Id
 @param success   成功
 @param failure   失败
 */
- (void)editClassPeriodName:(NSNumber *) classId
                   periodId:(NSNumber *) periodId
                  specialId:(NSNumber *) specialId
                    success:(YGRequestSuccess)success
                    failure:(YGRequestFailure)failure;

/**
  我的教学档案 教练端 获取课程的专项课时列表

 @param classId 课程Id
 @param success 成功
 @param failure 失败
 */
- (void)fetchClassSpecialList:(NSNumber *) classId
                      success:(YGRequestSuccess)success
                      failure:(YGRequestFailure)failure;

@end

#pragma mark - 全局搜索
@interface API (Search)
/*!
 *  @brief 全局搜索接口
 *
 *  @param keywords 关键词
 *  @param type     搜索类型 SearchQueryValue() 函数返回
 *  @param pageNo   页码。搜索类型不为0时使用。起始值为1.
 *  @param longitude 经度
 *  @param latitude 纬度
 *  @param success  success description
 *  @param failure  failure description
 */
- (void)generalSearch:(NSString *)keywords
                 type:(NSNumber *)type
                 page:(NSNumber *)pageNo
            longitude:(CGFloat)longitude
             latitude:(CGFloat)latitude
              success:(YGRequestSuccess)success
              failure:(YGRequestFailure)failure;

/*!
 *  @brief 是否可以通过手机号码搜索到我
 *
 *  @param canSearchByMobile NO，不允许。1，允许
 *  @param success           success description
 *  @param failure           failure description
 */
- (void)changeMobileSearchStatus:(BOOL)canSearchByMobile
                         success:(YGRequestSuccess)success
                         failure:(YGRequestFailure)failure;


@end

#pragma mark - 旅游套餐
@interface API (Package)

/*!
 *  @brief 获取旅游套餐首页的数据
 
 *  @param location 地理位置信息
 *  @param success  success description
 *  @param failure  failure description
 */
- (void)getTravelPackageHomePageWithLocation:(Location *)location
                                     success:(YGRequestSuccess)success
                                     failure:(YGRequestFailure)failure;


/*!
 *  @brief 获取旅游套餐列表数据
 *
 *  @param areEnum  PackageAreaEnum_NEARBY = 1,PackageAreaEnum_DOMESTIC = 2, PackageAreaEnum_ABROAD = 3 周边、国内、国际
 *  @param location 地理位置信息
 *  @param success  success description
 *  @param failure  failure description
 */
- (void)getTravelPackageRecommendByAreaEnum:(enum PackageAreaEnum)areaEnum
                                   location:(Location *)location
                                    success:(YGRequestSuccess)success
                                    failure:(YGRequestFailure)failure;

/*!
 *  @brief 获取旅游套餐列表数据
 *
 *  @param areEnum      PackageAreaEnum_NEARBY = 1,PackageAreaEnum_DOMESTIC = 2, PackageAreaEnum_ABROAD = 3 周边、国内、国际
 *  @param location     地理位置信息
 *  @param categoryEnum 特价、热门 PackageCategoryEnum_SPICEL_SORT = 1, PackageCategoryEnum_HOT_SORT = 2
 *  @param pageBean     分页参数
 *  @param success      success description
 *  @param failure      failure description
 */
- (void)getAreaTravelPackageListByAreaEnum:(enum PackageAreaEnum)areaEnum
                                 locatioin:(Location *)location
                              categoryEnum:(enum PackageCategoryEnum)categoryEnum
                                  pageBean:(PageBean *)pageBean
                                   success:(YGRequestSuccess)success
                                   failure:(YGRequestFailure)failure;


/*!
 *  @brief 获取旅游套餐列表数据，根据城市
 *
 *  @param cityBean     城市参数
 *  @param sortEnum     推荐PackageSortEnum_RECOMMEND_SORT = 1,价格PackageSortEnum_PRICT_SORT = 2,行程天数PackageSortEnum_TRAVEL_DAYS_SORT = 3
 *  @param pageBean     分页参数
 *  @param success      success description
 *  @param failure      failure description
 */
- (void)getCityTravelPackageListByCityBean:(CityBean *)cityBean
                                  sortEnum:(enum PackageSortEnum)sortEnum
                                  pageBean:(PageBean *)pageBean
                                   success:(YGRequestSuccess)success
                                   failure:(YGRequestFailure)failure;

/**
 旅行套餐详情

 @param packageId 套餐id
 @param success   success description
 @param failure   failure description
 */
- (void)getTravelPackageDetailWithPackageId:(int) packageId success:(YGRequestSuccess)success failure:(YGRequestFailure)failure;



/*!
 *  @brief 根据关键字搜索旅游套餐
 *
 *  @param sortEnum     推荐PackageSortEnum_RECOMMEND_SORT = 1,价格PackageSortEnum_PRICT_SORT = 2,行程天数PackageSortEnum_TRAVEL_DAYS_SORT = 3
 *  @param pageBean     分页参数
 *  @param success      success description
 *  @param failure      failure description
 */
- (void)searchTravelPackageListWithKeyword:(NSString *)keyword
                                  sortEnum:(enum PackageSortEnum)sortEnum
                                  pageBean:(PageBean *)pageBean
                                   success:(YGRequestSuccess)success
                                   failure:(YGRequestFailure)failure;


/*!
 *  @brief 提交定制套餐数据
 *
 *  @param cityName     目标城市
 *  @param personCount  人数
 *  @param memo         备注
 *  @param success      success description
 *  @param failure      failure description
 */
- (void)submitCustomizedPackageWithCityName:(NSString *)cityName
                                personCount:(int)personCount
                                       memo:(NSString *)memo
                                    success:(YGRequestSuccess)success
                                    failure:(YGRequestFailure)failure;

/**
 提交套餐订单

 @param order   订单信息
 @param success success description
 @param failure failure description
 */
- (void)submitOrderWithTravelPackageOrder:(TravelPackageOrder *)order
                                  success:(YGRequestSuccess)success
                                  failure:(YGRequestFailure)failure;

/**
 获取套餐订单详情

 @param orderID 套餐id
 @param success success description
 @param failure failure description
 */
- (void)getOrderDetailWithOrderID:(int)orderID
                          success:(YGRequestSuccess)success
                          failure:(YGRequestFailure)failure;


/**
 首页获取旅游套餐列表数据

 @param location 位置信息
 @param success success description
 @param failure failure description
 */
- (void)getIndexTravelPackageList:(Location *)location
                          success:(YGRequestSuccess)success
                          failure:(YGRequestFailure)failure;

@end
