//
//  TimeViewCell.m
//  Golf
//
//  Created by 黄希望 on 15/10/21.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "TimeViewCell.h"
#import "TimeView.h"

@interface TimeViewCell()

@property (nonatomic,strong) IBOutletCollection(TimeView) NSArray *timeViews;

@end

@implementation TimeViewCell

- (void)setTimes:(NSArray *)times{
    _times = times;
    for (Time *time in _times) {
        NSInteger index = [_times indexOfObject:time];
        TimeView *tv = _timeViews[index];
        tv.hasPrice = _hasPrice;
        tv.time = time;
        tv.scrolling = _scrolling;
    }
}

@end
