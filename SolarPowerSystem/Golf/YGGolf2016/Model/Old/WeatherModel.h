//
//  WeatherModel.h
//  Golf
//
//  Created by 黄希望 on 12-9-4.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeatherModel : NSObject{
    NSString *_dateStr;			// 日期
	NSString *_weekStr;			// 星期
	NSString *_temperatureRangeInfo;	// 温度范围
	NSString *_weatherInfo;			// 基本信息
    NSString *_windInfo;
	int _picureNo;		// 天气图片开始名称
}

@property(nonatomic, copy) NSString *dateStr;
@property(nonatomic, copy) NSString *weekStr;
@property(nonatomic, copy) NSString *temperatureRangeInfo;
@property(nonatomic, copy) NSString *weatherInfo;
@property(nonatomic, copy) NSString *windInfo;
@property(nonatomic) int picureNo;

+ (NSMutableArray *)arrayWithDic:(id)data;

@end
