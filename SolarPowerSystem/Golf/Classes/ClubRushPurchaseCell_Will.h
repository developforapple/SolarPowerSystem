//
//  ClubRushPurchaseCell_Will.h
//  Golf
//
//  Created by 黄希望 on 15/10/12.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "ClubRushPurchaseCell.h"

@interface ClubRushPurchaseCell_Will : ClubRushPurchaseCell

@property (nonatomic,weak) IBOutlet UIImageView *clubImageView;
@property (nonatomic,weak) IBOutlet UILabel *clubNameLabel;
@property (nonatomic,weak) IBOutlet UILabel *clubTeetimeLabel;
@property (nonatomic,weak) IBOutlet UILabel *currentPriceLabel;
@property (nonatomic,weak) IBOutlet UILabel *originalPriceLabel;
@property (nonatomic,weak) IBOutlet UILabel *returnYunbiLabel;
@property (nonatomic,weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic,weak) IBOutlet UIButton *opeBtn;
@property (nonatomic,weak) IBOutlet UILabel *rushPurchaseTimeLabel;

// 抢购提醒列表
@property (nonatomic,strong) NSArray *callList;

@end
