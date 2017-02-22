//
//  YGDatePickerViewCtrl.h
//  Golf
//
//  Created by bo wang on 2016/12/20.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGBasePopViewController.h"

@class YGDatePickerViewCtrl;

@protocol YGDatePickerDelegate <NSObject>
@optional
- (void)datePickerDidCanceled:(YGDatePickerViewCtrl *)datePicker;
- (void)datePicker:(YGDatePickerViewCtrl *)datePicker didSelectedDate:(NSDate *)date;
@end

@interface YGDatePickerViewCtrl : YGBasePopViewController

// 这两个属性在设置了可选择范围时无效。
// 今天之后的日期是否可选。默认为NO，不可选。
@property (assign, nonatomic) BOOL futureDatesSelectable;
// 今天之前的日期是否可选。默认为YES，可选。
@property (assign, nonatomic) BOOL previousDatesSelectable;

// 设置下面2个日期时，将会使 futureDatesSelectable 和 previousDatesSelectable 无效
// 可选择范围起始日期。包含此日期。设置此值时 selectableEndDate 默认为 distantFuture
@property (strong, nonatomic) NSDate *selectableStartDate;
// 可选择范围结束日期。不包含此日期。设置此值时 selectableStartDate 默认为  distantPast
@property (strong, nonatomic) NSDate *selectableEndDate;

// 当前选中的日期。默认为nil。
@property (strong, nonatomic) NSDate *date;

@property (weak, nonatomic) id<YGDatePickerDelegate> delegate;

- (void)show;
- (void)dismiss;

@end
