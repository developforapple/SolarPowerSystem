//
//  YGAreaPickerView.h
//  Golf
//
//  Created by bo wang on 2016/11/30.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGAreaManager.h"

@interface YGAreaPickerView : UIView

//默认216高度
+ (instancetype)pickerView;

// 是否显示区。默认为YES。
@property (assign, nonatomic) BOOL showDistrict;

- (void)reload;

- (void)setupWithArea:(YGArea *)area;

- (YGArea *)currentArea;
- (YGAreaProvince *)currentProvince;
- (YGAreaCity *)currentCity;
- (YGAreaDistrict *)currentDistrict;

@end
