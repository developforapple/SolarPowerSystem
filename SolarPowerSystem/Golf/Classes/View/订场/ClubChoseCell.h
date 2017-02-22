//
//  ClubChoseCell.h
//  Golf
//
//  Created by Dejohn Dong on 12-1-20.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utilities.h"

@interface ClubChoseCell : UITableViewCell

@property(nonatomic,strong) UIImageView *headImg;
@property(nonatomic,strong) UILabel *lblClubName;
@property(nonatomic,strong) UILabel *lblPrice;
@property(nonatomic,strong) UILabel *lblLeastDistance;
@property(nonatomic,strong) UIButton *btnImage;
@property(nonatomic,strong) UIButton *btnClubName;
@property(nonatomic,strong) UIImageView *vipTag;
@property(nonatomic,strong) UILabel *specialLabel;
@property(nonatomic,strong) UIImageView *officialFlag;
@property(nonatomic,strong) UIImageView *clubSpecialOff;
@property(nonatomic,strong) UIImageView *phoneBookImg;
@property(nonatomic,strong) UILabel *clubKindLabel;
@property(nonatomic,strong) UIImageView *alockIconImg;
@property(nonatomic,strong) UILabel *yunbiLabel;

@end
