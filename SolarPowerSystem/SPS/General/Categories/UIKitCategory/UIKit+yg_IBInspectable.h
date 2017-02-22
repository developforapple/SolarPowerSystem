//
//  UIKit+yg_IBInspectable.h
//  Golf
//
//  Created by bo wang on 16/6/29.
//  Copyright © 2016年 云高科技. All rights reserved.
//


#import <UIKit/UIKit.h>

/*!
 *  这里设置了很多可以在IB中使用的可设值的属性。在IB中设定值后，将会在运行时自动使用 KVC 调用属性的setter方法。
 *  所以这里每个属性都必须实现其 setter 方法。
 *
 *  IBInspectable 可以使用的类型：整形、浮点、BOOL、UIColor、CGSize、CGRect、NSRange、CGPoint、UIImage、NSString
 *  
 *  NSObject+KVCExceptionCatch.h 中对异常进行了处理，通过断言发现错误的key值，保障不会出现crash。
 */

#pragma mark - UIView

// 对应CALayer属性。
@interface UIView (yg_IBInspectable)
@property (assign, nonatomic) IBInspectable BOOL    masksToBounds_;
@property (assign, nonatomic) IBInspectable CGFloat cornerRadius_;
@property (strong, nonatomic) IBInspectable UIColor *borderColor_;
@property (assign, nonatomic) IBInspectable CGFloat borderWidth_;
@property (strong, nonatomic) IBInspectable UIColor *shadowColor_;
@property (assign, nonatomic) IBInspectable CGFloat shadowRadius_;
@property (assign, nonatomic) IBInspectable CGFloat shadowOpacity_;
@property (assign, nonatomic) IBInspectable CGSize  shadowOffset_;

// 分别设置水平和垂直方向上的长度是否为0。默认条件下不需要设置。
// 当设为YES时，将添加一个优先级999，值为0的约束。
// 所以当需要使用这两个属性来调整UIView的样式时，需要设置UIView的子view的一些约束优先级不能为1000
@property (assign, nonatomic) IBInspectable BOOL horizontalZero_;// 宽度 0
@property (assign, nonatomic) IBInspectable BOOL verticalZero_;// 高度 0

@end

#pragma mark - UIButton

// 设置不同状态下的backgroundColor
@interface UIButton (yg_IBInspectable)
@property (strong, nonatomic) IBInspectable UIColor *normalBGImageColor_;
@property (strong, nonatomic) IBInspectable UIColor *highlightBGImageColor_;
@property (strong, nonatomic) IBInspectable UIColor *selectedBGImageColor_;
@property (strong, nonatomic) IBInspectable UIColor *disabledBGImageColor_;
@end

#pragma mark - UITableView
@interface UITableView (yg_IBInspectable)
// 分割线inset是不是 zero。
@property (assign, nonatomic) IBInspectable BOOL separatorInsetZero;
@end


#pragma mark - UITableViewCell
@interface UITableViewCell (yg_IBInspectable)
// 可以在IB中设置这个值为YES。使cell的分割线没有边距
@property (assign, nonatomic) IBInspectable BOOL separatorInsetZero_;
// 设置selectedBackgroundView的颜色。默认为nil
@property (strong, nonatomic) IBInspectable UIColor *selectedBackgroundColor_;
@end

#pragma mark - UICollectionViewCell
@interface UICollectionViewCell (yg_IBInspectable)
// 设置selectedBackgroundView的颜色。默认为nil
@property (strong, nonatomic) IBInspectable UIColor *selectedBackgroundColor_;
// 设置selectedBackgroundView的圆角。默认为0
@property (assign, nonatomic) IBInspectable CGFloat selectedBackgroundCornerRadius;
@end

#pragma mark - UISearchBar
@interface UISearchBar (yg_IBInspectable)
// 设置searchBar的背景颜色。这个背景颜色可以带透明度。使用BarTintColor设置的背景颜色设置透明度无效
@property (strong, nonatomic) IBInspectable UIColor *realBackgroundColor;
// 通过设置backgroundImage的方式来设置背景颜色
@property (strong, nonatomic) IBInspectable UIColor *realBackgroundImageColor;
// 输入框的tintColor
@property (strong, nonatomic) IBInspectable UIColor *textFieldTintColor;
- (UITextField *)textField;
- (UIButton *)cancelButton;
@end

#pragma mark - UINavigationBar
@interface UINavigationBar (yg_IBInspectable)
// 设置导航栏底部的1px横线是否隐藏。默认为NO，显示横线。
@property (assign, nonatomic) IBInspectable BOOL lineViewHidden_;
// 设置导航栏底部的1px横线颜色。默认为 nil 如果手动设置了navigationBar的shadowImage，此属性不再有效。
// shadowImage 需要和 backgroundImage 一起设置。当不需要backgroundImage时单独设置shadowImage是没有用的。
@property (strong, nonatomic) IBInspectable UIColor *lineViewColor_;
// 设置导航栏底部是否有阴影效果。默认为YES，不显示阴影。
@property (assign, nonatomic) IBInspectable BOOL barShadowHidden_;

/*!
 *  @brief 让barTintColor支持透明度
 *  @brief 默认情况下设置barTintColor的alpha值是无效的，系统会忽略这个alpha值，会使用0.85f作为barTintColor附着的view的alpha。当barTintColor设置为亮色的时候，磨砂效果不明显。
 *  @brief 使用 barTintColorAlpha_ 属性可以修改barTintColor附着的view的alpha值。使磨砂效果可以更加清晰的显示。
 *  @brief 这个属性需要配合 translucent 和 barTintColor 使用。
 *  @brief 这个属性可以使用 UIAppearance 进行全局设置
 */
@property (assign, nonatomic) CGFloat barTintColorAlpha_ UI_APPEARANCE_SELECTOR;
@end

#pragma mark - UIToolbar
@interface UIToolbar (yg_IBInspectable)
// 设置UIToolbar顶部和底部的1px横线是否隐藏。默认为NO，显示横线。
@property (assign, nonatomic) IBInspectable BOOL lineViewHidden_;
// 设置UIToolbar顶部的1px横线颜色。默认为 nil 如果手动设置了UIToolbar 的 backgroundImage，此属性不再有效。
// shadowImage 需要和 backgroundImage 一起设置。当不需要 backgroundImage 时单独设置shadowImage是没有用的。
@property (strong, nonatomic) IBInspectable UIColor *lineViewColor_;
@end

#pragma mark - UITabBar
@interface UITabBar (yg_IBInspectable)
// 设置TabBar顶部的1px横线是否隐藏。默认为NO，显示横线。
@property (assign, nonatomic) IBInspectable BOOL lineViewHidden_;
// 设置TabBar顶部的1px横线颜色。默认为 nil 如果手动设置了TabBar 的 backgroundImage，此属性不再有效。
// shadowImage 需要和 backgroundImage 一起设置。当不需要 backgroundImage 时单独设置shadowImage是没有用的。
@property (strong, nonatomic) IBInspectable UIColor *lineViewColor_;
// 设置顶部是否有阴影效果。默认为YES，不显示阴影。
@property (assign, nonatomic) IBInspectable BOOL barShadowHidden_;
@end

#pragma mark - UIViewController
/*!
 *  @brief 下面4个属性具有默认值。控制器在显示时根据属性值对默认导航栏进行设置。只会影响默认的导航栏，作为view添加的导航栏不受影响
 *         只有需要特殊处理的控制器才需要在IB中设置。否则使用默认值即可。
 */
@interface UIViewController (yg_IBInspectable)

// 忽略列表
// 在忽略列表中的控制器实例不受后面属性的默认值影响。
+ (void)yg_setIgnored:(BOOL)ignored;
+ (BOOL)yg_isIgnored;

// 对默认值进行修改
+ (void)setDefaultInteractivePopEnabled:(BOOL)enabled;
+ (void)setDefaultNavigationBarTranslucent:(BOOL)translucent;
+ (void)setDefaultNavigationBarLineHidden:(BOOL)hidden;
+ (void)setDefaultNavigationBarLineColor:(UIColor *)color;
+ (void)setDefaultNavigationBarShadowHidden:(BOOL)hidden;

// 设置当前控制器是否支持全屏返回手势。默认为YES，支持手势返回
@property (assign, nonatomic) IBInspectable BOOL interactivePopEnabled_;
// 设置当前控制器的导航栏是否半透明。默认为YES，导航栏半透明
@property (assign, nonatomic) IBInspectable BOOL naviBarTranslucent_;
// 设置当前控制器的导航栏下的1px横线是否隐藏。默认为NO，显示细线。
@property (assign, nonatomic) IBInspectable BOOL naviBarLineHidden_;
// 设置当前控制器的导航栏下的1px横线的颜色。默认为 e5e5e5 60%
@property (strong, nonatomic) IBInspectable UIColor *naviBarLineColor_;
// 设置当前控制器的导航栏下的阴影是否隐藏。默认是YES，不显示阴影。 导航栏不可见或者全透明时将没有阴影。
@property (assign, nonatomic) IBInspectable BOOL naviBarShadowHidden_;

// 设置当前控制器下IQKeyboard是否打开。默认是关闭的。
@property (assign, nonatomic) IBInspectable BOOL IQKeyboardEnabled;

// 配置控制器对应的状态栏时，需要info.plist中“View controller-based status bar appearance”为YES。并且正确配置根控制器的 childViewControllerForStatusBarStyle
// 设置当前控制器的状态栏是否隐藏。默认为info.plist中定义的
@property (assign, nonatomic) IBInspectable BOOL statusBarHidden_;
// 设置当前控制的状态栏是否亮色。默认为info.plist中定义的
@property (assign, nonatomic) IBInspectable BOOL statusBarLight_;

@end

#pragma mark - UIActivityIndicatorView

@interface UIActivityIndicatorView (yg_IBInspectable)
// 设置此值来显示或者隐藏
@property (assign, nonatomic) IBInspectable BOOL animating_;
@end
