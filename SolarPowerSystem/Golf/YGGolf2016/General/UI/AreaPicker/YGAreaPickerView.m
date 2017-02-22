//
//  YGAreaPickerView.m
//  Golf
//
//  Created by bo wang on 2016/11/30.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGAreaPickerView.h"

typedef struct _YGIndex {
    NSUInteger c0;
    NSUInteger c1;
    NSUInteger c2;
} _YGIndex;

_YGIndex IndexMake(NSUInteger c0,NSUInteger c1,NSUInteger c2){
    _YGIndex c = {c0,c1,c2};
    return c;
}

#pragma mark - Picker
@interface YGAreaPickerView () <UIPickerViewDelegate,UIPickerViewDataSource>
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) YGAreaManager *areaManager;

@end

@implementation YGAreaPickerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.showDistrict = YES;
        self.pickerView = [[UIPickerView alloc] initWithFrame:frame];
        self.pickerView.delegate = self;
        self.pickerView.dataSource = self;
        self.pickerView.showsSelectionIndicator = YES;
        [self addSubview:self.pickerView];
    }
    return self;
}

+ (instancetype)pickerView
{
    return [[self alloc] initWithFrame:CGRectMake(0, 0, Device_Width, 216.f)];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.pickerView.frame = self.bounds;
}

- (YGAreaManager *)areaManager
{
    return [YGAreaManager areaManager];
}

- (void)reload
{
    [self.pickerView reloadAllComponents];
}

#pragma mark Data
- (YGAreaProvince *)provinceAtIndex:(_YGIndex)index
{
    if (index.c0 < self.areaManager.provinces.count) {
        return self.areaManager.provinces[index.c0];
    }
    return nil;
}

- (YGAreaCity *)cityAtIndex:(_YGIndex)index
{
    YGAreaProvince *province = [self provinceAtIndex:index];
    if (index.c1 < province.cities.count) {
        return province.cities[index.c1];
    }
    return nil;
}

- (YGAreaDistrict *)districtAtIndex:(_YGIndex)index
{
    YGAreaCity *city = [self cityAtIndex:index];
    if (index.c2 < city.districts.count) {
        return city.districts[index.c2];
    }
    return nil;
}

#pragma mark
- (void)setupWithArea:(YGArea *)area
{
    if (!area || !area.province || !area.city || (self.showDistrict?!area.district:NO)){
        [self.pickerView reloadAllComponents];
        return;
    }
    
    YGAreaManager *manager = [YGAreaManager areaManager];
    NSUInteger c0 = [manager.provinces indexOfObject:area.province];
    if (c0 == NSNotFound) return;
    NSUInteger c1 = [area.province.cities indexOfObject:area.city];
    if (!area.province.cities || c1 == NSNotFound) return;
    NSUInteger c2 = [area.city.districts indexOfObject:area.district];
    if (self.showDistrict && (!area.city.districts || c2 == NSNotFound)) return;
    [self.pickerView reloadComponent:0];
    [self.pickerView selectRow:c0 inComponent:0 animated:NO];
    [self.pickerView reloadComponent:1];
    [self.pickerView selectRow:c1 inComponent:1 animated:NO];
    
    if (self.showDistrict && self.pickerView.numberOfComponents > 2) {
        [self.pickerView reloadComponent:2];
        [self.pickerView selectRow:c2 inComponent:2 animated:NO];
    }
}

- (YGArea *)currentArea
{
    YGArea *area = [YGArea new];
    area.province = [self currentProvince];
    area.city = [self currentCity];
    area.district = [self currentDistrict];
    return area;
}

- (YGAreaProvince *)currentProvince
{
    NSUInteger c0 = [self.pickerView selectedRowInComponent:0];
    return [self provinceAtIndex:IndexMake(c0, 0, 0)];
}

- (YGAreaCity *)currentCity
{
    NSUInteger c0 = [self.pickerView selectedRowInComponent:0];
    NSUInteger c1 = [self.pickerView selectedRowInComponent:1];
    return [self cityAtIndex:IndexMake(c0, c1, 0)];
}

- (YGAreaDistrict *)currentDistrict
{
    if (self.showDistrict && self.pickerView.numberOfComponents > 2) {
        NSUInteger c0 = [self.pickerView selectedRowInComponent:0];
        NSUInteger c1 = [self.pickerView selectedRowInComponent:1];
        NSUInteger c2 = [self.pickerView selectedRowInComponent:2];
        return [self districtAtIndex:IndexMake(c0, c1, c2)];
    }
    return nil;
}

#pragma mark - UIPickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return self.showDistrict?3:2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return self.areaManager.provinces.count;
    }
    if (component == 1) {
        NSInteger c0 = [pickerView selectedRowInComponent:0];
        YGAreaProvince *province = [self provinceAtIndex:IndexMake(c0, 0, 0)];
        return province.cities.count;
    }
    if (component == 2) {
        NSInteger c0 = [pickerView selectedRowInComponent:0];
        NSInteger c1 = [pickerView selectedRowInComponent:1];
        YGAreaCity *city = [self cityAtIndex:IndexMake(c0, c1, 0)];
        return city.districts.count;
    }
    return 0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UILabel *)view
{
    UILabel *label;
    if (view && [view isKindOfClass:[UILabel class]]) {
        label = view;
    }else{
        CGSize rowSize = CGSizeMake(Device_Width/[pickerView numberOfComponents], 32.f);
        label = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, rowSize.width-4.f, rowSize.height)];
        label.numberOfLines = 2;
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentCenter;
    }
    if (component == 0) {
        YGAreaProvince *province = [self provinceAtIndex:IndexMake(row, 0, 0)];
        label.text = province.province;
    }
    if (component == 1) {
        NSUInteger c0 = [pickerView selectedRowInComponent:0];
        YGAreaCity *city = [self cityAtIndex:IndexMake(c0, row, 0)];
        label.text = city.city;
    }
    if (component == 2) {
        NSInteger c0 = [pickerView selectedRowInComponent:0];
        NSInteger c1 = [pickerView selectedRowInComponent:1];
        YGAreaDistrict *district = [self districtAtIndex:IndexMake(c0, c1, row)];
        label.text = district;
    }
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        [pickerView reloadComponent:1];
        if ([pickerView numberOfRowsInComponent:1] != 0) {
            [pickerView selectRow:0 inComponent:1 animated:NO];
            if (self.showDistrict && pickerView.numberOfComponents > 2) {
                [pickerView reloadComponent:2];
                [pickerView selectRow:0 inComponent:2 animated:NO];
            }
        }else{
            if (self.showDistrict && pickerView.numberOfComponents > 2) {
                [pickerView reloadComponent:2];
            }
        }
    }else if (component == 1){
        if (self.showDistrict && pickerView.numberOfComponents > 2) {
            [pickerView reloadComponent:2];
            if ([pickerView numberOfRowsInComponent:2] != 0) {
                [pickerView selectRow:0 inComponent:2 animated:NO];
            }
        }
    }
}

@end

