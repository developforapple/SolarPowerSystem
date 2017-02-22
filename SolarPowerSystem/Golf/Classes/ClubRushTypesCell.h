//
//  ClubRushTypesCell.h
//  Golf
//
//  Created by 黄希望 on 15/11/4.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClubSpreeModel.h"

@interface ClubRushTypesCell : UITableViewCell

@property (nonatomic,strong) ClubSpreeModel *csm;
@property (nonatomic,strong) ConditionModel *cm;
@property (nonatomic,copy) BlockReturn refreshBlock;
@property (nonatomic,copy) BlockReturn callRefreshBlock;
@property (nonatomic,copy) BlockReturn bookBlock;

+ (NSTimeInterval)timeIntervalWithCompareResult:(NSString*)time timeInterGab:(NSTimeInterval)timeInterGab;

@end
