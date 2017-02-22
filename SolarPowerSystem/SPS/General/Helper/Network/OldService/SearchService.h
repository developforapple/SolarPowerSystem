//
//  SearchService.h
//  Golf
//
//  Created by Vincent on 11-11-26.
//  Copyright (c) 2011年 Achievo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TeeTimeModel.h"
#import "TeeTimeAgentModel.h"
#import "ClubModel.h"
#import "ConditionModel.h"
#import "SearchCityModel.h"
#import "searchClubModel.h"
#import "VIPClubModel.h"
#import "ClubFairwayModel.h"
#import "ClubPictureModel.h"
#import "LoginManager.h"
#import "ActivityModel.h"
#import "PackageModel.h"
#import "PackageDetailModel.h"
#import "WeatherModel.h"
#import "SpecialOfferModel.h"
#import "SearchProvinceModel.h"
#import "TotalCommentModel.h"
#import "CommentModel.h"
#import "CouponModel.h"
#import "UserCommentModel.h"

typedef enum {
    /** 图片浏览 **/
    ClubTypeImage = 0,
    /** 球道展示 **/
    ClubTypeFairway = 1,
    /** 套餐展示 **/
    PackageTypeImage = 2,
} ClubTypeEnum;

@interface SearchService : NSObject

+ (SearchService *)sharedService;




// 获取城市列表
+ (void)getCityList:(int)flag
            success:(void (^)(NSArray *list))success
            failure:(void (^)(id error))failure;

// 获取vip球场
+ (void)getVIPClubsWithSession:(NSString *)sessionId
                     VipStatus:(int)vipStatus
                       success:(void (^)(NSArray *list))success
                       failure:(void (^)(id error))failure;

// 获取图片列表（球场主页，套餐，球道的图片集）
+ (void)getImageListWityId:(int)Id
                      type:(ClubTypeEnum)type
                   success:(void (^)(NSArray *list))success
                   failure:(void (^)(id error))failure;


// 添加评论
+ (void)addClubCommentWithSessionId:(NSString*)sessionId
                             clubId:(int)clubId
                            orderId:(int)orderId
                       commentModel:(CommentModel*)model
                            success:(void (^)(BOOL boolen))success
                            failure:(void (^)(id error))failure;

// 添加现金券
+ (void)addCouponWithSessionId:(NSString *)sessionId
                    couponCode:(NSString *)code
                       success:(void (^)(CouponModel *coupon))success
                       failure:(void (^)(id error))failure;

// 用户转账
+ (void)userTransferAccountSessionId:(NSString*)sessionId
                            phoneNum:(NSString*)phoneNum
                          tranAmount:(int)amount
                            passWord:(NSString *)pasaWord
                             success:(void (^)(BOOL boolen))success
                             failure:(void (^)(id error))failure;




@end
