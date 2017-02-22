//
//  AddPlayerCell.m
//  Golf
//
//  Created by user on 12-11-13.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import "AddPlayerCell.h"

@implementation AddPlayerCell
@synthesize markImageView = _markImageView;
@synthesize nameLabel = _nameLabel;
@synthesize isSelected = _isSelected;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
