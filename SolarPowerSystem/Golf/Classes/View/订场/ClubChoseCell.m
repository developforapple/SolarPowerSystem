//
//  ClubChoseCell.m
//  Golf
//
//  Created by Dejohn Dong on 12-1-20.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import "ClubChoseCell.h"
#import "Utilities.h"

@implementation ClubChoseCell
@synthesize lblClubName = _lblClubName;
@synthesize lblPrice = _lblPrice;
@synthesize lblLeastDistance = _lblLeastDistance;
@synthesize btnImage = _btnImage;
@synthesize btnClubName = _btnClubName;
@synthesize headImg = _headImg;
@synthesize vipTag = _vipTag;
@synthesize specialLabel = _specialLabel;
@synthesize officialFlag = _officialFlag;
@synthesize clubSpecialOff = _clubSpecialOff;
@synthesize clubKindLabel = _clubKindLabel;
@synthesize alockIconImg  = _alockIconImg;
@synthesize yunbiLabel = _yunbiLabel;
@synthesize phoneBookImg = _phoneBookImg;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //图片
        _headImg = [[UIImageView alloc] initWithFrame:CGRectMake(15, 17, 50, 50)];
        _headImg.image = [UIImage imageNamed:@"cgit_s.png"];
        [Utilities drawView:_headImg radius:25 borderColor:[Utilities R:219 G:219 B:219]];
        [self.contentView addSubview:_headImg];
        
        _btnImage = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnImage.frame = _headImg.frame;
        [self.contentView addSubview:_btnImage];
        
        //球会名字Label
        _lblClubName = [[UILabel alloc] initWithFrame:CGRectMake(80.0, 10.0, Device_Width-90, 16.0)];
        _lblClubName.font = [UIFont systemFontOfSize:16.0f];
        _lblClubName.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_lblClubName];
        
        _clubKindLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 36, Device_Width-120, 13)];
        _clubKindLabel.font = [UIFont systemFontOfSize:13.0f];
        _clubKindLabel.backgroundColor = [UIColor clearColor];
        _clubKindLabel.textColor = [UIColor colorWithHexString:@"#666666"];
        [self.contentView addSubview:_clubKindLabel];
        
        _alockIconImg = [[UIImageView alloc] initWithFrame:CGRectMake(Device_Width-115, 37, 12, 12)];
        _alockIconImg.image = [UIImage imageNamed:@"teetime_list_alock_icon.png"];
        [self.contentView addSubview:_alockIconImg];
        
        _specialLabel = [[UILabel alloc] initWithFrame:CGRectMake(Device_Width-100, 37, 100, 13)];
        _specialLabel.backgroundColor = [UIColor clearColor];
        _specialLabel.textColor = [UIColor darkGrayColor];
        _specialLabel.font = [UIFont systemFontOfSize:12.0f];
        [self.contentView addSubview:_specialLabel];
        
        //价格Label
        _lblPrice = [[UILabel alloc] initWithFrame:CGRectMake(Device_Width-105, 35, 90, 19)];
        _lblPrice.backgroundColor = [UIColor clearColor];
        _lblPrice.textColor = [UIColor orangeColor];
        _lblPrice.font = [UIFont boldSystemFontOfSize:19.0f];
        _lblPrice.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_lblPrice];
        
        _yunbiLabel = [[UILabel alloc] initWithFrame:CGRectMake(Device_Width-60, 46, 45, 12)];
        _yunbiLabel.backgroundColor = [UIColor clearColor];
        _yunbiLabel.textColor = [UIColor orangeColor];
        _yunbiLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        _yunbiLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_yunbiLabel];
        
        //最近距离Label
        _lblLeastDistance = [[UILabel alloc] initWithFrame:CGRectMake(80.0, 60, 230.0, 13.0)];
        _lblLeastDistance.backgroundColor = [UIColor clearColor];
        _lblLeastDistance.font = [UIFont systemFontOfSize:13.0];
        _lblLeastDistance.textColor = [UIColor colorWithHexString:@"#666666"];
        [self.contentView addSubview:_lblLeastDistance];
        
        _phoneBookImg = [[UIImageView alloc] initWithFrame:CGRectMake(Device_Width-30, 48, 14, 12)];
        _phoneBookImg.image = [UIImage imageNamed:@"phone_flag.png"];
        [self.contentView addSubview:_phoneBookImg];
        
        _officialFlag = [[UIImageView alloc] initWithFrame:CGRectMake(0, 36, 14, 14)];
        _officialFlag.image = [UIImage imageNamed:@"officialflag.png"];
        [self.contentView addSubview:_officialFlag];
        
        _vipTag = [[UIImageView alloc] initWithFrame:CGRectMake(0, 36, 14, 14)];
        _vipTag.image = [UIImage imageNamed:@"teetime_list_vip.png"];
        [self.contentView addSubview:_vipTag];
        
        _clubSpecialOff = [[UIImageView alloc] initWithFrame:CGRectMake(0, 36, 26, 14)];
        _clubSpecialOff.image = [UIImage imageNamed:@"teetime_list_specialoffer_icon.png"];
        [self.contentView addSubview:_clubSpecialOff];
    }
    return self;
}

@end
