//
//  DDSegmentScrollView.m
//  JuYouQu
//
//  Created by appleDeveloper on 15/12/17.
//  Copyright © 2015年 Bo Wang. All rights reserved.
//

#import "DDSegmentScrollView.h"
#import "YGCommon.h"

@interface DDSegmentScrollView () <UIScrollViewDelegate>
{
    CGSize _contentSize;
    BOOL _titleHeightDidSet;
    UIColor *_previousBackgroundColor;
}

@property (strong, nonatomic) NSMutableArray<NSString *> *titleList;
// 标签单元
@property (strong, nonatomic) NSMutableArray<UILabel *> *unitList;
// 标签宽度
@property (strong, nonatomic) NSMutableArray<NSNumber *> *widthList;

// 左右边缘最小边距。忽略top和bottom。 默认 0 20 0 20。
@property (assign, nonatomic) UIEdgeInsets edgeInsets;

// 滚动容器
@property (strong, nonatomic) UIScrollView *scrollView;
// 横线指示器
@property (strong, nonatomic) UIView *indicatorView;

@property (strong, nonatomic) CALayer *lineLayer;

// 实现高斯模糊效果
@property (strong, nonatomic) UIToolbar *toolBar;

@end

@implementation DDSegmentScrollView

static UIColor *kDefaultNormalColor;
static UIColor *kDefaultHighlightColor;

+ (void)load
{
    [self setDefaultNormalColor:MainTintColor];
    [self setDefaultHighlightColor:MainHighlightColor];
}

+ (void)setDefaultNormalColor:(UIColor *)color
{
    kDefaultNormalColor = color;
}

+ (void)setDefaultHighlightColor:(UIColor *)color
{
    kDefaultHighlightColor = color;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.normalColor = kDefaultNormalColor;
    self.highlightColor = kDefaultHighlightColor;
    self.normalBorderColor = [self.normalColor colorWithAlphaComponent:.4f];
    self.highlightBorderColor = [self.highlightColor colorWithAlphaComponent:.4f];
    self.normalFont = [UIFont systemFontOfSize:15];
    self.highlightScale = 1.4f;
    
    self.titleList = [NSMutableArray array];
    self.unitList = [NSMutableArray array];
    self.widthList = [NSMutableArray array];
    
    self.edgeInsets = UIEdgeInsetsMake(0, 20.f, 0.f, 20.f);
    self.indicatorOffset = CGPointZero;
    self.unitSpacing = 32.f;
    
    self.showIndicator = YES;
    self.showTitleBorder = NO;
    self.showLineView = YES;
    
    self.lineViewColor = RGBColor(230, 230, 230, 1);
    
    self.clipsToBounds = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self resetUnitsIfNeed];
    
    self.lineLayer.frame = CGRectMake(0, CGRectGetHeight(self.frame)-.5f, CGRectGetWidth(self.frame), .5f);
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
        [self addSubview:_scrollView];
        
        _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|" options:kNilOptions metrics:nil views:@{@"view":_scrollView}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|" options:kNilOptions metrics:nil views:@{@"view":_scrollView}]];
    }
    return _scrollView;
}

- (UIView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIView alloc] initWithFrame:CGRectMake(self.edgeInsets.left+self.indicatorOffset.x, CGRectGetHeight(self.frame)-2+self.indicatorOffset.y, 30.f, 1.f)];
        _indicatorView.backgroundColor = self.highlightColor;
        _indicatorView.layer.masksToBounds = YES;
        _indicatorView.layer.cornerRadius = 0.5f;
        [_scrollView addSubview:_indicatorView];
    }
    return _indicatorView;
}

- (void)setTitleMinimumHeight:(CGFloat)titleMinimumHeight
{
    _titleMinimumHeight = titleMinimumHeight;
    _titleHeightDidSet = YES;
}

- (UILabel *)unitAtIndex:(NSUInteger)index
{
    if (index < self.unitList.count) {
        return self.unitList[index];
    }
    return nil;
}

- (NSArray<NSString *> *)titles
{
    return self.titleList;
}

- (UILabel *)createUnitWithTitle:(NSString *)title
{
    UILabel *label = [[UILabel alloc] init];
    label.textColor = self.normalColor;
    label.font = self.normalFont;
    label.text = title;
    label.textAlignment = NSTextAlignmentCenter;
    label.userInteractionEnabled = YES;
    [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelAction:)]];
    return label;
}

- (void)labelAction:(UITapGestureRecognizer *)gr
{
    UILabel *label = (UILabel *)gr.view;
    NSUInteger index = [self.unitList indexOfObject:label];
    self.currentIndex = index;
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark - Update
- (void)setNormalFontSize:(CGFloat)normalFontSize
{
    self.normalFont = [UIFont systemFontOfSize:normalFontSize];
}

- (CGFloat)normalFontSize
{
    return [self.normalFont pointSize];
}

- (void)setTitles:(NSArray<NSString *> *)titles
{
    self.titleList = [titles mutableCopy];
    [self relayout];
}

- (void)setShowLineView:(BOOL)showLineView
{
    _showLineView = showLineView;
    if (showLineView) {
        self.lineLayer.hidden = NO;
    }else{
        self.lineLayer.hidden = YES;
    }
}

- (void)setTranslucent:(BOOL)translucent
{
    _translucent = translucent;
    [self setToolBarVisible:translucent];
}

- (void)setToolBarVisible:(BOOL)visible
{
    if (visible) {
        [self sendSubviewToBack:self.toolBar];
        _previousBackgroundColor = self.backgroundColor;
        self.backgroundColor = [UIColor clearColor];
    }else{
        [_toolBar removeFromSuperview];
        _toolBar = nil;
        self.backgroundColor = _previousBackgroundColor?:[UIColor whiteColor];
    }
}

- (UIToolbar *)toolBar
{
    if (!_toolBar) {
        _toolBar = [[UIToolbar alloc] init];
        _toolBar.translucent = YES;
        _toolBar.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:_toolBar];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[bar]-0-|" options:kNilOptions metrics:nil views:@{@"bar":_toolBar}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[bar]-0-|" options:kNilOptions metrics:nil views:@{@"bar":_toolBar}]];
    }
    return _toolBar;
}

- (void)addUnitWithTitle:(NSString *)title
{
    [self insertUnitAtIndex:self.unitList.count withTitle:title];
}

- (void)insertUnitAtIndex:(NSUInteger)index withTitle:(NSString *)title
{
    if (!title) return;

    [self.titleList insertObject:title atIndex:index];
    [self relayout];
}

- (void)relayout
{
    [self.unitList makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.unitList removeAllObjects];
    [self.widthList removeAllObjects];
    
    [self layoutIfNeeded];
    
    NSMutableArray *units = [NSMutableArray array];
    NSMutableArray *widths = [NSMutableArray array];
    
    CGFloat offset = self.edgeInsets.left;
    
    CGFloat height = CGRectGetHeight(self.frame);
    
    for (NSString *title in self.titleList) {
        UILabel *label = [self createUnitWithTitle:title];
        
        label.font = self.normalFont;
        CGSize normalSize = [label sizeThatFits:CGSizeMake(10000, height)];
        CGFloat normalWidth = normalSize.width;
        CGFloat normalHeight = normalSize.height;
        if (_titleHeightDidSet) {
            normalHeight = ceilf(MAX(self.titleMinimumHeight, normalSize.height));
        }
        
        if (self.showTitleBorder) {
            normalWidth += (2*15.f);
            
            label.layer.masksToBounds = YES;
            label.layer.borderColor = self.normalBorderColor.CGColor;
            label.layer.borderWidth = .5f;
            label.layer.cornerRadius = normalHeight/2;
        }
        
        label.frame = CGRectMake(offset, (height-normalHeight)/2, ceilf(normalWidth), normalHeight);
        
        offset += ceilf(normalWidth);  // offset 加上label的宽度
        offset += self.unitSpacing;       // offset 加上间距
        [widths addObject:@(ceilf(normalWidth*self.highlightScale))];
        
        [self.scrollView addSubview:label];
        [units addObject:label];
    }
    
    offset -= self.unitSpacing; //最后一个label的时候多加了一次
    offset += self.edgeInsets.right;
    
    self.unitList = units;
    self.widthList = widths;
    
    _contentSize = CGSizeMake(offset, height);
    self.scrollView.contentSize = _contentSize;
    
    [self setCurrentIndex:0];
    [self resetUnitsIfNeed];
    [self setupLineLayer];
}

- (void)setupLineLayer
{
    if (!self.lineLayer) {
        self.lineLayer = [CALayer layer];
        self.lineLayer.backgroundColor = self.lineViewColor.CGColor;
        self.lineLayer.frame = CGRectMake(0, CGRectGetHeight(self.frame)-.5f, CGRectGetWidth(self.frame), .5f);
        [self.layer addSublayer:self.lineLayer];
    }
    self.lineLayer.hidden = !self.showLineView;
}

- (void)resetUnitsIfNeed
{
    CGSize contentSize = _contentSize;
    CGSize scrollSize = self.scrollView.frame.size;
    
    if (self.titleList.count != 0 &&
        contentSize.width != 0 &&
        contentSize.width < scrollSize.width) {
        //标签数量不足。需要重新布局
        
        CGFloat width = scrollSize.width;
        CGFloat labelTotalWidth = 0.f;
        for (UILabel *label in self.unitList) {
            labelTotalWidth += CGRectGetWidth(label.frame);
        }
        
        //平分，间距相等
        CGFloat spacing = (width-labelTotalWidth)/((CGFloat)self.unitList.count+1);
        CGFloat offset = spacing;
        
        for (UILabel *label in self.unitList) {
            CGRect frame = label.frame;
            frame.origin.x = offset;
            label.frame = frame;
            
            offset += CGRectGetWidth(frame);
            offset += spacing;
        }
        self.scrollView.contentSize = scrollSize;
        [self moveIndicatorToIndex:self.currentIndex];
    }
}

- (void)setCurrentIndex:(NSUInteger)currentIndex
{
    if (currentIndex != 0 && currentIndex == _currentIndex) {
        return;
    }
    [self updateCurrentLabelFrom:_currentIndex to:currentIndex];
    [self moveIndicatorToIndex:currentIndex];
    
    _lastIndex = _currentIndex;
    _currentIndex = currentIndex;
    
    [self adjustCurrentIfNeed];
}

- (void)updateCurrentLabelFrom:(NSUInteger)from to:(NSUInteger)to
{
    UILabel *currentlabel = [self unitAtIndex:from];
    UILabel *nextlabel = [self unitAtIndex:to];
    
    [UIView animateWithDuration:.4f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        currentlabel.textColor = self.normalColor;
        currentlabel.transform = CGAffineTransformIdentity;
        nextlabel.textColor = self.highlightColor;
        nextlabel.transform = CGAffineTransformMakeScale(self.highlightScale, self.highlightScale);
        if (self.showTitleBorder) {
            currentlabel.layer.borderColor = self.normalBorderColor.CGColor;
            nextlabel.layer.borderColor = self.highlightBorderColor.CGColor;
        }
    } completion:^(BOOL finished) {
    }];
}

- (void)moveIndicatorToIndex:(NSUInteger)index
{
    if (!self.showIndicator || self.widthList.count == 0) {
        self.indicatorView.hidden = YES;
        return;
    }
    
    self.indicatorView.hidden = NO;
    
    CGFloat dValue = 2.f;   //这个值是指示器两端超出label的宽度的差值
    UILabel *label = [self unitAtIndex:index];
    
    CGPoint center = CGPointMake(CGRectGetMidX(label.frame), CGRectGetMidY(label.frame));
    CGFloat width = [self.widthList[index] floatValue] + dValue * 2;
    CGFloat x = center.x - width/2.f;
    CGFloat y = CGRectGetHeight(self.frame) - 2.f;
    CGFloat height = 1.f;
    
    x += self.indicatorOffset.x;
    y += self.indicatorOffset.y;
    
    [UIView animateWithDuration:.25f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.indicatorView.frame = CGRectMake(x, y, width, height);
    } completion:^(BOOL finished) {
    }];
}

// 如果需要的话，使当前的标签居中显示
- (void)adjustCurrentIfNeed
{
    CGPoint selfCenter = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2);
    
    UILabel *label = [self unitAtIndex:_currentIndex];
    
    CGRect rect = [self.scrollView convertRect:label.frame toView:self];
    CGPoint labelCenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    
    CGFloat offset = labelCenter.x - selfCenter.x;
    
    CGFloat scrollOffset = self.scrollView.contentOffset.x;
    scrollOffset += offset;
    
    CGFloat minimumLimit = 0.f;
    CGFloat maximumLimit = self.scrollView.contentSize.width - CGRectGetWidth(self.scrollView.frame);
    
    CGFloat contentOffsetY = self.scrollView.contentOffset.y;
    
    if (scrollOffset < minimumLimit) {
        [self.scrollView setContentOffset:CGPointMake(minimumLimit, contentOffsetY) animated:YES];
    }else if (scrollOffset > maximumLimit){
        [self.scrollView setContentOffset:CGPointMake(maximumLimit, contentOffsetY) animated:YES];
    }else{
        [self.scrollView setContentOffset:CGPointMake(scrollOffset, contentOffsetY) animated:YES];
    }
}

#pragma mark - UIControl
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{return YES;}
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{return YES;}
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{}
- (void)cancelTrackingWithEvent:(UIEvent *)event{}
@end
