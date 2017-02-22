//
//  PackageCell.h
//  Golf
//
//  Created by user on 12-12-14.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PackageCell : UITableViewCell{
    IBOutlet UIImageView *_logoView;
    IBOutlet UILabel *_lblPackageName;
    IBOutlet UILabel *_lblPrice;
    IBOutlet UILabel *_lblLabel;
    IBOutlet UILabel *_lblClubName;
}

@property (nonatomic,strong) UIImageView *logoView;
@property (nonatomic,strong) UILabel *lblPackageName;
@property (nonatomic,strong) UILabel *lblPrice;
@property (nonatomic,strong) UILabel *lblLabel;
@property (nonatomic,strong) UILabel *lblClubName;
@property (weak, nonatomic) IBOutlet UILabel *giveYunbiLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withType:(int)type;

@end
