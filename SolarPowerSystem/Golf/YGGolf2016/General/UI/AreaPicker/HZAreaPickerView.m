//
//  HZAreaPickerView.m
//  areapicker
//
//  Created by Cloud Dai on 12-9-9.
//  Copyright (c) 2012年 clouddai.com. All rights reserved.
//

#import "HZAreaPickerView.h"
#import <QuartzCore/QuartzCore.h>

#define kDuration 0.3

@interface HZAreaPickerView ()
{
    NSArray *provinces, *cities, *areas;
}

@end

@implementation HZAreaPickerView

@synthesize delegate=_delegate;
@synthesize locate=_locate;
@synthesize locatePicker = _locatePicker;
@synthesize toolBar = _toolBar;
@synthesize isNODistrict = _isNODistrict;


-(HZLocation *)locate
{
    if (_locate == nil) {
        _locate = [[HZLocation alloc] init];
    }
    
    return _locate;
}

- (id)initWithDelegate:(id<HZAreaPickerDelegate>)delegate locate:(HZLocation *)aLocate isNoDistrict:(BOOL)isNODistrict
{
    
    self = [[[NSBundle mainBundle] loadNibNamed:@"HZAreaPickerView" owner:self options:nil] objectAtIndex:0];
    CGRect rt = self.frame;
    rt.size.width = Device_Width;
    self.frame = rt;
    if (self) {
        self.delegate = delegate;
        self.toolBar = [[GToolBar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
        self.toolBar.toolBarDelegate = self;
        self.toolBar.isCancelBtnHide = YES;
        [self addSubview:self.toolBar];
        
        self.locate = aLocate;
        self.isNODistrict = isNODistrict;
        stateIndex = 0;
        cityIndex = 0;
        districtIndex = 0;
        //加载数据
        provinces = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"chinesearea.plist" ofType:nil]];
        
        if (!(self.locate.state.length>0)) {
            cities = [[provinces objectAtIndex:stateIndex] objectForKey:@"cities"];
            areas = [[cities objectAtIndex:cityIndex] objectForKey:@"areas"];
            self.locate.state = [[provinces objectAtIndex:0] objectForKey:@"state"];
            self.locate.city = [[cities objectAtIndex:0] objectForKey:@"city"];
            
            if (areas.count > 0) {
                self.locate.district = [areas objectAtIndex:0];
            } else{
                self.locate.district = @"";
            }
        }
        
        for (NSDictionary *p in provinces) {
            if (Equal(self.locate.state, [p objectForKey:@"state"])) {
                stateIndex = [provinces indexOfObject:p];
                cities = [[provinces objectAtIndex:stateIndex] objectForKey:@"cities"];
                for (NSDictionary *c in cities) {
                    if (Equal(self.locate.city, [c objectForKey:@"city"])) {
                        cityIndex = [cities indexOfObject:c];
                        areas = [[cities objectAtIndex:cityIndex] objectForKey:@"areas"];
                        for (NSString *d in areas) {
                            if (Equal(self.locate.district, d)) {
                                districtIndex = [areas indexOfObject:d];
                                break;
                            }
                        }
                        break;
                    }
                }
                break;
            }
        }
        self.locatePicker.dataSource = self;
        self.locatePicker.delegate = self;
        
        [self.locatePicker selectRow:stateIndex inComponent:0 animated:NO];
        [self.locatePicker selectRow:cityIndex inComponent:1 animated:NO];
        if (!self.isNODistrict) {
            [self.locatePicker selectRow:districtIndex inComponent:2 animated:NO];
        }
    }
    return self;
}

#pragma mark - PickerView lifecycle

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return self.isNODistrict ? 2 : 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [provinces count];
            break;
        case 1:
            return [cities count];
            break;
        case 2:
            return [areas count];
            break;
        default:
            return 0;
            break;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [[provinces objectAtIndex:row] objectForKey:@"state"];
            break;
        case 1:
            if ([cities count]>0) {
                return [[cities objectAtIndex:row] objectForKey:@"city"];
                break;
            }
        case 2:
            if ([areas count] > 0) {
                return [areas objectAtIndex:row];
                break;
            }
        default:
            return  @"";
            break;
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f, [pickerView rowSizeForComponent:component].width-12, [pickerView rowSizeForComponent:component].height)];
    
    [label setTextAlignment:NSTextAlignmentCenter];
    label.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            cities = [[provinces objectAtIndex:row] objectForKey:@"cities"];
            self.locate.state = [[provinces objectAtIndex:row] objectForKey:@"state"];

            if ([cities count] > 0) {
                [self.locatePicker selectRow:0 inComponent:1 animated:YES];
                [self.locatePicker reloadComponent:1];
                
                areas = [[cities objectAtIndex:0] objectForKey:@"areas"];
                if (!self.isNODistrict) {
                    [self.locatePicker selectRow:0 inComponent:2 animated:YES];
                    [self.locatePicker reloadComponent:2];
                }
                
                self.locate.city = [[cities objectAtIndex:0] objectForKey:@"city"];
                if (!self.isNODistrict) {
                    if ([areas count] > 0) {
                        self.locate.district = [areas objectAtIndex:0];
                    } else{
                        self.locate.district = @"";
                    }
                }
            }else{
                areas = [NSArray array];
                
                [self.locatePicker selectRow:0 inComponent:1 animated:YES];
                [self.locatePicker reloadComponent:1];
                
                if (!self.isNODistrict) {
                    [self.locatePicker selectRow:0 inComponent:2 animated:YES];
                    [self.locatePicker reloadComponent:2];
                }
                
                self.locate.city = @"";
                self.locate.district = @"";
            }
            
            break;
        case 1:
            areas = [[cities objectAtIndex:row] objectForKey:@"areas"];
            if (!self.isNODistrict) {
                [self.locatePicker selectRow:0 inComponent:2 animated:YES];
                [self.locatePicker reloadComponent:2];
            }
            
            self.locate.city = [[cities objectAtIndex:row] objectForKey:@"city"];
            if (!self.isNODistrict) {
                if ([areas count] > 0) {
                    self.locate.district = [areas objectAtIndex:0];
                } else{
                    self.locate.district = @"";
                }
            }
            
            break;
        case 2:
            if ([areas count] > 0) {
                self.locate.district = [areas objectAtIndex:row];
            } else{
                self.locate.district = @"";
            }
            break;
        default:
            break;
    }
}

- (void)toolBarActionWithIndex:(NSInteger)index{
    if (index == 2) {
        if([self.delegate respondsToSelector:@selector(pickerDidChaneStatus:)]) {
            [self.delegate pickerDidChaneStatus:self];
        }
    }
    
    [self cancelPicker];
}


#pragma mark - animation

- (void)showInView:(UIView *) view
{
    self.frame = CGRectMake(0,CGRectGetHeight(view.frame),self.frame.size.width, self.frame.size.height);
    [view addSubview:self];
        
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, CGRectGetHeight(view.frame) - CGRectGetHeight(self.frame), self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(pickerDidShow:)]) {
            [self.delegate pickerDidShow:self];
        }
    }];
}

- (void)cancelPicker
{
    if ([self.delegate respondsToSelector:@selector(pickerDidCancel:)]) {
        [self.delegate pickerDidCancel:self];
    }
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = CGRectMake(0,CGRectGetHeight(self.superview.frame), self.frame.size.width, self.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                     }];
    
}

@end
