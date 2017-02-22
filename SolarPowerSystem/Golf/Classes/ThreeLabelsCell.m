//
//  ThreeLabelsCell.m
//  Golf
//
//  Created by 黄希望 on 15/11/4.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "ThreeLabelsCell.h"

@implementation ThreeLabelsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [Utilities drawView:_theThirdLabel radius:2 bordLineWidth:0 borderColor:nil];
}

@end
