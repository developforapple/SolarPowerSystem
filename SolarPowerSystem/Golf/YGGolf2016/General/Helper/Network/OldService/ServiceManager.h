//
//  ServiceManager.h
//  Golf
//
//  Created by user on 13-8-12.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConditionModel.h"
#import "UserSessionModel.h"
#import "LoginParamsModel.h"
#import "TTModel.h"
#import "CoachModel.h"
#import "CoachDetailModel.h"
#import "AcademyModel.h"
#import "CommodityInfoModel.h"
#import "CommodityParamModel.h"
#import "CommodityCommentModel.h"
#import "OrderSubmitParamsModel.h"
#import "OrderPayModel.h"
#import "SystemParamInfo.h"
#import "AwardModel.h"
#import "TotalCommentModel.h"
#import "ConsumeModel.h"
#import "RedPaperModel.h"
#import "ArticleCommentModel.h"
#import "UserDetailModel.h"
#import "UserFollowModel.h"
#import "UserNewsModel.h"
#import "DepositInfoModel.h"
#import "HttpErroCodeModel.h"
#import "TopicModel.h"
#import "TrendsPraiseModel.h"
#import "FootprintModel.h"
#import "CommodityCategory.h"
#import "PublicCourseModel.h"
#import "PublicCourseDetail.h"
#import "TeachProductDetail.h"
#import "TeachingOrderModel.h"
#import "TeachingOrderDetailModel.h"
#import "TeachingSubmitInfo.h"
#import "TeachingTranModel.h"
#import "ReservationModel.h"
#import "CoachNoticeModel.h"
#import "StudentModel.h"
#import "CoachDataRpt.h"
#import "OrderModel.h"
#import "YGMallBrandModel.h"

@protocol ServiceManagerDelegate;

@interface ServiceManager : NSObject

@property (nonatomic,weak) id<ServiceManagerDelegate> delegate;

@property (nonatomic,strong) Class orignalClass;

@property(nonatomic,assign) int listCount;
@property(nonatomic,assign) int debugLevel;
@property(nonatomic) BOOL success;
@property(nonatomic) BOOL needLoading;
@property(nonatomic,copy) NSString *teeTime;
@property(nonatomic) BOOL preventError;
@property(nonatomic,copy) NSString *interfaceName;

- (void)post:(NSString *)mode params:(id)params;
- (void)get:(NSString *)mode params:(id)params completion:(void(^)(id obj))completion;
- (void)get:(NSString *)mode params:(id)params withMD5:(BOOL)amd5 completion:(void(^)(id obj))completion;
- (void)asynchronousGet:(NSString *)mode params:(id)params;
- (void)asynchronousGet:(NSString *)mode params:(id)params withMD5:(BOOL)amd5;

//BOOL 类型返回值
- (BOOL)getBoolValue:(id)value;



+ (ServiceManager*)serviceManagerWithDelegate:(id<ServiceManagerDelegate>)aDelegate;
+ (ServiceManager*)serviceManagerInstance;

- (void)getSpecialOfferList:(int)cityId             // 获取特价时段
                 provinceId:(int)provinceId
                  longitude:(float)longitude
                   latitude:(float)latitude
                    weekDay:(NSInteger)weekDay;

- (void)getActivityListByLongitude:(double)longitude latitude:(double)latitude putArea:(int)putArea  //投放区域 1：首页（缺省) 2：教学 3：入门
             resolution:(int)resolution needGroup:(BOOL)needGroup preventError:(BOOL)preventError; //活动列表
//- (void)getActivityListByLongitude:(double)longitude latitude:(double)latitude putArea:(int)putArea resolution:(int)resolution; //活动列表，增加投放区域，和图片分辨率参数

- (void)searchClubWithCondition:(ConditionModel *)condition  // 球会搜索结果
                       withPage:(int)page
                   withPageSize:(int)pageSize
                    withVersion:(NSString*)version;

- (void) searchTeeTime:(int)clubId        // teetime接口
           withAgentId:(int)agentId
              withDate:(NSString *)date
              withTime:(NSString *)time
           withVersion:(NSString*)version;

- (void)searchUser:(NSString *)session_id keyword:(NSString *)keyword;//查找用户，lyf

- (void)userPossibleFriendBySessionId:(NSString *)sessionId longitude:(double)longitude
                             latitude:(double)latitude;


- (void)getClubInfo:(int)clubId needPackage:(int)flag; // 球会信息

- (void)getClubSpecialOffList:(int)clubId weekDay:(NSInteger)weekDay date:(NSString*)date; // 球会特价时段

- (void)getCityPackageListWithCityId:(int)cityId provinceId:(int)provinceId longitude:(float)longitude latitude:(float)latitude pageSize:(int)size pageNo:(int)pageNo;   // 当前城市套餐

- (void)getClubPackageListWithClubId:(int)clubId;    // 球会套餐

- (void)getClubFairwayList:(int)clubId;              // 球道集

- (void)getPackageDetailListWithPackageId:(int)packageId clubId:(int)clubId agentId:(int)agentId;

- (void)getWeatherInfoWithCityId:(int)cityId;        // 天气预报

- (void)getOrderList:(NSString *)sessionId           // 订单列表
          withStatus:(OrderStatusEnum)status
         withPayType:(PayTypeEnum)payType
            withPage:(int)page
        withPageSize:(int)pageSize;

- (void)getDepositInfo:(NSString *)sessionId needCount:(int)needCount;       // 获取保证金
- (void)getDepositInfoData:(NSString *)sessionId callBack:(void(^)(DepositInfoModel *model))callBack;   // 同步方法
- (void)depositRechargeUnionpay:(NSString *)sessionId withMoney:(int)money isMobile:(int)isMobile payChannel:(NSString *)aPayChannel callBack:(void(^)(NSDictionary *data))callBack;

- (void) getOrderDetail:(NSString *)sessionId withOrderId:(int)orderId flag:(NSString*)flag;
//- (void) getOrderDetail:(NSString *)sessionId withOrderId:(int)orderId;  // 订单详情

- (void)getWaitPay:(NSString *)phone;                  // 待付款

- (void)getCouponListWithSessionId:(NSString*)sessionId status:(int)status;  //  现金券列表接口
- (void)getCouponListWithSessionId:(NSString*)sessionId
                            status:(int)status
                            pageNo:(int)pageNo
                          pageSize:(int)pageSize; //现金券列表分页


- (void)getAllClubs;

- (void)searchNewTeeTime:(int)clubId agentId:(int)agentId date:(NSString*)date time:(NSString*)time;

- (void)searchClubFreeTeetime:(int)clubId date:(NSString *)date;

- (void)getCommentListByPage:(int)page pageSize:(int)pageSize coachId:(int)coachId productId:(int)productId;

- (void)getTeachingMemberByReservationStatus:(int)status pageNo:(int)pageNo pageSize:(int)pageSize sessionId:(NSString *)sessionId coachId:(int)coachId memberId:(int)memberId keyword:(NSString*)keyword;

- (void)getCoachListByPageNo:(int)pageNo pageSize:(int)pageSize withLongitude:(double)longitude latitude:(double)latitude cityId:(int)cityId orderBy:(int)orderBy date:(NSString *)date time:(NSString *)time keyword:(NSString *)keyword academyId:(int)academyId productId:(int)productId; //加载教练分页数据

- (void)teachingMemberClassCancelByReservationId:(int)reservationId coachId:(int)coachId sessionId:(NSString *)sessionId periodId:(int) periodId;
- (void)teachingMemberClassCancelByReservationId:(int)reservationId coachId:(int)coachId sessionId:(NSString *)sessionId;
- (void)teachingOrderCancelByOrderId:(int)orderId sessionId:(NSString *)sessionId;

- (void)getTeachingMemberClassDetailByClassId:(int)classId orderId:(int)orderId sessionId:(NSString *)sessionId;

- (void)getTeachInfoDetailByReservationId:(int)reservationId sessionId:(NSString *)sessionId coachId:(int)coachId;

- (void)teachingUpdateTimetableByCoachId:(int)coachId date:(NSString *)date time:(NSString *)time operation:(int)operation sessionId:(NSString *)sessionId;
- (void)teachingCoachTimetableByCoachId:(int)coachId sessionId:(NSString *)sessionId;
- (void)teachingUpdateTimeSetByCoachId:(int)coachId timeSet:(NSString *)timeSet sessionId:(NSString *)sessionId;
- (void)getCoachDetailByCoachId:(int)coachId longitude:(double)longitude latitude:(double)latitude sessionId:(NSString *)sessionId;//根据教练id获得教练详情

- (void)searchCoachWithLongitude:(double)longitude
                    withLatitude:(double)latitude
                   withCoachName:(NSString *)coachName
                          pageNo:(int)pageNo
                        pageSize:(int)pageSize;

- (void)getCoachDetailWithCoachId:(int)coachId imeiNum:(NSString *)imeiNum;


- (void)getTeachingMemberClassList:(NSString *)sessionId coachId:(int)coachId;

//新增的学院列表接口
- (void)getTeachingAcademyList:(double)longitude latitude:(double)latitude cityId:(int)cityId keyword:(NSString *)keyword pageNo:(int)pageNo pageSize:(int)pageSize;

- (void)getTeachingAcademyDetail:(int)academyId;

- (void)getAcademyList:(double)longitude :(double)latitude keyWord:(NSString*)kw pageNo:(int)p_n pageSize:(int)p_s;

- (void)getAcademyDetail:(int)academyId;

- (void)drivingRangePosition:(int)drivingrangeId areaName:(NSString*)areaName;

- (void)drivingRangePictureList:(int)drivingrangeId;

- (void)getAcademyNameList;

- (void)coachEditAlbumWithSessionId:(NSString*)sessionId coachId:(int)coachId imageDelete:(NSString*)imageDelete imageData:(NSString*)imageData;

- (void)getClubPictureList:(int)clubId;

- (void)getCitysData:(int)flag;

- (void)addTeachingComment:(NSString *)txt commentLevel:(int)commentLevel reservationId:(int)reservationId sessionId:(NSString *)sessionId;

- (void)getCommodityCategoryData;

- (void)getCommodityInfoList:(NSString *)aCategoryId brandId:(NSString *)brandId commodityIds:(NSString *)ids longitude:(double)alongitude latitude:(double)aLatitude;
- (void)getCommodityInfoList:(int)aCategoryId brandId:(int)brandId subCategoryId:(int)subCategoryId orderBy:(int)aOrderBy longitude:(double)alongitude latitude:(double)aLatitude keyWord:(NSString*)aKeyWord pageNo:(int)aNo;

- (void)getCommodityAuctionWithLongitude:(double)alongitude latitude:(double)aLatitude pageNo:(int)aNo pageSize:(int)aSize;

- (void)getCommodityDetail:(int)aCommodityId auctionId:(int)aAuctionId;

- (void)getCommodityAuctionStatus:(int)auctionId;

- (void)commodityOrderSubmit:(CommodityParamModel *)model NS_UNAVAILABLE;

- (void)getDeliveryAddressList:(NSString*)sessionId;

- (void)getCommodityCommentList:(int)commodityId level:(int)aLevel pageNo:(int)pageNo;

- (void)CommodityCommentAdd:(NSString*)aSessionId orderId:(int)aOrderId level:(int)alevel content:(NSString*)aContent;

//- (void)modifyDeliveryAddress:(NSString*)aSessionId operation:(int)operation addressInfo:(DeliveryAddressModel*)model;

- (void)orderPay:(OrderSubmitParamsModel *)model flag:(NSString*)flag;

- (void)commodityOrderList:(NSString *)aSessionId orderState:(int)aState pageNo:(int)pageNo;

- (void)addCommodityComment:(NSString*)aSessionId orderId:(int)aOrderId level:(int)aLevel content:(NSString*)aContent;

- (void)commodityOrderMaintain:(NSString*)aSessionId orderId:(int)aOrderId operation:(int)aOperation description:(NSString*)aDescription;

- (void)getDeviceInfo:(NSString*)imeiNum
           deviceName:(NSString*)deviceName
          deviceToken:(NSString*)deviceToken
               osName:(NSString*)osName
            osVersion:(NSString*)osVersion
            sessionId:(NSString*)sessionId
            longitude:(double)longitude
             latitude:(double)latitude;

- (void)getPackageDetail:(int)aPackageId;

- (void)systemParamInfo:(NSString *)phone sessionID:(NSString *)sessionID;


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
 teachingAchievement:(NSString*)teachingAchievement
;

- (void)activityDetail:(int)activityId;

- (void)userWithdraw:(NSString *)sessionId amount:(int)amount;

- (void)commodityArrivalNotice:(int)commodityId specId:(int)specId deviceToken:(NSString*)deviceToken;

- (void)consumeAward:(NSString*)sessionId orderId:(int)orderId orderType:(NSString*)orderType;

- (void)getClubCommentList:(int)clubId pageNo:(int)pageNo;

- (void)accountConsumeList:(NSString*)aSessionId consumeType:(int)aType pageNo:(int)pageNo;

- (void)getRedPackeList:(NSString *)aSessionId type:(int)type pageNo:(int)pageNo pageSize:(int)pageSize;

- (void)redPaperDetail:(NSString *)aSessionId Id:(int)redPaperId;

- (void)articleCategory;

- (void)articleInfo:(int)categoryId pageNo:(int)pageNo pageSize:(int)pageSize keyWord:(NSString*)keyWord;

- (void)articleDetail:(int)articleId imeiNum:(NSString*)imeiNum;

- (void)articleCommentList:(int)articleId pageNo:(int)pageNo pageSize:(int)pageSize;

- (void)articleCommentAdd:(NSString*)aSessionId articleId:(int)articleId content:(NSString*)content;

- (void)articlePraise:(int)articleId imeiNum:(NSString*)imeiNum;

- (void)articleRank:(int)categoryId pageNo:(int)pageNo orderBy:(int)orderBy;

- (void)userDetail:(int)memberId mobilePhone:(NSString*)mobilePhone;

- (void)userFollowAdd:(NSString*)sessionId toMemberId:(int)toMemberId nameRemark:(NSString *)nameRemark operation:(int)operation;

- (void)userFollowList:(NSString*)sessionId
            followType:(int)followType
             longitude:(double)longitude
              latitude:(double)latitude
                pageNo:(int)pageNo
              pageSize:(int)pageSize;


- (void)userMessageAdd:(NSString*)sessionId toMemberId:(int)toMemberId msgContent:(NSString*)msgContent;
- (void)userMessageList:(NSString*)sessionId ;
- (void)userMessageChat:(NSString*)sessionId toMemberId:(int)toMemberId pageNo:(int)pageNo;


- (void)userPlayedCourseEdit:(NSString*)sessionId addId:(NSString*)addIds deleteId:(NSString*)deleteIds;
- (void)userPlayedCourseList:(int)memberId;
- (void)userPlayedCourseAll;
- (void)userEditAlbum:(NSString*)sessionId imageData:(NSString*)imageData imageDelete:(NSString*)imageDelete;


- (void)userTagAll;

- (void)userFindContracts:(NSString*)sessionId phoneNum:(NSString*)phoneNum;



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
         latitude:(double)latitude;

//- (void)tagListByKeyword:(NSString *)keyword pageNo:(int)pageNo pageSize:(int)pageSize;

- (void)topicCommentList:(int)topicId pageNo:(int)pageNo pageSize:(int)pageSize;

- (void)topicPraiseList:(int)topicId pageNo:(int)pageNo pageSize:(int)pageSize;
- (void)teachingPublicClassJoinList:(int)publicClassId pageNo:(int)pageNo pageSize:(int)pageSize;
- (void)topicShareList:(int)topicId pageNo:(int)pageNo pageSize:(int)pageSize;

- (void)topicMessageList:(NSString*)sessionId msgType:(int)msgType pageNo:(int)pageNo pageSize:(int)pageSize;

- (void)topicAdd:(NSString*)sessionId clubId:(int)clubId topicContent:(NSString*)topicContent images:(NSArray*)images videoPath:(NSString*)videoPath longitude:(double)longitude latitude:(double)latitude location:(NSString*)location;

- (void)footprintList:(NSString*)sessionId memberId:(int)memberId pageNo:(int)pageNo pageSize:(int)pageSize courseid:(int)courseid courseName:(NSString *)courseName;//lq 加 球场id 不用可传0


- (void)topicPraiseAdd:(NSString*)sessionId topicId:(int)topicId;
- (void)topicDelete:(NSString*)sessionId topicId:(int)topicId;

- (void)topicCommentAdd:(NSString*)sessionId topicId:(int)topicId toMemberId:(int)toMemberId cmtCnt:(NSString*)cmtCnt;
- (void)topicCommentDelete:(NSString*)sessionId commentId:(int)commentId topicId:(int)topicId;
//话题分享接口
- (void)topic_share_add:(NSString*)session_id topic_id:(int)topic_id share_type:(int)share_type;

- (void)userMessageDelete:(NSString *)sessionId msgId:(int)msgId toMemberId:(int)toMemberId;


//添加足迹接口
- (void)footprintAdd:(NSString*)sessionId    //当前用户会话ID
              clubId:(int)clubId             //球场ID
             teeDate:(NSString*)teeDate      //打球日期
               gross:(int)gross              //总杆
          publicMode:(int)publicMode         //0:私密 1:公开
        publishTopic:(int)publishTopic       //0:不发布话题 1:发布到话题
         footprintId:(int)footprintId        //小于0:新增订单球场  等于0: 手动新增 大于0: 修改批量添加的足迹
        topicContent:(NSString*)topicContent //话题内容
              images:(NSArray*)images    //多张图片参数重复上传
              scores:(NSArray*)scores    //多张图片参数重复上传
           longitude:(double)longitude
            latitude:(double)latitude;



//删除足迹接口
- (void)footprintDelete:(NSString*)sessionId
            footprintId:(int)footprintId
                 clubId:(int)clubId;


//批量修改足迹接口
- (void)footprintBatchEdit:(NSString*)sessionId
                     addId:(NSString*)addId
                  removeId:(NSString*)removeId;


// 查询批量已选球场

- (void)footprintBatchList:(NSString*)sessionId;



// 话题消息删除接口

- (void)topicMessageDelete:(NSString*)sessionId msgId:(int)msgId msgType:(int)msgType;


// 球场订单删除

- (void)orderDelete:(NSString*)sessionId orderId:(int)orderId;


// 商品订单删除

- (void)commodityOrderDelete:(NSString*)sessionId orderId:(int)orderId;


// 获取手机验证码

- (void)publicValidateCode:(NSString*)phoneNum  // 电话号码
                 groupFlag:(NSString*)groupFlag // 分组标志 eweeks 表示e周汇用户
                     noMsg:(int)noMsg  // 不发送短信，缺省为0(发送)，若客户端可以自动获取到手机号码，则填写1
                  codeType:(int)codeType;  // 验证码类型 0: 短信 1:语音


// 获取备注列表

- (void)userFollowRemark:(NSString*)sessionId;


// 用户设定推送开关user_edit_switch
- (void)userEditSwitch:(NSString*)sessionId
          noDisturbing:(int)noDisturbing
          memberFollow:(int)memberFollow
         memberMessage:(int)memberMessage
           topicPraise:(int)topicPraise
          topicComment:(int)topicComment
         yaoBallNotify:(int)yaoBallNotify;

// 推送开关设置接口
- (void)userSwitchInfo:(NSString*)sessionId;

- (void)commodityBrandList;

- (void)commodityBrandCategory:(int)brandId;


// 公开课
- (void)getPublicListWithLo:(double)longitude
                         la:(double)latitude
                    keyWord:(NSString*)keyWord
                     cityId:(int)cityId
                     pageNo:(int)pageNo
                   pageSize:(int)pageSize;

// 公开课详情
- (void)getPublicDetailWithCourseId:(int)publicClassId
                          productId:(int)productId
                          longitude:(double)longitude
                           latitude:(double)latitude;



// 教练产品时间表 classNo－－课程序号，团体课时上传
- (void)teachingCoachProductTime:(int)coachId productId:(int)productId classNo:(int)classNo;

// 教练产品明细
- (void)teachingProductDetail:(int)productId;
- (void)teachingProductInfoByIds:(NSString *)ids classType:(NSString *)classType;

// 提交订单teaching_order_submit
- (void)teachingSubmitOrder:(NSString*)sessionId
              publicClassId:(int)publicClassId
                  productId:(int)productId
                    coachId:(int)coachId
                       date:(NSString*)date
                       time:(NSString*)time
                   phoneNum:(NSString*)phoneNum;


// 教学订单列表 teaching_order_list
- (void)teachingOrderList:(NSString *)sessionId
                  coachId:(int)coachId
                 memberId:(int)memberId
               orderState:(int)orderState
                   pageNo:(int)pageNo
                 pageSize:(int)pageSize
                  keyWord:(NSString*)keyWord;

// 教学订单详情teaching_order_detail
- (void)teachingOrderDetail:(NSString*)sessionId
                    orderId:(int)orderId
                    coachId:(int)coachId;

// 教学订单删除teaching_order_delete
- (void)teachingOrderDelete:(NSString*)sessionId
                    orderId:(int)orderId;

- (void)teachingCommentReplyContent:(NSString *)content commentId:(int)commentId sessionId:(NSString *)sessionId; //回复教学评论
// 用户课程预约teaching_member_reservation_add
- (void)teachingMemberReservation:(NSString*)sessionId
                          classId:(int)classId
                             date:(NSString*)date
                             time:(NSString*)time
                        longitude:(double)longitude
                         latitude:(double)latitude
                        periodId:(int) periodId;


// 用户课程延期teaching_member_class_postpone
- (void)teachingMemberClassPostpone:(NSString*)sessionId classId:(int)classId dayNum:(NSInteger)dayNum;


// 教练消息列表teaching_coach_message_list
- (void)teachingCoachMessageList:(int)coachId pageNo:(int)pageNo pageSize:(int)pageSize;

// 教练学员列表 teaching_coach_member_list
- (void)teachingCoachMemberList:(NSString*)sessionId coachId:(int)coachId memberId:(int)memberId pageNo:(int)pageNo pageSize:(int)pageSize keyWord:(NSString*)keyWord;


// 教练数据报表teaching_coach_data_report
- (void)teachingCoachDataReport:(NSString*)sessionId coachId:(int)coachId dataType:(int)dataType;


/**
 * 意见反馈
 *
 * @param session_id
 * @param contents
 * @return
 * @throws Exception
 */
- (void)feedBack:(NSString *)phoneNum withContents:(NSString *)contents callBack:(void(^)(BOOL boolen))callBack;

- (void)userRecommendTel:(NSString *)phone phoneList:(NSString *)phoneList callBack:(void(^)(NSDictionary *dic))callBack;

- (void)joinActivityWithSessionId:(NSString *)sessionId activityCode:(NSString*)code callBack:(void(^)(NSString *callBackString))callBack;

- (void)validateVip:(NSString *)sessionId withClubId:(NSString *)clubId withCardNo:(NSString*)cardNo withMemberName:(NSString *)memberName callBack:(void(^)(BOOL boolen))callBack;


// 获取微信用户信息
- (void)wechatUserInfo:(NSString*)groupFlag code:(NSString*)code callBack:(void(^)(id obj))callBack;


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
         callBack:(void(^)(id obj))callBack;


// 课程预约完成teaching_member_reservation_complete
- (void)teachingMemberReservationComplete:(NSString*)sessionId coachId:(int)coachId reservationId:(int)reservationId opteraton:(int)opteraton periodId:(int) periodId callBack:(void(^)(BOOL boolen))callBack;
- (void)teachingMemberReservationComplete:(NSString*)sessionId coachId:(int)coachId reservationId:(int)reservationId opteraton:(int)opteraton callBack:(void(^)(BOOL boolen))callBack;

@end

#import "BaseService.h"

@protocol ServiceManagerDelegate <NSObject>

@optional
- (void)serviceResult:(ServiceManager*)serviceManager Data:(id)data flag:(NSString*)flag ;

// bwang加，把网络请求 BS 传出来
- (void)serviceResult:(ServiceManager *)serviceManager BS:(BaseService *)BS Data:(id)data flag:(NSString *)flag;

@end
