//
//  OnlyOneLineCell.m
//  Golf
//
//  Created by 黄希望 on 15/10/16.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "OnlyOneLineCell.h"

@implementation OnlyOneLineCell

- (IBAction)done:(id)sender{
    if (_blockDone) {
        _blockDone (nil);
    }
}

@end
