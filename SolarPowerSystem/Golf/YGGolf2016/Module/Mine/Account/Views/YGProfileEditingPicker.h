//
//  YGProfileEditingPicker.h
//  Golf
//
//  Created by bo wang on 2016/12/29.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YGProfileEditingPickerConfig;
@class YGProfileEditingPicker;

typedef NS_ENUM(NSUInteger, YGProfileEditingPickerStyle) {
    YGProfileEditingPickerStyleText,
    YGProfileEditingPickerStyleNumber,
    YGProfileEditingPickerStyleDate,
    YGProfileEditingPickerStyleArea,
};

@protocol YGProfileEditingPickerDelegate <NSObject>
@optional
- (void)editingPicker:(YGProfileEditingPicker *)picker didCanceled:(NSInteger)tag;
- (void)editingPicker:(YGProfileEditingPicker *)picker didCleared:(NSInteger)tag;
- (void)editingPicker:(YGProfileEditingPicker *)picker didDone:(NSInteger)tag;
@end

@interface YGProfileEditingPicker : NSObject

/**
 高度固定为216。作为一个隐藏的UITextField的inputView使用
 */
- (instancetype)initWithParentView:(UIView *)view;

@property (assign, readonly, nonatomic) YGProfileEditingPickerStyle style;
@property (weak, nonatomic) id<YGProfileEditingPickerDelegate> delegate;

// update
- (void)update:(void(^)(YGProfileEditingPickerConfig *config))configBlock;
// NSString NSNumber NSDate YGArea
- (id)currentValue;
@end

#import "YGAreaManager.h"

@interface YGProfileEditingPickerConfig : NSObject
@property (assign, nonatomic) YGProfileEditingPickerStyle style; //default text
@property (assign, nonatomic) NSInteger tag;        //default random
@property (assign, nonatomic) BOOL showCancel;      //default YES
@property (assign, nonatomic) BOOL showClear;       //default NO
@property (assign, nonatomic) BOOL showDone;        //default YES
// for YGProfileEditingPickerStyleText
@property (strong, nonatomic) NSArray<NSString *> *textOptions;//default nil
@property (assign, nonatomic) NSString *text;       //default nil
// for YGProfileEditingPickerStyleNumber
@property (strong, nonatomic) NSArray<NSNumber *> *numberOptions;//default nil
@property (strong, nonatomic) NSNumber *number;     //default nil
// for YGProfileEditingPickerStyleDate
@property (strong, nonatomic) NSDate *minimumDate;  //default distantPast
@property (strong, nonatomic) NSDate *maximumDate;  //default distantFuture
@property (strong, nonatomic) NSDate *date;         //default [NSDate date];
// for YGProfileEditingPickerStyleArea
@property (assign, nonatomic) BOOL showDistrict;    //default NO
@property (strong, nonatomic) YGArea *area;         //default nil
@end
