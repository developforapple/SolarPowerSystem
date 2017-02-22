//
//  OrderClickView.m
//  Golf
//
//  Created by 黄希望 on 15/6/3.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "OrderClickView.h"

@interface OrderClickView ()

@property (nonatomic,weak) IBOutlet UILabel *titleLabel;

@end

@implementation OrderClickView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //self.isSelected = YES;
}

- (void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    _titleLabel.textColor = isSelected ? MainHighlightColor : [UIColor colorWithHexString:@"#333333"];
}

@end
