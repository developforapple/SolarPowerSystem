//
//  SearchService.m
//  Golf
//
//  Created by 青 叶 on 11-11-26.
//  Copyright (c) 2011年 大展. All rights reserved.
//

#import "SearchService.h"

static SearchService *sharedServiceManager = nil;

@implementation SearchService

+ (SearchService *)sharedService{
    @synchronized(self){
        if (sharedServiceManager == nil) {
            sharedServiceManager = [[self alloc] init];
        }
    }
    return sharedServiceManager;
}

/**
 *
 * 根据条件搜索Club
 * @param condition
 * @param page
 * @param page_size
 * @return array of Club
 * @throws Exception
 */
- (NSDictionary *)searchClubWithCondition:(ConditionModel *)condition
                            withPage:(int)page
                        withPageSize:(int)pageSize 
                         withVersion:(NSString*)version
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if(condition){
        if(condition.provinceId > 0){
            [params setObject:[NSNumber numberWithInt:condition.provinceId] forKey:@"province_id"];
        }
        if(condition.cityId > 0){
            [params setObject:[NSNumber numberWithInt:condition.cityId] forKey:@"city_id"];
        }
        if(condition.longitude){
            [params setObject:[NSNumber numberWithFloat:condition.longitude] forKey:@"longitude"];
        }
        if(condition.latitude){
            [params setObject:[NSNumber numberWithFloat:condition.latitude] forKey:@"latitude"];
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
        if(condition.price){
            [params setObject:[NSNumber numberWithInt:condition.price] forKey:@"price"];
        }else{
            [params setObject:@"0" forKey:@"price"];
        }
        if(condition.people){
            [params setObject:[NSNumber numberWithInt:condition.people] forKey:@"people"];
        }
        if (condition.clubName) {
            [params setObject:condition.clubName forKey:@"club_name"];
        }
        [params setObject:[GolfAppDelegate shareAppDelegate].range forKey:@"range"];
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
    
    return params;
}

+ (void)getCityList:(int)flag
            success:(void (^)(NSArray *list))success
            failure:(void (^)(id error))failure{
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *golfVersion = flag > 0 ? @"GolfCitiesVersion" : @"GolfProvincesVersion";
    NSString *currentVersion = [[NSUserDefaults standardUserDefaults] objectForKey:golfVersion];
    if (currentVersion) {
        [params setObject:currentVersion forKey:@"version"];
    }else{
        [params setObject:@"" forKey:@"version"];
    }
    
    NSString *interfaceName = flag > 0 ? @"dict_city" : @"dict_province";
    
    [BaseService BSGet:interfaceName parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            NSDictionary *dic = (NSDictionary*)BS.data;
            
            NSString *path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
            NSString *plist = flag > 0 ? @"GolfCityInfo.plist" : @"GolfProvinceInfo.plist";
            NSString *filename=[path stringByAppendingPathComponent:plist];
            
            if (!dic) {
                NSMutableArray *localList = [NSMutableArray array];
                NSArray *localArray = [NSArray arrayWithContentsOfFile:filename];
                
                for (id obj in localArray) {
                    if (flag > 0) {
                        SearchCityModel *model = [[SearchCityModel alloc] initWithDic:obj];
                        [localList addObject:model];
                    }
                    else{
                        SearchProvinceModel *model = [[SearchProvinceModel alloc] initWithDic:obj];
                        [localList addObject:model];
                    }
                }
                success (localList);
            }else{
                NSString *version = [dic objectForKey:@"version"];
                
                if (version) {
                    [[NSUserDefaults standardUserDefaults] setObject:version forKey:golfVersion];
                }
                
                //更新数据库
                NSString *listName = flag > 0 ? @"city_list" : @"province_list";
                NSArray *resultArray = [dic objectForKey:listName];
                if (resultArray != nil && resultArray.count > 0) {
                    [resultArray writeToFile:filename atomically:YES];
                    NSMutableArray *list = [NSMutableArray array];
                    for (id obj in resultArray) {
                        if (flag > 0) {
                            SearchCityModel *model = [[SearchCityModel alloc] initWithDic:obj];
                            [list addObject:model];
                        }
                        else{
                            SearchProvinceModel *model = [[SearchProvinceModel alloc] initWithDic:obj];
                            [list addObject:model];
                        }
                    }
                    success (list);
                }
            }
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}


+ (void)getVIPClubsWithSession:(NSString *)sessionId
                     VipStatus:(int)vipStatus
                       success:(void (^)(NSArray *list))success
                       failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if(sessionId){
        [params setObject:sessionId forKey:@"session_id"];
    }
    
    [params setObject:[NSNumber numberWithInt:vipStatus] forKey:@"vip_status"];
    [BaseService BSGet:@"club_vip_list" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        NSMutableArray *vipClubs = nil;
        if (BS.success && BS.data) {
            NSArray *resultArray = (NSArray*)BS.data;
            if (resultArray != nil && resultArray.count > 0) {
                vipClubs = [NSMutableArray array];
                for (id obj in resultArray){
                    VIPClubModel *model = [[VIPClubModel alloc] initWithDic:obj];
                    [vipClubs addObject:model];
                }
            }
        }
        success (vipClubs);
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}


+ (void)getImageListWityId:(int)Id
                      type:(ClubTypeEnum)type
                   success:(void (^)(NSArray *list))success
                   failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *interfaceName = nil;
    if (type == ClubTypeImage) {
        [params setObject:@(Id) forKey:@"club_id"];
        interfaceName = @"club_picture_list";
    }else if (type == ClubTypeFairway){
        [params setObject:@(Id) forKey:@"club_id"];
        interfaceName = @"club_fairway_list";
    }else if (type == PackageTypeImage){
        [params setObject:@(Id) forKey:@"package_id"];
        interfaceName = @"package_picture_list";
    }
    [BaseService BSGet:interfaceName parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success && BS.data) {
            NSArray *resultArray = (NSArray*)BS.data;
            NSMutableArray *list = nil;
            if (resultArray.count > 0) {
                list = [NSMutableArray array];
                if (type == ClubTypeImage) {
                    for (id obj in resultArray){
                        ClubPictureModel *model = [[ClubPictureModel alloc] initWithDic:obj];
                        [list addObject:model];
                    }
                }else if (type == ClubTypeFairway){
                    for (id obj in resultArray){
                        ClubFairwayModel *model = [[ClubFairwayModel alloc] initWithDic:obj];
                        [list addObject:model];
                    }
                }else if (type == PackageTypeImage){
                    for (NSDictionary *dicUrl in resultArray){
                        NSString *picUrl = [dicUrl objectForKey:@"pic_url"];
                        [list addObject:picUrl];
                    }
                }
            }
            success (list);
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}

+ (void)addClubCommentWithSessionId:(NSString*)sessionId
                             clubId:(int)clubId
                            orderId:(int)orderId
                       commentModel:(CommentModel*)model
                            success:(void (^)(BOOL boolen))success
                            failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    if (clubId) {
        [params setObject:@(clubId) forKey:@"club_id"];
    }
    //if (orderId) {
    [params setObject:@(orderId) forKey:@"order_id"];
    //}
    if (model) {
        [params setObject:@(model.grassLevel) forKey:@"grass_level"];
        [params setObject:@(model.serviceLevel) forKey:@"service_level"];
        [params setObject:@(model.difficultyLevel) forKey:@"difficulty_level"];
        [params setObject:@(model.sceneryLevel) forKey:@"scenery_level"];
        if (model.commentContent) {
            [params setObject:model.commentContent forKey:@"comment_content"];
        }
    }
    [BaseService BSGet:@"club_comment_add" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        success (BS.success ? YES : NO);
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}


+ (void)addCouponWithSessionId:(NSString *)sessionId
                    couponCode:(NSString *)code
                       success:(void (^)(CouponModel *coupon))success
                       failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    if (code) {
        [params setObject:code forKey:@"coupon_code"];
    }
    [BaseService BSGet:@"coupon_add" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        if (BS.success) {
            id obj = BS.data;
            CouponModel *model = [[CouponModel alloc] initWithDic:obj];
            success (model);
        }
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}


+ (void)userTransferAccountSessionId:(NSString*)sessionId
                            phoneNum:(NSString*)phoneNum
                          tranAmount:(int)amount
                            passWord:(NSString *)pasaWord
                             success:(void (^)(BOOL boolen))success
                             failure:(void (^)(id error))failure{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (sessionId) {
        [params setObject:sessionId forKey:@"session_id"];
    }
    if (phoneNum) {
        [params setObject:[phoneNum stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"phone_num"];
    }
    if (pasaWord) {
        [params setObject:[pasaWord md5String] forKey:@"password"];
    }
    if (amount) {
        [params setObject:@(amount*100) forKey:@"tran_amount"];
    }
    
    [BaseService BSGet:@"user_transfer_account" parameters:params encrypt:YES needLoading:NO success:^(BaseService *BS) {
        success (BS.success ? YES : NO);
    } failure:^(id error) {
        if (failure && error) {
            failure(error);
        }
    }];
}



@end
