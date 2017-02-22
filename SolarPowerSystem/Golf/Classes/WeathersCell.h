//
//  WeathersCell.h
//  Golf
//
//  Created by 黄希望 on 15/10/23.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WeatherModel;

@interface WeathersCell : UITableViewCell

@property (nonatomic,assign) NSInteger index;
@property (nonatomic,strong) WeatherModel *wm;

@end
