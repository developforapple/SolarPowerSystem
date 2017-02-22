//
//  YGStatistics.h
//  Golf
//
//  Created by bo wang on 2016/11/25.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#ifndef YGStatistics_h
#define YGStatistics_h

#import <UMMobClick/MobClick.h>
#import "BaiduMobStat.h"

// 埋点
#define YGPostBuriedPoint(_p_) [[API shareInstance] statisticalWithBuriedpoint:(int)(_p_) Success:nil failure:nil];
// 百度和友盟统计
#define YGRecordEvent(_token_,_label_) \
{\
    NSString *t = _token_;\
    if (t.length != 0){\
        NSString *l = _label_;\
        [MobClick event:t label:l?:t];\
        [[BaiduMobStat defaultStat] logEvent:t eventLabel:l?:t];\
    }\
}

#pragma mark - 球场

typedef NS_ENUM(NSUInteger, YGCoursePoint) {
    YGCoursePointSearchList = 73, //搜索列表
    YGCoursePointCourse = 74,     //球场主页
    YGCoursePointCourseInfo = 75, //球场资料页
    
    
    YGTeachPointCoachList = 78,  //教练列表
    YGTeachPointSchoolList = 79, //学院列表
    YGTeachPointCoachDetail = 80, //教练详情页
    YGTeachPointSchooldDetail = 81, //学院详情页
    YGTeachPointH5Lessons = 82, //学院首页的H5课程介绍
    
    
    YGFeedPointList = 84,           //动态列表页
    YGFeedPointlist_Course = 85,    //球场的动态列表页
    
    
    YGUserProfilePoint_Home = 86, //个人主页
    YGUserProfilePoint_ConversationList = 87, //聊天会话列表
    YGUserProfilePoint_Chat = 88,           //聊天消息
    
    
    YGYueqiuPoint_Home = 89,    //约球首页
    YGYueqiuPoint_Detail = 90,  //约球详情
};


#endif /* YGStatistics_h */
