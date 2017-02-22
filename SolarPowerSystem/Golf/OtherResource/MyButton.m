//
//  MyButton.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/19.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "MyButton.h"

@implementation MyButton

- (void)setHighlighted:(BOOL)highlighted {
    if (self.highlighted != highlighted) {
        [super setHighlighted:highlighted];
        CGRect rect = CGRectMake(0.0f, 0.0f, 2.0f, 2.0f);
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (_highlightedColor == nil) {
            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:255/255.0 green:109/255.0 blue:0 alpha:1.0].CGColor);
        }else{
            CGContextSetFillColorWithColor(context, _highlightedColor.CGColor);
        }
        
        CGContextFillRect(context, rect);
        UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
        [self setBackgroundImage:coloredImage forState:UIControlStateHighlighted];
        [self setNeedsDisplay];
    }
}

-(void)setSelected:(BOOL)selected{
    if (self.selected != selected) {
        [super setSelected:selected];
        if (_selectedColor != nil) {
            CGRect rect = CGRectMake(0.0f, 0.0f, 2.0f, 2.0f);
            UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, _selectedColor.CGColor);
            CGContextFillRect(context, rect);
            UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
            [self setBackgroundImage:coloredImage forState:UIControlStateSelected];
            [self setNeedsDisplay];
        }
    }
}

-(void)setEnabled:(BOOL)enabled{
    if (self.enabled != enabled) {
        [super setEnabled:enabled];
        if (_disabledColor != nil) {
            CGRect rect = CGRectMake(0.0f, 0.0f, 2.0f, 2.0f);
            UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, _disabledColor.CGColor);
            CGContextFillRect(context, rect);
            UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
            [self setBackgroundImage:coloredImage forState:UIControlStateDisabled];
            [self setNeedsDisplay];
        }
    }
}

-(void)awakeFromNib{
    [super awakeFromNib];
    if (_borderColor) {
        self.layer.borderColor = _borderColor.CGColor;
//        self.layer.borderWidth
//        self.layer.cornerRadius
    }
}

@end
