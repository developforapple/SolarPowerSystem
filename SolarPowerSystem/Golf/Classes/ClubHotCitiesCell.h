//
//  ClubHotCitiesCell.h
//  Golf
//
//  Created by 黄希望 on 15/11/13.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClubHotCitiesCell : UITableViewCell

@property (nonatomic,copy) BlockReturn hotCityBlock;

- (void)loadHotCities:(NSArray *)hotCities reload:(BOOL)flag;

@end
