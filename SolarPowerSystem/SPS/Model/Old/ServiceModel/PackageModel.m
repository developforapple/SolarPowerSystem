//
//  PackageModel.m
//  Golf
//
//  Created by user on 12-12-13.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import "PackageModel.h"

@implementation PackageModel
@synthesize clubId = _clubId;
@synthesize packageId = _packageId;
@synthesize agentId = _agentId;
@synthesize packageName = _packageName;
@synthesize dayNum = _dayNum;
@synthesize beginDate = _beginDate;
@synthesize endDate = _endDate;
@synthesize currentPrice = _currentPrice;
@synthesize packageLogo = _packageLogo;
@synthesize agentName = _agentName;
@synthesize index = _index;
@synthesize imageIcon = _imageIcon;


- (id)initWithDic:(id)data{
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    
    NSDictionary *dic = (NSDictionary *)data;
    if ([dic objectForKey:@"club_id"]) {
        self.clubId = [[dic objectForKey:@"club_id"] intValue];
    }
    if ([dic objectForKey:@"day_num"]) {
        self.dayNum = [[dic objectForKey:@"day_num"] intValue];
    }
    if ([dic objectForKey:@"package_id"]) {
        self.packageId = [[dic objectForKey:@"package_id"] intValue];
    }
    if ([dic objectForKey:@"agent_id"]) {
        self.agentId = [[dic objectForKey:@"agent_id"] intValue];
    }
    if ([dic objectForKey:@"current_price"]) {
        self.currentPrice = [[dic objectForKey:@"current_price"] intValue]/100;
    }
    if ([dic objectForKey:@"package_name"]) {
        self.packageName = [dic objectForKey:@"package_name"];
    }
    if ([dic objectForKey:@"agent_name"]) {
        self.agentName = [dic objectForKey:@"agent_name"];
    }
    if ([dic objectForKey:@"package_logo"]) {
        self.packageLogo = [dic objectForKey:@"package_logo"];
    }
    if ([dic objectForKey:@"begin_date"]) {
        self.beginDate = [dic objectForKey:@"begin_date"];
    }
    if ([dic objectForKey:@"end_date"]) {
        self.endDate = [dic objectForKey:@"end_date"];
    }
    if ([dic objectForKey:@"give_yunbi"]) {
        self.giveYunbi = [[dic objectForKey:@"give_yunbi"] intValue]/100;
    }
    return self;
}

@end
