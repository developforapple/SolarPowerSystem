//
//  YGGlobalSearchBar.m
//  Golf
//
//  Created by bo wang on 16/8/4.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGGlobalSearchBar.h"
#import "YGUIKitCategories.h"
#import "ReactiveCocoa.h"

@interface YGGlobalSearchBar ()
@property (strong, nonatomic) UIFont *textFont;
@end

@implementation YGGlobalSearchBar

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // TextField 加边框圆角
    UITextField *textField = [self textField];
    textField.layer.borderColor = RGBColor(204, 204, 204, 1).CGColor;
    textField.layer.borderWidth = .5f;
    textField.layer.masksToBounds = YES;
    textField.layer.cornerRadius = 6.f;
    textField.font = self.textFont;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.enablesReturnKeyAutomatically = NO;
    
    if (self.cancelBtnShouldShow) {
        // 显示取消按钮
        [self setShowsCancelButton:YES animated:YES];
        
        // 不让取消按钮变灰色。默认情况下不在输入状态时，取消按钮变灰色。
        UIButton *cancelBtn = [self cancelButton];
        [cancelBtn setTitleColor:RGBColor(69, 154, 211, 1) forState:UIControlStateNormal];
        
        ygweakify(self);
        [RACObserve(cancelBtn, enabled)
         subscribeNext:^(NSNumber *x) {
             if (!x.boolValue) {
                 ygstrongify(self);
                 [[self cancelButton] setEnabled:YES];//强制去掉disable状态
             }
         }];
    }
    
    [self setImage:[UIImage imageNamed:@"search_index"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
}

- (UIColor *)placeholderColor
{
    if (!_placeholderColor) {
        _placeholderColor = [[UIColor blackColor] colorWithAlphaComponent:.7f];
    }
    return _placeholderColor;
}

- (UIFont *)textFont
{
    if (!_textFont) {
        _textFont = [UIFont systemFontOfSize:14];
    }
    return _textFont;
}

- (void)setTextFontSize:(NSInteger)textFontSize
{
    _textFontSize = textFontSize;
    self.textFont = [UIFont systemFontOfSize:textFontSize];
    [self update];
}

- (void)setPlaceholder:(NSString *)placeholder
{
    if (placeholder) {
        [[self textField] setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:placeholder attributes:@{NSFontAttributeName:self.textFont,NSForegroundColorAttributeName:self.placeholderColor}]];
    }
}

- (void)update
{
    [self textField].font = self.textFont;
    [self setText:self.text];
    [self setPlaceholder:self.placeholder];
}

- (void)setPossibleKeywords:(NSArray *)possibleKeywords
{
    NSIndexSet *indexes = [possibleKeywords indexesOfObjectsPassingTest:^BOOL(NSString *obj, NSUInteger idx, BOOL *stop) {
        NSString *k = [obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        return k.length != 0;
    }];
    _possibleKeywords = [possibleKeywords objectsAtIndexes:indexes];
    if (_possibleKeywords.count != 0) {
        [self randomDisplay];
    }
}

- (void)randomDisplay
{
    NSMutableArray *tmp = [NSMutableArray arrayWithArray:self.possibleKeywords];
    [tmp shuffle];
    _possibleKeywords = tmp;
    self.text = [self.possibleKeywords firstObject];
}

- (NSString *)currentKeywords
{
    return [self.possibleKeywords firstObject];
}

@end
