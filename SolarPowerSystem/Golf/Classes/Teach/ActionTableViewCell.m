//
//  ActionTableViewCell.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/21.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "ActionTableViewCell.h"

@implementation ActionTableViewCell

- (IBAction)btnPressed:(id)sender {
    if (_blockReturn) {
        _blockReturn(nil);
    }
}

@end
