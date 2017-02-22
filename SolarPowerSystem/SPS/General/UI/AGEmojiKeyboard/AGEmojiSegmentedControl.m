//
//  AGEmojiSegmentedControl.m
//  Golf
//
//  Created by 廖瀚卿 on 15/10/23.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "AGEmojiSegmentedControl.h"

@implementation AGEmojiSegmentedControl

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([AGEmojiSegmentedControl class])
                          bundle:[NSBundle bundleForClass:[AGEmojiSegmentedControl class]]];
}

-(void)setSelectedSegmentIndex:(int)selectedSegmentIndex{
    _selectedSegmentIndex = selectedSegmentIndex;
    for (int i = 0; i < _btns.count; i++) {
        UIButton *btn = (UIButton *)_btns[i];
        btn.selected = selectedSegmentIndex == i;
    }
}


- (IBAction)sendAction:(UIButton *)btn {
    if (_blockSendPressed) {
        _blockSendPressed(btn);
    }
    
}


- (IBAction)btnAction:(UIButton *)btn{
    if (_blockBtnSelectChanged) {
        _blockBtnSelectChanged(@(btn.tag));
    }
    [self setSelectedSegmentIndex:[@(btn.tag) intValue]];
}
@end
