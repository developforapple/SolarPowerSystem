//
//  YGProfileEditingPicker.m
//  Golf
//
//  Created by bo wang on 2016/12/29.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGProfileEditingPicker.h"
#import "YGAreaPickerView.h"

#pragma mark - interface
@interface YGProfileEditingToolbar : UIToolbar
@property (assign, nonatomic) BOOL showCancel;
@property (assign, nonatomic) BOOL showClear;
@property (assign, nonatomic) BOOL showDone;
@property (strong, nonatomic) UIBarButtonItem *cancelBtn;
@property (strong, nonatomic) UIBarButtonItem *clearBtn;
@property (strong, nonatomic) UIBarButtonItem *doneBtn;
@property (weak, nonatomic) YGProfileEditingPicker *picker;
- (instancetype)initWithPicker:(YGProfileEditingPicker *)picker;
- (void)setup:(YGProfileEditingPickerConfig *)config;
@end

@interface YGProfileEditingPickerConfig ()
// 适用于文本和数字
- (NSInteger)curContentIndex;
@end

@interface YGProfileEditingPicker () <UIPickerViewDelegate,UIPickerViewDataSource>
@property (strong, nonatomic) UIView *inputView;
@property (assign, readwrite, nonatomic) YGProfileEditingPickerStyle style;
@property (strong, nonatomic) UIPickerView *normalPicker;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) YGAreaPickerView *areaPicker;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) YGProfileEditingPickerConfig *config;
@property (strong, nonatomic) YGProfileEditingToolbar *toolbar;
@end

#pragma mark - implementation
@implementation YGProfileEditingPicker

- (instancetype)initWithParentView:(UIView *)view
{
    self = [super init];
    if (self) {
        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(-100, -100, 22, 22)];
        self.textField.alpha = 0.f;
        
        self.toolbar = [[YGProfileEditingToolbar alloc] initWithPicker:self];
        UIView *theView = view?:[UIApplication sharedApplication].keyWindow;
        [theView addSubview:self.textField];
    }
    return self;
}

- (UIPickerView *)normalPicker
{
    if (!_normalPicker) {
        _normalPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, Device_Width, 216.f)];
        _normalPicker.delegate = self;
        _normalPicker.dataSource = self;
        _normalPicker.showsSelectionIndicator = YES;
        _normalPicker.backgroundColor = [UIColor whiteColor];
    }
    return _normalPicker;
}

- (UIDatePicker *)datePicker
{
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, Device_Width, 216.f)];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        _datePicker.maximumDate = [NSDate date];
        _datePicker.backgroundColor = [UIColor whiteColor];
    }
    return _datePicker;
}

- (YGAreaPickerView *)areaPicker
{
    if (!_areaPicker) {
        _areaPicker = [[YGAreaPickerView alloc] initWithFrame:CGRectMake(0, 0, Device_Width, 216.f)];
        _areaPicker.backgroundColor = [UIColor whiteColor];
    }
    return _areaPicker;
}

- (void)dealloc
{
    _delegate = nil;
    [_textField endEditing:YES];
    _textField.inputView = nil;
    _textField.inputAccessoryView = nil;
    [_textField removeFromSuperview];
    _textField = nil;
    _toolbar = nil;
    _normalPicker = nil;
    _areaPicker = nil;
    _datePicker = nil;
    _config = nil;
}

- (void)btnAction:(UIBarButtonItem *)item
{
    [self.textField endEditing:YES];
    if (item == self.toolbar.cancelBtn) {
        if ([self.delegate respondsToSelector:@selector(editingPicker:didCanceled:)]) {
            [self.delegate editingPicker:self didCanceled:self.config.tag];
        }
    }else if (item == self.toolbar.doneBtn){
        if ([self.delegate respondsToSelector:@selector(editingPicker:didDone:)]) {
            [self.delegate editingPicker:self didDone:self.config.tag];
        }
    }else if (item == self.toolbar.clearBtn){
        if ([self.delegate respondsToSelector:@selector(editingPicker:didCleared:)]) {
            [self.delegate editingPicker:self didCleared:self.config.tag];
        }
    }
}

- (void)update:(void(^)(YGProfileEditingPickerConfig *config))configBlock
{
    YGProfileEditingPickerConfig *configInstance = [YGProfileEditingPickerConfig new];
    if (configBlock) {
        configBlock(configInstance);
    }
    self.config = configInstance;
    self.style = configInstance.style;
    [self.toolbar setup:configInstance];
    [self updatePickerViews];
    
    self.textField.inputView = self.inputView;
    self.textField.inputAccessoryView = self.toolbar;
    if (![self.textField isFirstResponder]) {
        [self.textField becomeFirstResponder];
    }
    [self.textField reloadInputViews];
}

- (void)updatePickerViews
{
    BOOL normalPickerVisible = self.style == YGProfileEditingPickerStyleText ||
                               self.style == YGProfileEditingPickerStyleNumber;
    BOOL datePickerVisible = self.style == YGProfileEditingPickerStyleDate;
    BOOL areaPickerVisible = self.style == YGProfileEditingPickerStyleArea;
    self.normalPicker.hidden = !normalPickerVisible;
    self.datePicker.hidden = !datePickerVisible;
    self.areaPicker.hidden = !areaPickerVisible;
    
    if (normalPickerVisible) {
        [self.normalPicker reloadAllComponents];
        [self.normalPicker selectRow:[self.config curContentIndex] inComponent:0 animated:YES];
        self.inputView = self.normalPicker;
    }
    if (areaPickerVisible) {
        self.areaPicker.showDistrict = self.config.showDistrict;
        [self.areaPicker setupWithArea:self.config.area];
        self.inputView = self.areaPicker;
    }
    if (datePickerVisible) {
        self.datePicker.minimumDate = self.config.minimumDate;
        self.datePicker.maximumDate = self.config.maximumDate;
        self.datePicker.date = self.config.date?:[NSDate date];
        self.inputView = self.datePicker;
    }
}

- (id)currentValue
{
    id value;
    switch (self.style) {
        case YGProfileEditingPickerStyleText:{
            NSInteger row = [self.normalPicker selectedRowInComponent:0];
            value = self.config.textOptions[row];
        }   break;
        case YGProfileEditingPickerStyleNumber:{
            NSInteger row = [self.normalPicker selectedRowInComponent:0];
            value = self.config.numberOptions[row];
        }   break;
        case YGProfileEditingPickerStyleDate:{
            value = self.datePicker.date;
        }   break;
        case YGProfileEditingPickerStyleArea:{
            value = [self.areaPicker currentArea];
        }   break;
    }
    return value;
}

#pragma mark UIPickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    BOOL isTextPicker = self.style == YGProfileEditingPickerStyleText;
    BOOL isNumberPicker = self.style == YYCategoriesVersionNumber;
    return isTextPicker?self.config.textOptions.count:(isNumberPicker?self.config.numberOptions.count:0);
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label;
    if (view && [view isKindOfClass:[UILabel class]]) {
        label = (UILabel *)view;
    }else{
        CGSize size = [pickerView rowSizeForComponent:component];
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:16];
    }
    NSString *text;
    if (self.style == YGProfileEditingPickerStyleText) {
        text = self.config.textOptions[row];
    }else if (self.style == YGProfileEditingPickerStyleNumber){
        text = [self.config.numberOptions[row] stringValue];
    }else{
        text = @"";
    }
    label.text = text;
    return label;
}

@end

@implementation YGProfileEditingToolbar
- (instancetype)initWithPicker:(YGProfileEditingPicker *)picker
{
    self = [super initWithFrame:CGRectMake(0, 0, Device_Width, 44.f)];
    if (self) {
        self.picker = picker;
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self.picker action:@selector(btnAction:)];
    self.clearBtn = [[UIBarButtonItem alloc] initWithTitle:@"清除" style:UIBarButtonItemStyleDone target:self.picker action:@selector(btnAction:)];
    self.doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self.picker action:@selector(btnAction:)];
    self.cancelBtn.tintColor = MainTintColor;
    self.clearBtn.tintColor = MainTintColor;
    self.doneBtn.tintColor = MainTintColor;
    _showCancel = YES;
    _showDone = YES;
    _showClear = YES;
    [self updateItems];
}

- (void)updateItems
{
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSMutableArray *items = [NSMutableArray array];
    self.showCancel ?   [items addObject:self.cancelBtn]:0;
    [items addObject:flexibleItem];
    self.showClear  ?   [items addObject:self.clearBtn] :0;
    self.showDone   ?   [items addObject:self.doneBtn]  :0;
    [self setItems:items animated:YES];
}

- (void)setup:(YGProfileEditingPickerConfig *)config
{
    self.showCancel = config.showCancel;
    self.showClear = config.showClear;
    self.showDone = config.showDone;
    [self updateItems];
}
@end

@implementation YGProfileEditingPickerConfig
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.style = YGProfileEditingPickerStyleText;
        self.showDone = YES;
        self.showCancel = YES;
        self.showClear = NO;
        self.showDistrict = NO;
        self.minimumDate = [NSDate distantPast];
        self.maximumDate = [NSDate distantFuture];
        self.date = [NSDate date];
        self.tag = arc4random_uniform(10e7);
    }
    return self;
}

- (NSInteger)curContentIndex
{
    if (self.style == YGProfileEditingPickerStyleText) {
        NSInteger idx = self.text?[self.textOptions indexOfObject:self.text]:0;
        return idx==NSNotFound?0:idx;
    }
    if (self.style == YGProfileEditingPickerStyleNumber) {
        NSInteger idx = self.number?[self.numberOptions indexOfObject:self.number]:0;
        return idx==NSNotFound?0:idx;
    }
    return 0;
}
@end
