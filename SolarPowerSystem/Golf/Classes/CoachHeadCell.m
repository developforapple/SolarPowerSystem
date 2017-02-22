//
//  CoachHeadCell.m
//  Golf
//
//  Created by 黄希望 on 15/6/17.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CoachHeadCell.h"

@implementation CoachHeadCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [Utilities drawView:_headImageV radius:19 bordLineWidth:0 borderColor:nil];
}

 
@end
