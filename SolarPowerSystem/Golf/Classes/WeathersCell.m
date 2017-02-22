//
//  WeathersCell.m
//  Golf
//
//  Created by 黄希望 on 15/10/23.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "WeathersCell.h"
#import "WeatherModel.h"

@interface WeathersCell ()

@property (nonatomic,weak) IBOutlet UILabel *dateLabel;
@property (nonatomic,weak) IBOutlet UIImageView *weatherIcon;
@property (nonatomic,weak) IBOutlet UILabel *tempLabel;
@property (nonatomic,weak) IBOutlet UILabel *windLabel;
@property (nonatomic,weak) IBOutlet UILabel *infoLabel;

@end

@implementation WeathersCell

- (void)setWm:(WeatherModel *)wm{
    _wm = wm;
    if (_wm) {
        if (_index == 0) _dateLabel.text = @"今天";
        else if (_index == 1) _dateLabel.text = @"明天";
        else if (_index == 2) _dateLabel.text = @"后天";
        else{
            _dateLabel.text = [NSString stringWithFormat:@"%@日",[self date:_wm.dateStr]];
        }
        
        NSString *ic = [NSString stringWithFormat:@"a_%d",_wm.picureNo];
        _weatherIcon.image = [UIImage imageNamed:ic];
        _infoLabel.text = _wm.weatherInfo.length>0?_wm.weatherInfo:@"";
        _windLabel.text = _wm.windInfo.length>0?_wm.windInfo:@"";
        _tempLabel.text = _wm.temperatureRangeInfo.length>0 ? _wm.temperatureRangeInfo : @"";
    }
}

- (NSString*)date:(NSString*)theDate{
    NSString *formatType = @"d";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formatter dateFromString:theDate];
    [formatter setDateFormat:formatType];
    return [formatter stringFromDate:date];
}

@end
