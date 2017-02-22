//
//  PackageCell.m
//  Golf
//
//  Created by user on 12-12-14.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import "PackageCell.h"

@implementation PackageCell
@synthesize logoView = _logoView;
@synthesize lblPackageName = _lblPackageName;
@synthesize lblPrice = _lblPrice;
@synthesize lblLabel = _lblLabel;
@synthesize lblClubName = _lblClubName;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withType:(int)type
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
       
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _giveYunbiLabel.layer.borderColor = [UIColor colorWithHexString:@"#ff6d00"].CGColor;
    CGRect rect = _lblLabel.frame;
    CGRect rect1 = _giveYunbiLabel.frame;
    rect1.origin.x = rect.size.width + rect.origin.x;
    _giveYunbiLabel.frame = rect1;
}

 
@end
