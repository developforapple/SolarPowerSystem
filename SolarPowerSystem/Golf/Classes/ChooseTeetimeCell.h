//
//  ChooseTeetimeCell.h
//  Golf
//
//  Created by 黄希望 on 15/10/29.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseTeetimeCell : UITableViewCell

@property (nonatomic,assign) BOOL isSpree;
@property (nonatomic,strong) TTModel *ttm;
@property (nonatomic,copy) BlockReturn bookBlock;

@end
