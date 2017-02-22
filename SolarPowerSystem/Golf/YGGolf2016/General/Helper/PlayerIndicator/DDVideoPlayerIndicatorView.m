//
//  DDVideoPlayerIndicatorView.m
//  JuYouQu
//
//  Created by Normal on 16/3/7.
//  Copyright © 2016年 Bo Wang. All rights reserved.
//

#import "DDVideoPlayerIndicatorView.h"
#import "DDBrightnessIndicator.h"

@interface DDVideoPlayerIndicatorView ()
@property (strong, nonatomic) DDBrightnessIndicator *brightnessView;
@end

@implementation DDVideoPlayerIndicatorView

- (void)setBrightness:(CGFloat)p hidden:(BOOL)hidden
{
    [self setView:self.brightnessView hidden:hidden];
    if (!hidden) {
        self.brightnessView.indicator.image = [UIImage imageNamed:@"icon_video_brightness"];
        self.brightnessView.titleLabel.text = @"亮度";
        [self.brightnessView setProgress:p];
        [self bringSubviewToFront:self.brightnessView];
    }
}

- (void)setVolume:(CGFloat)volume hidden:(BOOL)hidden
{
    [self setView:self.brightnessView hidden:hidden];
    if (!hidden) {
        self.brightnessView.indicator.image = [UIImage imageNamed:@"icon_video_volume"];
        self.brightnessView.titleLabel.text = @"音量";
        [self.brightnessView setProgress:volume];
        [self bringSubviewToFront:self.brightnessView];
    }
}

- (void)_layout
{
    [self setNeedsLayout];
}

#pragma mark - Animation
- (void)setView:(UIView *)view hidden:(BOOL)hidden
{
    if (view.hidden != hidden) {
        if (hidden) {
            [UIView animateWithDuration:.8f animations:^{
                view.alpha = 0.f;
            } completion:^(BOOL finished) {
                view.hidden = YES;
            }];
        }else{
            view.alpha = 0.f;
            view.hidden = NO;
            [UIView animateWithDuration:.4f animations:^{
                view.alpha = 1.f;
            } completion:^(BOOL finished) {
            }];
        }
    }
}

#pragma mark - Property

- (DDBrightnessIndicator *)brightnessView
{
    if (!_brightnessView) {
        _brightnessView = [DDBrightnessIndicator instance];
        _brightnessView.hidden = YES;
        [self addSubview:_brightnessView];
        
        _brightnessView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[view]-(>=0)-|" options:0 metrics:nil views:@{@"view":_brightnessView}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[view]-(>=0)-|" options:0 metrics:nil views:@{@"view":_brightnessView}]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_brightnessView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_brightnessView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        
        [self _layout];
    }
    return _brightnessView;
}

@end
