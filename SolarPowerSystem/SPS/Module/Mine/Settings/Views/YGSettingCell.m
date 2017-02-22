//
//  YGSettingCell.m
//  Golf
//
//  Created by zhengxi on 15/11/3.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "YGSettingCell.h"

@implementation YGSettingCell

- (IBAction)clickedSwitchButton:(id)sender {
    if (_switchButtonBlock) {
        _switchButtonBlock(_switchButton.isOn);
    }
}
@end
