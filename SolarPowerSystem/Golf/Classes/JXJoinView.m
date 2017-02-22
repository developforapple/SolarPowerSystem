//
//  JXJoinView.m
//  Golf
//
//  Created by 黄希望 on 15/5/21.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "JXJoinView.h"

@interface JXJoinView()<YGLoginViewCtrlDelegate>
@end

@implementation JXJoinView

- (IBAction)joinBtnAction:(id)sender{
    if (![LoginManager sharedManager].loginState) {
        [[LoginManager sharedManager] loginWithDelegate:self controller:[GolfAppDelegate shareAppDelegate].currentController animate:YES];
        return;
    }
    if (_buttonAction) {
        _buttonAction(nil);
    }
}

- (void)loginButtonPressed:(id)sender{
    if (_buttonAction) {
        _buttonAction(nil);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
