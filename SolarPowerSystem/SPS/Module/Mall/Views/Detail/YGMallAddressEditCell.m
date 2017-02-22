//
//  YGMallAddressEditCell.m
//  Golf
//
//  Created by bo wang on 2016/11/29.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallAddressEditCell.h"
#import "YGAreaPickerView.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

NSString *const kYGMallAddressEditCell = @"YGMallAddressEditCell";

@interface YGMallAddressEditCell () <UITextViewDelegate>
{
    BOOL _flag;
}
@property (strong, nonatomic) YGAreaPickerView *areaPickerView;
@end

@implementation YGMallAddressEditCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (YGAreaPickerView *)areaPickerView
{
    if (!_areaPickerView) {
        _areaPickerView = [YGAreaPickerView pickerView];
    }
    return _areaPickerView;
}

- (void)configureWithEditModel:(YGMallAddressEditModel *)model
{
    _editModel = model;
    
    self.infoLabel.text = model.title;
    self.inputTextView.placeholder = model.contentPlaceholder;
    self.inputTextView.text = model.content;
    
    self.accessoryType = model.isInputArea?UITableViewCellAccessoryDisclosureIndicator:UITableViewCellAccessoryNone;
    self.inputTextView.tintColor = model.isInputArea?[UIColor clearColor]:MainHighlightColor;
    
    if (model.isInputArea) {
//        self.inputTextView.scrollEnabled = NO;
        self.inputTextView.inputView = self.areaPickerView;
    }else{
        self.inputTextView.inputView = nil;
    }
    
    switch (model.row) {
        case YGMallAddressEditRowPhone:
        case YGMallAddressEditRowPostcode:{
            self.inputTextView.keyboardType = UIKeyboardTypeNumberPad;
        }   break;
        case YGMallAddressEditRowArea:
        case YGMallAddressEditRowName:
        case YGMallAddressEditRowAddress:{
            self.inputTextView.keyboardType = UIKeyboardTypeDefault;
        }   break;
    }
    
    if ([model.title isEqualToString:@"详细地址"] && !_flag) {
        _flag = YES;
        [self.contentView layoutIfNeeded];
        CGFloat h = self.inputTextView.contentSize.height + 16.f;
        if (self.shouldUpdateHeight) {
            self.shouldUpdateHeight(self.editModel,h);
        }
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (self.editModel.isInputArea) {
        [self.areaPickerView setupWithArea:self.editModel.area];
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView endEditing:YES];
        return NO;
    }
    
    NSString * toBeString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if (toBeString.length > self.editModel.maximumWords) {
        textView.text = [toBeString substringToIndex:self.editModel.maximumWords];
        return NO;
    }
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (self.editModel.isInputArea) {
        YGArea *area = [self.areaPickerView currentArea];
        self.editModel.area = area;
        textView.text = [NSString stringWithFormat:@"%@%@%@",area.province.province,area.city.city,area.district];
    }
    self.editModel.content = textView.text;
    CGFloat h = textView.contentSize.height + 16.f; //上下各8
    if (self.shouldUpdateHeight) {
        self.shouldUpdateHeight(self.editModel,h);
    }
}

@end

#import "YGMallAddressModel.h"

@implementation YGMallAddressEditModel

- (instancetype)initWithRow:(YGMallAddressEditRow)row title:(NSString *)title placeholder:(NSString *)placeholder words:(NSInteger)words
{
    self = [super init];
    if (self) {
        self.row = row;
        self.title = title;
        self.contentPlaceholder = placeholder;
        self.maximumWords = words;
        self.isInputArea = NO;
        self.isRequired = YES;
    }
    return self;
}

+ (NSArray<YGMallAddressEditModel *> *)createEditModel:(YGMallAddressModel *)address
{
    YGMallAddressEditModel *nameModel = [[YGMallAddressEditModel alloc] initWithRow:YGMallAddressEditRowName title:@"收货人" placeholder:@"请填写联系人姓名" words:10];
    YGMallAddressEditModel *phoneModel = [[YGMallAddressEditModel alloc] initWithRow:YGMallAddressEditRowPhone title:@"电话号码" placeholder:@"请填写电话号码" words:12];
    YGMallAddressEditModel *areaModel = [[YGMallAddressEditModel alloc] initWithRow:YGMallAddressEditRowArea title:@"所在省市" placeholder:@"请选择省市区" words:NSIntegerMax];
    areaModel.isInputArea = YES;
    YGMallAddressEditModel *addressModel = [[YGMallAddressEditModel alloc] initWithRow:YGMallAddressEditRowAddress title:@"详细地址" placeholder:@"请填写详细地址" words:50];
    YGMallAddressEditModel *postcodeModel = [[YGMallAddressEditModel alloc] initWithRow:YGMallAddressEditRowPostcode title:@"邮政编码" placeholder:@"选填" words:6];
    postcodeModel.isRequired = NO;
    
    if (address) {
        nameModel.content = address.link_man;
        phoneModel.content = address.link_phone;
        addressModel.content = address.address;
        postcodeModel.content = address.post_code;
        
        areaModel.content = [NSString stringWithFormat:@"%@%@%@",address.province_name,address.city_name,address.district_name];
        areaModel.area = [YGAreaManager areaWithProvince:address.province_name city:address.city_name district:address.district_name];
    }
    
    return @[nameModel,phoneModel,areaModel,addressModel,postcodeModel];
}

+ (YGMallAddressModel *)createAddressModel:(NSArray<YGMallAddressEditModel *> *)editModels
{
    YGMallAddressModel *model = [YGMallAddressModel new];
    
    for (YGMallAddressEditModel *editModel in editModels) {
        switch (editModel.row) {
            case YGMallAddressEditRowName: model.link_man = editModel.content;break;
            case YGMallAddressEditRowPhone:model.link_phone = editModel.content;break;
            case YGMallAddressEditRowArea:{
                model.province_name = editModel.area.province.province;
                model.city_name = editModel.area.city.city;
                model.district_name = editModel.area.district;
            }   break;
            case YGMallAddressEditRowAddress:model.address = editModel.content;break;
            case YGMallAddressEditRowPostcode:model.post_code = editModel.content;break;
        }
    }
    model.address_id = -1;
    model.is_default = NO;
    return model;
}

@end
