//
//  YGEmojiKeyboardViewCtrl.h
//  Golf 抽象了一个，发布动态和发布足迹也可以继承，去掉之前老掉牙的表情键盘
//
//  Created by Main on 2016/9/28.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGBaseViewController.h"
#import "AGEmojiKeyBoardView.h"
#import "YGTAPublishToolBar.h"
#import <YYText/YYTextView.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface YGEmojiKeyboardViewCtrl : YGBaseViewController<AGEmojiKeyboardViewDelegate,AGEmojiKeyboardViewDataSource,YYTextViewDelegate>

// 工具条
@property (strong, nonatomic) YGTAPublishToolBar *toolbar;
@property (weak, nonatomic) IBOutlet YYTextView *textView;
@property (assign, nonatomic) YGKeyboardStatus status;
@property (nonatomic) YGToolbarType toolbarType;
@property (assign, nonatomic) int maxLength; //文本长度限制, 默认1000

- (CGFloat)sizeWithSize:(CGFloat)size;
- (BOOL)isNotEmpty;
@end
