//
//  YGLineView.m
//  Golf
//
//  Created by bo wang on 16/6/20.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGLineView.h"

@interface YGLineView ()
@property (strong, readwrite, nonatomic) CALayer *lineLayer;
@end

@implementation YGLineView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self->_lineColor = [UIColor whiteColor];
        self->_lineWidth = .5f;
        self->_direction = YGLineDirectionHorizontal;
        self->_insets = UIEdgeInsetsZero;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self update];
}

- (void)update
{
    CGFloat width = self.lineWidth;
    CGRect frame = CGRectZero;
    
    switch (self.direction) {
        case YGLineDirectionHorizontal: {
            
            CGFloat x = self.insets.left;
            CGFloat y = self.insets.top;
            CGFloat w = CGRectGetWidth(self.frame) - self.insets.left - self.insets.right;
            CGFloat h = width;
    
            frame = CGRectMake(x, y, w, h);
            break;
        }
        case YGLineDirectionVertical: {
            
            CGFloat x = self.insets.left;
            CGFloat y = self.insets.top;
            CGFloat w = width;
            CGFloat h = CGRectGetHeight(self.frame) - self.insets.top - self.insets.bottom;
            
            frame = CGRectMake(x, y, w, h);
            break;
        }
        case YGLineDirectionHorizontalBottom:{
            CGFloat w = CGRectGetWidth(self.frame) - self.insets.left - self.insets.right;
            CGFloat h = width;
            CGFloat x = self.insets.left;
            CGFloat y = CGRectGetHeight(self.frame) - self.insets.bottom - h;
            
            frame = CGRectMake(x, y, w, h);
            break;
        }
        case YGLineDirectionVerticalRight:{
            CGFloat w = width;
            CGFloat h = CGRectGetHeight(self.frame) - self.insets.top - self.insets.bottom;
            CGFloat x = CGRectGetWidth(self.frame) - self.insets.right - w;
            CGFloat y = self.insets.top;
            
            frame = CGRectMake(x, y, w, h);
            break;
        }
    }
    self.lineLayer.frame = frame;
}

- (CALayer *)lineLayer
{
    if (!_lineLayer) {
        _lineLayer = [CALayer layer];
        [self.layer insertSublayer:_lineLayer atIndex:0];
    }
    return _lineLayer;
}

#pragma mark - Setter
- (void)setLineColor:(UIColor *)lineColor
{
    _lineColor = lineColor;
    self.lineLayer.backgroundColor = self.lineColor.CGColor;
}

- (void)setLineWidth:(CGFloat)lineWidth
{
    _lineWidth = lineWidth;
    [self update];
}

- (void)setDirection:(NSUInteger)direction
{
    _direction = direction;
    [self update];
}

- (void)setDirectionDesc:(NSString *)directionDesc
{
    _directionDesc = directionDesc;
    YGLineDirection direction;
    if ([directionDesc isEqualToString:kYGLineDirectionHorizontal]) {
        direction = YGLineDirectionHorizontal;
    }else if ([directionDesc isEqualToString:kYGLineDirectionVertical]){
        direction = YGLineDirectionVertical;
    }else if ([directionDesc isEqualToString:kYGLineDirectionVerticalRight]){
        direction = YGLineDirectionVerticalRight;
    }else if ([directionDesc isEqualToString:kYGLineDirectionHorizontalBottom]){
        direction = YGLineDirectionHorizontalBottom;
    }else{
        return;
    }
    self.direction = direction;
}

- (void)setInsetsTop:(CGFloat)insetsTop
{
    UIEdgeInsets insets = self.insets;
    insets.top = insetsTop;
    self.insets = insets;
}

- (void)setInsetsLeft:(CGFloat)insetsLeft
{
    UIEdgeInsets insets = self.insets;
    insets.left = insetsLeft;
    self.insets = insets;
}

- (void)setInsetsBottom:(CGFloat)insetsBottom
{
    UIEdgeInsets insets = self.insets;
    insets.bottom = insetsBottom;
    self.insets = insets;
}

- (void)setInsetsRight:(CGFloat)insetsRight
{
    UIEdgeInsets insets = self.insets;
    insets.right = insetsRight;
    self.insets = insets;
}

- (CGFloat)insetsTop{return self.insets.top;}
- (CGFloat)insetsLeft{return self.insets.left;}
- (CGFloat)insetsBottom{return self.insets.bottom;}
- (CGFloat)insetsRight{return self.insets.right;}

- (void)setInsets:(UIEdgeInsets)insets
{
    _insets = insets;
    [self update];
}

@end
