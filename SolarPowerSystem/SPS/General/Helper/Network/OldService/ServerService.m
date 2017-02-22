//
//  ServerService.m
//  Golf
//
//  Created by 黄希望 on 15/7/15.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "ServerService.h"
#import "NSMutableDictionary+Util.h"
#import "BaseService.h"
#import "GTMBase64.h"
#import "TrendsModel.h"
#import "ClubSpreeModel.h"
#import "CalendarClass.h"
#import "FCUUID.h"
#import "YGMallCartGroup.h"
#import "YGMallOrderModel.h"
#import "YGMallAddressModel.h"
#import "YGMallBrandModel.h"
#import "SearchProvinceModel.h"
#import "ActivityModel.h"
#import "CouponModel.h"

@implementation ServerService


+ (void)deviceInfoWithSessionId:(NSString *)sessionId deviceToken:(NSString *)token longitude:(double)longitude latitude:(double)latitude deviceName:(NSString *)deviceName osName:(NSString *)osName
                      osVersion:(NSString *)osVersion success:(void (^)(id data))success failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObjectPassNil:sessionId forKey:@"session_id"];
    [params setObjectPassNil:token forKey:@"device_token"];
    [params setObjectPassNil:@(longitude) forKey:@"longitude"];
    [params setObjectPassNil:@(latitude) forKey:@"latitude"];
    [params setObjectPassNil:deviceName forKey:@"device_name"];
    [params setObjectPassNil:osName forKey:@"os_name"];
    [params setObjectPassNil:osVersion forKey:@"os_version"];
    [params setObject:[FCUUID uuidForDevice] forKey:@"imei_num"];
    
    [BaseService BSGet:@"device_info" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        success (nil);
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}


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
                     failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObjectPassNil:sessionid forKey:@"session_id"];
    [params setObject:@(auctionId) forKey:@"auction_id"];
    [params setObject:@(commodityId) forKey:@"commodity_id"];
    [params setObject:@(price*100) forKey:@"price"];
    [params setObject:@(freight*100) forKey:@"freight"];
    [params setObject:@(isMobile) forKey:@"is_mobile"];
    [params setObjectPassNil:linkMan forKey:@"link_man"];
    [params setObjectPassNil:linkPhone forKey:@"link_phone"];
    [params setObjectPassNil:address forKey:@"address"];
    [params setObjectPassNil:userMemo forKey:@"user_memo"];
    [params setObjectPassNil:specIds forKey:@"spec_id"];
    [params setObjectPassNil:quantitys forKey:@"quantity"];
    [BaseService BSGet:@"commodity_order_submit" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success)
            success (BS.data);
        else
            success (nil);
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}


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
                     failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObjectPassNil:sessionId forKey:@"session_id"];
    [params setObject:@(operation) forKey:@"operation"];
    [params setObjectPassNil:commodityIds forKey:@"commodity_ids"];
    [params setObjectPassNil:specIds forKey:@"spec_ids"];
    [params setObjectPassNil:quantitys forKey:@"quantitys"];
    [BaseService BSGet:@"shopping_cart_maintain" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success&&BS.data) {
            NSArray *arr = (NSArray*)BS.data;
            success (arr);
        }else{
            success (nil);
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}


/**
 *  购物车列表接口 shopping_cart_list
 *
 *  @param sessionid    用户会话ID
 */
+ (void)shoppingCartList:(NSString*)sessionId
                 success:(void (^)(NSArray *list))success
                 failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObjectPassNil:sessionId forKey:@"session_id"];
    [BaseService BSGet:@"shopping_cart_list" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success&&BS.data) {
            NSArray *arr = (NSArray*)BS.data;
            NSMutableArray *datas = [NSMutableArray array];
        
            for (id obj in arr) {
                YGMallCartGroup *group = [[YGMallCartGroup alloc] initWithDic:obj];
                group?[datas addObject:group]:0;
            }
            
            success (datas);
        }else{
            success (nil);
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}




/**
 *  商品主题接口 commodity_theme
 */
+ (void)commodityThemeWithSuccess:(void (^)(NSArray *list))success
                          failure:(void (^)(id error))failure{
    [BaseService BSGet:@"commodity_theme" parameters:nil encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success&&BS.data) {
            NSArray *list = [NSArray yy_modelArrayWithClass:[YGMallThemeModel class] json:BS.data];
            success (list);
        }else{
            success (nil);
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}


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
                        failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObjectPassNil:@(themeId) forKey:@"theme_id"];
    [params setObject:@(gender) forKey:@"gender"];
    [params setObject:@(pageNo) forKey:@"page_no"];
    [params setObject:@(pageSize) forKey:@"page_size"];
    
    [BaseService BSGet:@"commodity_theme_commodity" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success&&BS.data) {
            NSArray *arr = (NSArray*)BS.data;
            NSMutableArray *datas = [NSMutableArray array];
            for (id obj in arr) {
                CommodityModel *cm = [[CommodityModel alloc] initWithDic:obj];
                [datas addObject:cm];
            }
            success (datas);
        }else{
            success (nil);
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}


/**
 *  商品类别接口 commodity_category
 */
+ (void)commodityCategoryWithSuccess:(void (^)(NSArray *list))success
                             failure:(void (^)(id error))failure{
    [BaseService BSGet:@"commodity_category" parameters:nil encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success&&BS.data) {
            NSArray *arr = (NSArray*)BS.data;
            NSMutableArray *datas = [NSMutableArray array];
            for (id obj in arr) {
                CommodityCategory *cm = [[CommodityCategory alloc] initWithDic:obj];
                [datas addObject:cm];
            }
            success (datas);
        }else{
            success (nil);
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}

+ (void)commodityHotBrandWithSuccess:(void (^)(NSArray *list))success
                             failure:(void (^)(id error))failure{
    [BaseService BSGet:@"commodity_hot_brand" parameters:nil encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success&&BS.data) {
            NSArray *list = [NSArray yy_modelArrayWithClass:[YGMallBrandModel class] json:BS.data];
            success (list);
        }else{
            success (nil);
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}



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
                            failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObjectPassNil:sessionId forKey:@"session_id"];
    [params setObjectPassNil:@(followType) forKey:@"follow_type"];
    [params setObject:@(longitude) forKey:@"longitude"];
    [params setObject:@(latitude) forKey:@"latitude"];
    [params setObject:@(pageNo) forKey:@"page_no"];
    [params setObject:@(pageSize) forKey:@"page_size"];
    [params setObjectPassNil:keyword forKey:@"keyword"];
    
    [BaseService BSGet:@"user_follow_list" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            NSDictionary *dic = (NSDictionary*)BS.data;
            NSArray *list = dic[@"follow_list"];
            NSMutableArray *resultList = [[NSMutableArray alloc] init];
            for (NSDictionary *nd in list) {
                UserFollowModel *m = [[UserFollowModel alloc] initWithDic:nd];
                [resultList addObject:m];
            }
            success (resultList);
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}

/**
 *  获取系统时间与本地时间的时差（秒） server_time
 *
 */
+ (void)getServerTimeWithSuccess:(void (^)(NSTimeInterval timeInterval))success
                         failure:(void (^)(id error))failure{
    [BaseService BSGet:@"server_time" parameters:nil encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            NSDictionary *dic = (NSDictionary*)BS.data;
            if (dic[@"server_time"]) {
                NSString *serverTime = dic[@"server_time"];
                NSDate *dt = [Utilities getDateFromString:serverTime WithFormatter:@"yyyy-MM-dd HH:mm:ss"];
                NSDate *today = [CalendarClass dateForStandardTodayAll];
                NSTimeInterval timeInterval = [dt timeIntervalSinceDate:today];
                success (timeInterval);
            }else{
                success (0);
            }
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}


/**
 *  获得用户头像和昵称 user_head_image_list
 *
 *  @param  sessionId       会话ID
 *  @param  memberIds       memberId集合，字符串逗号隔开
 */
+ (void)userHeadImageList:(NSString *)sessionId
                memberIds:(NSString *)memberIds
                  success:(void (^)(NSArray *list))success
                  failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObjectPassNil:sessionId forKey:@"session_id"];
    [params setObjectPassNil:memberIds forKey:@"member_ids"];
    [BaseService BSGet:@"user_head_image_list" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            NSArray *arr = (NSArray *)BS.data;
            NSMutableArray *datas = [[NSMutableArray alloc] initWithCapacity:arr.count];
            for (NSDictionary *a in arr) {
                UserFollowModel *m = [[UserFollowModel alloc] initWithDic:a];
                [datas addObject:m];
            }
            success (datas) ;
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}


/**
 *  支付时间提示 order_pay_time
 *
 *  @param  orderType   订单类型commodity,teaching,teetime
 */
+ (void)orderPayTime:(NSString*)sessionId
             orderId:(int)orderId
           orderType:(NSString*)orderType
             success:(void (^)(NSString *payTimeNote,NSString *payTimeAlert))success
             failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObjectPassNil:sessionId forKey:@"session_id"];
    [params setObject:@(orderId) forKey:@"order_id"];
    [params setObjectPassNil:orderType forKey:@"order_type"];
    [BaseService BSGet:@"order_pay_time" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            NSDictionary *dic = (NSDictionary*)BS.data;
            success(dic[@"pay_time_note"],dic[@"pay_time"]);
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}


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
                 failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObjectPassNil:sessionId forKey:@"session_id"];
    [params setObjectPassNil:@(spreeId) forKey:@"spree_id"];
    [params setObjectPassNil:teetime forKey:@"teetime"];
    [params setObject:@(memberNum) forKey:@"member_num"];
    [params setObjectPassNil:@(serialNo) forKey:@"serial_no"];
    [params setObjectPassNil:memberName forKey:@"member_name"];
    [params setObjectPassNil:mobilePhone forKey:@"mobile_phone"];
    [params setObjectPassNil:userMemo forKey:@"user_memo"];
    [params setObject:@(isMobile) forKey:@"is_mobile"];
    if (needInvoice>0) {
        [params setObject:@(needInvoice) forKey:@"need_invoice"];
        [params setObjectPassNil:invoiceTitle forKey:@"invoice_title"];
        [params setObjectPassNil:linkMan forKey:@"link_man"];
        [params setObjectPassNil:linkPhone forKey:@"link_phone"];
        [params setObjectPassNil:address forKey:@"address"];
    }
    
    [BaseService BSGet:@"order_submit_spree" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            NSDictionary *dic = (NSDictionary*)BS.data;
            OrderSubmitModel *osm = [[OrderSubmitModel alloc] initWithDic:dic];
            success (osm) ;
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}


/**
 *  球场时间价格 club_price_timetable
 *
 *  @param  clubId      球场ID
 *  @param  date        当前要查的日期
 */
+ (void)clubPriceTimetable:(int)clubId
                      date:(NSString *)date
                   success:(void (^)(NSDictionary *dic))success
                   failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(clubId) forKey:@"club_id"];
    [params setObject:date forKey:@"date"];
    [BaseService BSGet:@"club_price_timetable" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            NSMutableDictionary *md = [NSMutableDictionary dictionary];
            NSArray *list = (NSArray*)BS.data;
            if (list.count > 0) {
                for (id obj in list) {
                    TimeTableModel *ttm = [[TimeTableModel alloc] initWithDic:obj];
                    [md setObject:ttm forKey:ttm.time];
                }
            }
            success (md);
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}

/**
 *  球场价格日历 club_price_calendar
 *
 *  @param  days    需要返回多少天数据，最大60
 */
+ (void)clubPriceCalendar:(int)clubId
                     days:(NSInteger)days
                  success:(void (^)(NSDictionary *dic))success
                  failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(clubId) forKey:@"club_id"];
    [params setObject:@(days) forKey:@"days"];
    [BaseService BSGet:@"club_price_calendar" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            NSMutableDictionary *md = [NSMutableDictionary dictionary];
            NSArray *list = (NSArray*)BS.data;
            if (list.count > 0) {
                for (id obj in list) {
                    CalendarPriceModel *cpm = [[CalendarPriceModel alloc] initWithDic:obj];
                    [md setObject:cpm forKey:cpm.date];
                }
            }
            success (md);
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}


/**
 *  省份数据    dict_province
 */
+ (void)getProvinceWithSuccess:(void (^)(NSArray *list))success
                       failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *golfVersion = @"GolfProvincesVersion";
    NSString *currentVersion = [[NSUserDefaults standardUserDefaults] objectForKey:golfVersion];
    if (currentVersion) {
        [params setObject:currentVersion forKey:@"version"];
    }
    else{
        [params setObject:@"" forKey:@"version"];
    }
    [BaseService BSGet:@"dict_province" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            NSMutableArray *arr = [NSMutableArray array];
            if (BS.data) {
                NSDictionary *resultDic = (NSDictionary*)BS.data;
                
                NSString *path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
                NSString *filename=[path stringByAppendingPathComponent:@"GolfProvinceInfo.plist"];
                NSString *version = [resultDic objectForKey:@"version"];
                
                if (version) {
                    [[NSUserDefaults standardUserDefaults] setObject:version forKey:golfVersion];
                }
                
                //更新数据库
                NSArray *resultArray = [resultDic objectForKey:@"province_list"];
                if (resultArray != nil && resultArray.count > 0) {
                    [resultArray writeToFile:filename atomically:YES];
                    for (id obj in resultArray) {
                        SearchProvinceModel *model = [[SearchProvinceModel alloc] initWithDic:obj];
                        [arr addObject:model];
                    }
                }
            }
            success (arr);
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}


/**
 *  城市数据 dict_city
 *
 *  @param  hotCity     1：热门城市 0：全部城市
 */
+ (void)getCityListWithHotCity:(NSInteger)hotCity
                       success:(void (^)(NSArray *list))success
                       failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *golfVersion = @"GolfCitiesVersion";
    NSString *currentVersion = [[NSUserDefaults standardUserDefaults] objectForKey:golfVersion];
    if (currentVersion) {
        [params setObject:currentVersion forKey:@"version"];
    }
    else{
        [params setObject:@"" forKey:@"version"];
    }
    [params setObject:@(hotCity) forKey:@"hot_city"];
    [BaseService BSGet:@"dict_city" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            NSMutableArray *arr = [NSMutableArray array];
            if (BS.data) {
                NSDictionary *resultDic = (NSDictionary*)BS.data;
                if (hotCity == 0) {
                    NSString *path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
                    NSString *filename=[path stringByAppendingPathComponent:@"GolfCityInfo.plist"];
                    NSString *version = [resultDic objectForKey:@"version"];
                    if (version) {
                        [[NSUserDefaults standardUserDefaults] setObject:version forKey:golfVersion];
                    }
                    //更新数据库
                    NSArray *resultArray = [resultDic objectForKey:@"city_list"];
                    if (resultArray != nil && resultArray.count > 0) {
                        [resultArray writeToFile:filename atomically:YES];
                        for (id obj in resultArray) {
                            SearchCityModel *model = [[SearchCityModel alloc] initWithDic:obj];
                            [arr addObject:model];
                        }
                    }
                }else{
                    NSArray *resultArray = [resultDic objectForKey:@"city_list"];
                    if (resultArray != nil && resultArray.count > 0) {
                        for (id obj in resultArray) {
                            SearchCityModel *model = [[SearchCityModel alloc] initWithDic:obj];
                            [arr addObject:model];
                        }
                    }
                }
            }
            success (arr);
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}


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
                              failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:0];
    [params setObject:@(spreeType) forKey:@"spree_type"];
    if (spreeId>0) {
        [params setObject:@(spreeId) forKey:@"spree_id"];
    }
    [params setObject:@(pageNo) forKey:@"page_no"];
    [params setObject:@(pageSize) forKey:@"page_size"];
    [params setObject:@(longitude) forKey:@"longitude"];
    [params setObject:@(latitude) forKey:@"latitude"];
    [BaseService BSGet:@"club_spree_list" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            NSArray *arr = (NSArray*)BS.data;
            NSMutableArray *mutArr = [NSMutableArray array];
            if (arr.count > 0) {
                for (id obj in arr) {
                    ClubSpreeModel *scm = [[ClubSpreeModel alloc] initWithDic:obj];
                    [mutArr addObject:scm];
                }
            }
            success (mutArr);
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}


+ (void)footprintList:(NSString*)sessionId
             memberId:(int)memberId
               pageNo:(int)pageNo
             pageSize:(int)pageSize
              success:(void (^)(NSDictionary *data))success
              failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    if (memberId) {
        [params setObject:@(memberId) forKey:@"member_id"];
    }
    [params setObject:@(pageNo) forKey:@"page_no"];
    [params setObject:@(pageSize) forKey:@"page_size"];
    
    [BaseService BSGet:@"footprint_list" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            NSArray *arr = (NSArray*)BS.data;
            NSMutableArray *mutArr = [NSMutableArray array];
            if (arr != nil && arr.count > 0) {
                for (id obj in arr) {
                    FootprintModel *model = [[FootprintModel alloc] initWithData:obj];
                    [mutArr addObject:model];
                }
            }
        
            NSMutableDictionary *nd = [[NSMutableDictionary alloc] init];
            if (mutArr) {
                [nd setObject:mutArr forKey:@"data"];
            }
            if (BS.dataExtra) {
                [nd setObject:BS.dataExtra forKey:@"dataExtra"];
            }
            success (nd);
            
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}

/**
 *  获取保证金信息接口
 *
 *  @param  sessionId   会话id
 *  @param  needCount   是否需要统计数据 1:需要 0:不需要
 */
+ (void)getDepositInfo:(NSString *)sessionId
             needCount:(int)needCount
               success:(void (^)(DepositInfoModel *depositInfo))success
               failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:0];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    if (needCount > 0) {
        [params setObject:@(needCount) forKey:@"need_count"];
    }
    [BaseService BSGet:@"deposit_info" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success&&BS.data) {
            DepositInfoModel *depositInfo = [DepositInfoModel yy_modelWithJSON:BS.data];
            success(depositInfo);
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}


+(void)topicDelete:(NSString *)sessionId topicId:(int)topicId success:(void (^)(id))success failure:(void (^)(id))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    if (topicId) {
        [params setObject:@(topicId) forKey:@"topic_id"];
    }
    [BaseService BSGet:@"topic_delete" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            success(BS.data);
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}

+ (void)admin_topicDelete:(NSString *)sessionId
                  topicId:(int)topicId
                    black:(BOOL)black
                   reason:(NSString *)reason
                  success:(void (^)(id data))success
                  failure:(void (^)(id error))failure
{
    if ([LoginManager sharedManager].session.memberLevel != 10) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"session_id"] = sessionId;
    params[@"topic_id"] = @(topicId);
    params[@"report_reason"] = reason;
    params[@"add_black"] = @(black);
    [BaseService BSGet:@"topic_delete" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            success(BS.data);
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}

+ (void)admin_digestTrend:(int)topicId
                 isDigest:(BOOL)isDigest
                  success:(void (^)(id data))success
                  failure:(void (^)(id error))failure
{
    if ([LoginManager sharedManager].session.memberLevel != 10) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"session_id"] = [[LoginManager sharedManager] getSessionId];
    params[@"topic_id"] = @(topicId);
    params[@"hot_rank"] = @(isDigest);
    [BaseService BSGet:@"topic_rank" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            success(BS.data);
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}


+(void)topicCommentDelete:(NSString *)sessionId commentId:(int)commentId topicId:(int)topicId success:(void (^)(id))success failure:(void (^)(id))failure{
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
    [BaseService BSGet:@"topic_comment_delete" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            success(BS.data);
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}

+ (void)topicCommentAdd:(NSString *)sessionId topicId:(int)topicId toMemberId:(int)toMemberId text:(NSString *)text success:(void (^)(id data))success
                failure:(void (^)(id error))failure{
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
    if (text) {
        [params setObject:text forKey:@"comment_content"];
    }
    [BaseService BSPost:@"topic_comment_add" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            success(BS.data);
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}

+ (void)topicPraiseAdd:(NSString*)sessionId
               topicId:(int)topicId
               success:(void (^)(id data))success
               failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    if (topicId) {
        [params setObject:@(topicId) forKey:@"topic_id"];
    }
    [BaseService BSGet:@"topic_praise_add" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            success(BS.data);
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}


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
                          failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(toMemberId) forKey:@"to_member_id"];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [params setObject:@(operation) forKey:@"operation"];
    if (nameRemark) {
        [params setObject:nameRemark forKey:@"name_remark"];
    }
    [BaseService BSGet:@"user_follow_add" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            success(BS.data);
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}

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
                        failure:(void (^)(id error))failure {

    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(resId) forKey:@"res_id"];
    [params setObject:@(partId) forKey:@"part_id"];
    if(partSize > 0) {
        NSString* filePath = (NSString *)resData;
        NSFileHandle *fileHandle=[NSFileHandle fileHandleForReadingAtPath:filePath];
        NSUInteger length=[fileHandle availableData].length;
        NSUInteger startPos = (partId - 1) * partSize;
        [fileHandle seekToFileOffset:startPos];
        NSData *data=[fileHandle readDataOfLength: startPos < length - partSize ? partSize : length - startPos];
        NSString* videoData = [[NSString alloc] initWithData:[GTMBase64 encodeData:data] encoding:NSUTF8StringEncoding];
        [params setObject:videoData forKey:@"res_data"];
    } else {
        NSString *imageData = [Utilities imageDataWithImage:(UIImage *)resData];
        [params setObject:imageData forKey:@"res_data"];
    }

    [BaseService BSPost:@"upload_resource" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            success (BS.data);
        }else{
            success (nil);
        }
    } failure:^(id error) {
        if (error && failure) {
            failure (error);
        }
    }];
}


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
             failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObjectPassNil:sessionId forKey:@"session_id"];
    if (clubId) {
        [params setObject:@(clubId) forKey:@"club_id"];
    }
    [params setObjectPassNil:teeDate forKey:@"tee_date"];
    [params setObject:@(gross) forKey:@"gross"];
    [params setObject:@(publicMode) forKey:@"public_mode"];
    [params setObject:@(publishTopic) forKey:@"publish_topic"];
    [params setObject:@(footprintId) forKey:@"footprint_id"];
//    if (topicContent.length>=1000) {
//        NSString *string=[topicContent substringToIndex:1998];
//        topicContent=[string stringByAppendingString:@"..."];
//    }
    [params setObjectPassNil:topicContent forKey:@"topic_content"];

    if (images&&images.count>0) {
        if(images.count > 1) {
            [params setObject:@(images.count) forKey:@"image_data_count"];
        } else {
            [params setObject:@(images.count) forKey:@"image_count"];
            UIImage *image = images[0];
            NSString *imageData = [Utilities imageDataWithImage:image];
            [params setObject:imageData forKey:@"image_data0"];
        }
    }
    
    [params setObject:@(longitude) forKey:@"longitude"];
    [params setObject:@(latitude) forKey:@"latitude"];
    
    [BaseService BSPost:@"footprint_add" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            int resId = 0;
            if (BS.data) {
                NSDictionary *dic = (NSDictionary*)BS.data;
                if (dic[@"res_id"]) {
                    resId = [dic[@"res_id"] intValue];
                }
            }
            if (resId > 0 &&  images.count > 0) {
                __block int s = 0;
                __block int e = 0;
                for (int i=0; i<images.count; i++) {
                    [ServerService uploadResourceWithResId:resId partId:i+1 partSize:0 resData:images[i] success:^(id obj) {
                        s ++;
                        if(s + e >= images.count) {
                            success (BS.data);
                        }
                    } failure:^(id error) {
                        e ++;
                        if(s + e >= images.count) {
                            success (s > 0 ? BS.data : nil);
                        }
                    }];
                }
            } else {
                success (BS.data);
            }
        }else{
            success (nil);
        }
    } failure:^(id error) {
        if (error && failure) {
            failure (error);
        }
    }];
}


/**
 *  获取标签列表
 *
 *  @param  pageNo          页号
 *  @param  pageSize        页大小
 *  @param  keyword         关键字
 */
+ (void)tagList:(NSInteger)pageNo
       pageSize:(NSInteger)pageSize
          tagId:(int)tagId
        tagName:(NSString *)tagName
        keyword:(NSString*)keyword
        success:(void (^)(NSArray *list))success
        failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(pageNo) forKey:@"page_no"];
    [params setObject:@(pageSize) forKey:@"page_size"];
    [params setObject:@(tagId) forKey:@"tag_id"];
    [params setObjectPassNil:tagName forKey:@"tag_name"];
    [params setObjectPassNil:keyword forKey:@"keyword"];
    
    [BaseService BSGet:@"tag_list" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            NSArray *arr = (NSArray*)BS.data;
            NSMutableArray *mutArr = [NSMutableArray array];
            if (arr.count > 0) {
                for (id obj in arr) {
                    TagModel *scm = [[TagModel alloc] initWithDic:obj];
                    [mutArr addObject:scm];
                }
            }
            success (mutArr);
        }
    } failure:^(id error) {
        if (error && failure) {
            failure (error);
        }
    }];
}

+ (void)topicList:(NSString *)sessionId tagId:(int)tagId tagName:(NSString *)tagName memberId:(int)memberId clubId:(int)clubId topicId:(int)topicId topicType:(int)topicType pageNo:(int)pageNo pageSize:(int)pageSize longitude:(double)longitude latitude:(double)latitude success:(void (^)(NSArray *))success failure:(void (^)(id))failure{
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
    
    [BaseService BSGet:@"topic_list" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            NSMutableArray *mutArr = [NSMutableArray array];
            if (BS.data) {
                TrendsModel *model = [[TrendsModel alloc] initWithDic:BS.data];
                [mutArr addObject:model];
            }
            success (mutArr);
        }
    } failure:^(id error) {
        if (error && failure) {
            failure (error);
        }
    }];
}


/**
 *  发布话题接口
 *
 *  @param  sessionId
 *  @param  clubId
 *  @param  topicContent
 *  @param  images
 *  @param  videoPath
 *  @param  longitude
 *  @param  latitude
 *  @param  location
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
         failure:(void (^)(id error))failure{
    
    int videoChunkCount = 0;
    int partSize = 0;
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObjectPassNil:sessionId forKey:@"session_id"];
    if (clubId>0) {
        [params setObject:@(clubId) forKey:@"club_id"];
    }
    
    [params setObjectPassNil:topicContent forKey:@"topic_content"];
    [params setObjectPassNil:location forKey:@"location"];
    if (images && images.count>0) {
        if(images.count > 1) {
            [params setObject:@(images.count) forKey:@"image_data_count"];
        } else {
            [params setObject:@(images.count) forKey:@"image_count"];
            UIImage *image = images[0];
            NSString *imageData = [Utilities imageDataWithImage:image];
            [params setObject:imageData forKey:@"image_data0"];
        }
    }
    if (videoPath && videoPath.length>0) {
        int fileLength = (int)[Utilities fileSizeAtPath:videoPath];
        partSize = 120*1024;
        if(fileLength > partSize) {
            videoChunkCount =  fileLength / partSize;
            if(videoChunkCount > 10) {
                videoChunkCount = 10;
            }
            partSize =  (fileLength % (videoChunkCount * 1024)) == 0 ?  fileLength / videoChunkCount  : (fileLength / videoChunkCount / 1024 + 1) * 1024;
            if(partSize * (videoChunkCount - 1) > fileLength) {
                videoChunkCount --;
            }
            [params setObject:@(videoChunkCount) forKey:@"video_data_count"];
        } else {
            NSString *videoData = [Utilities videoDataWithPath:videoPath];
            [params setObject:videoData forKey:@"video_data"];
        }
    }
    [params setObject:@(longitude) forKey:@"longitude"];
    [params setObject:@(latitude) forKey:@"latitude"];
    
    [BaseService BSPost:@"topic_add" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            int resId = 0;
            if (BS.data) {
                NSDictionary *dic = (NSDictionary*)BS.data;
                if (dic[@"res_id"]) {
                    resId = [dic[@"res_id"] intValue];
                }
            }
            if (resId > 0 && (videoChunkCount > 0 || images.count >0)) {
                __block int s = 0;
                __block int e = 0;
                if(videoChunkCount > 0) {
                    for (int i=0; i<videoChunkCount; i++) {
                        [ServerService uploadResourceWithResId:resId partId:i+1 partSize:partSize resData:videoPath success:^(id obj) {
                            s ++;
                            if(s >= videoChunkCount) {
                                success (BS.data);
                            }
                        } failure:^(id error) {
                            e ++;
                            success (nil);
                        }];
                    }
                } else {
                    for (int i=0; i<images.count; i++) {
                        [ServerService uploadResourceWithResId:resId partId:i+1 partSize:partSize resData:images[i] success:^(id obj) {
                            s ++;
                            if(s + e >= images.count) {
                                success (BS.data);
                            }
                        } failure:^(id error) {
                            e ++;
                            if(s + e >= images.count) {
                                success (s > 0 ? BS.data : nil);
                            }
                        }];
                    }
                }
            } else {
                success (BS.data);
            }
        }else{
            failure (nil);
        }
    } failure:^(id error) {
        if (error && failure) {
            failure (error);
        }
    }];
    
    
}



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
                failure:(void (^)(id error))failure{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@(longitude) forKey:@"longitude"];
    [param setObject:@(latitude) forKey:@"latitude"];
    [param setObject:@(pageNo) forKey:@"page_no"];
    [param setObject:@(pageSize) forKey:@"page_size"];
    [param setObjectPassNil:keyword forKey:@"keyword"];
    
    [BaseService BSGet:@"club_list" parameters:param encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            NSArray *arr = (NSArray*)BS.data;
            NSMutableArray *mutArr = [NSMutableArray array];
            if (arr.count > 0) {
                for (id obj in arr) {
                    SearchClubModel *scm = [[SearchClubModel alloc] initWithDic:obj];
                    [mutArr addObject:scm];
                }
            }
            success (mutArr);
        }
    } failure:^(id error) {
        if (error && failure) {
            failure (error);
        }
    }];
}


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
//                 failure:(void (^)(id error))failure{
//    NSMutableDictionary *param = [NSMutableDictionary dictionary];
//    [param setObject:@(articleId) forKey:@"article_id"];
//    [param setObjectPassNil:imeiNum forKey:@"imei_num"];
//    
//    [BaseService BSGet:@"article_detail" parameters:param encrypt:YES needLoading:NO success:^(BaseService *BS) {
//        if (BS.success) {
//            NSDictionary *dic = (NSDictionary*)BS.data;
//            ArticleInfoModel *model = [[ArticleInfoModel alloc] initWithDic:dic];
//            success (model);
//        }
//    } failure:^(id error) {
//        if (error && failure) {
//            failure (error);
//        }
//    }];
//}


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
              failure:(void (^)(id error))failure{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@(articleId) forKey:@"article_id"];
    [param setObjectPassNil:imeiNum forKey:@"imei_num"];
    [param setObject:@(praiseType) forKey:@"praise_type"];
    
    [BaseService BSGet:@"article_praise" parameters:param encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            success (BS.data);
        }
    } failure:^(id error) {
        if (error && failure) {
            failure (error);
        }
    }];
}

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
                  failure:(void (^)(id error))failure{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObjectPassNil:aSessionId forKey:@"session_id"];
    [param setObject:@(articleId) forKey:@"article_id"];
    [param setObjectPassNil:content forKey:@"comment_content"];
    
    [BaseService BSGet:@"article_comment_add" parameters:param encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            success (BS.data);
        }
    } failure:^(id error) {
        if (error && failure) {
            failure (error);
        }
    }];
}




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
                          failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObjectPassNil:sessionId forKey:@"session_id"];
    [params setObjectPassNil:dataType forKey:@"data_type"];
    [params setObject:@(dataId) forKey:@"data_id"];
    [params setObject:@(imageDataCount) forKey:@"image_data_count"];
    [params setObject:@(videoDataCount) forKey:@"video_data_count"];
    
    [BaseService BSGet:@"init_resource" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        success (BS);
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}


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
                           failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObjectPassNil:sessionId forKey:@"session_id"];
    [params setObjectPassNil:imageData forKey:@"image_data"];
    [params setObjectPassNil:imageDelete forKey:@"image_delete"];
    [params setObject:@(currentPosition) forKey:@"curr_position"];
    [params setObject:@(newPosition) forKey:@"new_position"];
    
    [BaseService BSPost:@"user_edit_album" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success && BS.data) {
            success (@[BS.data]);
        }else{
            success (nil);
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}


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
             failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObjectPassNil:sessionId forKey:@"session_id"];
    [params setObjectPassNil:memberName forKey:@"member_name"];
    [params setObjectPassNil:nickName forKey:@"nick_name"];
    [params setObjectPassNil:headImageData forKey:@"head_image_data"];
    [params setObjectPassNil:photoImageData forKey:@"photo_image_data"];
    [params setObjectPassNil:birthday forKey:@"birthday"];
    [params setObjectPassNil:signature forKey:@"signature"];
    [params setObjectPassNil:location forKey:@"location"];
    [params setObjectPassNil:personalTag forKey:@"personal_tag"];
    [params setObjectPassNil:introduction forKey:@"introduction"];
    [params setObjectPassNil:careerAchievement forKey:@"career_achievement"];
    [params setObjectPassNil:teachingAchievement forKey:@"teaching_achievement"];
    if (academyId > 0) {
        [params setObjectPassNil:@(academyId) forKey:@"academy_id"];
    }
    if (seniority > 0) {
        [params setObjectPassNil:@(seniority) forKey:@"seniority"];
    }
//    if (handicap > -100) {
        [params setObject:@(handicap) forKey:@"handicap"];
//    }
    if (gender > -1 && gender < 2) {
        [params setObject:@(gender) forKey:@"gender"];
    }
    
    [BaseService BSPost:@"user_edit_info" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success && BS.data) {
            success (@[BS.data]);
        }else{
            success (nil);
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}


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
                             failure:(void (^)(id error))failure{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObjectPassNil:sessionId forKey:@"session_id"];
    [param setObject:@(footprintId) forKey:@"footprint_id"];
    [param setObject:@(clubId) forKey:@"club_id"];
    
    [BaseService BSGet:@"footprint_delete" parameters:param encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            success (BS.data);
        }
    } failure:^(id error) {
        if (error && failure) {
            failure (error);
        }
    }];
}
/** lyf 加
 *  活动信息列表 activity_list
 *
 *  @param longitude            经度
 *  @param latitude             纬度
 *  @param putArea              投放区域 1：首页（缺省） 2：教学 3：入门 4:teeTime首页 5:启动页 6.商品乐活动 8.旅行套餐
 *  @param resolution           分辩率 1：高 2:中（缺省） 3:低
 *  @param needGroup          足迹ID
 */
+ (void)getActivityListByLongitude:(double)longitude
                          latitude:(double)latitude
                           putArea:(int)putArea
                         esolution:(int)resolution
                         needGroup:(BOOL)needGroup
                           success:(void (^)(id data))success
                           failure:(void (^)(id error))failure{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    if (longitude!=0 &&latitude!=0) {
        [param setObject:@(longitude) forKey:@"longitude"];
        [param setObject:@(latitude) forKey:@"latitude"];
    }
    if (putArea != 0) {
        [param setObject:@(putArea) forKey:@"put_area"];
    }
    if (resolution != 0) {
        [param setObject:@(resolution) forKey:@"resolution"];
    }
    
    [param setObject:needGroup ? @"1":@"0" forKey:@"need_group"];
    
    [BaseService BSGet:@"activity_list" parameters:param encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            NSArray *resultArray = (NSArray *)BS.data;
            NSMutableArray *array = [NSMutableArray array];
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
            success (array);
        }
    } failure:^(id error) {
        if (error && failure) {
            failure (error);
        }
    }];
}

+ (void)systemParamInfoByGolfSessionPhone:(NSString *)phone success:(void (^)(SystemParamInfo *data))success
                                  failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if(phone && phone.length>0){
        [params setObject:phone forKey:@"phone_num"];
    }
    [BaseService BSGet:@"xram" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success && BS.data != nil) {
            success([[SystemParamInfo alloc] initWithDic:BS.data]);
        }
    } failure:^(id error) {
        if (error && failure) {
            failure (error);
        }
    }];
}

+ (void)reportInfoAddWithImei:(NSString*)imeiNum
                    sessionId:(NSString*)sessionId
                 reportReason:(NSString*)reportReason
                   targetType:(int)targetType
                     targetId:(int)targetId
                      success:(void (^)(BOOL flag))success
                      failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (imeiNum) {
        [params setObject:imeiNum forKey:@"imei_num"];
    }
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    if (reportReason) {
        [params setObject:reportReason forKey:@"report_reason"];
    }
    if (targetType) {
        [params setObject:@(targetType) forKey:@"target_type"];
    }
    if (targetId) {
        [params setObject:@(targetId) forKey:@"target_id"];
    }
    [BaseService BSGet:@"user_report_add" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            success(BS.success);
        }
    } failure:^(id error) {
        if (error && failure) {
            failure (error);
        }
    }];
}

+ (void)userDetailByMemberId:(int)memberId mobilePhone:(NSString *)mobilePhone
                   sessionID:(NSString *)sessionID
                     success:(void (^)(UserDetailModel *userDetail))success
                     failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(memberId) forKey:@"member_id"];
    if (mobilePhone) {
        [params setObject:mobilePhone forKey:@"phone_num"];
    }
    if (sessionID) {
        [params setObject:sessionID forKey:@"session_id"];
    }
    [BaseService BSGet:@"user_detail" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            UserDetailModel *model = [[UserDetailModel alloc] initWithDic:BS.data];
            success(model);
        }
    } failure:^(id error) {
        if (error && failure) {
            failure (error);
        }
    }];
}

+ (void)footPrintListWithSessionId:(NSString *)sessionId memberId:(int)memberId pageNo:(int)pageNo pageSize:(int)pageSize courseid:(int)courseid courseName:(NSString *)courseName success:(void (^)(NSMutableArray *arr))success failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
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
    [BaseService BSGet:@"footprint_list" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            NSArray *arr = (NSArray *)BS.data;
            NSMutableArray *array = [[NSMutableArray alloc] init];
            if (BS.data != nil && arr.count > 0) {
                for (id obj in arr) {
                    FootprintModel *model = [[FootprintModel alloc] initWithData:obj];
                    [array addObject:model];
                }
            }
            success(array);
        }
    } failure:^(id error) {
        if (error && failure) {
            failure (error);
        }
    }];
}

+ (void)userPlayedCourseListByMemberId:(int)memberId success:(void (^)(UserPlayedClubListModel *obj))success failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@(memberId) forKey:@"member_id"];
    [BaseService BSGet:@"user_played_club_list" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            UserPlayedClubListModel *obj = [[UserPlayedClubListModel alloc] initWithDic:BS.data];
            success(obj);
        }
    } failure:^(id error) {
        if (error && failure) {
            failure (error);
        }
    }];
}

/**
 *  获取版本号  get_ios_last_version
 *
 *  @param success
 *  @param failure
 */
+ (void)getLastVersionSuccess:(void (^)(GetLastVersionModel *obj))success failure:(void (^)(id error))failure{
    [BaseService BSGet:@"get_ios_last_version" parameters:nil encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            GetLastVersionModel *model = [[GetLastVersionModel alloc] initWithDic:BS.data];
            success(model);
        }
    } failure:^(id error) {
        if (error && failure) {
            failure(error);
        }
    }];
}

/**
 获取验证码

 @param phoneNum  电话号码
 @param groupFlag 分组标志 eweeks 表示e周汇用户
 @param noMsg     不发送短信，缺省为0（发送），若客户端可以自动获取到手机号，则填写1
 @param codeType  验证码类型 0：短信 1：语音
 @param success   请求成功
 @param failure   请求失败
 */
+ (void)publicValidateCode:(NSString*)phoneNum
                 groupFlag:(NSString*)groupFlag
                     noMsg:(int)noMsg
                  codeType:(int)codeType success:(void (^)(id obj))success failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (phoneNum) {
        [params setObject:phoneNum forKey:@"phone_num"];
    }
    if (groupFlag) {
        [params setObject:groupFlag forKey:@"group_flag"];
    }
    [params setObject:@(noMsg) forKey:@"no_msg"];
    [params setObject:@(MIN(1, codeType)) forKey:@"code_type"];
    [BaseService BSGet:@"public_validate_code" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            success(BS);
        }
    } failure:^(id error) {
        if (error && failure) {
            failure(error);
        }
    }];
}

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
        callBack:(void (^)(id))callBack failure:(void (^)(id))failure{
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
    [BaseService BSGet:@"user_bound" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            callBack(BS);
        }
    } failure:^(id error) {
        if (error && failure) {
            failure(error);
        }
    }];
}

+ (void)fetchDepositInfoCallBack:(void(^)(id obj))callBack
                         failure:(void (^)(id error))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"session_id"] = [[LoginManager sharedManager] getSessionId];
    params[@"need_count"] = @1;
    [BaseService BSGet:@"deposit_info" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        id data = BS.data;
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            DepositInfoModel *info = [DepositInfoModel yy_modelWithJSON:data];
            if (callBack) {
                callBack(info);
            }
        }
    } failure:failure];
}

+ (void)fetchMallAddressList:(void(^)(NSArray<YGMallAddressModel *> *obj))callBack
                     failure:(void (^)(id error))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"session_id"] = [[LoginManager sharedManager] getSessionId];
    
    [BaseService BSGet:@"delivery_address_list" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        NSArray *data = (NSArray *)BS.data;
        if ([data isKindOfClass:[NSArray class]]) {
            NSArray *addressList = [NSArray yy_modelArrayWithClass:[YGMallAddressModel class] json:data];
            if (callBack) {
                callBack(addressList);
            }
        }
    } failure:failure];
}

+ (void)maintainMallAddress:(NSInteger)type
                       info:(NSDictionary *)addressInfo
                   callBack:(void(^)(id obj))callBack
                    failure:(void (^)(id error))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"session_id"] = [[LoginManager sharedManager] getSessionId];
    params[@"operation"] = @(type);
    [params addEntriesFromDictionary:addressInfo];
    [BaseService BSGet:@"delivery_address_maintain" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (callBack) {
            callBack(BS.data);
        }
    } failure:failure];
}

+ (void)fetchCourseOrderList:(NSInteger)status
                     payType:(NSInteger)payType
                        page:(NSInteger)pageNo
                    pageSize:(NSInteger)pageSize
                    callBack:(void(^)(id obj))callBack
                     failure:(void (^)(id error))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"session_id"] = [[LoginManager sharedManager] getSessionId];
    params[@"order_state"] = @(status);
    params[@"pay_type"] = @(payType);
    params[@"page_no"] = @(pageNo);
    params[@"page_size"] = @(pageSize);
    [BaseService BSGet:@"order_list" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (callBack) {
            callBack(BS.data);
        }
    } failure:failure];
}

+ (void)fetchTeachOrderList:(NSInteger)status
                    coachId:(NSInteger)coachId
                   memberId:(NSInteger)memberId
                   keywords:(NSString *)keywords
                       page:(NSInteger)pageNo
                   pageSize:(NSInteger)pageSize
                   callBack:(void(^)(id obj))callBack
                    failure:(void (^)(id error))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"session_id"] = [[LoginManager sharedManager] getSessionId];
    params[@"order_state"] = @(status);
    params[@"coach_id"] = @(coachId);
    params[@"member_id"] = @(memberId);
    params[@"keyword"] = keywords;
    params[@"page_no"] = @(pageNo);
    params[@"page_size"] = @(pageSize);
    [BaseService BSGet:@"teaching_order_list" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        
        if (callBack) {
            callBack(BS.data);
        }
    } failure:failure];
}

+ (void)fetchCouponList:(int)status
                 pageNo:(int)pageNo
               pageSize:(int)size
               callBack:(void(^)(id obj))callBack
                failure:(void (^)(id error))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"session_id"] = [[LoginManager sharedManager] getSessionId];
    params[@"coupon_status"] = @(status);
    params[@"page_no"] = @(pageNo);
    params[@"page_size"] = @(size);
    [BaseService BSGet:@"coupon_list" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        id data = BS.data;
        if (callBack && [data isKindOfClass:[NSArray class]]) {
            NSMutableArray *result = [NSMutableArray array];
            for (id obj in (NSArray *)data){
                CouponModel *model = [[CouponModel alloc] initWithDic:obj];
                [result addObject:model];
            }
            callBack(result);
        }
        
    } failure:failure];
}

+ (void)fetchCouponFilteredList:(int)status
                         pageNo:(int)pageNo
                       pageSize:(int)size
                          scene:(int)scene
                          price:(NSInteger)price
                            ids:(NSSet<NSNumber *> *)ids
                       callBack:(void(^)(id obj))callBack
                        failure:(void (^)(id error))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"session_id"] = [[LoginManager sharedManager] getSessionId];
    params[@"coupon_status"] = @(status);
    params[@"page_no"] = @(pageNo);
    params[@"page_size"] = @(size);
    params[@"type"] = @(scene);
    params[@"price"] = @(price);
    params[@"ids"] = [[ids allObjects] componentsJoinedByString:@","];
    [BaseService BSGet:@"coupon_list_status" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        id data = BS.data;
        if (callBack && [data isKindOfClass:[NSArray class]]) {
            NSMutableArray *result = [NSMutableArray array];
            for (id obj in (NSArray *)data){
                CouponModel *model = [[CouponModel alloc] initWithDic:obj];
                [result addObject:model];
            }
            callBack(result);
        }
        
    } failure:failure];
}

+ (void)submitCommodityOrder:(NSDictionary *)data
                    callBack:(void(^)(id obj))callBack
                     failure:(void (^)(id error))failure
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:data];
    dict[@"session_id"] = [[LoginManager sharedManager] getSessionId];
    [BaseService BSGet:@"commodity_order_merge" parameters:dict encrypt:YES needLoading:NO success:callBack failure:failure];
}

+ (void)fetchOrderDetail:(NSInteger)orderId
                callBack:(void(^)(id obj))callBack
                 failure:(void (^)(id error))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"order_id"] = @(orderId);
    params[@"session_id"] = [[LoginManager sharedManager] getSessionId];
    [BaseService BSGet:@"commodity_order_detail" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        
        id data = BS.data;
        if (callBack && [data isKindOfClass:[NSDictionary class]]) {
            YGMallOrderModel *order = [YGMallOrderModel yy_modelWithJSON:data];
            callBack(order);
        }
    } failure:failure];
}

+ (void)fetchMallOrderList:(NSInteger)status
                    pageNo:(NSInteger)page
                  pageSize:(NSInteger)size
                  callBack:(void(^)(id obj))callBack
                   failure:(void (^)(id error))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"session_id"] = [[LoginManager sharedManager] getSessionId];
    params[@"order_state"] = @(status);
    params[@"page_no"] = @(page);
    params[@"page_size"] = @(size);
    [BaseService BSGet:@"commodity_order_list" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        id data = BS.data;
        if (callBack) {
            callBack(data);
        }
    } failure:failure];
}

+ (void)operateOrder:(NSInteger)orderId
           operation:(int)operation
                desc:(NSString *)desc
            callBack:(void(^)(id obj))callBack
             failure:(void (^)(id error))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"session_id"] = [[LoginManager sharedManager] getSessionId];
    params[@"order_id"] = @(orderId);
    params[@"operation"] = @(operation);
    params[@"description"] = desc;
    [BaseService BSGet:@"commodity_order_maintain" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        id data = BS.data;
        if (callBack) {
            callBack(data);
        }
    } failure:failure];
}

+ (void)deleteMallOrder:(NSInteger)orderId
               callBack:(void(^)(id obj))callBack
                failure:(void (^)(id error))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"session_id"] = [[LoginManager sharedManager] getSessionId];
    params[@"order_id"] = @(orderId);
    [BaseService BSGet:@"commodity_order_delete" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        id data = BS.data;
        if (callBack) {
            callBack(data);
        }
    } failure:failure];
}

+ (void)editMallOrderMemo:(NSInteger)orderId
                     memo:(NSString *)memo
                 callBack:(void(^)(id obj))callBack
                  failure:(void (^)(id error))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"session_id"] = [[LoginManager sharedManager] getSessionId];
    params[@"order_id"] = @(orderId);
    params[@"user_memo"] = memo;
    [BaseService BSGet:@"commodity_order_user_memo" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        id data = BS.data;
        if (callBack) {
            callBack(data);
        }
    } failure:failure];
}

+ (void)addMallOrderReview:(NSInteger)orderId
                 commodity:(NSInteger)commodityId
                     level:(NSInteger)level
                   content:(NSString *)content
                  callBack:(void(^)(id obj))callBack
                   failure:(void (^)(id error))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"session_id"] = [[LoginManager sharedManager] getSessionId];
    params[@"order_id"] = @(orderId);
    params[@"comment_level"] = @(level);
    params[@"comment_content"] = content;
    params[@"commodity_id"] = @(commodityId);
    [BaseService BSPost:@"commodity_comment_add" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        id data = BS.data;
        if (callBack) {
            callBack(data);
        }
    } failure:failure];
}

+ (void)fetchMallOrderCommodityList:(NSInteger)orderId
                           callBack:(void(^)(id obj))callBack
                            failure:(void (^)(id error))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"session_id"] = [[LoginManager sharedManager] getSessionId];
    params[@"order_id"] = @(orderId);
    [BaseService BSPost:@"commodity_order_comment_list" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        id data = BS.data;
        if (callBack && [data isKindOfClass:[NSArray class]]) {
            NSArray *list = [NSArray yy_modelArrayWithClass:[YGMallOrderCommodity class] json:data];
            callBack(list);
        }
    } failure:failure];
}

/**
 球场订单和旅行套餐删除
 
 @param sessionId sessionID
 @param orderId   订单ID
 */
+ (void)orderDelete:(NSString*)sessionId orderId:(int)orderId callBack:(void (^)(id obj))callBack failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    [params setObject:@(orderId) forKey:@"order_id"];
    
    [BaseService BSGet:@"order_delete" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            callBack(BS);
        }
    } failure:^(id error) {
        if (error && failure) {
            failure(error);
        }
    }];
}

+ (void)fetchMallFlashSaleList:(NSInteger)from
                        pageNo:(NSInteger)pageNo
                       pagSize:(NSInteger)size
                      callBack:(void(^)(id obj))callBack
                       failure:(void (^)(id error))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"session_id"] = [[LoginManager sharedManager] getSessionId];
    params[@"page_no"] = @(MAX(1, pageNo));
    params[@"page_size"] = @(MAX(0, size));
    params[@"from"] = @(from);
    [BaseService BSGet:@"commodity_flash_sale_list" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        
        NSArray *data = (NSArray *)BS.data;
        if ([data isKindOfClass:[NSArray class]]) {
            NSMutableArray *list = [NSMutableArray array];
            for (NSDictionary *dic in data) {
                CommodityModel *commodity = [[CommodityModel alloc] initWithDic:dic];
                if (commodity) {
                    [list addObject:commodity];
                }
            }
            if (callBack) {
                callBack(list);
            }
        }else{
            if (callBack) {
                callBack(@"数据错误");
            }
        }
    } failure:failure];
}

+ (void)fetchMallFlashSaleTimestamp:(void(^)(id obj))callBack
                            failure:(void (^)(id error))failure
{
    [BaseService BSGet:@"commodity_flash_sale_status" parameters:nil encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (callBack) {
            callBack(BS.data);
        }
    } failure:failure];
}

+ (void)fetchMallCommodityDetail:(NSInteger)cid
                        callBack:(void(^)(id obj))callBack
                         failure:(void (^)(id error))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"commodity_id"] = @(cid);
    params[@"session_id"] = [[LoginManager sharedManager] getSessionId];
    [BaseService BSGet:@"commodity_detail" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        
        NSDictionary *data = (NSDictionary *)BS.data;
        if ([data isKindOfClass:[NSDictionary class]]) {
            CommodityInfoModel *model = [CommodityInfoModel yy_modelWithDictionary:data];
            if (callBack) {
                callBack(model);
            }
        }else if (callBack){
            callBack(@"数据错误");
        }
    } failure:failure];
}

+ (void)updateMallCommodityArrivalNotice:(NSInteger)cid
                                    type:(NSInteger)noticeType
                                addOpera:(BOOL)isAdd
                                   token:(NSString *)token
                                callBack:(void(^)(id obj))callBack
                                 failure:(void (^)(id error))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"session_id"] = [[LoginManager sharedManager] getSessionId];
    params[@"commodity_id"] =@(cid);
    params[@"device_token"] = token;
    params[@"notice_type"] = @(noticeType);
    params[@"opera"] = isAdd?@0:@1;
    params[@"spec_id"] = @0;
    params[@"phone_num"] = @0;
    [BaseService BSGet:@"commodity_arrival_notice" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        
        if (callBack) {
            callBack(BS.data);
        }
        
    } failure:failure];
}

#pragma mark CourseOrder
+ (void)deleteCourseOrder:(NSInteger)orderId
                 callBack:(void(^)(id obj))callBack
                  failure:(void (^)(id error))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"session_id"] = [[LoginManager sharedManager] getSessionId];
    params[@"order_id"] = @(orderId);
    [BaseService BSGet:@"order_delete" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (callBack) {
            callBack(BS.data);
        }
    } failure:failure];
}

+ (void)cancelCourseOrderRefund:(NSInteger)orderId
                       callBack:(void(^)(id obj))callBack
                        failure:(void (^)(id error))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"session_id"] = [[LoginManager sharedManager] getSessionId];
    params[@"order_id"] = @(orderId);
    params[@"operation"] = @1;
    [BaseService BSGet:@"cancel_order" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (callBack) {
            callBack(BS.data);
        }
    } failure:failure];
}

+ (void)fetchRecentOrders:(NSInteger)state
              lastOrderId:(NSInteger)lastOrderId
                 pageSize:(NSInteger)size
                 callBack:(void(^)(id obj))callBack
                  failure:(void (^)(id error))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"session_id"] = [[LoginManager sharedManager] getSessionId];
    params[@"order_state"] = @(state);
    params[@"max_order_id"] = @(lastOrderId);
    params[@"pageSize"] = @(size);
    [BaseService BSGet:@"person_order_manager" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (callBack) {
            callBack(BS.data);
        }
    } failure:failure];
}

@end
