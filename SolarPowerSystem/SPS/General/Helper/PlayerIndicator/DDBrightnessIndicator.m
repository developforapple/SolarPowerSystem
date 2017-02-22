//
//  DDBrightnessIndicator.m
//  JuYouQu
//
//  Created by Normal on 16/2/17.
//  Copyright © 2016年 Bo Wang. All rights reserved.
//

#import "DDBrightnessIndicator.h"

@implementation DDBrightnessIndicator

+ (instancetype)instance
{
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.progressView.numberOfGrids = 16;
    self.layer.cornerRadius = 8.f;
    self.layer.masksToBounds = YES;
    
    if (Device_SysVersion >= 8.f) {
        self.effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        self.effectView.backgroundColor = [UIColor colorWithWhite:0.4f alpha:.6f];
        self.backgroundColor = [UIColor clearColor];
    }else{
        self.backgroundColor = [UIColor colorWithWhite:0.6f alpha:.8f];
    }
    
    self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
}

- (void)setProgress:(CGFloat)progress
{
    progress = MAX(0, MIN(1, progress));
    self.progressView.progress = progress;
}

@end
