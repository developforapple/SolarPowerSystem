//
//  YGInternationalCodePicker.m
//  Golf
//
//  Created by bo wang on 2016/12/27.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGInternationalCodePicker.h"

@interface YGInternationalCodePicker ()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIControl *backControl;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@end

@implementation YGInternationalCodePicker

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
}

+ (void)selectChinaCodes:(void (^)(YGInternationalCode *code))callback
{
    YGInternationalCodePicker *picker = [YGInternationalCodePicker instanceFromStoryboard];
    picker.codeItems = [YGInternationalCode chinaCodes];
    picker.codeChangedBlock = callback;
    [picker show];
}

- (void)show
{
    [super show];
    [self.textField becomeFirstResponder];
}

- (IBAction)backControlAction:(id)sender
{
    if ([self.textField isEditing]) {
        [self.textField endEditing:YES];
        [self dismiss];
    }else{
        [self.textField becomeFirstResponder];
    }
}

- (void)initUI
{
    self.textField.inputView = self.pickerView;
}

#pragma mark - UIPickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.codeItems.count;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    YGInternationalCode *code = self.codeItems[row];
    NSString *text = [NSString stringWithFormat:@"%@          %@",code.area,code.code];
    NSAttributedString *att = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18],NSForegroundColorAttributeName:RGBColor(51, 51, 51, 1)}];
    return att;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 50.f;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.codeChangedBlock) {
        self.codeChangedBlock(self.codeItems[row]);
    }
}

@end

@implementation YGInternationalCode

- (instancetype)initWithArea:(NSString *)area code:(NSString *)code
{
    self = [super init];
    if (self) {
        self.area = area;
        self.code = code;
    }
    return self;
}

+ (NSArray<YGInternationalCode *> *)chinaCodes
{
    static NSArray *chinaCodes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        chinaCodes = @[[[YGInternationalCode alloc] initWithArea:@"中国大陆" code:@"+86"],
                       [[YGInternationalCode alloc] initWithArea:@"中国香港" code:@"+852"],
                       [[YGInternationalCode alloc] initWithArea:@"中国澳门" code:@"+853"],
                       [[YGInternationalCode alloc] initWithArea:@"中国台湾" code:@"+886"]];
    });
    return chinaCodes;
}

@end
