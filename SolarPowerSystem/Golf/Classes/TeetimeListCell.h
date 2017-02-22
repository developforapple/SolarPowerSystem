//
//  TeetimeListCell.h
//  Golf
//
//  Created by 黄希望 on 15/10/26.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeetimeListCell : UITableViewCell

@property (nonatomic,assign) int timeMinPrice;
@property (nonatomic,strong) TTModel *ttm;

@property (nonatomic,copy) BlockReturn bookBlock;
@property (nonatomic,assign) NSInteger clubSpecialOffType;

@end
