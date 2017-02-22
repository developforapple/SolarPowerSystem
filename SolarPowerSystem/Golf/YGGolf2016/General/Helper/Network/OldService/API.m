
//  RemoteService.m
//  Golf
//
//  Created by 廖瀚卿 on 16/2/23.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "API.h"
#import "FCUUID.h"
#import "TTransport.h"
#import "TFramedTransport.h"
#import "TProtocol.h"
#import "TBinaryProtocol.h"
#import "THTTPClient.h"
#import "TCompactProtocol.h"
#import "TNSStreamTransport.h"

@interface API()
@end

@implementation API

static API *_instance = nil;
#pragma mark - 首页改版

/**
 高球头条
 */
- (void)headLineTopListSuccess:(void (^)(HeadLineList *ab))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            HeadLineList *headLineList = [[[API shareInstance] client] headLineTopList:[weakSelf getHeadBean]];
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(headLineList);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}


- (void)headLineListSuccess:(void (^)(HeadLineList *ab))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            HeadLineList *headLineList = [[[API shareInstance] client] headLineList:[weakSelf getHeadBean]];
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(headLineList);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

/**
 教学课程
 */
- (void)teachActivityListSuccess:(void (^)(TeachActivityList *ab))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            TeachActivityList *teachActivityList = [[[API shareInstance] client] teachActivityList:[weakSelf getHeadBean]];
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(teachActivityList);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

/**
 精选商品
 */
- (void)themeCommodityListSuccess:(void (^)(ThemeCommodityList *ab))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            ThemeCommodityList *themeCommodityList = [[[API shareInstance] client] themeCommodityList:[weakSelf getHeadBean]];
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(themeCommodityList);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}
/**
 附近热门球场
 */
- (void)hotCourseListWithLocation:(Location *)location success:(void (^)(HotCourseList *ab))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            HotCourseList *hotCourseList = [[[API shareInstance] client] hotCourseList:[weakSelf getHeadBean] location:location];
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(hotCourseList);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

#pragma amrk - 动态改版
- (void)topicRecomendSuccess:(void (^)(TopicRecommendList *ab))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            TopicRecommendList *topicRecommendList = [[[API shareInstance] client] topicRecommend:[weakSelf getHeadBean]];
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(topicRecommendList);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

- (void)topicRecommendStatueSuccess:(void (^)(AckBean *ab))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            AckBean *bean = [[[API shareInstance] client] topicRecommendStatus:[weakSelf getHeadBean]];
            if (bean.success) {
                [weakSelf.mainQueue addOperationWithBlock:^{
                    if (success) {
                        success(bean);
                    }
                }];
            }else{
                if (failure) {
                    Error *err = [Error new];
                    err.errorMsg = bean.err.errorMsg;
                    err.code = bean.err.code;
                    failure(err);
                }
            }
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

- (void)topicRecommendReqWithText:(NSString *)text  success:(void (^)(AckBean *ab))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            AckBean *bean = [[[API shareInstance] client] topicRecommendReq:[weakSelf getHeadBean] intro:text];
            if (bean.success) {
                [weakSelf.mainQueue addOperationWithBlock:^{
                    if (success) {
                        success(bean);
                    }
                }];
            }else{
                if (failure) {
                    Error *err = [Error new];
                    err.errorMsg = bean.err.errorMsg;
                    err.code = bean.err.code;
                    failure(err);
                }
            }
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

- (void)getTopicRecommendPageSuccess:(void (^)(TopicRecommendPage *ab))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            TopicRecommendPage *topicRecommendPage = [[[API shareInstance] client] getTopicRecommendPage:[weakSelf getHeadBean]];
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(topicRecommendPage);
                }
            }];
            
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

/**
 获取我要上推荐图片
 */
- (void)getTopicRecommendImageSuccess:(void (^)(TopicRecommendImage *ab))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            TopicRecommendImage *topicRecommendPage = [[[API shareInstance] client] getTopicRecommendImage:[weakSelf getHeadBean]];
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(topicRecommendPage);
                }
            }];
            
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

-(void)sendMsg:(SendBean *)sendBean success:(void (^)(AckBean *ab))success failure:(void (^)(Error *))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            AckBean *bean = [[[API shareInstance] client] sendmsg:[weakSelf getHeadBean] sendBean:sendBean];
            if (bean.success) {
                [weakSelf.mainQueue addOperationWithBlock:^{
                    if (success) {
                        success(bean);
                    }
                }];
            }else{
                if (failure) {
                    Error *err = [Error new];
                    err.errorMsg = bean.err.errorMsg;
                    err.code = bean.err.code;
                    failure(err);
                }
            }
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

- (void)imSessionNotifyToMemberId:(NSString *)memberId success:(void (^)(AckBean *ab))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            AckBean *bean = [[[API shareInstance] client] imSessionNotify:[weakSelf getHeadBean] tidname:memberId];
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(bean);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

- (void)timSignAuthWithSuccess:(void (^)(AckBean *ab))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            AckBean *bean = [[[API shareInstance] client] timSignAuth:[weakSelf getHeadBean]];
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(bean);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

- (void)roserSessionsSuccess:(void (^)(RoserSessionList *list))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            RoserSessionList *bean = [[[API shareInstance] client] roserSessions:[weakSelf getHeadBean]];
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(bean);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

- (void)deleteRoserSessionByMemberId:(NSString *)memberId success:(void (^)(AckBean *ab))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            AckBean *bean = [[[API shareInstance] client] deleteRoserSession:[weakSelf getHeadBean] toName:memberId];
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(bean);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

- (void)clearMsgFromSessionByMemberId:(NSString *)memberId success:(void (^)(AckBean *ab))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            AckBean *bean = [[[API shareInstance] client] clearMsgFromSession:[weakSelf getHeadBean] toName:memberId];
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(bean);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}


- (void)publicModeWithFootprintId:(int)footPrintId andPublicMode:(int)publicMode success:(void (^)(id data))success failure:(void (^)(NSException *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            [[[API shareInstance] client] publicMode:[weakSelf getHeadBean] footprintId:footPrintId publicMode:publicMode];
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(nil);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                failure(exception);
            }
        }
    }];
}

- (void)saveCardWithCardId:(int)cardId success:(void (^)(id data))success failure:(void (^)(NSException *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            [[[API shareInstance] client] saveCard:[weakSelf getHeadBean] cardId:cardId];
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(nil);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                failure(exception);
            }
        }
    }];
}

//发布动态
- (void)pubDynamic:(MediaBean *)mb location:(Location *)loc success:(void (^)(id data))success failure:(void (^)(NSException *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            AckBean *bean = [[[API shareInstance] client] pubDynamic:[weakSelf getHeadBean] mb:mb location:loc];
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(bean);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                failure(exception);
            }
        }
    }];
}

//用户卡信息
- (void)finishCardByCardId:(int)cardId success:(void (^)(id data))success failure:(void (^)(NSException *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            [[[API shareInstance] client] finishCard:[weakSelf getHeadBean] cardId:cardId];
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(nil);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                failure(exception);
            }
        }
    }];
}

//已关注的用户 打球月份排名
- (void)monthRank:(NSString *)month success:(void (^)(MonthRank *data))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            MonthRank *hr = [[[API shareInstance] client] monthRank:[weakSelf getHeadBean] month:month];
            
            if (hr.err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkHttpError" object:hr.err];
                });
                if (failure) {
                    failure(hr.err);
                }
                return ;
            }
            
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(hr);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

//已关注的用户 打球历史排名
- (void)historyRankSuccess:(void (^)(HistoryRank *data))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            HistoryRank *hr = [[[API shareInstance] client] historyRank:[weakSelf getHeadBean]];
            
            if (hr.err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkHttpError" object:hr.err];
                });
                if (failure) {
                    failure(hr.err);
                }
                return ;
            }
            
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(hr);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}


//用户卡信息
- (void)cardInfo:(int)cardId toMemberId:(int)memberId success:(void (^)(CardInfo *data))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            CardInfo *cb = [[[API shareInstance] client] cardInfo:[weakSelf getHeadBean] cardId:cardId toMemberid:memberId];
            if (cb.err) {//HttpErroCodeModel
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkHttpError" object:cb.err];
                });
                if (failure) {
                    failure(cb.err);
                }
                return ;
            }
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(cb);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

//我的足迹
- (void)myFootSuccess:(void (^)(id data))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            MyFoots *myFoots = [[[API shareInstance] client] myFoot:[weakSelf getHeadBean]];
            
            if (myFoots.err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkHttpError" object:myFoots.err];
                });
                if (failure) {
                    failure(myFoots.err);
                }
                return ;
            }
            
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(myFoots.footlist);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

- (void)parnerListSuccess:(void (^)(Parners *data))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            Parners *cb = [[[API shareInstance] client] parnerlist:[weakSelf getHeadBean]];
            
            if (cb.err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkHttpError" object:cb.err];
                });
                if (failure) {
                    failure(cb.err);
                }
                return ;
            }
            
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(cb);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}


- (void)courseInfo:(int)courseId success:(void (^)(CourseBean *data))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            CourseBean *cb = [[[API shareInstance] client] courseInfo:[weakSelf getHeadBean] courseId:courseId];
            
            if (cb.err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkHttpError" object:cb.err];
                });
                if (failure) {
                    failure(cb.err);
                }
                return ;
            }
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(cb);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}


- (void)score:(ModifyBean *)mb success:(void (^)(id data))success failure:(void (^)(NSException *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            [[[API shareInstance] client] score:[weakSelf getHeadBean] modifyBean:mb];
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(nil);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                failure(exception);
            }
        }
    }];
}

- (void)allscoreWithCardInfo:(CardInfo *)cardInfo success:(void (^)(AckBean *ack))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            AckBean *ack = [[[API shareInstance] client] allscore:[weakSelf getHeadBean] cardInfo:cardInfo];
            if (ack.err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkHttpError" object:ack.err];
                });
                if (failure) {
                    failure(ack.err);
                }
                return ;
            }
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(ack);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

- (void)setParByModifyBean:(ModifyBean *)mb success:(void (^)(AckBean *data))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            AckBean *ack = [[[API shareInstance] client] setPar:[weakSelf getHeadBean] modifyBean:mb];
            if (ack.err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkHttpError" object:ack.err];
                });
                if (failure) {
                    failure(ack.err);
                }
                return ;
            }
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(ack);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}



- (void)addCard:(Card *)card success:(void (^)(id data))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            UserScore *us = [[[API shareInstance] client] addCard:[weakSelf getHeadBean] cardinfo:card];
            
            if (us.err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkHttpError" object:us.err];
                });
                if (failure) {
                    failure(us.err);
                }
                return ;
            }
            
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(us);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

//附近球场 // lyf 加
- (void)nearByCourse:(Location *)location success:(void (^)(id data))success failure:(void (^)(Error *error))failure {
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            CourseBean *us = [[[API shareInstance] client] nearByCourseInfo:[weakSelf getHeadBean] location:location];
            
            if (us.err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkHttpError" object:us.err];
                });
                if (failure) {
                    failure(us.err);
                }
                return ;
            }
            
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(us);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

//选择球场 // lyf 加
- (void)selectCourse:(Location *)location page:(PageBean *)pageBean success:(void (^)(id data))success failure:(void (^)(Error *error))failure {
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            CourseSelect *us = [[[API shareInstance] client] selectCourse:[weakSelf getHeadBean] location:location page:(PageBean *)pageBean];
            
            if (us.err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkHttpError" object:us.err];
                });
                if (failure) {
                    failure(us.err);
                }
                return ;
            }
            
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(us);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

//自定义球场列表 // lyf 加
- (void)privateCoursesSuccess:(void (^)(id data))success failure:(void (^)(Error *error))failure {
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            PrivateCourseList *us = [[[API shareInstance] client] privateCourses:[weakSelf getHeadBean]];
            
            if (us.err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkHttpError" object:us.err];
                });
                if (failure) {
                    failure(us.err);
                }
                return ;
            }
            
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(us);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

// 删除自定义球场
- (void)delPrivateCourseWithCourseID:(int)courseID success:(void (^)(AckBean *data))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            AckBean *bean = [[[API shareInstance] client] delPrivateCourse:[weakSelf getHeadBean] courseId:courseID];
            
            if (bean.err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkHttpError" object:bean.err];
                });
                if (failure) {
                    failure(bean.err);
                }
                return ;
            }
            
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(bean);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

//编辑足迹详情
- (void)modifyFootDetail:(MediaBean *)mb location:(Location *)location success:(void (^)(id data))success failure:(void (^)(NSException *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            [[[API shareInstance] client] modifyFootDetail:[weakSelf getHeadBean] mb:mb location:location];
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(nil);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                failure(exception);
            }
        }
    }];
}

//标杆或净杆  scoreType：0标杆 1净杆
- (void)scoreTypeByCardId:(int)cardId andScoreTypeId:(int)scoreType success:(void (^)(id data))success failure:(void (^)(NSException *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            [[[API shareInstance] client] scoreType:[weakSelf getHeadBean] cardId:cardId scoretype:scoreType];
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(nil);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                failure(exception);
            }
        }
    }];
}

//设备是否已存在
- (void)deviceExistSuccess:(void (^)(id data))success failure:(void (^)(NSException *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            int list = [[[API shareInstance] client] deviceExist:[weakSelf getHeadBean]];
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(@(list));
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                failure(exception);
            }
        }
    }];
    
}

//上传设备标识
-(void)deviceUpSuccess:(void (^)(id))success failure:(void (^)(NSException *))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            [[[API shareInstance] client] deviceUp:[weakSelf getHeadBean]];
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(nil);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                failure(exception);
            }
        }
    }];
}

//足迹详情
- (void)footprintDetailWithFootprintID:(int)footPrintId success:(void (^)(id data))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            FootDetailBean *footDetailBean = [[[API shareInstance] client] footprintDetail:[weakSelf getHeadBean] footprintId:footPrintId];
            if (footDetailBean.err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkHttpError" object:footDetailBean.err];
                });
                if (failure) {
                    failure(footDetailBean.err);
                }
                return ;
            }
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(footDetailBean);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

- (void)cgitAdWithAdsite:(NSString *)adsite success:(void (^)(id data))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            AdBean *adBean = [[[API shareInstance] client] cgitAd:[weakSelf getHeadBean] ads:adsite];
            if (adBean.err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkHttpError" object:adBean.err];
                });
                if (failure) {
                    failure(adBean.err);
                }
                return ;
            }
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(adBean);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

//添加足迹
- (void)footprintAdd:(MediaBean *)mb location:(Location *)location success:(void (^)(id data))success failure:(void (^)(NSException *error))failure {
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            FootDetailBean *bean = [[[API shareInstance] client] footprintAdd:[weakSelf getHeadBean] mb:mb location:location];
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(bean);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                failure(exception);
            }
        }
    }];
}

//足迹列表分组，暂时不用
- (void)footprintLisWithFootReq:(FootReq *)footReq Success:(void (^)(MyFoots *data))success failure:(void (^)(NSException *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            MyFoots *myfoots = [[[API shareInstance] client] footprintList:[weakSelf getHeadBean] fr:footReq];
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(myfoots);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                failure(exception);
            }
        }
    }];
}
#pragma mark 约球

- (void)yaoWantWithLocation:(Location *)location success:(void (^)(AckBean *data))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            AckBean *bean = [[[API shareInstance] client] yaoWant:[weakSelf getHeadBean] location:location];
            
            if (bean.err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkHttpError" object:bean.err];
                });
                if (failure) {
                    failure(bean.err);
                }
                return ;
            }
            
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(bean);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

//判断是否已经存在位置信息 // lyf 加
- (void)yaoExistSuccess:(void (^)(id data))success failure:(void (^)(Error *error))failure {
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            AckBean *us = [[[API shareInstance] client] yaoExist:[weakSelf getHeadBean]];
            
            if (us.err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkHttpError" object:us.err];
                });
                if (failure) {
                    failure(us.err);
                }
                return ;
            }
            
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(us);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}


//我收到的约球
-(void)yaoBallRecvList:(PageBean *)pages yaoId:(int)yaoID unRead:(int)unRead success:(void (^)(id data))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            YaoBallRecvList *yaoBallRecvList = [[[API shareInstance] client] yaoRecv:[weakSelf getHeadBean] page:pages yaoid:yaoID unRead:unRead];
            if (yaoBallRecvList.err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkHttpError" object:yaoBallRecvList.err];
                });
                if (failure) {
                    failure(yaoBallRecvList.err);
                }
                return ;
            }
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(yaoBallRecvList);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

//我发起的约球
-(void)yaoBallPublist:(PageBean *)page yaoID:(int)yaoId unRead:(int)unRead success:(void (^)(id data))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            YaoBallPublist *yaoBallPubList = [[[API shareInstance] client] yaoPub:[weakSelf getHeadBean] page:page yaoid:yaoId unRead:unRead];
            if (yaoBallPubList.err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkHttpError" object:yaoBallPubList.err];
                });
                if (failure) {
                    failure(yaoBallPubList.err);
                }
                return ;
            }
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(yaoBallPubList);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

//关闭约球
-(void)yaoCloseById:(int)yaoId success:(void (^)(AckBean *data))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            AckBean *ackBean = [[[API shareInstance] client] yaoClose:[weakSelf getHeadBean] yaoid:yaoId];
            if (ackBean.err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkHttpError" object:ackBean.err];
                });
                if (failure) {
                    failure(ackBean.err);
                }
                return ;
            }
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(ackBean);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

//删除约球 dtype 1发布的约球，2收到的约球
-(void)yaoDeleteById:(int)yaoId dType:(int)dType success:(void (^)(AckBean *))success failure:(void (^)(Error *))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            AckBean *ackBean = [[[API shareInstance] client] yaoDelete:[weakSelf getHeadBean] yaoid:yaoId dType:dType];
            if (ackBean.err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkHttpError" object:ackBean.err];
                });
                if (failure) {
                    failure(ackBean.err);
                }
                return ;
            }
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(ackBean);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
    
}

- (void)yaoType:(int)type success:(void (^)(AckBean *data))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            AckBean *bean = [[[API shareInstance] client] yaoType:[weakSelf getHeadBean] type:type];
            
            if (bean.err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkHttpError" object:bean.err];
                });
                if (failure) {
                    failure(bean.err);
                }
                return ;
            }
            
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(bean);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

- (void)yaoBallListByPage:(PageBean *)pageBean location:location success:(void (^)(YaoBallList *data))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            YaoBallList *list = [[[API shareInstance] client] yaoBallList:[weakSelf getHeadBean] location:location page:pageBean];
            
            if (list.err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkHttpError" object:list.err];
                });
                if (failure) {
                    failure(list.err);
                }
                return ;
            }
            
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(list);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}


//发布约球 // lyf 加
- (void)yaoBall:(Location *)location yaoBallContent:(YaoBallContent *)ybc success:(void (^)(id data))success failure:(void (^)(Error *error))failure {
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            AckBean *us = [[[API shareInstance] client] yaoBall:[weakSelf getHeadBean]  location:location ybc:ybc];
            
            if (us.err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkHttpError" object:us.err];
                });
                if (failure) {
                    failure(us.err);
                }
                return ;
            }
            
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(us);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

//当前约球信息 // lyf 加
- (void)yaoCurrentSuccess:(void (^)(id data))success failure:(void (^)(Error *error))failure {
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            YaoBallCurrent *us = [[[API shareInstance] client] yaoCurrent:[weakSelf getHeadBean]];
            
            if (us.err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkHttpError" object:us.err];
                });
                if (failure) {
                    failure(us.err);
                }
                return ;
            }
            
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(us);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

//加入约球 // lyf 加
- (void)yaoJoinWithId:(int)yaoId success:(void (^)(id data))success failure:(void (^)(Error *error))failure {
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            AckBean *us = [[[API shareInstance] client] yaoJoin:[weakSelf getHeadBean] yaoid:yaoId];
            
            if (us.err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkHttpError" object:us.err];
                });
                if (failure) {
                    failure(us.err);
                }
                return ;
            }
            
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(us);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

//约球信息 // lyf 加
- (void)yaoInfoWithId:(int)yaoId success:(void (^)(id data))success failure:(void (^)(Error *error))failure {
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            YaoBallRecvBean *us = [[[API shareInstance] client] yaoInfo:[weakSelf getHeadBean] yaoid:yaoId];
            
            if (us.err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkHttpError" object:us.err];
                });
                if (failure) {
                    failure(us.err);
                }
                return ;
            }
            
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(us);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

//发布后随机显示的照片 lyf 加
- (void)yaoImageSuccess:(void (^)(id data))success failure:(void (^)(NSException *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            ImageBean *list = [[[API shareInstance] client] yaoImage:[weakSelf getHeadBean]];
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(list);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                failure(exception);
            }
        }
    }];
}

//开/关约球推送
-(void)yaoNotifyWithOnoff:(int)onOff success:(void (^)(AckBean *data))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            AckBean *us = [[[API shareInstance] client] yaoNotify:[weakSelf getHeadBean] onOff:onOff];
            if (us.err) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkHttpError" object:us.err];
                });
                if (failure) {
                    failure(us.err);
                }
                return ;
            }
            
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(us);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

//约球推送未读消息获取
-(void)unReadPushMsgWithType:(int)type success:(void (^)(AckBean *data))success failure:(void (^)(Error *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].asyncQueue addOperationWithBlock:^{
        @try {
            AckBean *ackBean = [[[API shareInstance] client] unReadPushMsg:[weakSelf getHeadBean] type:type];
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(ackBean);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}

#pragma mark 接口统计
-(void)statisticalWithBuriedpoint:(int)buriedpoint Success:(void (^)(id data))success failure:(void (^)(NSException *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].statQueue addOperationWithBlock:^{
        @try {
            NSLog(@"统计埋点：%d",buriedpoint);
            [[[API shareInstance] client] statistical:[weakSelf getHeadBean] buriedpoint:buriedpoint];
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(nil);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                failure(exception);
            }
        }
    }];
}

#pragma mark --首页banner和精选动态埋点
/**
 *  首页banner和精选动态埋点
 *
 *  @param buriedpoint 首页传18 精选传19
 *  @param objectID
 *  @param success
 *  @param failure
 */
- (void)statisticalNewWithBuriedpoint:(int)buriedpoint objectID:(NSString *)objectID Success:(void (^)(id data))success failure:(void (^)(NSException *error))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].statQueue addOperationWithBlock:^{
        @try {
            NSLog(@"统计埋点：%d",buriedpoint);
            [[[API shareInstance] client] statisticalNew:[weakSelf getHeadBean] buriedpoint:buriedpoint objectId:objectID];
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(nil);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                failure(exception);
            }
        }
    }];
}

-(void)uploadLogFileBean:(LogFileBean *)lfb success:(void (^)(id))success failure:(void (^)(Error *))failure{
     __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].statQueue addOperationWithBlock:^{
        @try {
            AckBean *ack = [[[API shareInstance] client] uploadLogFiles:[weakSelf getHeadBean] logFileBean:lfb];
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(ack);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}


#pragma mark -

- (HeadBean *)getHeadBean
{
    static NSString *deviceText;
    static NSString *curVersion;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIDevice *device = [UIDevice currentDevice];
        NSString *name = device.name;       //获取设备所有者的名称
        NSString *model = device.model;      //获取设备的类别
        NSString *type = device.localizedModel; //获取本地化版本
        NSString *systemName = device.systemName;   //获取当前运行的系统
        NSString *systemVersion = device.systemVersion;//获取当前系统的版本
        deviceText = [NSString stringWithFormat:@"%@|%@|%@|%@|%@",model,systemName,systemVersion,type,name];
        curVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];  //获取当前的app版本
    });
    
    HeadBean *hb = [HeadBean new];
    
    hb.token = [FCUUID uuidForDevice];
    hb.device = deviceText;
    hb.platform = 2;
    hb.version = curVersion;
    hb.sessionId = [LoginManager sharedManager].session.sessionId;
    
    NSString *input = [NSString stringWithFormat:@"%llu",(unsigned long long)[[NSDate date] timeIntervalSince1970]*1000];
    hb.input = input;
    hb.div = [[NSString stringWithFormat:@"%@password@cgit.com.cn",input] md5String];
    
//    static HeadBean *hb;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        hb = [[HeadBean alloc] init];
//        
//        UIDevice *device = [[UIDevice alloc] init];
//        NSString *name = device.name;       //获取设备所有者的名称
//        NSString *model = device.model;      //获取设备的类别
//        NSString *type = device.localizedModel; //获取本地化版本
//        NSString *systemName = device.systemName;   //获取当前运行的系统
//        NSString *systemVersion = device.systemVersion;//获取当前系统的版本
//        
//        hb.device = [NSString stringWithFormat:@"%@|%@|%@|%@|%@",model,systemName,systemVersion,type,name];
//        
//        NSString *currVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];  //获取当前的app版本
//        if (currVersion.length > 0) {
//            [hb setVersion:currVersion];
//        }
//        
//        hb.platform = 2;
//        hb.token = [FCUUID uuidForDevice];
//    });
//    
//    hb.sessionId = [LoginManager sharedManager].session.sessionId;
//    NSString *input = [NSString stringWithFormat:@"%llu",(unsigned long long)[[NSDate date] timeIntervalSince1970]*1000];
//    @try {
//        if (input.length > 0) {
//            hb.input = input;
//            hb.div = [[NSString stringWithFormat:@"%@password@cgit.com.cn",input] md5String];
//        }
//    } @catch (NSException *exception) {
//        NSLog(@"fuck:%@",exception);
//    } @finally {
//    }
//    
    
    return hb;
}


- (IServicesClient *)client {
    //    return [[IServicesClient alloc] initWithProtocol:[[TBinaryProtocol alloc] initWithTransport:[[THTTPClient alloc] initWithURL:[NSURL URLWithString:API_THRIFT]]]];
    return [[IServicesClient alloc] initWithProtocol:[[TCompactProtocol alloc] initWithTransport:[[THTTPClient alloc] initWithURL:[NSURL URLWithString:API_THRIFT]]]];//压缩协议
}

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
        _instance.asyncQueue = [[NSOperationQueue alloc] init];
        [_instance.asyncQueue setMaxConcurrentOperationCount:5];    // serial
        _instance.mainQueue = [NSOperationQueue mainQueue];         // for GUI, DB
        
        _instance.statQueue = [NSOperationQueue new];
        [_instance.statQueue setMaxConcurrentOperationCount:10];
        if (iOS8) {
            _instance.statQueue.qualityOfService = NSQualityOfServiceBackground;//降低优先级
        }
    });
    
    return _instance ;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [API shareInstance] ;
}

- (id)copyWithZone:(struct _NSZone *)zone {
    return [API shareInstance] ;
}

@end

@implementation API (binDingPhone)//手机号绑定
- (void)bindeviceWithBindBean:(BindBean *)bb Success:(void (^)(AckBean *data))success failure:(void (^)(Error *err))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].statQueue addOperationWithBlock:^{
        @try {
            AckBean *ackBean = [[[API shareInstance] client] bindevice:[weakSelf getHeadBean] bb:bb];
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(ackBean);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}
@end

@implementation API (unbind)//微信解绑
- (void)unbindWithBindType:(int) bindType success:(void (^)(AckBean *data))success failure:(void (^)(Error *err))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].statQueue addOperationWithBlock:^{
        @try {
            AckBean *ackBean = [[[API shareInstance] client] unbind:[weakSelf getHeadBean] bindType:bindType];
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(ackBean);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}
@end

@implementation API (guideAlert)//APP好评弹窗上传服务器，已经弹过了
- (void)guideAlertSuccess:(void (^)(AckBean *data))success failure:(void (^)(Error *err))failure{
    __unsafe_unretained API *weakSelf = self;
    [[API shareInstance].statQueue addOperationWithBlock:^{
        @try {
            AckBean *ackBean = [[[API shareInstance] client] guideAlert:[weakSelf getHeadBean]];
            [weakSelf.mainQueue addOperationWithBlock:^{
                if (success) {
                    success(ackBean);
                }
            }];
        }
        @catch (NSException *exception) {
            if (failure) {
                Error *err = [Error new];
                err.errorMsg = exception.reason;
                failure(err);
            }
        }
    }];
}
@end
