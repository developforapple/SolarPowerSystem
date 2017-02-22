//
//  PackageDetailModel.m
//  Golf
//
//  Created by user on 12-12-14.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import "PackageDetailModel.h"

@implementation PackageDetailModel
@synthesize packagePicture = _packagePicture;
@synthesize tourNote = _tourNote;
@synthesize priceInclude = _priceInclude;
@synthesize priceExclude = _priceExclude;
@synthesize description = _description;
@synthesize cityId = _cityId;
@synthesize clubList = _clubList;
@synthesize specList = _specList;
@synthesize maxPrice = _maxPrice;
@synthesize minPrice = _minPrice;
@synthesize bookConfirm = _bookConfirm;
@synthesize linkPhone = _linkPhone;
@synthesize payType = _payType;
@synthesize giveYunbi = _giveYunbi;


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
    if ([dic objectForKey:@"min_price"]) {
        self.minPrice = [[dic objectForKey:@"min_price"] intValue]/100;
    }
    if ([dic objectForKey:@"max_price"]) {
        self.maxPrice = [[dic objectForKey:@"max_price"] intValue]/100;
    }
    if ([dic objectForKey:@"prepay_amount"]) {
        self.prepayAmount = [[dic objectForKey:@"prepay_amount"] intValue]/100;
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
    if ([dic objectForKey:@"link_phone"]) {
        self.linkPhone = [dic objectForKey:@"link_phone"];
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
    if ([dic objectForKey:@"package_picture"]) {
        self.packagePicture = [dic objectForKey:@"package_picture"];
    }
    if ([dic objectForKey:@"tour_note"]) {
        self.tourNote = [dic objectForKey:@"tour_note"];
    }
    if ([dic objectForKey:@"price_include"]) {
        self.priceInclude = [dic objectForKey:@"price_include"];
    }
    if ([dic objectForKey:@"price_exclude"]) {
        self.priceExclude = [dic objectForKey:@"price_exclude"];
    }
    if ([dic objectForKey:@"description"]) {
        self.description = [dic objectForKey:@"description"];
    }
    if ([dic objectForKey:@"city_id"]) {
        self.cityId = [[dic objectForKey:@"city_id"] intValue];
    }
    if ([dic objectForKey:@"book_confirm"]) {
        self.bookConfirm = [[dic objectForKey:@"book_confirm"] intValue];
    }
    if ([dic objectForKey:@"club_list"]) {
        self.clubList = [dic objectForKey:@"club_list"];
    }
    if ([dic objectForKey:@"spec_list"]) {
        self.specList = [dic objectForKey:@"spec_list"];
    }
    if ([dic objectForKey:@"pay_type"]) {
        self.payType = [[dic objectForKey:@"pay_type"] intValue];
    } else {
        self.payType = PayTypeOnline;
    }
    if ([dic objectForKey:@"give_yunbi"]) {
        self.giveYunbi = [[dic objectForKey:@"give_yunbi"] intValue]/100;
    }
    return self;
}

@end
