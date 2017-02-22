//
//  YGMineCell.m
//  Golf
//
//  Created by zhengxi on 15/12/7.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "YGMineCell.h"

@interface YGMineCell ()
@property (strong, nonatomic) NSString *headImageString;
@property (strong, nonatomic) NSString *nickNameString;
@property (weak, nonatomic) IBOutlet UILabel *friendBadgeLabel;
@property (weak, nonatomic) IBOutlet UIView *viewBadge;
@property (weak, nonatomic) IBOutlet UIView *viewBadge1;

@property (retain, nonatomic) IBOutlet UILabel *badge;
@property (retain, nonatomic) IBOutlet UILabel *badge1;
@end

@implementation YGMineCell
 

- (void)setIsFirstCell:(BOOL)isFirstCell {
    _isFirstCell = isFirstCell;
    if (isFirstCell) {
        if([LoginManager sharedManager].session.headImage.length > 0) {
            if (![_headImageString isEqualToString:[LoginManager sharedManager].session.headImage]) {
                [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[LoginManager sharedManager].session.headImage] placeholderImage:[UIImage imageNamed:@"head_image"]];
            }
        } else {
            [self.headImageView setImage:[UIImage imageNamed:@"head_image"]];
        }
        if([LoginManager sharedManager].session.nickName.length > 0) {
            if (![_nickNameString isEqualToString:[LoginManager sharedManager].session.nickName]) {
                self.nameLabel.text = [LoginManager sharedManager].session.nickName;
            }
        } else {
            self.nameLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:KGolfSessionPhone];
        }
        
        UIImage *img = [Utilities imageOfUserType:[LoginManager sharedManager].session.memberLevel];
        if (!img) {
            img = [UIImage imageNamed:@"vip_un.png"];
        }
        [self.levelButton setImage:img forState:UIControlStateNormal];
        
        if([LoginManager sharedManager].session.nickName.length > 0) {
            self.phoneNumberLabel.hidden = NO;
            self.phoneNumberLabel.text = [LoginManager sharedManager].session.mobilePhone;
            NSLog(@"%@",[LoginManager sharedManager].session.mobilePhone);
        } else {
            self.phoneNumberLabel.hidden = YES;
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)toUserGuide:(id)sender {
    if (_toUserGuideBlock) {
        _toUserGuideBlock();
    }
}

- (IBAction)toCoachGuide:(id)sender {
    if (!_levelButton.hidden) {
        if (_toCoachGuideBlock) {
            _toCoachGuideBlock();
        }
    }
}

- (IBAction)clickButton:(id)sender {
    NSInteger tag = ((UIButton *)sender).tag;
    if (_toAccountBlock) {
        _toAccountBlock(tag);
    }
}

- (IBAction)friendClick:(UIButton *)sender {
    if (self.blockFriend) {
        self.blockFriend(@(sender.tag));
    }
}

- (void)setMsgCount:(int)msgCount {
    _msgCount = msgCount;
    [self configWithConversation:msgCount];
}

- (void)configWithConversation:(int)unreadCount {
    //    self.conversation = msg;
    
    //    self.labelName.text = msg.sessionTitle;
    if (unreadCount > 0) {
        self.badge.text = [NSString stringWithFormat:@"%d",unreadCount];
        [self.viewBadge addSubview:self.badge];
        self.viewBadge.hidden = NO;
    }
    else {
        self.badge.text = @"0";
        self.viewBadge.hidden = YES;
    }
}

- (void)setRedPointAboutFriends:(BOOL)redPointAboutFriends {
    _redPointAboutFriends = redPointAboutFriends;
    int unreadCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"NEW_FOLLOWED_COUNT"] intValue];
    if (unreadCount > 0) {
        self.badge1.text = [NSString stringWithFormat:@"%d",unreadCount];
        [self.viewBadge1 addSubview:self.badge1];
        self.viewBadge1.hidden = NO;
        self.friendBadgeLabel.hidden = YES;
    } else {
        self.badge1.text = @"0";
        self.viewBadge1.hidden = YES;
        if (redPointAboutFriends) {
            self.friendBadgeLabel.hidden = NO;
        } else {
            self.friendBadgeLabel.hidden = YES;
        }
    }
}
@end
