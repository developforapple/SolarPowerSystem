//
//  DDVideoPlayerIndicatorView.h
//  JuYouQu
//
//  Created by Normal on 16/3/7.
//  Copyright © 2016年 Bo Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDVideoPlayer;

// 指示器
// 指示器有3种  进度、亮度、loading。音量调节采用系统自带。
@interface DDVideoPlayerIndicatorView : UIView

- (void)setBrightness:(CGFloat)p hidden:(BOOL)hidden;
- (void)setVolume:(CGFloat)volume hidden:(BOOL)hidden;

@end
