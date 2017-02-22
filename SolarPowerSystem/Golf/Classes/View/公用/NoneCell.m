//
//  NoneCell.m
//  Golf
//
//  Created by user on 12-11-19.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import "NoneCell.h"
#import "Utilities.h"

@implementation NoneCell
@synthesize mainTitle =  _mainTitle;
@synthesize subTitle = _subTitle;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        _mainTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 10.0, Device_Width, 20.0)];
        _mainTitle.text = @"暂无记录";
        _mainTitle.textColor = [Utilities R:51.0 G:51.0 B:51.0];
        _mainTitle.font = [UIFont systemFontOfSize:13.0f];
        _mainTitle.textAlignment = NSTextAlignmentCenter;
        _mainTitle.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_mainTitle];
        
        _subTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 30.0, Device_Width, 20.0)];
        _subTitle.textColor = [Utilities R:187.0 G:187.0 B:187.0];
        _subTitle.font = [UIFont systemFontOfSize:12.0f];
        _subTitle.textAlignment = NSTextAlignmentCenter;
        _subTitle.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_subTitle];
    }
    return self;
}

+ (NoneCell *)shareCell{
    NoneCell *nonecell = [[NoneCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NoneCell"];
	return nonecell;
}


@end
