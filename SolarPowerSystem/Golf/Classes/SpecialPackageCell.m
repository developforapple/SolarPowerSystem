//
//  SpecialPackageCell.m
//  Golf
//
//  Created by 黄希望 on 15/11/13.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "SpecialPackageCell.h"

@implementation SpecialPackageCell

- (IBAction)btnClickAction:(UIButton*)sender{
    if (_clickBlock) {
        _clickBlock (@(sender.tag));
    }
}

@end
