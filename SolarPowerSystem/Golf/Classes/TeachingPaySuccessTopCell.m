//
//  TeachingPaySuccessTopCell.m
//  Golf
//
//  Created by 黄希望 on 15/7/31.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "TeachingPaySuccessTopCell.h"

@implementation TeachingPaySuccessTopCell

- (IBAction)pressBtnAction:(id)sender{
    if (_reserveAction) {
        _reserveAction (nil);
    }
}

@end
