//
//  ClubManagerTableViewCell.m
//  Golf
//
//  Created by 黄希望 on 15/9/30.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "ClubManagerTableViewCell.h"

@implementation ClubManagerTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _memberNameLabel.text = @"";
    _clubTitleLabel.text = @"";
}

- (void)setClubManagerData:(NSDictionary*)clubManagerData{
    _clubManagerData = clubManagerData;
    if (_clubManagerData) {
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:_clubManagerData[@"head_image"]] placeholderImage:[UIImage imageNamed:@"head_member"]];
        
        if (_clubManagerData[@"display_name"]) {
            _memberNameLabel.text = _clubManagerData[@"display_name"];
        }
        
        [_memberLevelImg setImage:[Utilities imageOfUserType:[_clubManagerData[@"member_rank"] intValue]]];
        
        if (_clubManagerData[@"member_title"]) {
            _clubTitleLabel.text = _clubManagerData[@"member_title"];
        }
    }
}

- (IBAction)sendMsgAction:(id)sender{
    if (_sendMsgBlock) {
        if ([LoginManager sharedManager].loginState == NO) {
            [[LoginManager sharedManager] loginWithDelegate:nil controller:[GolfAppDelegate shareAppDelegate].currentController animate:YES blockRetrun:^(id data) {
                _sendMsgBlock (self.headImageView.image);
            }];
            return;
        }
        _sendMsgBlock (self.headImageView.image);
    }
}


@end
