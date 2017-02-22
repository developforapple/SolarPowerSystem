//
//  ClubChooseDTCell.m
//  Golf
//
//  Created by 黄希望 on 15/10/26.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "ClubChooseDTCell.h"

@interface ClubChooseDTCell()

@end

@implementation ClubChooseDTCell

- (IBAction)buttonClickAction:(UIButton*)sender{
    if (_blockClick) {
        _blockClick (@(sender.tag));
    }
}

@end
