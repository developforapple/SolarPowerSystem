

#import "YGFillInProfileCell.h"

@implementation YGFillInProfileCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [super awakeFromNib];
    [super awakeFromNib];
    _nicknameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入昵称"attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1]}];
    [_nicknameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

}

- (IBAction)clickedHeadimageButton:(id)sender {
    if (_selectHeadimageBlock) {
        _selectHeadimageBlock();
    }
}

- (IBAction)selectMaleButton:(id)sender {
    if (!_maleButton.selected) {
        _maleButton.selected = YES;
        _femaleButton.selected = NO;
        if (_selectGenderBlock) {
            _selectGenderBlock(1);
        }
    }
 
}

- (IBAction)selectFemaleButton:(id)sender {
    if (!_femaleButton.selected) {
        _femaleButton.selected = YES;
        _maleButton.selected = NO;
        if (_selectGenderBlock) {
            _selectGenderBlock(0);
        }
    }
}

- (IBAction)clickedCompletebutton:(id)sender {
    if (_clickCompleteButtonBlock) {
        _clickCompleteButtonBlock();
    }
}


- (void)textFieldDidChange:(UITextField *)textField {
    NSString *toBeString = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *lang = [[UIApplication sharedApplication] textInputMode].primaryLanguage;
    if ([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            if (toBeString.length > 12) {
                textField.text = [toBeString substringToIndex:12];
            }
            if (_textFieldBlock) {
                _textFieldBlock([textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]);
            }
        }
    } else {
        if (toBeString.length > 12) {
            textField.text = [toBeString substringToIndex:12];
        }
        if (_textFieldBlock) {
            _textFieldBlock([textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]);
        }
    }
}
@end
