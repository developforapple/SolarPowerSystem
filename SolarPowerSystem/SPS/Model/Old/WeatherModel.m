//
//  WeatherModel.m
//  Golf
//
//  Created by 黄希望 on 12-9-4.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import "WeatherModel.h"

@implementation WeatherModel


+ (NSMutableArray *)arrayWithDic:(id)data{
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    NSDictionary *dic = (NSDictionary *)data;
    for (int i=0; i<5; i++) {
        WeatherModel *model = [[WeatherModel alloc] init];
        model.dateStr = [dic objectForKey:[NSString stringWithFormat:@"day%d_date",i+1]];
        model.weekStr = [dic objectForKey:[NSString stringWithFormat:@"day%d_week",i+1]];
        model.weatherInfo = [dic objectForKey:[NSString stringWithFormat:@"day%d_weather",i+1]];
        model.temperatureRangeInfo = [dic objectForKey:[NSString stringWithFormat:@"day%d_temp",i+1]];
        model.windInfo = [dic objectForKey:[NSString stringWithFormat:@"day%d_wind",i+1]];
        model.picureNo = [[dic objectForKey:[NSString stringWithFormat:@"day%d_img",i+1]] intValue];
        if (model.weatherInfo.length==0) {
            break;
        }
        [array addObject:model];
    }
    return array;
}

@end
