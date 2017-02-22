//
//  HHProgressView.m
//  HHProgressView
//
//  Created by zengcatch on 15/3/22.
//  Copyright © 2015年 yizhixiang. All rights reserved.
//

#import "HHProgressView.h"

void hhStrokeRectInContext(CGContextRef context, CGRect rect, CGFloat lineWidth, CGFloat radius);
void hhFillRectInContext(CGContextRef context, CGRect rect, CGFloat radius);
void hhSetRectPathInContext(CGContextRef context, CGRect rect, CGFloat radius);


@implementation HHProgressView

@synthesize progress = _progress;
@synthesize barBorderWidth = _barBorderWidth;
@synthesize barBorderColor = _barBorderColor;
@synthesize barInnerBorderWidth = _barInnerBorderWidth;
@synthesize barInnerBorderColor = _barInnerBorderColor;
@synthesize barInnerPadding = _barInnerPadding;
@synthesize barFillColor = _barFillColor;
@synthesize barBackgroundColor = _barBackgroundColor;
@synthesize usesRoundedCorners = _usesRoundedCorners;


#pragma mark - public Methods

- (void)setProgress:(CGFloat)newProgress {
    _progress = fmaxf(0.0, fminf(1.0, newProgress));
    [self setNeedsDisplay];
}

- (void)setBarBorderWidth:(CGFloat)barBorderWidth {
    _barBorderWidth = barBorderWidth;
    [self setNeedsDisplay];
}

- (void)setBarBorderColor:(UIColor *)barBorderColor {
    _barBorderColor = barBorderColor;
    [self setNeedsDisplay];
}

- (void)setBarInnerBorderWidth:(CGFloat)barInnerBorderWidth {
    _barInnerBorderWidth = barInnerBorderWidth;
    [self setNeedsDisplay];
}

- (void)setBarInnerBorderColor:(UIColor *)barInnerBorderColor {
    _barInnerBorderColor = barInnerBorderColor;
    [self setNeedsDisplay];
}

- (void)setBarInnerPadding:(CGFloat)barInnerPadding {
    _barInnerPadding = barInnerPadding;
    [self setNeedsDisplay];
}

- (void)setBarFillColor:(UIColor *)barFillColor {
    _barFillColor = barFillColor;
    [self setNeedsDisplay];
}

- (void)setBarBackgroundColor:(UIColor *)barBackgroundColor {
    _barBackgroundColor = barBackgroundColor;
    [self setNeedsDisplay];
}

- (void)setUsesRoundedCorners:(NSInteger)usesRoundedCorners {
    _usesRoundedCorners = usesRoundedCorners;
    [self setNeedsDisplay];
}


#pragma mark - Class Methods

+ (UIColor *)defaultBarColor {
    return [UIColor colorWithRed:255.f/255.f green:255.f/255.f blue:255.f/255.f alpha:1.0f];
}

#pragma mark - UIView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self initialize];
    }
    return self;
}


- (id)initWithFrame:(CGRect)aFrame {
    if ((self = [super initWithFrame:aFrame])) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.contentMode = UIViewContentModeRedraw;
    self.backgroundColor = [UIColor clearColor];
}

+ (void)initialize {
    if (self == [HHProgressView class]) {
        HHProgressView *appearance = [HHProgressView appearance];
        [appearance setUsesRoundedCorners:YES];
        [appearance setProgress:.0f];
        [appearance setBarBorderWidth:0.0f];
        [appearance setBarBorderColor:[self defaultBarColor]];
        [appearance setBarInnerBorderWidth:.0f];
        [appearance setBarInnerBorderColor:[self defaultBarColor]];
        [appearance setBarInnerPadding:.0f];
        [appearance setBarFillColor:[self defaultBarColor]];
        UIColor *bColor = [UIColor colorWithRed:255.f/255.f green:255.f/255.f blue:255.f/255.f alpha:.35f];
        [appearance setBarBackgroundColor:bColor];
    }
}

#pragma mark - Drawing Functions

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetAllowsAntialiasing(context, TRUE);
    
    CGRect currentRect = rect;
    CGFloat radius = 0;
    CGFloat halfLineWidth = 0;
    
    // Background
    if (self.backgroundColor) {
        if (self.usesRoundedCorners) radius = currentRect.size.height / 2.0;
        
        [self.barBackgroundColor setFill];
        hhFillRectInContext(context, currentRect, radius);
    }
    
    // Border
    if (self.barBorderColor && self.barBorderWidth > 0.0) {
        // Inset, because a stroke is centered on the path
        // See http://stackoverflow.com/questions/10557157/drawing-rounded-rect-in-core-graphics
        halfLineWidth = self.barBorderWidth / 2.0;
        currentRect = CGRectInset(currentRect, halfLineWidth, halfLineWidth);
        if (self.usesRoundedCorners) radius = currentRect.size.height / 2.0;
        
        [self.barBorderColor setStroke];
        hhStrokeRectInContext(context, currentRect, self.barBorderWidth, radius);
        
        currentRect = CGRectInset(currentRect, halfLineWidth, halfLineWidth);
    }
    
    // Padding
    currentRect = CGRectInset(currentRect, self.barInnerPadding, self.barInnerPadding);
    
    BOOL hasInnerBorder = NO;
    // Inner border
    if (self.barInnerBorderColor && self.barInnerBorderWidth > 0.0) {
        hasInnerBorder = YES;
        halfLineWidth = self.barInnerBorderWidth / 2.0;
        currentRect = CGRectInset(currentRect, halfLineWidth, halfLineWidth);
        if (self.usesRoundedCorners) radius = currentRect.size.height / 2.0;
        
        // progress
        currentRect.size.width *= self.progress;
        currentRect.size.width = fmaxf(currentRect.size.width, 2 * radius);
        
        [self.barInnerBorderColor setStroke];
        hhStrokeRectInContext(context, currentRect, self.barInnerBorderWidth, radius);
        
        currentRect = CGRectInset(currentRect, halfLineWidth, halfLineWidth);
    }
    
    // Fill
    if (self.barFillColor) {
        if (self.usesRoundedCorners) radius = currentRect.size.height / 2;
        
        // recalculate width
        if (!hasInnerBorder) {
            currentRect.size.width *= self.progress;
            currentRect.size.width = fmaxf(currentRect.size.width, 2 * radius);
        }
        
        if (self.progress > 0) {
             [self.barFillColor setFill];
            hhFillRectInContext(context, currentRect, radius);
        }
    }
    
    // Restore the context
    CGContextRestoreGState(context);
}


void hhStrokeRectInContext(CGContextRef context, CGRect rect, CGFloat lineWidth, CGFloat radius) {
    CGContextSetLineWidth(context, lineWidth);
    hhSetRectPathInContext(context, rect, radius);
    CGContextStrokePath(context);
}


void hhFillRectInContext(CGContextRef context, CGRect rect, CGFloat radius) {
    hhSetRectPathInContext(context, rect, radius);
    CGContextFillPath(context);
}


void hhSetRectPathInContext(CGContextRef context, CGRect rect, CGFloat radius) {
    CGContextBeginPath(context);
    if (radius > 0.0) {
        CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMidY(rect));
        CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMidX(rect), CGRectGetMinY(rect), radius);
        CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMidY(rect), radius);
        CGContextAddArcToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMidX(rect), CGRectGetMaxY(rect), radius);
        CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMidY(rect), radius);
    } else {
        CGContextAddRect(context, rect);
    }
    CGContextClosePath(context);
}

@end
