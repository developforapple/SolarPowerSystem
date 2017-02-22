//
//  UIKit+yg_IBInspectable.m
//  Golf
//
//  Created by bo wang on 16/6/29.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "UIKit+yg_IBInspectable.h"
#import "ReactiveCocoa.h"

#pragma mark - UIView

static void *horizontalZeroConstraintKey = &horizontalZeroConstraintKey;
static void *verticalZeroConstraintKey = &verticalZeroConstraintKey;

@implementation UIView (yg_IBInspectable)
- (BOOL)masksToBounds_
{
    return self.layer.masksToBounds;
}

- (void)setMasksToBounds_:(BOOL)masksToBounds_
{
    self.layer.masksToBounds = masksToBounds_;
}

- (CGFloat)cornerRadius_
{
    return self.layer.cornerRadius;
}

- (void)setCornerRadius_:(CGFloat)cornerRadius_
{
    self.layer.cornerRadius = cornerRadius_;
}

- (UIColor *)borderColor_
{
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

- (void)setBorderColor_:(UIColor *)borderColor_
{
    self.layer.borderColor = borderColor_.CGColor;
}

- (CGFloat)borderWidth_
{
    return self.layer.borderWidth;
}

- (void)setBorderWidth_:(CGFloat)borderWidth_
{
    self.layer.borderWidth = borderWidth_;
}

- (UIColor *)shadowColor_
{
    return [UIColor colorWithCGColor:self.layer.shadowColor];
}

- (void)setShadowColor_:(UIColor *)shadowColor_
{
    self.layer.shadowColor = shadowColor_.CGColor;
}

- (CGFloat)shadowRadius_
{
    return self.layer.shadowRadius;
}

- (void)setShadowRadius_:(CGFloat)shadowRadius_
{
    self.layer.shadowRadius = shadowRadius_;
}

- (CGFloat)shadowOpacity_
{
    return self.layer.shadowOpacity;
}

- (void)setShadowOpacity_:(CGFloat)shadowOpacity_
{
    self.layer.shadowOpacity = shadowOpacity_;
}

- (CGSize)shadowOffset_
{
    return self.layer.shadowOffset;
}

- (void)setShadowOffset_:(CGSize)shadowOffset_
{
    self.layer.shadowOffset = shadowOffset_;
}

#pragma mark Constraint
- (void)setHorizontalZero_:(BOOL)horizontalZero_
{
    NSLayoutConstraint *c = [self horizontalZeroConstraint];
    c.priority = horizontalZero_?999:UILayoutPriorityFittingSizeLevel;
}

- (BOOL)horizontalZero_
{
    return [self horizontalZeroConstraint].priority > UILayoutPriorityFittingSizeLevel;
}

- (void)setVerticalZero_:(BOOL)verticalZero_
{
    NSLayoutConstraint *c = [self verticalZeroConstraint];
    c.priority = verticalZero_?999:UILayoutPriorityFittingSizeLevel;
}

- (BOOL)verticalZero_
{
    return [self verticalZeroConstraint].priority > UILayoutPriorityFittingSizeLevel;
}

- (NSLayoutConstraint *)horizontalZeroConstraint
{
    NSLayoutConstraint *c = objc_getAssociatedObject(self, horizontalZeroConstraintKey);
    if (!c) {
        c = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:kNilOptions multiplier:1 constant:0];
        c.priority = UILayoutPriorityFittingSizeLevel;
        objc_setAssociatedObject(self, horizontalZeroConstraintKey, c, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraint:c];
    }
    return c;
}

- (NSLayoutConstraint *)verticalZeroConstraint
{
    NSLayoutConstraint *c = objc_getAssociatedObject(self, horizontalZeroConstraintKey);
    if (!c) {
        c = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:kNilOptions multiplier:1 constant:0];
        c.priority = UILayoutPriorityFittingSizeLevel;
        objc_setAssociatedObject(self, verticalZeroConstraintKey, c, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraint:c];
    }
    return c;
}
@end

#pragma mark - UIButton

static const void *normalBGColorKey = &normalBGColorKey;
static const void *highlightBGColorKey = &highlightBGColorKey;
static const void *selectedBGColorKey = &selectedBGColorKey;
static const void *disabledBGColorKey = &disabledBGColorKey;

@implementation UIButton (yg_IBInspectable)

- (UIColor *)normalBGImageColor_
{
    return objc_getAssociatedObject(self, normalBGColorKey);
}

- (void)setNormalBGImageColor_:(UIColor *)normalBGImageColor_
{
    objc_setAssociatedObject(self, normalBGColorKey, normalBGImageColor_, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setBackgroundImage:[UIImage imageWithColor:normalBGImageColor_] forState:UIControlStateNormal];
}

- (UIColor *)highlightBGImageColor_
{
    return objc_getAssociatedObject(self, highlightBGColorKey);
}

- (void)setHighlightBGImageColor_:(UIColor *)highlightBGImageColor_
{
    objc_setAssociatedObject(self, highlightBGColorKey, highlightBGImageColor_, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setBackgroundImage:[UIImage imageWithColor:highlightBGImageColor_] forState:UIControlStateHighlighted];
}

- (UIColor *)selectedBGImageColor_
{
    return objc_getAssociatedObject(self, selectedBGColorKey);
}

- (void)setSelectedBGImageColor_:(UIColor *)selectedBGImageColor_
{
    objc_setAssociatedObject(self, selectedBGColorKey, selectedBGImageColor_, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setBackgroundImage:[UIImage imageWithColor:selectedBGImageColor_] forState:UIControlStateSelected];
}

- (UIColor *)disabledBGImageColor_
{
    return objc_getAssociatedObject(self, disabledBGColorKey);
}

- (void)setDisabledBGImageColor_:(UIColor *)disabledBGImageColor_
{
    objc_setAssociatedObject(self, disabledBGColorKey, disabledBGImageColor_, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setBackgroundImage:[UIImage imageWithColor:disabledBGImageColor_] forState:UIControlStateDisabled];
}

@end

#pragma mark - UITableView
static BOOL separatorInsetChanged;
static UIEdgeInsets defaultSeparatorInset;
static UIEdgeInsets defaultLayoutMargins;

static const void *separatorInsetZeroKey = &separatorInsetZeroKey;

@implementation UITableView (yg_IBInspectable)
- (void)setSeparatorInsetZero:(BOOL)separatorInsetZero
{
    if (separatorInsetZero) {
        separatorInsetChanged = YES;
        defaultSeparatorInset = self.separatorInset;
        self.separatorInset = UIEdgeInsetsZero;
        if (iOS8) {
            defaultLayoutMargins = self.layoutMargins;
            self.layoutMargins = UIEdgeInsetsZero;
        }
    }else{
        if (separatorInsetChanged) {
            self.separatorInset = defaultSeparatorInset;
            if (iOS8) {
                self.layoutMargins = defaultLayoutMargins;
            }
        }
    }
}
- (BOOL)separatorInsetZero
{
    return UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, self.separatorInset);
}
@end

#pragma mark - UITableViewCell
@implementation UITableViewCell (yg_IBInspectable)

- (void)setSeparatorInsetZero_:(BOOL)separatorInsetZero_
{
    if (separatorInsetZero_) {
        separatorInsetChanged = YES;
        defaultSeparatorInset = self.separatorInset;
        self.separatorInset = UIEdgeInsetsZero;
        if (iOS8) {
            defaultLayoutMargins = self.layoutMargins;
            self.layoutMargins = UIEdgeInsetsZero;
        }
    }else{
        if (separatorInsetChanged) {
            self.separatorInset = defaultSeparatorInset;
            if (iOS8) {
                self.layoutMargins = defaultLayoutMargins;
            }
        }
    }
}

- (BOOL)separatorInsetZero_
{
    return UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, self.separatorInset);
}

- (void)setSelectedBackgroundColor_:(UIColor *)selectedBackgroundColor_
{
    UIView *view = [UIView new];
    view.backgroundColor = selectedBackgroundColor_;
    self.selectedBackgroundView = view;
}

- (UIColor *)selectedBackgroundColor_
{
    return self.selectedBackgroundView.backgroundColor;
}

@end

#pragma mark - UICollectionViewCell
@implementation UICollectionViewCell (yg_IBInspectable)

- (UIView *)theSelectedBackgroundView
{
    UIView *view = self.selectedBackgroundView;
    if (!view) {
        view = [UIView new];
        self.selectedBackgroundView = view;
    }
    return view;
}

- (void)setSelectedBackgroundColor_:(UIColor *)selectedBackgroundColor_
{
    UIView *view = [self theSelectedBackgroundView];
    view.backgroundColor = selectedBackgroundColor_;
    self.selectedBackgroundView = view;
}

- (UIColor *)selectedBackgroundColor_
{
    return [self theSelectedBackgroundView].backgroundColor;
}

- (void)setSelectedBackgroundCornerRadius:(CGFloat)selectedBackgroundCornerRadius
{
    UIView *view = [self theSelectedBackgroundView];
    view.cornerRadius_ = selectedBackgroundCornerRadius;
    self.selectedBackgroundView = view;
}

- (CGFloat)selectedBackgroundCornerRadius
{
    return [self theSelectedBackgroundView].cornerRadius_;
}
@end

#pragma mark - UISearchBar

#import "YYCategories.h"

static const void *realBackgroundColorKey = &realBackgroundColorKey;
static const void *realBackgroundImageColorKey = &realBackgroundImageColorKey;

@implementation UISearchBar (yg_IBInspectable)
- (void)setRealBackgroundColor:(UIColor *)realBackgroundColor
{
    objc_setAssociatedObject(self, realBackgroundColorKey, realBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    CGFloat alpha;
    [realBackgroundColor getWhite:NULL alpha:&alpha];
    
    NSString *k = [NSString stringWithFormat:@"%@%@%@",@"UISear",@"chBarBa",@"ckground"];
    Class c = NSClassFromString(k);
    
    for (UIView *view in self.subviews) {
        for (UIView *view2 in view.subviews) {
            if ([view2 isKindOfClass:c]) {
                [view2 setBackgroundColor:realBackgroundColor];
                view2.alpha = alpha;
            }
        }
    }
}

- (UIColor *)realBackgroundColor
{
    return objc_getAssociatedObject(self, realBackgroundColorKey);
}

- (void)setRealBackgroundImageColor:(UIColor *)realBackgroundImageColor
{
    objc_setAssociatedObject(self, realBackgroundImageColorKey, realBackgroundImageColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    UIImage *image = [UIImage imageWithColor:realBackgroundImageColor];
    [self setBackgroundImage:image forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
}

- (UIColor *)realBackgroundImageColor
{
    return objc_getAssociatedObject(self, realBackgroundImageColorKey);
}

- (void)setTextFieldTintColor:(UIColor *)textFieldTintColor
{
    [[self textField] setTintColor:textFieldTintColor];
}

- (UIColor *)textFieldTintColor
{
    return [[self textField] tintColor];
}

- (UITextField *)textField
{
    for (UIView *view in self.subviews) {
        for (UIView *view2 in view.subviews) {
            if ([view2 isKindOfClass:[UITextField class]]) {
                return (UITextField *)view2;
            }
        }
    }
    return nil;
}

- (UIButton *)cancelButton
{
    for (UIView *view in self.subviews) {
        for (UIView *view2 in view.subviews) {
            if ([view2 isKindOfClass:[UIButton class]]) {
                return (UIButton *)view2;
            }
        }
    }
    return nil;
}

@end

#pragma mark - UINavigationBar

static void *lineViewColorKey = &lineViewColorKey;
static void *barTintColorAlphaKey = &barTintColorAlphaKey;
static void *barShadowHiddenKey = &barShadowHiddenKey;

@implementation UINavigationBar (yg_IBInspectable)

- (UIView *)lineView
{
    NSString *bgClassStr;
    if (iOS10) {
        bgClassStr = [NSString stringWithFormat:@"_UIBarB%@ground",@"ack"];
    }else{
        bgClassStr = [NSString stringWithFormat:@"_UINa%@ionBarBa%@und",@"vigat",@"ckgro"];
    }
    
    Class bgClass = NSClassFromString(bgClassStr);
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:bgClass]) {
            for (UIView *bgSubView in view.subviews) {
                if (CGRectGetHeight(bgSubView.bounds) <= 1.1f) {
                    return bgSubView;
                }
            }
        }
    }
    return nil;
}

- (UIView *)backgroundView_
{
    @try {
        UIView *view = [self valueForKey:@"_backgroundView"];
        return view;
    } @catch (NSException *exception) {
        return nil;
    }
}

// 设置barTintColor后barTintColor所在的view
- (UIView *)barTintColorEffectView
{
    UIView *view = [self backgroundView_];
    UIView *backdropView = [view.subviews firstObject];
    if (backdropView) {
        UIView *barTintColorView = [[backdropView subviews] lastObject];
        return barTintColorView;
    }
    return nil;
}

- (void)setLineViewHidden_:(BOOL)lineViewHidden_
{
    [[self lineView] setHidden:lineViewHidden_];
}

- (BOOL)lineViewHidden_
{
    return [[self lineView] isHidden];
}

- (void)setLineViewColor_:(UIColor *)lineViewColor_
{
    if (!self.lineViewHidden_ && self.lineViewColor_ != lineViewColor_) {
        UIView *lineView = [self lineView];
        
        /*!
         *  @brief 这里不能直接修改颜色。因为在UINavigationBar内部，lineView的颜色会被系统再次修改。
         *         所以采用监听的方法，当lineView的颜色不一致时进行调整
         */
        
        ygweakify(self);
        [RACObserve(lineView, backgroundColor)
         subscribeNext:^(UIColor *x) {
             ygstrongify(self);
             CGColorRef color1 = x.CGColor;
             CGColorRef color2 = lineViewColor_.CGColor;
             if (!CGColorEqualToColor(color1, color2)) {
                 [[self lineView] setBackgroundColor:lineViewColor_];
             }
         }];
    }
}

- (UIColor *)lineViewColor_
{
    return objc_getAssociatedObject(self, lineViewColorKey);
}

- (void)setBarTintColorAlpha_:(CGFloat)barTintColorAlpha_
{
    CGFloat alpha = MAX(0, MIN(1, barTintColorAlpha_));
    objc_setAssociatedObject(self, barTintColorAlphaKey, @(alpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (self.barTintColor) {
        
        /*!
         *  @brief 这里不能直接修改alpha。因为在UINavigationBar内部，alpha值和backgroundColor会被系统再次修改。
         *         所以采用监听的方法，当alpha值和设定的值不一致时进行调整。
         */
        
        UIView *view = [self barTintColorEffectView];
        ygweakify(self);
        [RACObserve(view, alpha)
         subscribeNext:^(NSNumber *x) {
             if (x.floatValue != barTintColorAlpha_) {
                 ygstrongify(self);
                 [[self barTintColorEffectView] setAlpha:barTintColorAlpha_];
             }
         }];
    }
}

- (CGFloat)barTintColorAlpha_
{
    NSNumber *alpha = objc_getAssociatedObject(self, barTintColorAlphaKey);
    if (!alpha) {
        return 0.85f;   //系统默认透明度。
    }
    return alpha.floatValue;
}

- (BOOL)barShadowHidden_
{
    NSNumber *hidden = objc_getAssociatedObject(self, barShadowHiddenKey);
    if (!hidden) {
        return YES;
    }
    return hidden.boolValue;
}

- (void)setBarShadowHidden_:(BOOL)barShadowHidden_
{
    if (self.barShadowHidden_ != barShadowHidden_) {
        objc_setAssociatedObject(self, barShadowHiddenKey, @(barShadowHidden_), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        self.layer.shadowColor = MainTintColor.CGColor;
        self.layer.shadowOffset = CGSizeMake(2.f, 2.f);
        self.layer.shadowOpacity = barShadowHidden_?0.f:.2f;
        self.layer.shadowRadius = 4.f;
    }
}

@end

#pragma mark - UIToolbar

static void *lineViewHiddenKey = &lineViewHiddenKey;

@implementation UIToolbar (yg_IBInspectable)

DDSwizzleMethod

+ (void)load
{
    SEL oldSel = @selector(layoutSubviews);
    SEL newSel = @selector(yg_layoutSubviews);
    [self swizzleInstanceSelector:oldSel withNewSelector:newSel]; //UIToolbar的子view是后期加进去的
}

- (UIView *)lineView
{
    if (iOS10) {
        
        NSString *className = [NSString stringWithFormat:@"_UIBarB%@ground",@"ack"];
        Class class = NSClassFromString(className);
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:class]) {
                for (UIView *lineView in view.subviews) {
                    if (CGRectGetHeight(lineView.bounds) <= 1.1f) {
                        return lineView;
                    }
                }
            }
        }
        return nil;
    }
    
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            if (CGRectGetHeight(view.bounds) <= 1.1f) {
                return view;
            }
        }
    }
    return nil;
}

- (void)yg_layoutSubviews
{
    [self yg_layoutSubviews];
    if (objc_getAssociatedObject(self, lineViewHiddenKey)) {
        [self setLineViewHidden_:self.lineViewHidden_];
    }
    if (objc_getAssociatedObject(self, lineViewColorKey)) {
        [self setLineViewColor_:self.lineViewColor_];
    }
}

- (void)setLineViewHidden_:(BOOL)lineViewHidden_
{
    objc_setAssociatedObject(self, lineViewHiddenKey, @(lineViewHidden_), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [[self lineView] setHidden:lineViewHidden_];
}

- (BOOL)lineViewHidden_
{
    return [objc_getAssociatedObject(self, lineViewHiddenKey) boolValue];
}

- (void)setLineViewColor_:(UIColor *)lineViewColor_
{
    if (lineViewColor_ && !self.lineViewHidden_) {
        objc_setAssociatedObject(self, lineViewColorKey, lineViewColor_, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        UIView *lineView = [self lineView];
        ygweakify(self);
        [RACObserve(lineView, backgroundColor)
         subscribeNext:^(UIColor *x) {
             ygstrongify(self);
             CGColorRef color1 = x.CGColor;
             CGColorRef color2 = lineViewColor_.CGColor;
             if (!CGColorEqualToColor(color1, color2)) {
                 [[self lineView] setBackgroundColor:lineViewColor_];
             }
         }];
    }
}

- (UIColor *)lineViewColor_
{
    return objc_getAssociatedObject(self, lineViewColorKey);
}

@end

#pragma mark - UITabBar
@implementation UITabBar (yg_IBInspectable)

- (UIView *)lineView
{
    if (iOS10) {
        // iOS10 修改了TabBar的视图层次
        NSString *className = [NSString stringWithFormat:@"_UIBarB%@ground",@"ack"];
        Class class = NSClassFromString(className);
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:class]) {
                for (UIView *lineView in view.subviews) {
                    if (CGRectGetHeight(lineView.bounds) <= 1.1f) {
                        return lineView;
                    }
                }
            }
        }
        return nil;
    }
    
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            if (CGRectGetHeight(view.bounds) <= 1.1f) {
                return view;
            }
        }
    }
    return nil;
}

- (void)setLineViewHidden_:(BOOL)lineViewHidden_
{
    [[self lineView] setHidden:lineViewHidden_];
}

- (BOOL)lineViewHidden_
{
    return [[self lineView] isHidden];
}

- (void)setLineViewColor_:(UIColor *)lineViewColor_
{
    if (!self.lineViewHidden_) {
        objc_setAssociatedObject(self, lineViewColorKey, lineViewColor_, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        UIView *lineView = [self lineView];
        
        /*!
         *  @brief 这里不能直接修改颜色。因为在UITabBar内部，lineView的颜色会被系统再次修改。
         *         所以采用监听的方法，当lineView的颜色不一致时进行调整
         */
        
        ygweakify(self);
        [RACObserve(lineView, backgroundColor)
         subscribeNext:^(UIColor *x) {
             ygstrongify(self);
             CGColorRef color1 = x.CGColor;
             CGColorRef color2 = lineViewColor_.CGColor;
             if (!CGColorEqualToColor(color1, color2)) {
                 [[self lineView] setBackgroundColor:lineViewColor_];
             }
         }];
    }
}

- (UIColor *)lineViewColor_
{
    return objc_getAssociatedObject(self, lineViewColorKey);
}

- (BOOL)barShadowHidden_
{
    NSNumber *hidden = objc_getAssociatedObject(self, barShadowHiddenKey);
    if (!hidden) {
        return YES;
    }
    return hidden.boolValue;
}

- (void)setBarShadowHidden_:(BOOL)barShadowHidden_
{
    if (self.barShadowHidden_ != barShadowHidden_) {
        objc_setAssociatedObject(self, barShadowHiddenKey, @(barShadowHidden_), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        self.layer.shadowColor = MainTintColor.CGColor;
        self.layer.shadowOffset = CGSizeMake(-2.f, -2.f);
        self.layer.shadowOpacity = barShadowHidden_?0.f:.2f;
        self.layer.shadowRadius = 4.f;
    }
}

@end

#pragma mark - UIViewController
#import "JZNavigationExtension.h"
#import <IQKeyboardManager/IQKeyboardManager.h>

@implementation UIViewController (yg_IBInspectable)

static const void *interactivePopEnabledKey = &interactivePopEnabledKey;
static const void *naviBarTranslucentKey = &naviBarTranslucentKey;
static const void *naviBarLineHiddenKey = &naviBarLineHiddenKey;
static const void *naviBarLineColorKey = &naviBarLineColorKey;
static const void *naviBarShadowHiddenKey = &naviBarShadowHiddenKey;

static const void *IQKeyboardEnabledKey = &IQKeyboardEnabledKey;

static const void *statusBarHiddenKey = &statusBarHiddenKey;
static const void *statusBarLightKey = &statusBarLightKey;

static BOOL kDefaultInteractivePopEnabled = YES;
static BOOL kDefaultNaviBarTranslucent = YES;
static BOOL kDefaultNaviBarLineHidden = NO;
static UIColor *kDefaultNaviBarLineColor;
static BOOL kDefaultNaviBarShadowHidden = YES;

static NSMutableSet<Class> *kIgnoredViewControllerClasses;

#pragma mark Ignore List
+ (void)yg_setIgnored:(BOOL)ignored
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kIgnoredViewControllerClasses = [NSMutableSet set];
    });
    if (ignored) {
        [kIgnoredViewControllerClasses addObject:[self class]];
    }else{
        [kIgnoredViewControllerClasses removeObject:[self class]];
    }
}

+ (BOOL)yg_isIgnored
{
    return [kIgnoredViewControllerClasses containsObject:[self class]];
}

- (BOOL)yg_isIgnored
{
    return [[self class] yg_isIgnored] || [[[self parentViewController] class] yg_isIgnored];
}

- (BOOL)yg_isSystemController
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    return [NSBundle mainBundle]==bundle;
}

#pragma mark Lift Cycle

DDSwizzleMethod

+ (void)load
{
    kDefaultNaviBarLineColor = RGBColor(229, 229, 229, 0.8f);
    
    SEL oldViewWillAppearSel = @selector(viewWillAppear:);
    SEL newViewWillAppearSel = @selector(yg_viewWillAppear:);
    [self swizzleInstanceSelector:oldViewWillAppearSel withNewSelector:newViewWillAppearSel];
    
    SEL oldViewDidAppearSel = @selector(viewDidAppear:);
    SEL newViewDidAppearSel = @selector(yg_viewDidAppear:);
    [self swizzleInstanceSelector:oldViewDidAppearSel withNewSelector:newViewDidAppearSel];
    
    SEL oldViewDidLoadSel = @selector(viewDidLoad);
    SEL newViewDidLoadSel = @selector(yg_viewDidLoad);
    [self swizzleInstanceSelector:oldViewDidLoadSel withNewSelector:newViewDidLoadSel];
    
    if ([self canSetupStatusBar]) {
        SEL oldPrefersStatusBarHidden = @selector(prefersStatusBarHidden);
        SEL newPrefersStatusBarHidden = @selector(yg_prefersStatusBarHidden);
        [self swizzleInstanceSelector:oldPrefersStatusBarHidden withNewSelector:newPrefersStatusBarHidden];
        
        SEL oldPreferredStatusBarStyle = @selector(preferredStatusBarStyle);
        SEL newPreferredStatusBarStyle = @selector(yg_preferredStatusBarStyle);
        [self swizzleInstanceSelector:oldPreferredStatusBarStyle withNewSelector:newPreferredStatusBarStyle];
        
        SEL oldChildViewControllerForStatusBarHidden = @selector(childViewControllerForStatusBarHidden);
        SEL newChildViewControllerForStatusBarHidden = @selector(yg_childViewControllerForStatusBarHidden);
        [self swizzleInstanceSelector:oldChildViewControllerForStatusBarHidden withNewSelector:newChildViewControllerForStatusBarHidden];
        
        SEL oldChildViewControllerForStatusBarStyle = @selector(childViewControllerForStatusBarStyle);
        SEL newChildViewControllerForStatusBarStyle = @selector(yg_childViewControllerForStatusBarStyle);
        [self swizzleInstanceSelector:oldChildViewControllerForStatusBarStyle withNewSelector:newChildViewControllerForStatusBarStyle];
    }
}

- (void)yg_viewDidLoad
{
    [self yg_viewDidLoad];
    
    if ([self yg_isIgnored]) return;
    
    [self _setupJz];
    
    // 取消默认的手势返回，使用JZ的全屏手势返回
    if ([self isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *)self interactivePopGestureRecognizer].enabled = NO;
    }

    // 使用自定义的返回按钮
    [self.navigationItem setHidesBackButton:YES];  //不显示默认的返回按钮，采用leftBarButtonItem作为返回按钮
    [self.navigationController.navigationBar.backItem setHidesBackButton:YES];  //解决使用手势返回中途取消手势时，导航栏出现一个默认返回按钮的问题。
    [self.navigationItem.backBarButtonItem setTitle:@""];  //隐藏默认返回按钮的标题。
    
    [self updateIQKeyboardEnabled];
}

- (void)yg_viewWillAppear:(BOOL)animated
{
    [self yg_viewWillAppear:animated];
    
    if ([self yg_isIgnored]) return;
    
    [UIView animateWithDuration:.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        // 这里为什么要禁用？
        // 发现一个bug，上一个界面A不要手势返回，push的下一个界面B有手势返回时，B界面的手势返回将不起作用。此时view上所有操作发生错乱。
        // 原因是这种情况下，在B界面的手势开始时，导航控制器会将 B 移出栈，将 A 加入到视图层级里面，此时将会调用A界面的 viewWillAppear 方法。在这个方法内[self updateInteractivePop] 会因为A不支持手势返回，而将B界面正在进行中的手势给取消掉。
        // 通常手势被取消，导航控制器会将 B 重新加入到栈里面来。但是此种条件下，导航控制器没有将B界面重新加入到栈里面来。此时navigationItem是A的，但是view是B的。造成界面错乱
        
//        [self updateInteractivePop];
        
        [self updateNaviBarTranslucent];
        [self updateNaviBarLine];
        [self updateNaviBarShadow];
    } completion:^(BOOL finished) {}];
    
    [self updateIQKeyboardEnabled];
}

- (void)yg_viewDidAppear:(BOOL)animated
{
    [self yg_viewDidAppear:animated];
    
    if ([self yg_isIgnored]) return;
    
    [UIView animateWithDuration:.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self updateInteractivePop];
        [self updateNaviBarTranslucent];
        [self updateNaviBarLine];
        [self updateNaviBarShadow];
    } completion:^(BOOL finished) {}];
    
    // 设置TabBar的默认样式
    if ([self isKindOfClass:[UITabBarController class]]) {
        UITabBar *tabbar = [(UITabBarController *)self tabBar];
        tabbar.lineViewHidden_ = NO;
        tabbar.lineViewColor_ = kDefaultNaviBarLineColor;
        //        tabbar.barShadowHidden_ = YES;
    }
    
    [self updateIQKeyboardEnabled];
}

#pragma mark  setup
- (void)_setupJz
{
    if (!self.navigationController || self.parentViewController != self.navigationController){
        return;
    }
    
    // 设置一些默认值
    UIColor *jz_navigationBarTintColor = objc_getAssociatedObject(self, @selector(jz_navigationBarTintColor));
    if (!jz_navigationBarTintColor) {
        self.jz_navigationBarTintColor = nil;
    }
    
    id jz_wantsNavigationBarVisibleObject = objc_getAssociatedObject(self, @selector(jz_wantsNavigationBarVisible));
    if (!jz_wantsNavigationBarVisibleObject) {
        self.jz_wantsNavigationBarVisible = YES;
    }
    
    id jz_navigationBarBackgroundAlpha = objc_getAssociatedObject(self, @selector(jz_navigationBarBackgroundAlpha));
    if (!jz_navigationBarBackgroundAlpha) {
        self.jz_navigationBarBackgroundAlpha = 1.f;
    }
}

#pragma mark  Default
+ (void)setDefaultInteractivePopEnabled:(BOOL)enabled
{
    kDefaultInteractivePopEnabled = enabled;
}

+ (void)setDefaultNavigationBarTranslucent:(BOOL)translucent
{
    kDefaultNaviBarTranslucent = translucent;
}

+ (void)setDefaultNavigationBarLineHidden:(BOOL)hidden
{
    kDefaultNaviBarLineHidden = hidden;
}

+ (void)setDefaultNavigationBarLineColor:(UIColor *)color
{
    kDefaultNaviBarLineColor = color;
}

+ (void)setDefaultNavigationBarShadowHidden:(BOOL)hidden
{
    kDefaultNaviBarShadowHidden = hidden;
}

#pragma mark interactivePopEnabled_
- (BOOL)interactivePopEnabled_
{
    NSNumber *enable = objc_getAssociatedObject(self, interactivePopEnabledKey);
    if (enable) {
        return enable.boolValue;
    }
    return kDefaultInteractivePopEnabled;
}

- (void)setInteractivePopEnabled_:(BOOL)interactivePopEnabled_
{
    objc_setAssociatedObject(self, interactivePopEnabledKey, @(interactivePopEnabled_), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateInteractivePop];
}

- (void)updateInteractivePop
{
    if (self.navigationController && self.parentViewController==self.navigationController) {
        self.navigationController.jz_fullScreenInteractivePopGestureEnabled = self.interactivePopEnabled_;
    }
}

#pragma mark naviBarTranslucent_
- (BOOL)naviBarTranslucent_
{
    NSNumber *translucent = objc_getAssociatedObject(self, naviBarTranslucentKey);
    if (translucent) {
        return [translucent boolValue];
    }
    return kDefaultNaviBarTranslucent;
}

- (void)setNaviBarTranslucent_:(BOOL)naviBarTranslucent_
{
    objc_setAssociatedObject(self, naviBarTranslucentKey, @(naviBarTranslucent_), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateNaviBarTranslucent];
}

- (void)updateNaviBarTranslucent
{
    if (self.navigationController && self.parentViewController==self.navigationController) {
        self.navigationController.navigationBar.translucent = self.naviBarTranslucent_;
    }
}

#pragma mark naviBarLineHidden_
- (BOOL)_naviBarLineHiddenIsSet
{
    return nil!=objc_getAssociatedObject(self, naviBarLineHiddenKey);
}

- (BOOL)naviBarLineHidden_
{
    NSNumber *hidden = objc_getAssociatedObject(self, naviBarLineHiddenKey);
    if (hidden) {
        return hidden.boolValue;
    }
    return kDefaultNaviBarLineHidden;
}

- (void)setNaviBarLineHidden_:(BOOL)naviBarLineHidden_
{
    objc_setAssociatedObject(self, naviBarLineHiddenKey, @(naviBarLineHidden_), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self updateNaviBarLine];
}

- (void)updateNaviBarLine
{
    if (self.navigationController && self.parentViewController==self.navigationController) {
        self.navigationController.navigationBar.lineViewHidden_ = self.naviBarLineHidden_;
        self.navigationController.navigationBar.lineViewColor_ = self.naviBarLineColor_;
    }
}

#pragma mark  naviBarLineColor_
- (UIColor *)naviBarLineColor_
{
    UIColor *color = objc_getAssociatedObject(self, naviBarLineColorKey);
    if (!color) {
        color = kDefaultNaviBarLineColor;
    }
    return color;
}

- (void)setNaviBarLineColor_:(UIColor *)naviBarLineColor_
{
    objc_setAssociatedObject(self, naviBarLineColorKey, naviBarLineColor_, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark naviBarShadowHidden_
- (BOOL)_naviBarShadowHiddenIsSet
{
    return nil!=objc_getAssociatedObject(self, naviBarShadowHiddenKey);
}

- (BOOL)naviBarShadowHidden_
{
    NSNumber *hidden = objc_getAssociatedObject(self, naviBarShadowHiddenKey);
    if (hidden) {
        return hidden.boolValue;
    }
    return kDefaultNaviBarShadowHidden;
}

- (void)setNaviBarShadowHidden_:(BOOL)naviBarShadowHidden_
{
    objc_setAssociatedObject(self, naviBarShadowHiddenKey, @(naviBarShadowHidden_), OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self updateNaviBarShadow];
}

- (void)updateNaviBarShadow
{
    if (self.navigationController && self.parentViewController == self.navigationController) {
        if (!self.jz_wantsNavigationBarVisible || self.jz_isNavigationBarBackgroundHidden) {
            // 默认导航栏不显示或者背景为透明时不显示阴影
            return;
        }
        self.navigationController.navigationBar.barShadowHidden_ = self.naviBarShadowHidden_;
    }
}

#pragma mark IQKeybaord
- (void)setIQKeyboardEnabled:(BOOL)IQKeyboardEnabled
{
    objc_setAssociatedObject(self, IQKeyboardEnabledKey, @(IQKeyboardEnabled), OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self updateIQKeyboardEnabled];
}

- (BOOL)IQKeyboardEnabled
{
    return [objc_getAssociatedObject(self, IQKeyboardEnabledKey) boolValue];
}

- (void)updateIQKeyboardEnabled
{
    if (self.navigationController && self.parentViewController == self.navigationController) {
        BOOL enabled = self.IQKeyboardEnabled;
        [[IQKeyboardManager sharedManager] setEnable:enabled];
        [[IQKeyboardManager sharedManager] setEnableAutoToolbar:enabled];
    }
}

#pragma mark StatusBar
+ (BOOL)canSetupStatusBar
{
    static BOOL can = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        can = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIViewControllerBasedStatusBarAppearance"] boolValue];
    });
    return can;
}

- (void)setStatusBarHidden_:(BOOL)statusBarHidden_
{
    if (![UIViewController canSetupStatusBar]) return;
    objc_setAssociatedObject(self, statusBarHiddenKey, @(statusBarHidden_), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)statusBarHidden_
{
    BOOL isHidden = NO;
    NSNumber *hidden = objc_getAssociatedObject(self, statusBarHiddenKey);
    if (!hidden) {
        isHidden = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIStatusBarHidden"] boolValue];
    }else{
        isHidden = hidden.boolValue;
    }
    return isHidden;
}

- (BOOL)statusBarHiddenIsSet
{
    return objc_getAssociatedObject(self, statusBarHiddenKey);
}

- (void)setStatusBarLight_:(BOOL)statusBarLight_
{
    if (![UIViewController canSetupStatusBar]) return;
    objc_setAssociatedObject(self, statusBarLightKey, @(statusBarLight_), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)statusBarLight_
{
    BOOL isLight = NO;
    NSNumber *light = objc_getAssociatedObject(self, statusBarLightKey);
    if (!light) {
        UIStatusBarStyle style = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIStatusBarHidden"] intValue];
        isLight = style == UIStatusBarStyleLightContent;
    }else{
        isLight = light.boolValue;
    }
    return isLight;
}

- (BOOL)statusBarLightIsSet
{
    return objc_getAssociatedObject(self, statusBarLightKey);
}

- (BOOL)yg_prefersStatusBarHidden
{
    if ([self statusBarHiddenIsSet]) {
        return self.statusBarHidden_;
    }
    return [self yg_prefersStatusBarHidden];
}

- (UIStatusBarStyle)yg_preferredStatusBarStyle
{
    if ([self statusBarLightIsSet]) {
        return [self statusBarLight_]?UIStatusBarStyleLightContent:UIStatusBarStyleDefault;
    }
    return [self yg_preferredStatusBarStyle];
}

- (UIViewController *)yg_childViewControllerForStatusBarStyle
{
    if ([self isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)self topViewController];
    }else if ([self isKindOfClass:[UITabBarController class]]){
        return [(UITabBarController *)self selectedViewController];
    }else if ([self statusBarLightIsSet]){
        return nil;
    }
    return [self yg_childViewControllerForStatusBarStyle];
}

- (UIViewController *)yg_childViewControllerForStatusBarHidden
{
    if ([self isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)self topViewController];
    }else if ([self isKindOfClass:[UITabBarController class]]){
        return [(UITabBarController *)self selectedViewController];
    }else if ([self statusBarHiddenIsSet]) {
        return nil;
    }
    return [self yg_childViewControllerForStatusBarHidden];
}

@end


#pragma mark - UIActivityIndicatorView

@implementation UIActivityIndicatorView (yg_IBInspectable)

- (BOOL)animating_
{
    return self.isAnimating;
}

- (void)setAnimating_:(BOOL)animating_
{
    if (animating_) {
        [self startAnimating];
    }else{
        [self stopAnimating];
    }
}

@end
