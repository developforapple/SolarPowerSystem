//
//  DDGridProgressView.m
//  JuYouQu
//
//  Created by Normal on 16/2/17.
//  Copyright © 2016年 Bo Wang. All rights reserved.
//

#import "DDGridProgressView.h"

@interface DDGridProgressView ()
@property (strong, nonatomic) NSMutableArray<CALayer *> *separateLines;
@end

@implementation DDGridProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self->_backColor = RGBColor(12, 7, 33, 1);
    self->_gridColor = [UIColor whiteColor];
    self->_numberOfGrids = 1;
    self->_gridSeparateLineWidth = 1;
    self->_gridSeparateLineColor = self->_backColor;
    self->_borderWidth = 1;
    self->_borderColor = self->_backColor;
    self->_jumpUpdate = YES;
    
    self->_separateLines = [NSMutableArray array];
    
    [self update];
}

- (void)update
{
    self.trackTintColor = self.backColor;
    self.progressTintColor = self.gridColor;
    
    self.layer.masksToBounds = YES;
    self.layer.borderColor = self.borderColor.CGColor;
    self.layer.borderWidth = self.borderWidth;
}

- (void)updateGridSeparate
{
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    
    CGFloat a = self.borderWidth;   //边框宽度
    CGFloat b = self.gridSeparateLineWidth; //分隔线宽度
    CGFloat n = self.numberOfGrids; //格子数量
    
    CGFloat c = (width-2*a-b*(n-1))/n;   //格子的宽度
    CGFloat h = height-2*a;              //分隔线的高度
    
    [self.separateLines makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    for (NSUInteger idx = 0; idx < self.numberOfGrids-1; idx++) {
        CALayer *layer = [CALayer layer];
        layer.backgroundColor = self.gridSeparateLineColor.CGColor;
        
        CGFloat x = a+(idx+1)*c+idx*b;
        CGFloat y = a;
        
        layer.frame = CGRectMake(x, y, b, h);
        [self.layer addSublayer:layer];
        [self.separateLines addObject:layer];
    }
}

- (void)setProgress:(float)progress
{
    [super setProgress:[self realProgress:progress]];
}

- (void)setProgress:(float)progress animated:(BOOL)animated
{
    [super setProgress:[self realProgress:progress] animated:animated];
}

- (CGFloat)realProgress:(CGFloat)progress
{
    if (self.jumpUpdate) {
        CGFloat p = ceil(progress * self.numberOfGrids) / self.numberOfGrids;
        return p;
    }else{
        return progress;
    }
}

#pragma mark - Setter
- (void)setBackColor:(UIColor *)backColor
{
    _backColor = backColor;
    [self update];
}

- (void)setGridColor:(UIColor *)gridColor
{
    _gridColor = gridColor;
    [self update];
}

- (void)setNumberOfGrids:(NSUInteger)numberOfGrids
{
    _numberOfGrids = numberOfGrids;
    [self updateGridSeparate];
}

- (void)setGridSeparateLineWidth:(CGFloat)gridSeparateLineWidth
{
    _gridSeparateLineWidth = gridSeparateLineWidth;
    [self updateGridSeparate];
}

- (void)setGridSeparateLineColor:(UIColor *)gridSeparateLineColor
{
    _gridSeparateLineColor = gridSeparateLineColor;
    [self updateGridSeparate];
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    _borderWidth = borderWidth;
    [self update];
}

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    [self update];
}

@end
