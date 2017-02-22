//
//  ClubRushPurchaseCell.h
//  Golf
//
//  Created by 黄希望 on 15/10/12.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClubSpreeModel.h"
#import "CalendarClass.h"


@interface ClubRushPurchaseCell : UITableViewCell{
    @public
    ClubSpreeModel *_csm;
    NSTimeInterval _timeInteval;
    BOOL _hasSetted;
}

@property (nonatomic,strong) ClubSpreeModel *csm;

@property (nonatomic,assign) NSTimeInterval timeInteval;

@property (nonatomic,copy) BlockReturn spreeBlock;

@property (nonatomic,copy) BlockReturn callBlock;

+ (NSTimeInterval)timeIntervalWithCompareResult:(NSString*)time timeInterGab:(NSTimeInterval)timeInterGab;



@end
