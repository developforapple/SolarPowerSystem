//
//  HZAreaPickerView.h
//  areapicker
//
//  Created by Cloud Dai on 12-9-9.
//  Copyright (c) 2012年 clouddai.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HZLocation.h"
#import "GToolBar.h"

@class HZAreaPickerView;

@protocol HZAreaPickerDelegate <NSObject>

@optional
- (void)pickerDidChaneStatus:(HZAreaPickerView *)picker;
- (void)pickerDidCancel:(HZAreaPickerView *)picker;
- (void)pickerDidShow:(HZAreaPickerView *)picker;
- (void)pickerDidAnimateFinished:(BOOL)finished;

@end

@interface HZAreaPickerView : UIView <UIPickerViewDelegate, UIPickerViewDataSource,GToolBarDelegate>{
    NSInteger stateIndex;
    NSInteger cityIndex;
    NSInteger districtIndex;
}

@property (weak, nonatomic) id <HZAreaPickerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIPickerView *locatePicker;
@property (strong, nonatomic) HZLocation *locate;
@property (strong, nonatomic) GToolBar *toolBar;
@property (nonatomic) BOOL isNODistrict;

- (id)initWithDelegate:(id<HZAreaPickerDelegate>)delegate locate:(HZLocation *)aLocate isNoDistrict:(BOOL)isNODistrict;
- (void)showInView:(UIView *)view;
- (void)cancelPicker;

@end
