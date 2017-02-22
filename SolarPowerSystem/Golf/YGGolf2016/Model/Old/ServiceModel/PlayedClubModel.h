//
//  PlayedClubModel.h
//  Golf
//
//  Created by 黄希望 on 14-9-19.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlayedClubModel : NSObject<NSCopying>

@property (nonatomic) int cityId;
@property (nonatomic,copy) NSString *cityName;
@property (nonatomic) int clubId;
@property (nonatomic,copy) NSString *clubName;
@property (nonatomic,copy) NSString *clubImage;
@property (nonatomic) double longitude;
@property (nonatomic) double latitude;
@property (nonatomic) BOOL selected;
@property (nonatomic,copy) NSString *teeDate;
@property (nonatomic,copy) NSString *footteedate;
@property(nonatomic,copy) NSString *footids;
@property(nonatomic,assign) int playedNum;
@property(nonatomic,assign) int cardid;
@property(nonatomic,assign) int cardstatus;
@property(nonatomic,assign) int playFlag;
@property (nonatomic,assign) int publicMode;//是否是仅自己可见，0表示仅自己可见，1表示公开
- (id)initWithDic:(id)data;

@end

@interface PlayedProvinceModel : NSObject

@property (nonatomic) int provinceId;
@property (nonatomic,copy) NSString *provinceName;
@property (nonatomic) double longitude;
@property (nonatomic) double latitude;
@property (nonatomic,strong) NSMutableArray *playedClubList;
@property (nonatomic,strong) NSMutableArray *waitRecordList;

- (id)initWithDic:(id)data;

@end

@interface UserPlayedClubListModel : NSObject

@property (nonatomic) int playCount;
@property (nonatomic) int bookCount;
@property (nonatomic) int footprintCount;
@property (nonatomic,copy) NSString *overRate;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,strong) NSMutableArray *playedProvinceList;
@property (nonatomic,strong) NSMutableArray *waitRecordList;

- (id)initWithDic:(id)data;

@end
