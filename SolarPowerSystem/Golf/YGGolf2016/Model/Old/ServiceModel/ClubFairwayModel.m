//
//  ClubFairwayModel.m
//  Golf
//
//  Created by 黄希望 on 12-9-10.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import "ClubFairwayModel.h"

@implementation ClubFairwayModel
@synthesize fairwayNo = _fairwayNo;
@synthesize fairwayIntro = _fairwayIntro;
@synthesize fairwayPicture = _fairwayPicture;


- (id)initWithDic:(id)data{
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    
    NSDictionary *dic = (NSDictionary *)data;
    if ([dic objectForKey:@"fairway_no"]) {
        self.fairwayNo = [[dic objectForKey:@"fairway_no"] intValue];
    }
    if ([dic objectForKey:@"fairway_intro"]) {
        self.fairwayIntro = [dic objectForKey:@"fairway_intro"];
    }
    if ([dic objectForKey:@"fairway_picture"]) {
        self.fairwayPicture = [dic objectForKey:@"fairway_picture"];
    }
    return self;
}

@end
