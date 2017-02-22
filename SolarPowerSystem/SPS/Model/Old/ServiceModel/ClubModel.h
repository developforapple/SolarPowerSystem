//
//  ClubModel.h
//  Golf
//
//  Created by 青 叶 on 11-11-26.
//  Copyright (c) 2011年 大展. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TopicModel.h"

@interface ClubModel : NSObject {
    /**球会ID**/
    int _clubId;
    /**城市ID**/
    int _cityId;
    /**球会名称**/
    NSString *_clubName;
    /**球会简称**/
    NSString *_shortName;
    /**球会图片**/
    NSString *_clubImage;
    /**球会大图**/
    NSString *_clubPhoto;
    /**距离**/
    NSString *_remote;
    /**经度**/
    float _longitude;
    /**纬度**/
    float _latitude;
    /**球场介绍**/
    NSString *_introduction;
    /**球场通知**/
    NSString *_publicNotice;
    /**球场地址**/
    NSString *_address;
    /**最低价格**/
    int _minPrice;
    
    int _timeMinPrice;
    
    /**最低时段价**/
    int _minTimePrice;
    /**最低套餐价**/
    int _minPackagePrice;
    
    /**起始时段**/
    NSString *_startTime;
    /**结束时段**/
    NSString *_endTime;
    
    NSString *_shortAddress;
    int _clubHoleNum;
    /**返云币**/
    int _giveYunbi;
    
    /**联系电话**/
    NSString *_phone;
    //是否官方直通
    int _isOfficial; 
    /**交通位置**/
    NSString *_trafficGuide;
    /**建立时间**/
    NSString *_buildDate;
    /**设计师**/
    NSString *_designer;
    /**球场类型**/
    NSString *_courseKind;
    /**球场数据**/
    NSString *_courseData;
    /**球道长度**/
    NSString *_fairwayLength;
    /**球道草种**/
    NSString *_fairwayGrass;
    /**果岭草种**/
    NSString *_greenGrass;
    /**球场面积**/
    NSString *_courseArea;
    int _payType;
    NSString *_teeDate;
    NSString *_fairwayIntro;
    NSString *_clubFacility;
    NSString *_cityName;
    NSIndexPath *_cellIndexPath;
    UIImage *_imageIcon;
    
    // 点评
    int _commentCount;
    int _totalLevel;
    int _grassLevel;
    int _serviceLevel;
    int _difficultyLevel;
    int _sceneryLevel;
    
}

@property(nonatomic) int clubId;
@property(nonatomic) int cityId;
@property(nonatomic,copy) NSString *clubName;
@property(nonatomic,copy) NSString *shortName;
@property(nonatomic,copy) NSString *clubImage;
@property(nonatomic,copy) NSString *clubPhoto;
@property(nonatomic,copy) NSString *remote;
@property(nonatomic) float longitude;
@property(nonatomic) float latitude;
@property(nonatomic,copy) NSString *introduction;
@property(nonatomic,copy) NSString *publicNotice;
@property(nonatomic,copy) NSString *address;
@property(nonatomic) int minPrice;
@property(nonatomic) int minTimePrice;
@property(nonatomic) int minPackagePrice;
@property(nonatomic) int isOfficial;
@property(nonatomic) int closure;
@property(nonatomic,copy) NSString *phone;
@property(nonatomic,copy) NSString *trafficGuide;
@property(nonatomic,copy) NSString *buildDate;
@property(nonatomic,copy) NSString *designer;
@property(nonatomic,copy) NSString *courseKind;
@property(nonatomic,copy) NSString *courseData;
@property(nonatomic,copy) NSString *fairwayLength;
@property(nonatomic,copy) NSString *fairwayGrass;
@property(nonatomic,copy) NSString *greenGrass;
@property(nonatomic,copy) NSString *courseArea;
@property(nonatomic) int payType;
@property(nonatomic,copy) NSString *teeDate;
@property(nonatomic,copy) NSString *fairwayIntro;
@property(nonatomic,copy) NSString *clubFacility;
@property(nonatomic,copy) NSString *cityName;
@property(nonatomic,strong) NSIndexPath *cellIndexPath;
@property(nonatomic,strong) UIImage *imageIcon;
@property(nonatomic) int timeMinPrice;
@property(nonatomic,copy) NSString *startTime;
@property(nonatomic,copy) NSString *endTime;
@property(nonatomic) int commentCount;
@property(nonatomic) int totalLevel;
@property(nonatomic) int grassLevel;
@property(nonatomic) int serviceLevel;
@property(nonatomic) int difficultyLevel;
@property(nonatomic) int sceneryLevel;
@property(nonatomic,copy) NSString *shortAddress;
@property(nonatomic) int clubHoleNum;
@property(nonatomic) int giveYunbi;
@property(nonatomic,strong) NSDictionary *clubManagerData;
@property(nonatomic) int topicCount;

@property(nonatomic,strong) TopicModel *topicData;

- (id)initWithDic:(id)data;
+ (NSArray *)initWithArray:(id)data;

@end
