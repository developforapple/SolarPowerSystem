//
//  HXPickerView.m
//  Golf
//
//  Created by 黄希望 on 14-9-18.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "HXPickerView.h"

@interface HXPickerView()

@property (nonatomic,copy) void (^completion)(id callBack);

@end

@implementation HXPickerView

HXPickerView *_standerHXPickerView = nil;

+ (void)hideInView:(UIView*)aView{
    for (UIView *v in aView.subviews) {
        if ([v isKindOfClass:[HXPickerView class]]) {
            HXPickerView *standerHXPickerView = (HXPickerView*)v;
            if (standerHXPickerView) {
                [UIView animateWithDuration:0.3 animations:^{
                    standerHXPickerView.frame = CGRectMake(0, Device_Height, Device_Width, 260);
                } completion:^(BOOL finished) {
                    [standerHXPickerView removeFromSuperview];
                }];
            }
        }
    }
}

- (id)initWithFrame:(CGRect)frame identifier:(NSString*)identifier data:(NSString*)dataString delegate:(id<HXPickerViewDelegate>)aDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.identifier = identifier;
        self.callBackString = dataString;
        self.delegate = aDelegate;
        
        _toolBar = [[GToolBar alloc] initWithFrame:CGRectMake(0, 0, Device_Width, 44)];
        _toolBar.toolBarDelegate = self;
        [self addSubview:_toolBar];
        
        _pickerview = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, Device_Width, 220)];
        _pickerview.delegate = self;
        _pickerview.dataSource = self;
        _pickerview.showsSelectionIndicator = YES;
        _pickerview.backgroundColor = [UIColor whiteColor];
        [self addSubview:_pickerview];
        
        if (Equal(self.identifier, @"birthday")) {
            _maxYeay = [[Utilities getCurrentTimeWithFormatter:@"yyyy"] intValue];
        }
        
        if (Equal(self.identifier, @"birthday")||Equal(self.identifier, @"handicap")) {
            _toolBar.isClearBtnHide = NO;
        }
        
        if (Equal(self.identifier, @"seniority")) {
            NSString *s = [NSString stringWithFormat:@"%@年",self.callBackString];
            if ([[self seniorityList] containsObject:s]) {
                [_pickerview selectRow:[[self seniorityList] indexOfObject:s] inComponent:0 animated:YES];
            }else{
                [_pickerview selectRow:4 inComponent:0 animated:YES];
                row_0 = -1;
            }
        }else if (Equal(self.identifier, @"gender")) {
            if ([self.callBackString intValue]==1) {
                [_pickerview selectRow:0 inComponent:0 animated:YES];
            }else if ([self.callBackString intValue] == 0){
                [_pickerview selectRow:1 inComponent:0 animated:YES];
            } else {
                row_0 = -1;
            }
        }else if (Equal(self.identifier, @"birthday")){
            if (self.callBackString.length>0) {
                NSArray *array = [self.callBackString componentsSeparatedByString:@"-"];
                if ([[self ageOfYears] containsObject:[NSString stringWithFormat:@"%@年",[array objectAtIndex:0]]]) {
                    [_pickerview selectRow:[[self ageOfYears] indexOfObject:[NSString stringWithFormat:@"%@年",[array objectAtIndex:0]]] inComponent:0 animated:YES];
                }else{
                    [_pickerview selectRow:80 inComponent:0 animated:YES];
                }
                if ([[self ageOfMonths] containsObject:[NSString stringWithFormat:@"%@月",[array objectAtIndex:1]]]) {
                    [_pickerview selectRow:[[self ageOfMonths] indexOfObject:[NSString stringWithFormat:@"%@月",[array objectAtIndex:1]]] inComponent:1 animated:YES];
                }else{
                    [_pickerview selectRow:0 inComponent:1 animated:YES];
                }
                if ([[self ageOfDays] containsObject:[NSString stringWithFormat:@"%@日",[array objectAtIndex:2]]]) {
                    [_pickerview selectRow:[[self ageOfDays] indexOfObject:[NSString stringWithFormat:@"%@日",[array objectAtIndex:2]]] inComponent:2 animated:YES];
                }else{
                    [_pickerview selectRow:0 inComponent:2 animated:YES];
                }
            }else{
                [_pickerview selectRow:80 inComponent:0 animated:YES];
                [_pickerview selectRow:0 inComponent:1 animated:YES];
                [_pickerview selectRow:0 inComponent:2 animated:YES];
                row_0 = -1;
            }
            [_pickerview reloadAllComponents];
        }else if (Equal(self.identifier, @"handicap")){
            if ([[self handicaps] containsObject:self.callBackString]) {
                [_pickerview selectRow:[[self handicaps] indexOfObject:self.callBackString] inComponent:0 animated:YES];
            }else{
                [_pickerview selectRow:28 inComponent:0 animated:YES];
                row_0 = -1;
            }
        }else if (Equal(self.identifier, @"score")){
            if ([[self scores] containsObject:self.callBackString]) {
                [_pickerview selectRow:[[self scores] indexOfObject:self.callBackString] inComponent:0 animated:YES];
            }else{
                [_pickerview selectRow:28 inComponent:0 animated:YES];
                row_0 = -1;
            }
        }
        
        if(row_0 != -1) {
            if (Equal(self.identifier, @"birthday")) {
                row_0 = [_pickerview selectedRowInComponent:0];
                row_1 = [_pickerview selectedRowInComponent:1];
                row_2 = [_pickerview selectedRowInComponent:2];
            }else{
                row_0 = [_pickerview selectedRowInComponent:0];
            }
        }
    }
    return self;
}

+ (HXPickerView*)sharePickerViewInView:(UIView*)aView identifier:(NSString*)identifier data:(NSString*)dataString delegate:(id<HXPickerViewDelegate>)aDelegate{
    for (UIView *v in aView.subviews) {
        if ([v isKindOfClass:[HXPickerView class]]) {
            HXPickerView *standerHXPickerView = (HXPickerView*)v;
            if (standerHXPickerView) {
                [UIView animateWithDuration:0.3 animations:^{
                    standerHXPickerView.frame = CGRectMake(0, Device_Height, Device_Width, 260);
                } completion:^(BOOL finished) {
                    [standerHXPickerView removeFromSuperview];
                }];
            }
        }
    }
    
    _standerHXPickerView = [[self alloc] initWithFrame:CGRectMake(0, Device_Height, Device_Width, 260) identifier:identifier data:dataString delegate:aDelegate];
    [aView addSubview:_standerHXPickerView];
    
    [UIView animateWithDuration:0.3 animations:^{
        _standerHXPickerView.frame = CGRectMake(0, Device_Height-260, Device_Width, 260);
    } completion:^(BOOL finished) {
        if (finished) {
            if ([_standerHXPickerView.delegate respondsToSelector:@selector(hxpickerViewShow:)]) {
                [_standerHXPickerView.delegate hxpickerViewShow:_standerHXPickerView];
            }
            
        }
        
    }];
    return _standerHXPickerView;
}

+ (void)sharePickerViewInView:(UIView*)aView identifier:(NSString*)identifier data:(NSString*)dataString completion:(void(^)(id callBack))completion{
    _standerHXPickerView = [HXPickerView sharePickerViewInView:aView identifier:identifier data:dataString delegate:nil];
    _standerHXPickerView.completion = completion;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    if (Equal(self.identifier, @"gender")) {
        return 1;
    }else if (Equal(self.identifier, @"birthday")){
        return 3;
    }else if (Equal(self.identifier, @"handicap")){
        return 1;
    }else if (Equal(self.identifier, @"score")){
        return 1;
    }else if (Equal(self.identifier, @"seniority")){
        return 1;
    }
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (Equal(self.identifier, @"gender")) {
        return 2;
    }else if (Equal(self.identifier, @"birthday")){
        if (component==0) {
            return _maxYeay-1900+1;
        }else if (component==1){
            return [self ageOfMonths].count;
        }else {
            return [self ageOfDays].count;
        }
    }else if (Equal(self.identifier, @"handicap")){
        return [self handicaps].count;
    }else if (Equal(self.identifier, @"score")){
        return [self scores].count;
    }else if (Equal(self.identifier, @"seniority")){
        return [self seniorityList].count;
    }
    return 0;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (Equal(self.identifier, @"birthday")) {
        if (component == 0 || component == 1) {
            [_pickerview reloadAllComponents];
        }
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 30;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (Equal(self.identifier, @"gender")) {
        return [@[@"男",@"女"] objectAtIndex:row];
    }else if (Equal(self.identifier, @"birthday")){
        if (component==0) {
            return [[self ageOfYears] objectAtIndex:row];
        }else if (component==1){
            return [[self ageOfMonths] objectAtIndex:row];
        }else {
            return [[self ageOfDays] objectAtIndex:row];
        }
    }else if (Equal(self.identifier, @"handicap")){
        return [[self handicaps] objectAtIndex:row];
    }else if (Equal(self.identifier, @"score")){
        return [[self scores] objectAtIndex:row];
    }else if (Equal(self.identifier, @"seniority")){
        return [[self seniorityList] objectAtIndex:row];
    }
    return 0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f, [pickerView rowSizeForComponent:component].width-12, [pickerView rowSizeForComponent:component].height)];
    
    [label setTextAlignment:NSTextAlignmentCenter];
    label.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return label;
}


- (NSArray *)ageOfYears{
    NSMutableArray *array = [NSMutableArray array];
    for (int i=1900; i<=_maxYeay; i++) {
        [array addObject:[NSString stringWithFormat:@"%d年",i]];
    }
    return array;
}

- (NSArray *)ageOfMonths{
    NSInteger row_a = [_pickerview selectedRowInComponent:0];
    NSString *year = [[self ageOfYears] objectAtIndex:row_a];
    int y = [[year substringToIndex:year.length-1] intValue];
    
    int month = 12;
    
    if (y == _maxYeay) {
        month = [[Utilities getCurrentTimeWithFormatter:@"MM"] intValue];
    }
    
    NSMutableArray *array = [NSMutableArray array];
    for (int i=1; i<=month; i++) {
        [array addObject:[NSString stringWithFormat:@"%d月",i]];
    }
    return array;
}

- (NSArray *)ageOfDays{
    NSInteger row_a = [_pickerview selectedRowInComponent:0];
    NSString *year = [[self ageOfYears] objectAtIndex:row_a];
    int y = [[year substringToIndex:year.length-1] intValue];
    
    NSInteger row_b = [_pickerview selectedRowInComponent:1];
    NSString *month = [[self ageOfMonths] objectAtIndex:row_b];
    int m = [[month substringToIndex:month.length-1] intValue];
    
    int currentMonth = [[Utilities getCurrentTimeWithFormatter:@"MM"] intValue];
    
    int max = 31;
    if((m<=7 && m % 2==0) || (m>=8 && m % 2==1)) {
        max = 30;
        if(m==2) {
            if( (y % 400 == 0) || (y % 4 == 0 && y % 100 != 0) ) {
                max = 29;
            } else {
                max = 28;
            }
        }
    }
    
    if (y == _maxYeay && m == currentMonth){
        max = [[Utilities getCurrentTimeWithFormatter:@"dd"] intValue];
    }
    
    NSMutableArray *array = [NSMutableArray array];
    for (int i=1; i<= max; i++) {
        [array addObject:[NSString stringWithFormat:@"%d日",i]];
    }
    return array;
}

- (NSArray*)handicaps{
    NSMutableArray *array = [NSMutableArray array];
    for (int i=-20; i<=50; i++) {
        [array addObject:[NSString stringWithFormat:@"%d",i]];
    }
    return array;
}

- (NSArray*)scores{
    NSMutableArray *array = [NSMutableArray array];
    for (int i=50; i<=140; i++) {
        [array addObject:[NSString stringWithFormat:@"%d",i]];
    }
    return array;
}

- (NSArray*)seniorityList{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:50];
    for (int i=1; i<=50; i++) {
        [array addObject:[NSString stringWithFormat:@"%d年",i]];
    }
    return array;
}

- (void)toolBarActionWithIndex:(NSInteger)index{
    if (index == 2) {
        BOOL _isNeedSubmit = NO;
        if (Equal(self.identifier, @"birthday")) {
            NSInteger row_a = [_pickerview selectedRowInComponent:0];
            NSInteger row_b = [_pickerview selectedRowInComponent:1];
            NSInteger row_c = [_pickerview selectedRowInComponent:2];
            
            [self pickerSelectRow:row_a inComponent:0];
            [self pickerSelectRow:row_b inComponent:1];
            [self pickerSelectRow:row_c inComponent:2];
            
            NSString *birthday = [NSString stringWithFormat:@"%04d-%02d-%02d",[_year intValue],[_month intValue],[_day intValue]];
            
            if (row_0==row_a && row_1==row_b && row_2==row_c && Equal(self.callBackString, birthday)) {
                _isNeedSubmit = NO;
            }else{
                _isNeedSubmit = YES;
            }
            self.callBackString = birthday;
        }else{
            NSInteger row_a = [_pickerview selectedRowInComponent:0];
            [self pickerSelectRow:row_a inComponent:0];
            if (row_0 != row_a) {
                _isNeedSubmit = YES;
            }
        }
        
        if (_isNeedSubmit) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(hxpickerViewCallBackString:identifier:)]) {
                [self.delegate hxpickerViewCallBackString:self.callBackString identifier:self.identifier];
            }else if (self.completion){
                self.completion (self.callBackString);
            }
        }
    }else if (index == 3){
        if (Equal(self.identifier, @"birthday")||Equal(self.identifier, @"handicap")) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(hxpickerViewCallBackString:identifier:)]) {
                [self.delegate hxpickerViewCallBackString:@"" identifier:self.identifier];
            }else if (self.completion){
                self.completion (@"");
            }
        }
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        _standerHXPickerView.frame = CGRectMake(0, Device_Height, Device_Width, 260);
    } completion:^(BOOL finished) {
        if (self&&self.superview) {
            [self removeFromSuperview];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(hxpickerViewCancel:)]) {
            [self.delegate hxpickerViewCancel:self];
        }
    }];
}

- (void)pickerSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (Equal(self.identifier, @"gender")) {
        if (row == 0)
            self.callBackString = [NSString stringWithFormat:@"1"];
        else
            self.callBackString = [NSString stringWithFormat:@"0"];
    }else if (Equal(self.identifier, @"birthday")){
        if (component==0) {
            _year = [[self ageOfYears] objectAtIndex:row];
            _year = [_year substringToIndex:_year.length-1];
        }else if (component==1){
            _month = [[self ageOfMonths] objectAtIndex:row];
            _month = [_month substringToIndex:_month.length-1];
        }else {
            _day = [[self ageOfDays] objectAtIndex:row];
            _day = [_day substringToIndex:_day.length-1];
        }
        if (_year.length>0&&_month.length>0&&_day.length>0) {
            self.callBackString = [NSString stringWithFormat:@"%04d-%02d-%02d",[_year intValue],[_month intValue],[_day intValue]];
        }
    }else if (Equal(self.identifier, @"handicap")){
        self.callBackString = [[self handicaps] objectAtIndex:row];
    }else if (Equal(self.identifier, @"score")){
        self.callBackString = [[self scores] objectAtIndex:row];
    }else if (Equal(self.identifier, @"seniority")){
        NSString *seniority = [[[self seniorityList] objectAtIndex:row] description];
        self.callBackString = [seniority substringToIndex:seniority.length-1];
    }
}

@end
