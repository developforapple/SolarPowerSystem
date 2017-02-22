//
//  ADBannerTableViewCell.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/6.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "ADBannerTableViewCell.h"

@implementation ADBannerTableViewCell

- (IBAction)btnPressed:(id)sender {
    if (_blockReturn) {
        _blockReturn(_activityModel);
    }
}

@end
