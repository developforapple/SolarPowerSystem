//
//  ServerService.h
//  Golf
//
//  Created by 黄希望 on 15/7/15.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "searchClubModel.h"
#import "TagModel.h"
#import "CalendarPriceModel.h"
#import "TimeTableModel.h"
#import "UserFollowModel.h"
#import "OrderSubmitModel.h"
#import "YGMallThemeModel.h"
#import "CommodityModel.h"
#import "PlayedClubModel.h"
#import "GetLastVersionModel.h"

@class YGMallAddressModel;

@interface ServerService : NSObject

// ********************** 《请写好注释》 ************************//


/**
 * 登录成功以后上传设备信息
 * @param sessionId 回话id
 * @param token 推送id
 * @param longitude,latitude 经纬度
 * @param deviceName 设备名称
 * @param osName 操作系统名称
 * @param osVersion 操作系统版本
 *
 */
+ (void)deviceInfoWithSessionId:(NSString *)sessionId deviceToken:(NSString *)token longitude:(double)longitude latitude:(double)latitude deviceName:(NSString *)deviceName osName:(NSString *)osName
                      osVersion:(NSString *)osVersion success:(void (^)(id data))success failure:(void (^)(id error))failure;



/**
 *  商品订单提交接口 commodity_order_submit
 *
 *  @param sessionid            用户会话ID
 *  @param auctionId            抢购ID
 *  @param commodityId          商品ID
 *  @param price                商品价格
 *  @param freight              商品运费
 *  @param linkMan              联系人
 *  @param linkPhone            联系电话
 *  @param address              地址
 *  @param specIds              规格列表
 *  @param quantitys            数量列表
 */
+ (void)commodityOrderSubmit:(NSString*)sessionid
                   auctionId:(int)auctionId
                 commodityId:(int)commodityId
                       price:(int)price
                     freight:(int)freight
                    isMobile:(int)isMobile
                     linkMan:(NSString*)linkMan
                   linkPhone:(NSString*)linkPhone
                     address:(NSString*)address
                    userMemo:(NSString*)userMemo
                     specIds:(NSString*)specIds
                   quantitys:(NSString*)quantitys
                     success:(void (^)(id data))success
                     failure:(void (^)(id error))failure;



/**
 *  购物车列表接口 shopping_cart_maintain
 *
 *  @param sessionid        用户会话ID
 *  @param operation        操作 1：增加商品 2：删除商品
 *  @param commodityIds     商品ID列表，用逗号分隔
 *  @param specIds          规则ID列表, 用逗号分隔，无具体规格用取0值
 *  @param quantitys        商品数量列表，用逗号分隔
 */
+ (void)shoppingCartMaintain:(NSString*)sessionId
                   operation:(NSInteger)operation
                commodityIds:(NSString*)commodityIds
                     specIds:(NSString*)specIds
                   quantitys:(NSString*)quantitys
                     success:(void (^)(NSArray *list))success
                     failure:(void (^)(id error))failure;

/**
 *  购物车列表接口 shopping_cart_list
 *  此接口在具有合并订单功能时，返回全新的数据结构
 *  @param sessionid    用户会话ID
 */
+ (void)shoppingCartList:(NSString*)sessionId
                 success:(void (^)(NSArray *list))success
                 failure:(void (^)(id error))failure;


/**
 *  商品主题接口 commodity_theme
 */
+ (void)commodityThemeWithSuccess:(void (^)(NSArray *list))success
                          failure:(void (^)(id error))failure;


/**
 *  商品主题接口 commodity_theme_commodity
 *
 *  @param themeId  主题id
 */
+ (void)commodityThemeCommodity:(NSInteger)themeId
                         gender:(int)gender
                         pageNo:(NSInteger)pageNo
                       pageSize:(NSInteger)pageSize
                        success:(void (^)(NSArray *list))success
                        failure:(void (^)(id error))failure;

/**
 *  商品类别接口 commodity_category
 */
+ (void)commodityCategoryWithSuccess:(void (^)(NSArray *list))success
                             failure:(void (^)(id error))failure;

/**
 商城首页品牌热榜 commodity_hot_brand
 */
+ (void)commodityHotBrandWithSuccess:(void (^)(NSArray *list))success
                             failure:(void (^)(id error))failure;


/**
 * 关注用户列表。
 *          参数名     必选	类型     说明
 * @param session_id	Y	string	会话ID
 * @param follow_type	Y	Integer	1:我关注的人 2：关注我的人 3:相互关注 4:黑名单 5：新朋友 6:不看TA的动态
 * @param longitude     Y	Double	经度
 * @param latitude      Y	Double	纬度
 * @param page_no       Y	Integer	页号
 * @param page_size     Y	Integer	每页大小
 * @param keyword       N	String	搜索关键字
 */
+ (void)userFollowListWithSessionId:(NSString *)sessionId
                         followType:(int)followType
                          longitude:(double)longitude
                           latitude:(double)latitude
                             pageNo:(int)pageNo
                           pageSize:(int)pageSize
                            keyword:(NSString *)keyword
                            success:(void (^)(NSArray *list))success
                            failure:(void (^)(id error))failure;

/**
 *  获取系统时间与本地时间的时差（秒） server_time
 *
 */
+ (void)getServerTimeWithSuccess:(void (^)(NSTimeInterval timeInterval))success
                         failure:(void (^)(id error))failure;


/**
 *  支付时间提示 order_pay_time
 *
 *  @param  orderType   订单类型commodity,teaching,teetime
 */
+ (void)orderPayTime:(NSString*)sessionId
             orderId:(int)orderId
           orderType:(NSString*)orderType
             success:(void (^)(NSString *payTimeNote,NSString *payTimeAlert))success
             failure:(void (^)(id error))failure;


/**
 *  获得用户头像和昵称 user_head_image_list
 *
 *  @param  sessionId       会话ID
 *  @param  memberIds       memberId集合，字符串逗号隔开
 */
+ (void)userHeadImageList:(NSString *)sessionId
                memberIds:(NSString *)memberIds
                  success:(void (^)(NSArray *list))success
                  failure:(void (^)(id error))failure;

/**
 *  提交抢购订单 order_submit_spree
 *
 *  @param  sessionId       会话ID
 *  @param  spreeId         抢购ID
 *  @param  teetime         开球时间,格式 hh:mm
 *  @param  memberNum       预定人数
 *  @param  serialNo        终端流水号，每天不能重复
 *  @param  memberName      联系人姓名
 *  @param  mobilePhone     联系人电话
 *  @param  userMemo        用户备注
 *  @param  needInvoice     1:需要发票 0：不需要发票
 *  @param  invoiceTitle    发票抬头,need_invoice=1时填写
 *  @param  linkMan         联系人
 *  @param  linkPhone       联系电话
 *  @param  address         地址
 */
+ (void)orderSubmitSpree:(NSString*)sessionId
                 spreeId:(NSInteger)spreeId
                 teetime:(NSString*)teetime
               memberNum:(int)memberNum
                serialNo:(int)serialNo
              memberName:(NSString*)memberName
             mobilePhone:(NSString*)mobilePhone
                userMemo:(NSString*)userMemo
                isMobile:(int)isMobile
             needInvoice:(NSInteger)needInvoice
            invoiceTitle:(NSString*)invoiceTitle
                 linkMan:(NSString*)linkMan
               linkPhone:(NSString*)linkPhone
                 address:(NSString*)address
                 success:(void (^)(OrderSubmitModel *osm))success
                 failure:(void (^)(id error))failure;


/**
 *  球场时间价格 club_price_timetable
 *
 *  @param  clubId      球场ID
 *  @param  date        当前要查的日期
 */
+ (void)clubPriceTimetable:(int)clubId
                      date:(NSString *)date
                   success:(void (^)(NSDictionary *dic))success
                   failure:(void (^)(id error))failure;


/**
 *  球场价格日历 club_price_calendar
 *
 *  @param  days    需要返回多少天数据，最大60
 */
+ (void)clubPriceCalendar:(int)clubId
                     days:(NSInteger)days
                  success:(void (^)(NSDictionary *dic))success
                  failure:(void (^)(id error))failure;


/**
 *  省份数据    dict_province
 */
+ (void)getProvinceWithSuccess:(void (^)(NSArray *list))success
                       failure:(void (^)(id error))failure;


/**
 *  城市数据 dict_city
 *
 *  @param  hotCity     1：热门城市 0：全部城市
 */
+ (void)getCityListWithHotCity:(NSInteger)hotCity
                       success:(void (^)(NSArray *list))success
                       failure:(void (^)(id error))failure;

/**
 *  球场抢购列表接口  club_spree_list
 *
 *  @param  spreeType   抢购类型 1：正在抢购 2: 即将抢购
 */
+ (void)getClubSpreeListWithSpreeType:(NSInteger)spreeType
                              spreeId:(int)spreeId
                               pageNo:(NSInteger)pageNo
                             pageSize:(NSInteger)pageSize
                            longitude:(double)longitude
                             latitude:(double)latitude
                              success:(void (^)(NSArray *list))success
                              failure:(void (^)(id error))failure;


+ (void)footprintList:(NSString*)sessionId
             memberId:(int)memberId
               pageNo:(int)pageNo
             pageSize:(int)pageSize
              success:(void (^)(NSDictionary *list))success
              failure:(void (^)(id error))failure;


/**
 *  获取保证金信息接口
 *
 *  @param  sessionId   会话id
 *  @param  needCount   是否需要统计数据 1:需要 0:不需要
 */
+ (void)getDepositInfo:(NSString *)sessionId
             needCount:(int)needCount
               success:(void (^)(DepositInfoModel *depositInfo))success
               failure:(void (^)(id error))failure;



/**
 *  发布动态评论
 *
 *  @param  topicId     动态id
 *  @param  toMemberId  对谁评论
 *  @param  text        评论内容
 */
+ (void)topicCommentAdd:(NSString *)sessionId
                topicId:(int)topicId
             toMemberId:(int)toMemberId
                   text:(NSString *)text
                success:(void (^)(id data))success
                failure:(void (^)(id error))failure;


/**
 * 动态赞
 *
 *  @param topicId 动态id
 */
+ (void)topicPraiseAdd:(NSString*)sessionId
               topicId:(int)topicId
               success:(void (^)(id data))success
               failure:(void (^)(id error))failure;

/**
 *  用户关注
 *
 *  @param  toMemberId              //要关注或取消的用户ID
 *  @param  nameRemark              //名字备注
 *  @param  operation               //1: 关注 2:取消关注 3:改备注 4:加黑名单
 * //new DataPicker("1","已关注"),
 * //new DataPicker("2","已取消"),
 * //new DataPicker("3","黑名单"),
 * //new DataPicker("4","相互关注"),
 */
+ (void)userFollowAddWithSessionId:(NSString *)sessionId
                        toMemberId:(int)toMemberId
                        nameRemark:(NSString *)nameRemark
                         operation:(int)operation
                           success:(void (^)(id data))success
                           failure:(void (^)(id error))failure;



/**
 *  批量或分块资源上传接口
 *
 *  @param  resId               //资源上传id
 *  @param  partId              //资源序号，从1开始
 *  @param  partSize            //分块大小，非分块方式传0
 *  @param  resData             //文件路径或图片对象
 */
+ (void)uploadResourceWithResId:(NSInteger)resId
                         partId:(NSInteger)partId
                       partSize:(NSInteger)partSize
                        resData:(id)resData
                        success:(void (^)(id obj))success
                        failure:(void (^)(id error))failure;


/**
 *  发布足迹接口
 *
 *  @param  sessionId           //当前用户会话ID
 *  @param  clubId              //球场ID
 *  @param  teeDate             //打球日期
 *  @param  gross               //总杆
 *  @param  publicMode          //0:私密 1:公开
 *  @param  publishTopic        //0:不发布话题 1:发布到话题
 *  @param  footprintId         //小于0:新增订单球场  等于0: 手动新增 大于0: 修改批量添加的足迹
 *  @param  topicContent        //话题内容
 *  @param  images              //多张图片参数重复上传
 *  @param  scores              //多张图片参数重复上传
 *  @param  longitude           //经度
 *  @param  latitude            //纬度
 */
+ (void)footprintAdd:(NSString*)sessionId
              clubId:(int)clubId
             teeDate:(NSString*)teeDate
               gross:(int)gross
          publicMode:(int)publicMode
        publishTopic:(int)publishTopic
         footprintId:(int)footprintId
        topicContent:(NSString*)topicContent
              images:(NSArray*)images
              scores:(NSArray*)scores
           longitude:(double)longitude
            latitude:(double)latitude
             success:(void (^)(id obj))success
             failure:(void (^)(id error))failure;


/**
 *  发布话题接口
 *
 *  @param  pageNo          页号
 *  @param  pageSize        页大小
 *  @param  keyword         关键字
 */
+ (void)tagList:(NSInteger)pageNo
       pageSize:(NSInteger)pageSize
          tagId:(int)tagId
        tagName:(NSString *)tagName
        keyword:(NSString *)keyword
        success:(void (^)(NSArray *list))success
        failure:(void (^)(id error))failure;


/**
 动态列表接口
 */
+ (void)topicList:(NSString *)sessionId
            tagId:(int)tagId
          tagName:(NSString *)tagName
         memberId:(int)memberId
           clubId:(int)clubId
          topicId:(int)topicId
        topicType:(int)topicType
           pageNo:(int)pageNo
         pageSize:(int)pageSize
        longitude:(double)longitude
         latitude:(double)latitude
          success:(void (^)(NSArray *list))success
          failure:(void (^)(id error))failure;

/**
 *  发布话题接口
 *
 *  @param  sessionId       会话id
 *  @param  clubId          球场ID
 *  @param  topicContent    发布内容
 *  @param  images          发布的图片
 *  @param  videoPath       发布的视频
 *  @param  longitude       经度
 *  @param  latitude        纬度
 *  @param  location        地点
 */
+ (void)topicAdd:(NSString*)sessionId
          clubId:(int)clubId
    topicContent:(NSString*)topicContent
          images:(NSArray*)images
       videoPath:(NSString*)videoPath
       longitude:(double)longitude
        latitude:(double)latitude
        location:(NSString*)location
         success:(void (^)(id obj))success
         failure:(void (^)(id error))failure;

/**
  *  删除动态
  *  @param topicId 动态id
 */

+ (void)topicDelete:(NSString *)sessionId topicId:(int)topicId success:(void (^)(id data))success
            failure:(void (^)(id error))failure;

// 管理员权限的删除
+ (void)admin_topicDelete:(NSString *)sessionId topicId:(int)topicId black:(BOOL)black reason:(NSString *)reason success:(void (^)(id data))success
                  failure:(void (^)(id error))failure;
// 管理员权限的加精
+ (void)admin_digestTrend:(int)topicId
                 isDigest:(BOOL)isDigest
                  success:(void (^)(id data))success
                  failure:(void (^)(id error))failure;

/**
 *  删除评论
 *  @param  commentId   评论id
 *  @param  topicId     动态id
 */
+ (void)topicCommentDelete:(NSString*)sessionId commentId:(int)commentId topicId:(int)topicId
                   success:(void (^)(id obj))success
                   failure:(void (^)(id error))failure;


/**
 *  球场列表接口
 *
 *  @param longitude    经度
 *  @param latitude     纬度
 *  @param pageSize     每页条数
 *  @param pageNo       页数
 *  @param keyword      关键字
 */
+ (void)clubListWithLon:(double)longitude
                    lat:(double)latitude
                 pageNo:(NSInteger)pageNo
               pageSize:(NSInteger)pageSize
                keyword:(NSString*)keyword
                success:(void (^)(NSArray *list))success
                failure:(void (^)(id error))failure;

/**
 *  入门文章详情列表接口
 *
 *  @param articleId    文章id
 *  @param imeiNum      设备号
 *  @param success      成功返回
 */
//+ (void)getArticleDetail:(int)articleId
//                 imeiNum:(NSString*)imeiNum
//                 success:(void (^)(ArticleInfoModel *model))success
//                 failure:(void (^)(id error))failure;

/**
 *  入门文章赞／踩通用接口
 *
 *  @param articleId    文章id
 *  @param imeiNum      设备号
 *  @param praiseType   1.赞  2.踩
 *  @param success      成功返回
 */
+ (void)articlePraise:(int)articleId
              imeiNum:(NSString*)imeiNum
           praiseType:(int)praiseType
              success:(void (^)(id data))success
              failure:(void (^)(id error))failure;

/**
 *  入门文章赞／踩通用接口
 *
 *  @param sessionId    用户身份id
 *  @param articleId    文章ID
 *  @param content      评论内容
 *  @param success      成功返回
 */
+ (void)articleCommentAdd:(NSString*)aSessionId
                articleId:(int)articleId
                  content:(NSString*)content
                  success:(void (^)(id data))success
                  failure:(void (^)(id error))failure;


/**
 *          参数名         必选	类型     说明
 * @param session_id        Y	String	用户会话ID
 * @param data_type         Y	String	"数据类型，目前支持: topic (动态) footprint (足迹) member (用户相册) 注：若调用topic_add,footprint_add接口已生成批量上传res_id，则无需调用此接口。"
 * @param data_id           Y	Integer	"数据ID：与data_type对应关系 1.topic: topicId 2.footprint:footPrintId 3:member:memberId"
 * @param image_data_count	N	Integer	图片总数量
 * @param video_data_count	N	Integer	视频块数量（每块大小不能小于100k）
 */
+ (void)initResourceWithSessionId:(NSString *)sessionId
                         dataType:(NSString *)dataType
                           dataId:(int)dataId
                   imageDataCount:(int)imageDataCount
                   videoDataCount:(int)videoDataCount
                          success:(void (^)(BaseService *BS))success
                          failure:(void (^)(id error))failure;



/**
 *          参数名         必选	类型     说明
 * @param  session_id       Y	Integer	会话ID
 * @param  image_delete     N	String	要删除的照片名称
 * @param  image_data       N	Integer	要上传的照片数据(BASE64编码)
 * @param  curr_position	N	Integer	当前图片位置(从0开始)
 * @param  new_position     N	Integer	移动到新位置(从0开始)
 */
+ (void)userEditAlbumWithSessionId:(NSString *)sessionId
                         imageData:(NSString *)imageData
                       imageDelete:(NSString *)imageDelete
                   currentPosition:(int)currentPosition
                       newPosition:(int)newPosition
                           success:(void (^)(NSArray *list))success
                           failure:(void (^)(id error))failure;

/**
 *          参数名             必选	类型     说明
 * @param  session_id           Y	string	会话ID
 * @param  member_name          N	String	用户姓名
 * @param  nick_name            N	String	昵称
 * @param  gender               N	Integer	性别 1:男 0：女
 * @param  head_image_data      N	String	头像照片数据(BASE64编码)，新增时必填
 * @param  photo_image_data     N	String	封面照片数据(BASE64编码)，新增时必填
 * @param  birthday             N	String	生日格式yyyy-MM-dd，可以为空串
 * @param  signature            N	String	个性签名
 * @param  location             N	String	所在地
 * @param  handicap             N	Intger	差点
 * @param  personal_tag         N	String	个人标签
 * @param  academy_id           N	Integer	学院ID，教练修改资料
 * @param  seniority            N	Integer	教龄, 教练修改资料
 * @param  introduction         N	String	个人简介, 教练修改资料
 * @param  career_achievement	N	String	所获成就, 教练修改资料
 * @param  teaching_achievement	N	String	教学成就, 教练修改资料
 */
+ (void)userEditInfo:(NSString*)sessionId
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
             success:(void (^)(id data))success
             failure:(void (^)(id error))failure;

/**
 *  删除足迹 footprint_delete
 *
 *  @param sessionid            用户会话ID
 *  @param footprintId          足迹ID
 *  @param clubId               球会ID
 */
+ (void)footprintDeleteWithSessionId:(NSString *)sessionId
                         footprintId:(int)footprintId
                              clubId:(int)clubId
                             success:(void (^)(id data))success
                             failure:(void (^)(id error))failure;

/**
 *  活动信息列表 activity_list
 *
 *  @param longitude            经度
 *  @param latitude             纬度
 *  @param putArea              投放区域 1：首页（缺省） 2：教学 3：入门 4:teeTime首页 5:启动页 6.商品乐活动
 *  @param resolution           分辩率 1：高 2:中（缺省） 3:低
 *  @param needGroup          足迹ID
 */
+ (void)getActivityListByLongitude:(double)longitude
                          latitude:(double)latitude
                           putArea:(int)putArea
                         esolution:(int)resolution
                         needGroup:(BOOL)needGroup
                           success:(void (^)(id data))success
                           failure:(void (^)(id error))failure;

/*
 * 获取系统参数
 * @param phone 电话号码
 */
+ (void)systemParamInfoByGolfSessionPhone:(NSString *)phone success:(void (^)(SystemParamInfo *data))success
                                  failure:(void (^)(id error))failure;

/*
 target_type 举报目标类型 1：用户 2：话题 3：球场留言 4：商品留言
 举报目标ID， 与target_type对应
 1： 用户ID
 2： 话题ID
 3：球场留言ID
 4：商品留言ID
 */
+ (void)reportInfoAddWithImei:(NSString*)imeiNum
            sessionId:(NSString*)sessionId
         reportReason:(NSString*)reportReason
           targetType:(int)targetType
             targetId:(int)targetId
              success:(void (^)(BOOL flag))success
              failure:(void (^)(id error))failure;
/* 
 * 获取用户详情
 */
+ (void)userDetailByMemberId:(int)memberId mobilePhone:(NSString *)mobilePhone
                   sessionID:(NSString *)sessionID
                     success:(void (^)(UserDetailModel *userDetail))success
                     failure:(void (^)(id error))failure;

//足迹列表
+ (void)footPrintListWithSessionId:(NSString *)sessionId memberId:(int)memberId pageNo:(int)pageNo pageSize:(int)pageSize courseid:(int)courseid courseName:(NSString *)courseName success:(void (^)(NSMutableArray *arr))success failure:(void (^)(id error))failure;

+ (void)userPlayedCourseListByMemberId:(int)memberId success:(void (^)(UserPlayedClubListModel *obj))success failure:(void (^)(id error))failure;

/**
 *  获取版本号  get_ios_last_version
 *
 *  @param success
 *  @param failure
 */
+ (void)getLastVersionSuccess:(void (^)(GetLastVersionModel *obj))success failure:(void (^)(id error))failure;

/**
 public_validate_code
 */
+ (void)publicValidateCode:(NSString*)phoneNum  // 电话号码
groupFlag:(NSString*)groupFlag // 分组标志 eweeks 表示e周汇用户
noMsg:(int)noMsg  // 不发送短信，缺省为0(发送)，若客户端可以自动获取到手机号码，则填写1
codeType:(int)codeType success:(void (^)(id 
obj))success failure:(void (^)(id error))failure;  // 验证码类型 0: 短信 1:语音


/**
 user_bound

 @param groupFlag    分组标志,详见group_flag说明
 @param groupData    分组数据，取决group_flag的值
 如当group_flag为cmb时，需要传招行登录加密数据
 group_flag为wechat时，group_data=微信openId+|+微信unionId+|+MD5(微信openId+微信unionId+APIKEY)
 @param sessionId    会话ID,要绑定当前已登录用户时上传
 此时不用上传手机号,验证码
 @param phoneNum     用户手机号
 @param validateCode 短信验证码, 要绑定已注册且未登录的用户,必须上传此字段
 @param isMobile
 @param nickName     昵称
 @param gender       性别 1:男 0:女 2:未知
 @param headImageUrl 头像
 @param callBack     成功回调
 @param failure      失败回调
 */
+(void)userBound:(NSString*)groupFlag
       groupData:(NSString*)groupData
       sessionId:(NSString*)sessionId
        phoneNum:(NSString*)phoneNum
    validateCode:(NSString*)validateCode
        isMobile:(int)isMobile
        nickName:(NSString*)nickName
          gender:(int)gender
    headImageUrl:(NSString*)headImageUrl
        callBack:(void(^)(id obj))callBack
         failure:(void (^)(id error))failure;


#pragma mark - 7.2新增

/**
 请求我的账户的一些个人信息

 @param callBack
 @param failure
 */
+ (void)fetchDepositInfoCallBack:(void(^)(id obj))callBack
                         failure:(void (^)(id error))failure;


/**
 请求我的收货地址

 @param callBack
 @param failure
 */
+ (void)fetchMallAddressList:(void(^)(NSArray<YGMallAddressModel *> *obj))callBack
                     failure:(void (^)(id error))failure;

/**
 维护收货地址

 @param type 操作类型 1 新增 2 修改 3 设为默认 4 删除
 @param addressInfo 地址信息  keys: address_id link_man link_phone post_code province_name city_name district_name address
 @param callBack
 @param failure
 */
+ (void)maintainMallAddress:(NSInteger)type
                       info:(NSDictionary *)addressInfo
                   callBack:(void(^)(id obj))callBack
                    failure:(void (^)(id error))failure;

/**
 请求球场订单列表

 @param status 订单状态。0为全部
 @param payType 支付状态
 @param pageNo 页码 1开始
 @param pageSize 分页数据量
 @param callBack
 @param failure
 */
+ (void)fetchCourseOrderList:(NSInteger)status
                     payType:(NSInteger)payType
                        page:(NSInteger)pageNo
                    pageSize:(NSInteger)pageSize
                    callBack:(void(^)(id obj))callBack
                     failure:(void (^)(id error))failure;

+ (void)fetchTeachOrderList:(NSInteger)status
                    coachId:(NSInteger)coachId
                   memberId:(NSInteger)memberId
                   keywords:(NSString *)keywords
                       page:(NSInteger)pageNo
                   pageSize:(NSInteger)pageSize
                   callBack:(void(^)(id obj))callBack
                    failure:(void (^)(id error))failure;

/**
 获取优惠券列表

 @param status   0：全部。1：可用
 @param pageNo   分页
 @param size     分页数据量
 @param callBack 成功回调
 @param failure  失败回调
 */
+ (void)fetchCouponList:(int)status
                 pageNo:(int)pageNo
               pageSize:(int)size
               callBack:(void(^)(id obj))callBack
                failure:(void (^)(id error))failure;

/**
 获取筛选后的优惠券列表

 @param status 0全部 1可用
 @param pageNo 分页
 @param size 分页数据量
 @param scene 订单场景 YGCouponScene。1商城
 @param price 订单总价。包括价格+运费。单位：分
 @param ids 筛选id列表
 @param callBack
 @param failure
 */
+ (void)fetchCouponFilteredList:(int)status
                         pageNo:(int)pageNo
                       pageSize:(int)size
                          scene:(int)scene
                          price:(NSInteger)price
                            ids:(NSSet<NSNumber *> *)ids
                       callBack:(void(^)(id obj))callBack
                        failure:(void (^)(id error))failure;

/**
 提交一个商品订单。 支持合并支付。

 @param data     订单数据
 @param callBack 成功回调
 @param failure  失败回调
 */
+ (void)submitCommodityOrder:(NSDictionary *)data
                    callBack:(void(^)(id obj))callBack
                     failure:(void (^)(id error))failure;

// 获取订单详情
+ (void)fetchOrderDetail:(NSInteger)orderId
                callBack:(void(^)(id obj))callBack
                 failure:(void (^)(id error))failure;

// 获取订单列表。
+ (void)fetchMallOrderList:(NSInteger)status
                    pageNo:(NSInteger)page
                  pageSize:(NSInteger)size
                  callBack:(void(^)(id obj))callBack
                   failure:(void (^)(id error))failure;

// 操作订单
+ (void)operateOrder:(NSInteger)orderId
           operation:(int)operation
                desc:(NSString *)desc
            callBack:(void(^)(id obj))callBack
             failure:(void (^)(id error))failure;
// 删除商城订单
+ (void)deleteMallOrder:(NSInteger)orderId
               callBack:(void(^)(id obj))callBack
                failure:(void (^)(id error))failure;
// 修改商城订单留言
+ (void)editMallOrderMemo:(NSInteger)orderId
                     memo:(NSString *)memo
                 callBack:(void(^)(id obj))callBack
                  failure:(void (^)(id error))failure;

/**
 评价商城订单商品

 @param orderId 订单id
 @param commodityId 商品id
 @param level 评分等级 1 好 2 中 3 差
 @param content 评论内容
 @param callBack
 @param failure
 */
+ (void)addMallOrderReview:(NSInteger)orderId
                 commodity:(NSInteger)commodityId
                     level:(NSInteger)level
                   content:(NSString *)content
                  callBack:(void(^)(id obj))callBack
                   failure:(void (^)(id error))failure;

/**
 获取订单中的商品列表。商品中标记了是否评论

 @param orderId 订单id
 @param callBack
 @param failure
 */
+ (void)fetchMallOrderCommodityList:(NSInteger)orderId
                           callBack:(void(^)(id obj))callBack
                            failure:(void (^)(id error))failure;

/**
 球场订单和旅行套餐删除

 @param sessionId sessionID
 @param orderId   订单ID
 */
+ (void)orderDelete:(NSString*)sessionId orderId:(int)orderId callBack:(void (^)(id obj))callBack failure:(void (^)(id error))failure;

/**
 请求商城限时抢购列表

 @param from 请求来源：0列表 1App首页 2商城首页
 @param pageNo 分页
 @param size 分页数据数
 @param callBack
 @param failure
 */
+ (void)fetchMallFlashSaleList:(NSInteger)from
                        pageNo:(NSInteger)pageNo
                       pagSize:(NSInteger)size
                      callBack:(void(^)(id obj))callBack
                       failure:(void (^)(id error))failure;

/**
 请求商城限时抢购时间戳

 @param callBack
 @param failure
 */
+ (void)fetchMallFlashSaleTimestamp:(void(^)(id obj))callBack
                            failure:(void (^)(id error))failure;

/**
 请求商城商品详情

 @param cid 商品id
 @param callBack
 @param failure
 */
+ (void)fetchMallCommodityDetail:(NSInteger)cid
                        callBack:(void(^)(id obj))callBack
                         failure:(void (^)(id error))failure;

/**
 为商品添加提醒

 @param cid 商品id
 @param noticeType 提醒类型：0到货提醒 1抢购提醒
 @param isAdd YES：添加 NO：移除
 @param token 推送token
 @param callBack
 @param failure
 */
+ (void)updateMallCommodityArrivalNotice:(NSInteger)cid
                                    type:(NSInteger)noticeType
                                addOpera:(BOOL)isAdd
                                   token:(NSString *)token
                                callBack:(void(^)(id obj))callBack
                                 failure:(void (^)(id error))failure;

#pragma mark CourseOrder

/**
 删除一个球场订单

 @param orderId 订单id
 @param callBack
 @param failure
 */
+ (void)deleteCourseOrder:(NSInteger)orderId
                 callBack:(void(^)(id obj))callBack
                  failure:(void (^)(id error))failure;

/**
 撤销一个球场订单的退款申请

 @param orderId 订单id
 @param callBack
 @param failure
 */
+ (void)cancelCourseOrderRefund:(NSInteger)orderId
                       callBack:(void(^)(id obj))callBack
                        failure:(void (^)(id error))failure;

/**
 订单管理-我的最近订单列表

 @param state 状态 0：无状态
 @param lastOrderId 分页时使用，最后一个订单id
 @param size 分页数量
 @param callBack
 @param failure
 */
+ (void)fetchRecentOrders:(NSInteger)state
              lastOrderId:(NSInteger)lastOrderId
                 pageSize:(NSInteger)size
                 callBack:(void(^)(id obj))callBack
                  failure:(void (^)(id error))failure;


@end
