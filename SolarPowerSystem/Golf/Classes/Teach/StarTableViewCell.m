//
//  StarTableViewCell.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/19.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "StarTableViewCell.h"
#import "UIView+AutoLayout.h"

@interface StarTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *imgStar;


@end

@implementation StarTableViewCell

- (void)starLevel:(float)starLevel{
    CGFloat width = 165.0/5 * starLevel;
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


@end
