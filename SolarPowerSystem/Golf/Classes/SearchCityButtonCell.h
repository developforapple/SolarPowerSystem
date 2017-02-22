//
//  SearchCityButtonCell.h
//  Golf
//
//  Created by 黄希望 on 15/10/19.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchCityButtonCell : UITableViewCell

@property (nonatomic,assign) BOOL isHotCity;
@property (nonatomic,strong) NSArray *citys;

// 删除
@property (nonatomic,copy) BlockReturn deleteBlock;

// 点击
@property (nonatomic,copy) BlockReturn clickBlock;

@end
