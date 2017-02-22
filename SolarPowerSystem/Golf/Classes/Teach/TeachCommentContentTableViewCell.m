//
//  TeachCommentContentTableViewCell.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/21.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "TeachCommentContentTableViewCell.h"
#import "UIView+AutoLayout.h"

@interface TeachCommentContentTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *imgStar;


@end

@implementation TeachCommentContentTableViewCell


- (void)loadCommentContent:(NSString *)content andReplyContent:(NSString *)reply starLevel:(int)starLevel{
    _labelContent.text = content;
    _labelReplyContent.text = reply;
    [self starLevel:starLevel];
}

//设置星星级别  //浦发红酒300176
- (void)starLevel:(int)starLevel{
    CGFloat width = 80.0/5 * starLevel;
    BOOL flag = YES;
    for (NSLayoutConstraint *c  in [_imgStar constraints]) {
        if (c.firstAttribute == NSLayoutAttributeWidth) {
            c.constant = width;
            [_imgStar layoutIfNeeded];
            flag = NO;
            break;
        }
    }
    if (flag) { //标记是否有设置width约束，如果没有则设置
        [_imgStar constrainToWidth:width];
        [_imgStar layoutIfNeeded];
    }
}

- (IBAction)btnReply:(id)sender {
    if (_blockReply) {
        _blockReply(sender);
    }
}


@end
