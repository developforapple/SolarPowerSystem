//
//  ActionBarTableViewCell.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/13.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "ActionBarTableViewCell.h"


@implementation ActionBarTableViewCell

-(void)followed:(BOOL)followed{
    _btnFollowed.selected = followed;
}

- (IBAction)btnAction:(UIButton *)btn {
    NSInteger tag = btn.tag;
    switch (tag) {
        case 0:
        {
            if (_blockHome) {
                _blockHome(nil);
                return;
            }
        }
            break;
        case 1:
        {
            if (_blockChat) {
                if (_teachingCoachModel.coachId == [LoginManager sharedManager].session.memberId) {
                    [SVProgressHUD showInfoWithStatus:@"不能跟自己聊天"];
                    return;
                }
                _blockChat(nil);
                return;
            }
        }
            break;
        case 2:
        {
            if (_blockAdd) {
                if (_teachingCoachModel.coachId == [LoginManager sharedManager].session.memberId) {
                    [SVProgressHUD showInfoWithStatus:@"不能对自己进行操作"];
                    return;
                }
                if (![LoginManager sharedManager].loginState) {
                    [[LoginManager sharedManager] loginWithDelegate:_loginDelegeate controller:[GolfAppDelegate shareAppDelegate].currentController animate:YES blockRetrun:^(id data) {
                        _blockAdd(@(!_btnFollowed.selected));
                        _btnFollowed.selected = !_btnFollowed.selected;
                    }];
                    return;
                }
                
                _blockAdd(@(!_btnFollowed.selected));
                _btnFollowed.selected = !_btnFollowed.selected;
            }
        }
            break;
        default:
            break;
    }
}


@end
