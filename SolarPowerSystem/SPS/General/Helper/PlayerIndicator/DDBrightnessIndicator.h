//
//  DDBrightnessIndicator.h
//  JuYouQu
//
//  Created by Normal on 16/2/17.
//  Copyright © 2016年 Bo Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDGridProgressView.h"

@interface DDBrightnessIndicator : UIView

+ (instancetype)instance;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *indicator;
@property (weak, nonatomic) IBOutlet DDGridProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *effectView;

- (void)setProgress:(CGFloat)progress;

@end
