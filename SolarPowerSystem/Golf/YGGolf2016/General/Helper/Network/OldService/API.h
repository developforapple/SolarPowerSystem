//
//  RemoteService.h
//  Golf
//
//  Created by 廖瀚卿 on 16/2/23.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "service.h"

@interface API : NSObject

@property (nonatomic, strong) NSOperationQueue *statQueue;  //统计使用的队列
@property (nonatomic, strong) NSOperationQueue *asyncQueue; //异步队列
@property (nonatomic, strong) NSOperationQueue *mainQueue;  //主线程队列

+ (instancetype)shareInstance;

- (HeadBean *)getHeadBean;
#pragma mark - 首页改版
/**
 高球头条
 */
- (void)headLineTopListSuccess:(void (^)(HeadLineList *ab))success failure:(void (^)(Error *error))failure;

- (void)headLineListSuccess:(void (^)(HeadLineList *ab))success failure:(void (^)(Error *error))failure;

/**
 教学课程
 */
- (void)teachActivityListSuccess:(void (^)(TeachActivityList *ab))success failure:(void (^)(Error *error))failure;
/**
 精选商品
 */
- (void)themeCommodityListSuccess:(void (^)(ThemeCommodityList *ab))success failure:(void (^)(Error *error))failure;
/**
 附近热门球场
 */
- (void)hotCourseListWithLocation:(Location *)location success:(void (^)(HotCourseList *ab))success failure:(void (^)(Error *error))failure;

#pragma mark - 动态改版
/**
 *  动态推荐用户滚动
 *
 *  @param success 请求成功
 *  @param failure 请求失败
 */
- (void)topicRecomendSuccess:(void (^)(TopicRecommendList *ab))success failure:(void (^)(Error *error))failure;
/**
 *  我要上推荐
 *
 *  @param success 请求成功
 *  @param failure 请求失败
 */
- (void)topicRecommendStatueSuccess:(void (^)(AckBean *ab))success failure:(void (^)(Error *error))failure;

- (void)topicRecommendReqWithText:(NSString *)text  success:(void (^)(AckBean *ab))success failure:(void (^)(Error *error))failure;
/**
 获取我要上推荐H5页地址
 */
- (void)getTopicRecommendPageSuccess:(void (^)(TopicRecommendPage *ab))success failure:(void (^)(Error *error))failure;
/**
 获取我要上推荐图片
 */
- (void)getTopicRecommendImageSuccess:(void (^)(TopicRecommendImage *ab))success failure:(void (^)(Error *error))failure;
#pragma mark - 发送消息
//发送im消息
- (void)sendMsg:(SendBean *)sendBean success:(void (^)(AckBean *ab))success failure:(void (^)(Error *error))failure;

//通过服务器发送通知到对方
- (void)imSessionNotifyToMemberId:(NSString *)memberId success:(void (^)(AckBean *ab))success failure:(void (^)(Error *error))failure;

//通过微信登录前需要从服务器获取临时密码来登录im服务器
- (void)timSignAuthWithSuccess:(void (^)(AckBean *ab))success failure:(void (^)(Error *error))failure;

//聊天会话列表
- (void)roserSessionsSuccess:(void (^)(RoserSessionList *list))success failure:(void (^)(Error *error))failure;

//删除会话
- (void)deleteRoserSessionByMemberId:(NSString *)memberId success:(void (^)(AckBean *ab))success failure:(void (^)(Error *error))failure;

//清空聊天记录的时候需要调用这个接口告诉业务服务器删除回话最后一条记录，防止加载历史记录的时候再次看到它
- (void)clearMsgFromSessionByMemberId:(NSString *)memberId success:(void (^)(AckBean *ab))success failure:(void (^)(Error *error))failure;

#pragma mark 约球
//我收到的约球
-(void)yaoBallRecvList:(PageBean *)pages yaoId:(int)yaoID unRead:(int)unRead success:(void (^)(id data))success failure:(void (^)(Error *error))failure;

//我发起的约球
-(void)yaoBallPublist:(PageBean *)page yaoID:(int)yaoId unRead:(int)unRead success:(void (^)(id data))success failure:(void (^)(Error *error))failure;

//关闭约球   yaoid==0 清除退出  >0 关闭约球
-(void)yaoCloseById:(int)yaoId success:(void (^)(AckBean *data))success failure:(void (^)(Error *error))failure;

//删除约球
-(void)yaoDeleteById:(int)yaoId dType:(int)dType success:(void (^)(AckBean *data))success failure:(void (^)(Error *error))failure;

//修改订场类型  0全部 1球场 2练习场
- (void)yaoType:(int)type success:(void (^)(AckBean *data))success failure:(void (^)(Error *error))failure;

//打开约球上报，修改地理位置上报
- (void)yaoWantWithLocation:(Location *)location success:(void (^)(AckBean *data))success failure:(void (^)(Error *error))failure;

//附近约球列表
- (void)yaoBallListByPage:(PageBean *)pageBean location:location success:(void (^)(YaoBallList *data))success failure:(void (^)(Error *error))failure;

//发布约球 // lyf 加
- (void)yaoBall:(Location *)location yaoBallContent:(YaoBallContent *)ybc success:(void (^)(id data))success failure:(void (^)(Error *error))failure;

//当前约球信息 // lyf 加
- (void)yaoCurrentSuccess:(void (^)(id data))success failure:(void (^)(Error *error))failure;

//加入约球 // lyf 加
- (void)yaoJoinWithId:(int)yaoId success:(void (^)(id data))success failure:(void (^)(Error *error))failure;

//约球信息 // lyf 加
- (void)yaoInfoWithId:(int)yaoId success:(void (^)(id data))success failure:(void (^)(Error *error))failure;

//判断是否已经存在位置信息 // lyf 加
- (void)yaoExistSuccess:(void (^)(id data))success failure:(void (^)(Error *error))failure;

//开/关约球推送
-(void)yaoNotifyWithOnoff:(int)onOff success:(void (^)(AckBean *data))success failure:(void (^)(Error *error))failure;

//约球推送未读消息获取
-(void)unReadPushMsgWithType:(int)type success:(void (^)(AckBean *data))success failure:(void (^)(Error *error))failure;

#pragma mark 足迹

//足迹是否开放  1公开 0 不公开
- (void)publicModeWithFootprintId:(int)footPrintId andPublicMode:(int)publicMode success:(void (^)(id data))success failure:(void (^)(NSException *error))failure;

//发布动态
- (void)pubDynamic:(MediaBean *)mb location:(Location *)loc success:(void (^)(id data))success failure:(void (^)(NSException *error))failure;

//用户卡信息
- (void)finishCardByCardId:(int)cardId success:(void (^)(id data))success failure:(void (^)(NSException *error))failure;

//已关注的用户 打球月份排名
- (void)monthRank:(NSString *)month success:(void (^)(MonthRank *data))success failure:(void (^)(Error *error))failure;

//已关注的用户 打球历史排名
- (void)historyRankSuccess:(void (^)(HistoryRank *data))success failure:(void (^)(Error *error))failure;

//用户卡信息
- (void)cardInfo:(int)cardId toMemberId:(int)memberId success:(void (^)(CardInfo *data))success failure:(void (^)(Error *error))failure;

//我的足迹
- (void)myFootSuccess:(void (^)(id data))success failure:(void (^)(Error *error))failure;

//好友列表
- (void)parnerListSuccess:(void (^)(Parners *data))success failure:(void (^)(Error *error))failure;

//获取球场信息
- (void)courseInfo:(int)courseId success:(void (^)(CourseBean *data))success failure:(void (^)(Error *error))failure;

//用户记分
- (void)score:(ModifyBean *)mb success:(void (^)(id data))success failure:(void (^)(NSException *error))failure;

//一次提交整个计分卡
- (void)allscoreWithCardInfo:(CardInfo *)cardInfo success:(void (^)(AckBean *data))success failure:(void (^)(Error *error))failure;

//设置Par
- (void)setParByModifyBean:(ModifyBean *)mb success:(void (^)(AckBean *data))success failure:(void (^)(Error *error))failure;

//添加卡信息,返回球场信息，标准杆等，“出发
- (void)addCard:(Card *)card success:(void (^)(id data))success failure:(void (^)(Error *error))failure;

//附近球场 //lyf 加
- (void)nearByCourse:(Location *)location success:(void (^)(id data))success failure:(void (^)(Error *error))failure;

//选择球场 //lyf 加
- (void)selectCourse:(Location *)location page:(PageBean *)pageBean success:(void (^)(id data))success failure:(void (^)(Error *error))failure;

//自定义球场列表 // lyf 加
- (void)privateCoursesSuccess:(void (^)(id data))success failure:(void (^)(Error *error))failure;


// 删除自定义球场
- (void)delPrivateCourseWithCourseID:(int)courseID success:(void (^)(AckBean *data))success failure:(void (^)(Error *error))failure;

//标杆或净杆  scoreType：0标杆 1净杆
- (void)scoreTypeByCardId:(int)cardId andScoreTypeId:(int)scoreType success:(void (^)(id data))success failure:(void (^)(NSException *error))failure;

//设备是否已存在  lq加
- (void)deviceExistSuccess:(void (^)(id data))success failure:(void (^)(NSException *error))failure;

//上传设备标识  lq加
- (void)deviceUpSuccess:(void (^)(id data))success failure:(void (^)(NSException *error))failure;

//足迹详情  lq加
- (void)footprintDetailWithFootprintID:(int)footPrintId success:(void (^)(id data))success failure:(void (^)(Error *error))failure;

//广告弹窗  lq加
- (void)cgitAdWithAdsite:(NSString *)adsite success:(void (^)(id data))success failure:(void (^)(Error *error))failure;

//保存卡片
- (void)saveCardWithCardId:(int)cardId success:(void (^)(id data))success failure:(void (^)(NSException *error))failure;

//编辑足迹详情
- (void)modifyFootDetail:(MediaBean *)mb location:(Location *)location success:(void (^)(id data))success failure:(void (^)(NSException *error))failure;

//添加足迹
- (void)footprintAdd:(MediaBean *)mb location:(Location *)location success:(void (^)(id data))success failure:(void (^)(NSException *error))failure;

//发布后随机显示的照片 lyf 加
- (void)yaoImageSuccess:(void (^)(id data))success failure:(void (^)(NSException *error))failure;

//足迹列表，暂时不用
- (void)footprintLisWithFootReq:(FootReq *)footReq Success:(void (^)(MyFoots *data))success failure:(void (^)(NSException *error))failure;

#pragma mark ---接口统计
-(void)statisticalWithBuriedpoint:(int)buriedpoint Success:(void (^)(id data))success failure:(void (^)(NSException *error))failure;
#pragma mark --首页banner和精选动态埋点
/**
 *  首页banner和精选动态埋点
 *
 *  @param buriedpoint 首页传18 精选传19
 *  @param objectID
 *  @param success
 *  @param failure
 */
- (void)statisticalNewWithBuriedpoint:(int)buriedpoint objectID:(NSString *)objectID Success:(void (^)(id data))success failure:(void (^)(NSException *error))failure;


- (void)uploadLogFileBean:(LogFileBean *)lfb success:(void (^)(id data))success failure:(void (^)(Error *error))failure;
@end

@interface API (binDingPhone)//手机号绑定
- (void)bindeviceWithBindBean:(BindBean *)bb Success:(void (^)(AckBean *data))success failure:(void (^)(Error *err))failure;
@end

@interface API (unbind)//微信解绑
- (void)unbindWithBindType:(int) bindType success:(void (^)(AckBean *data))success failure:(void (^)(Error *err))failure;
@end

@interface API (guideAlert)//APP好评弹窗上传服务器，已经弹过了
- (void)guideAlertSuccess:(void (^)(AckBean *data))success failure:(void (^)(Error *err))failure;
@end
