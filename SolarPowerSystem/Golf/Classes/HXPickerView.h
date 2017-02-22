//
//  HXPickerView.h
//  Golf
//
//  Created by 黄希望 on 14-9-18.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GToolBar.h"
@class HXPickerView;

@protocol HXPickerViewDelegate <NSObject>

@optional
- (void)hxpickerViewCallBackString:(NSString*)backString identifier:(NSString*)identifier;
- (void)hxpickerViewCancel:(HXPickerView *)pickerView;
- (void)hxpickerViewShow:(HXPickerView *)pickerView;

@end

@interface HXPickerView : UIView<UIPickerViewDelegate,UIPickerViewDataSource,GToolBarDelegate>{
    UIPickerView *_pickerview;
    int _maxYeay;
    GToolBar *_toolBar;
    NSString *_year;
    NSString * _month;
    NSString * _day;
    NSInteger row_0;
    NSInteger row_1;
    NSInteger row_2;
}

@property (nonatomic,weak) id<HXPickerViewDelegate> delegate;
@property (nonatomic,copy) NSString *identifier;
@property (nonatomic,copy) NSString *callBackString;

+ (HXPickerView*)sharePickerViewInView:(UIView*)aView identifier:(NSString*)identifier data:(NSString*)dataString delegate:(id<HXPickerViewDelegate>)aDelegate;

+ (void)sharePickerViewInView:(UIView*)aView identifier:(NSString*)identifier data:(NSString*)dataString completion:(void(^)(id callBack))completion;

+ (void)hideInView:(UIView*)aView;
@end
