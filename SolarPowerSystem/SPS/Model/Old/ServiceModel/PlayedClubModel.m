//
//  PlayedClubModel.m
//  Golf
//
//  Created by 黄希望 on 14-9-19.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "PlayedClubModel.h"

@implementation PlayedClubModel

@synthesize cityId,cityName,clubId,clubName,clubImage,selected,longitude,latitude,footids,playedNum,cardid,cardstatus,teeDate,footteedate,playFlag,publicMode;


- (id)copyWithZone:(NSZone *)zone {
    PlayedClubModel *model = [[PlayedClubModel allocWithZone:zone] init];
    model.cityId = self.cityId;
    model.cityName = self.cityName;
    model.latitude = self.latitude;
    model.longitude = self.longitude;
    model.clubId = self.clubId;
    model.clubImage = self.clubImage;
    model.clubName = self.clubName;
    model.selected = self.selected;
    model.playedNum = self.playedNum;
    model.footids = self.footids;
    model.cardid = self.cardid;
    model.cardstatus = self.cardstatus;
    model.footteedate = self.footteedate;
    model.teeDate = self.teeDate;
    model.playFlag = self.playFlag;
    model.publicMode = self.publicMode;
    return model;
}

- (id)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    
    NSDictionary *dic = (NSDictionary *)data;
    if ([dic objectForKey:@"city_id"]) {
        self.cityId = [[dic objectForKey:@"city_id"] intValue];
    }
    if ([dic objectForKey:@"city_name"]) {
        self.cityName = [dic objectForKey:@"city_name"];
    }
    if ([dic objectForKey:@"club_id"]) {
        self.clubId = [[dic objectForKey:@"club_id"] intValue];
    }
    if ([dic objectForKey:@"club_name"]) {
        self.clubName = [dic objectForKey:@"club_name"];
    }
    if ([dic objectForKey:@"club_image"]) {
        self.clubImage = [dic objectForKey:@"club_image"];
    }
    if ([dic objectForKey:@"longitude"]) {
        self.longitude = [[dic objectForKey:@"longitude"] doubleValue];
    }
    if ([dic objectForKey:@"latitude"]) {
        self.latitude = [[dic objectForKey:@"latitude"] doubleValue];
    }
    if ([dic objectForKey:@"tee_date"]) {
        self.teeDate = [dic objectForKey:@"tee_date"];
    }
    if ([dic objectForKey:@"footids"]) {
        self.footids = [dic objectForKey:@"footids"];
    }
    if ([dic objectForKey:@"played_num"]) {
        self.playedNum = [[dic objectForKey:@"played_num"] intValue];
    }
    if ([dic objectForKey:@"cardid"]) {
        self.cardid = [[dic objectForKey:@"cardid"] intValue];
    }
    if ([dic objectForKey:@"cardstatus"]) {
        self.cardstatus = [[dic objectForKey:@"cardstatus"] intValue];
    }
    if ([dic objectForKey:@"foot_tee_date"]) {
        self.footteedate = [dic objectForKey:@"foot_tee_date"];
    }
    if ([dic objectForKey:@"play_flag"]) {
        self.playFlag = [[dic objectForKey:@"play_flag"] intValue];
    }
    if ([dic objectForKey:@"public_mode"]) {
        self.publicMode = [[dic objectForKey:@"public_mode"] intValue];
    }
    return self;
}

@end

@implementation PlayedProvinceModel
@synthesize provinceId;
@synthesize provinceName;
@synthesize longitude;
@synthesize latitude;
@synthesize playedClubList;


- (id)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    
    NSDictionary *dic = (NSDictionary *)data;
    if ([dic objectForKey:@"province_id"]) {
        self.provinceId = [[dic objectForKey:@"province_id"] intValue];
    }
    if ([dic objectForKey:@"province_name"]) {
        self.provinceName = [dic objectForKey:@"province_name"];
    }
    
    if ([dic objectForKey:@"longitude"]) {
        self.longitude = [[dic objectForKey:@"longitude"] doubleValue];
    }
    if ([dic objectForKey:@"latitude"]) {
        self.latitude = [[dic objectForKey:@"latitude"] doubleValue];
    }
    if ([dic objectForKey:@"club_list"]) {
        self.playedClubList = [NSMutableArray array];
        self.waitRecordList = [NSMutableArray array];
        NSArray *array = [dic objectForKey:@"club_list"];
        for ( NSDictionary *obj in array) {
            PlayedClubModel *model = [[PlayedClubModel alloc] initWithDic:obj];
            if (model.teeDate.length>0) {
                [self.waitRecordList addObject:model];
            }
            [self.playedClubList addObject:model];
        }
    }
    return self;
}

@end


@implementation UserPlayedClubListModel

@synthesize title, playCount, overRate, playedProvinceList;


- (id)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    
    NSDictionary *dic = (NSDictionary *)data;
    if ([dic objectForKey:@"footprint_count"]) {
        self.footprintCount = [[dic objectForKey:@"footprint_count"] intValue];
    }
    if ([dic objectForKey:@"play_count"]) {
        self.playCount = [[dic objectForKey:@"play_count"] intValue];
    }
    if ([dic objectForKey:@"book_count"]) {
        self.bookCount = [[dic objectForKey:@"book_count"] intValue];
    }
    if ([dic objectForKey:@"over_rate"]) {
        self.overRate = [dic objectForKey:@"over_rate"];
    }
    if ([dic objectForKey:@"title"]) {
        self.title = [dic objectForKey:@"title"];
    }
    if ([dic objectForKey:@"play_list"]) {
        self.playedProvinceList = [NSMutableArray array];
        self.waitRecordList = [NSMutableArray array];
        NSArray *array = [dic objectForKey:@"play_list"];
        for ( NSDictionary *obj in array) {
            PlayedProvinceModel *model = [[PlayedProvinceModel alloc] initWithDic:obj];
            [self.playedProvinceList addObject:model];
            [self.waitRecordList addObjectsFromArray:model.waitRecordList];
        }
    }
    return self;
}

@end
