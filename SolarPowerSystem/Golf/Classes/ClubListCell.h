//
//  ClubListCell.h
//  Golf
//
//  Created by 黄希望 on 15/10/14.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClubListCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIImageView *clubImageView;
@property (nonatomic,weak) IBOutlet UILabel *clubNameLabel;
@property (nonatomic,weak) IBOutlet UILabel *clubTypeLabel;
@property (nonatomic,weak) IBOutlet UILabel *shortAddressLabel;
@property (nonatomic,weak) IBOutlet UIImageView *officialFlag; // 官方标志
@property (nonatomic,weak) IBOutlet UIImageView *vipFlag; // 会员标志
@property (nonatomic,weak) IBOutlet UIImageView *specialPriceFlag; // 特价标志
@property (nonatomic,weak) IBOutlet UIImageView *alockFlag;
@property (nonatomic,weak) IBOutlet UILabel *specialPriceLabel;
@property (nonatomic,weak) IBOutlet UILabel *moneyMarkLabel1;
@property (nonatomic,weak) IBOutlet UILabel *moneyMarkLabel2;
@property (nonatomic,weak) IBOutlet UILabel *minPriceLabel1;
@property (nonatomic,weak) IBOutlet UILabel *minPriceLabel2;
@property (nonatomic,weak) IBOutlet UILabel *fanYunbiLabel;
@property (nonatomic,weak) IBOutlet UIImageView *phoneBookFlag; // 电话预订标志

@property (nonatomic,strong) ClubModel *club;
@property (nonatomic,strong) ConditionModel *cm;

@end
