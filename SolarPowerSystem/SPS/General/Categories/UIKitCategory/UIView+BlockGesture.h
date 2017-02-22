//
//  UIView+BlockGesture.h
//  Golf
//
//  Created by bo wang on 2016/12/15.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^YGGestureBlock)(__kindof UIGestureRecognizer *gr);

@interface UIView (BlockGesture)

// 为NO时，当使用下述方法添加手势时，将会自动设置 userInteractionEnabled 为YES。
// 更改此属性为YES时，将取消此特性
// 默认不做任何设置，为NO
@property (assign, nonatomic) BOOL setupUserInteractionOutside;

// 单击
- (UITapGestureRecognizer *)whenTapped:(YGGestureBlock)block;

// 双击
- (UITapGestureRecognizer *)whenDoubleTapped:(YGGestureBlock)block;

// 双指点击
- (UITapGestureRecognizer *)whenDoubleTouchTapped:(YGGestureBlock)block;

// 长按
- (UILongPressGestureRecognizer *)whenLongPressed:(YGGestureBlock)block;

// 拖动
- (UIPanGestureRecognizer *)whenPan:(YGGestureBlock)block;

// 捏合
- (UIPinchGestureRecognizer *)whenPinch:(YGGestureBlock)block;

// 旋转
- (UIRotationGestureRecognizer *)whenRotation:(YGGestureBlock)block;

// 轻扫，全部方向
- (UISwipeGestureRecognizer *)whenSwip:(YGGestureBlock)block;

// 指定方向轻扫
- (UISwipeGestureRecognizer *)whenSwipDirection:(UISwipeGestureRecognizerDirection)direction block:(YGGestureBlock)block;

@end
