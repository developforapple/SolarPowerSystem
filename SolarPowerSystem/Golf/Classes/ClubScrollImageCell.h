//
//  ClubScrollImageCell.h
//  Golf
//
//  Created by 黄希望 on 15/11/13.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClubScrollImageCell : UITableViewCell

@property (nonatomic,copy) BlockReturn checkNearbyBlock;
@property (nonatomic,strong) NSArray *activityList;

- (void)setDatas:(NSArray *)activityList reload:(BOOL)flag;

@end
