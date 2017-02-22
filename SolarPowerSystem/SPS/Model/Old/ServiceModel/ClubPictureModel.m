//
//  ClubPictureModel.m
//  Golf
//
//  Created by 黄希望 on 12-9-10.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import "ClubPictureModel.h"

@implementation ClubPictureModel
@synthesize ImgAddress = _ImgAddress;


- (id)initWithDic:(id)data{
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }

    NSDictionary *dic = (NSDictionary *)data;
    if ([dic objectForKey:@"pic_url"]) {
        self.ImgAddress = [dic objectForKey:@"pic_url"];
    }
    return self;
}

@end
