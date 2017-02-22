//
//  ActivityModel.m
//  Golf
//
//  Created by user on 12-11-30.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import "ActivityModel.h"
#import <YYModel/YYModel.h>

@implementation ActivityModel

YYModelDefaultCode

- (id)initWithDic:(id)data{
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    
    NSDictionary *dic = (NSDictionary *)data;
    if ([dic objectForKey:@"activity_id"]) {
        self.activityId = [[dic objectForKey:@"activity_id"] intValue];
    }
    if ([dic objectForKey:@"action_id"]) {
        self.actionId = [[dic objectForKey:@"action_id"] intValue];
    }
    if ([dic objectForKey:@"activity_name"]) {
        self.activityName = [dic objectForKey:@"activity_name"];
    }
    if ([dic objectForKey:@"activity_picture"]) {
        self.activityPicture = [dic objectForKey:@"activity_picture"];
    }
    if ([dic objectForKey:@"activity_page"]) {
        self.activityPage = [dic objectForKey:@"activity_page"];
    }
    if ([dic objectForKey:@"activity_action"]) {
        self.activityAction = [[dic objectForKey:@"activity_action"] intValue];
    }
    if ([dic objectForKey:@"activity_intro"]) {
        self.activityIntro = [dic objectForKey:@"activity_intro"];
    }
    if ([dic objectForKey:@"action_date"]) {
        self.actionDate = [dic objectForKey:@"action_date"];
    }
    if ([dic objectForKey:@"action_time"]) {
        self.actionTime = [dic objectForKey:@"action_time"];
    }
    if ([dic objectForKey:@"begin_date"]) {
        self.beginDate = [dic objectForKey:@"begin_date"];
    }
    if ([dic objectForKey:@"end_date"]) {
        self.endDate = [dic objectForKey:@"end_date"];
    }
    if ([dic objectForKey:@"area_shape"]) {
        self.areaShape = [[dic objectForKey:@"area_shape"] intValue];
    }
    if ([dic objectForKey:@"data_type"]) {
        self.dataType = [dic objectForKey:@"data_type"];
    }else{
        self.dataType = @"";
    }
    if ([dic objectForKey:@"data_id"]) {
        self.dataId = [[dic objectForKey:@"data_id"] intValue];
    }
    if ([dic objectForKey:@"sub_type"]) {
        self.subType = [[dic objectForKey:@"sub_type"] intValue];
    }
    if ([dic objectForKey:@"combine_mode"]) {
        self.combineMode = [[dic objectForKey:@"combine_mode"] intValue];
    }
    if ([dic objectForKey:@"data_extra"]) {
        self.dataExtra = [dic objectForKey:@"data_extra"];
    }else{
        self.dataExtra = @"";
    }
    return self;
}

@end
