//
//  YGEmojiKeyboardViewCtrl.m
//  Golf
//
//  Created by Main on 2016/9/28.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGEmojiKeyboardViewCtrl.h"
#import "RecorderView.h"
#import "RecordVoiceView.h"
#import "YGTAPublishTextParser.h"
#import "YYText.h"

@interface YGEmojiKeyboardViewCtrl ()


@property (weak, nonatomic) IBOutlet UIButton *emojiBtn;
@property (weak, nonatomic) IBOutlet UIButton *endEditingBtn;
@property (strong, nonatomic) AGEmojiKeyboardView *emojiView;
@property (strong, nonatomic) RecorderView *recorderView;
@property (strong, nonatomic) RecordVoiceView *recordVoiceKeyboardView;


@end

@implementation YGEmojiKeyboardViewCtrl

#pragma mark - 视图控制

- (void)viewDidLoad {
    [super viewDidLoad];

    [self _initData];
    [self _initUI];
    [self _initSignal];
}

#pragma mark - init

- (void)_initData{
    if (self.maxLength == 0) {
        self.maxLength = 1000;
    }
    
}

- (void)_initUI
{
    self.textView.delegate = self;
    self.textView.inputView = nil;
    self.textView.inputAccessoryView = self.toolbar;
    self.textView.textParser = [YGTAPublishTextParser new];
    self.textView.textContainerInset = UIEdgeInsetsMake(15, 12, 15, 12);
    self.textView.showsVerticalScrollIndicator = NO;
    self.textView.alwaysBounceVertical = YES;
    self.textView.allowsCopyAttributedString = NO;
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.extraAccessoryViewHeight = [YGTAPublishToolBar containerHeight];
    self.textView.inputAccessoryView = [UIView new];
    [self.textView setTintColor:MainHighlightColor];

    
    // 默认文字
    NSString *placeholderPlainText = @"说点什么吧...";
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:placeholderPlainText];
    atr.yy_color = UIColorHex(b4b4b4);
    atr.yy_font = [UIFont systemFontOfSize:16];
    self.textView.placeholderAttributedText = atr;
    
    [self.textView reloadInputViews];
}


- (void)beginRecording {}//不要删，子类要重写此方法
- (void)endRecording {}//不要删，子类要重写此方法
-(RecorderView *)recorderView{
    if (_recorderView == nil) {
        _recorderView = [[NSBundle mainBundle] loadNibNamed:@"RecorderView" owner:self options:nil].firstObject;
        [self.view addSubview:_recorderView];
        _recorderView.hidden = YES;
        __weak YGEmojiKeyboardViewCtrl *weakSelf = self;
        _recorderView.blockAutomaticEnd = ^ {
            weakSelf.recordVoiceKeyboardView.longPressGesture.enabled = NO;
            weakSelf.recordVoiceKeyboardView.longPressGesture.enabled = YES;
        };
    }
    return _recorderView;
}

- (void)_initSignal
{
    ygweakify(self);
    [RACObserve(self, status)
     subscribeNext:^(id x) {
         ygstrongify(self);
         switch (self.status) {
             case YGKeyboardStatusHidden: {
                 if ([self.textView isFirstResponder]) {
                     [self.textView setInputView:nil];
                     [self.textView reloadInputViews];
                     [self.textView endEditing:YES];
                     [self.toolbar handleFactBtn:self.toolbar.isKeyBoardEditing];
                 }
                 break;
             }
             case YGKeyboardStatusStandard: {
                 self.textView.inputView = nil;
                 self.textView.inputAccessoryView = self.toolbar;
                 [self.textView reloadInputViews];
                 [self.toolbar handleFactBtn:YES];
                 if (![self.textView isFirstResponder]) {
                     [self.textView becomeFirstResponder];
                 }
                 break;
             }
             case YGKeyboardStatusEmoji: {
                 self.textView.inputView = self.emojiView;
                 self.textView.inputAccessoryView = self.toolbar;
                 [self.textView reloadInputViews];
                 [self.toolbar handleFactBtn:NO];
                 if (![self.textView isFirstResponder]) {
                     [self.textView becomeFirstResponder];
                 }
                 break;
             }
             case YGKeyboardStatusVoice:{
                 self.textView.inputView = self.recordVoiceKeyboardView;
                 self.textView.inputAccessoryView = self.toolbar;
                 [self.textView reloadInputViews];
                 [self.toolbar handleFactBtn:YES];
                 if (![self.textView isFirstResponder]) {
                     [self.textView becomeFirstResponder];
                 }
                 break;
             }
         }
     }];
}

#pragma mark - getter


-(YGTAPublishToolBar *)toolbar{
    
    if (!_toolbar) {
        if (self.toolbarType == YGToolbarTypeVoice) {
            _toolbar = [[[NSBundle mainBundle] loadNibNamed:@"YGTAPublishVoiceToolBar" owner:self options:nil] lastObject];
        }else{
            _toolbar = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([YGTAPublishToolBar class]) owner:self options:nil] lastObject];
        }
        _toolbar.toolbarType = self.toolbarType;
        _toolbar.width = Device_Width;
    }
    
    if (_toolbar.blockBtnPressed == nil) {
        ygweakify(self)
        _toolbar.blockBtnPressed = ^(YGKeyboardStatus status) {
            ygstrongify(self)
            self.status = status;
        };
    }
    
    
    return _toolbar;
}


-(AGEmojiKeyboardView *)emojiView{
    if (_emojiView == nil) {
        _emojiView = [[AGEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, Device_Width, 251.f) dataSource:self];
        _emojiView.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
        _emojiView.delegate = self;
        ygweakify(self);
        [_emojiView setBlockSendPressed:^(id data){
            ygstrongify(self);
            [self.textView insertText:@"\n"];
        }];
        _emojiView.mySegmentsBar.btnSend.enabled = YES;
        [_emojiView.mySegmentsBar.btnSend setTitle:@"换行" forState:UIControlStateNormal];
    }
    return _emojiView;
}




-(RecordVoiceView *)recordVoiceKeyboardView{
    if (_recordVoiceKeyboardView == nil) {
        ygweakify(self);
        _recordVoiceKeyboardView = [[NSBundle mainBundle] loadNibNamed:@"RecordVoiceView" owner:self options:nil].firstObject;
        _recordVoiceKeyboardView.frame = CGRectMake(0, 0,Device_Width, 271.f);
        
        _recordVoiceKeyboardView.blockBeginRecorder = ^ {
            ygstrongify(self);
            [self beginRecording];
        };
        _recordVoiceKeyboardView.blockEndRecorder = ^ {
            ygstrongify(self);
            [self endRecording];
        };
    }
    return _recordVoiceKeyboardView;
}


#pragma mark - private method

- (BOOL)isNotEmpty{
    return [self.textView.attributedText string].length > 0  && ![Utilities isBlankString:[self.textView.attributedText string]];
}


- (CGFloat)sizeWithSize:(CGFloat)size{
    if (Device_Width == 375.) {
        size *= 375./320;
    }else if (Device_Width == 414.){
        size *= 414./320;
    }
    return size;
}


#pragma mark - YYTextView delegate


- (void)textViewDidChange:(YYTextView *)textView
{
    //该判断用于联想输入
    if (textView.text.length > self.maxLength) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"文字不能超过%d",self.maxLength]];
        textView.text = [textView.text substringToIndex:self.maxLength];
    }
}


- (void)textViewDidBeginEditing:(YYTextView *)textView
{
//    if (self.status > 0) { //获取焦点显示上一次的键盘样式，否则就显示默认键盘
//        return;
//    }
    self.status = YGKeyboardStatusStandard;
}

- (void)textViewDidEndEditing:(YYTextView *)textView
{
    self.status = YGKeyboardStatusHidden;
}


#pragma mark - EmojiDataSource
- (UIImage *)backSpaceButtonImageForEmojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView {
    return [UIImage imageNamed:@"shanchu_"];
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView
      imageForSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category{
    NSAssert(NO, @"Error! required method not implemented in subclass. Need to implement %s", __PRETTY_FUNCTION__);
    return nil;
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView
   imageForNonSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category{
    NSAssert(NO, @"Error! required method not implemented in subclass. Need to implement %s", __PRETTY_FUNCTION__);
    return nil;
}

#pragma mark - Emoji delegate
- (void)emojiKeyBoardViewDidPressBackSpace:(AGEmojiKeyboardView *)emojiKeyBoardView
{
    [self.textView deleteBackward];
}

- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)emojiKeyBoardView didUseEmoji:(NSString *)emoji
{
    [self.textView insertText:emoji];
}


@end
