//
//  ThreeEntranceTableViewCell.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/6.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "ThreeEntranceTableViewCell.h"

@interface ThreeEntranceTableViewCell()

@end

@implementation ThreeEntranceTableViewCell

- (IBAction)btnTouched:(UIButton *)btn {
    if (_blockReturn) {
        _blockReturn(@(btn.tag));
    }
}


@end
