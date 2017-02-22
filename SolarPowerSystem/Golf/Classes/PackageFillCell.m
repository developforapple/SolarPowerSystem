//
//  PackageFillCell.m
//  Golf
//
//  Created by user on 12-12-19.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import "PackageFillCell.h"

@implementation PackageFillCell
@synthesize titleLabel = _titleLabel;
@synthesize textField = _textField;
@synthesize noteLabel = _noteLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
