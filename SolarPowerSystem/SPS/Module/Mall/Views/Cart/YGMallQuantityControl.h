//
//  YGMallQuantityControl.h
//  Golf
//
//  Created by bo wang on 2016/10/10.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YGMallQuantityControl;

@protocol YGMallQuantityControlDelegate <NSObject>
@optional
- (BOOL)quantityControl:(YGMallQuantityControl *)control shouldChangeValue:(NSInteger)toValue from:(NSInteger)fromValue;
- (void)quantityControl:(YGMallQuantityControl *)control didChangedValue:(NSInteger)value;
@end

@interface YGMallQuantityControl : UIView
@property (weak, nonatomic) IBOutlet id<YGMallQuantityControlDelegate> delegate;
@property (assign, nonatomic) IBInspectable NSInteger value;
@property (assign, nonatomic) IBInspectable NSUInteger stepValue;
@end
