//
//  UIView+YGGeometry.m
//  Golf
//
//  Created by bo wang on 2016/12/8.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "UIView+YGGeometry.h"

@implementation UIView (YGGeometry)

- (CGFloat)yg_x
{
    return CGRectGetMinX(self.frame);
}

- (void)yg_setX:(CGFloat)yg_x
{
    CGRect frame = self.frame;
    frame.origin.x = yg_x;
    self.frame = frame;
}

- (CGFloat)yg_y
{
    return CGRectGetMinY(self.frame);
}

- (void)yg_setY:(CGFloat)yg_y
{
    CGRect frame = self.frame;
    frame.origin.y = yg_y;
    self.frame = frame;
}

- (CGPoint)yg_origin
{
    return self.frame.origin;
}

- (void)yg_setOrigin:(CGPoint)yg_origin
{
    CGRect frame = self.frame;
    frame.origin = yg_origin;
    self.frame = frame;
}

- (CGFloat)yg_maxX
{
    return CGRectGetMaxX(self.frame);
}

- (CGFloat)yg_maxY
{
    return CGRectGetMaxY(self.frame);
}

- (CGFloat)yg_w
{
    return CGRectGetWidth(self.frame);
}

- (void)yg_setW:(CGFloat)yg_w
{
    CGRect frame = self.frame;
    frame.size.width = yg_w;
    self.frame = frame;
}

- (CGFloat)yg_h
{
    return CGRectGetHeight(self.frame);
}

- (void)yg_setH:(CGFloat)yg_h
{
    CGRect frame = self.frame;
    frame.size.height = yg_h;
    self.frame = frame;
}

- (CGSize)yg_size
{
    return self.frame.size;
}

- (void)yg_setSize:(CGSize)yg_size
{
    CGRect frame = self.frame;
    frame.size = yg_size;
    self.frame = frame;
}

- (CGFloat)yg_centerX
{
    return self.center.x;
}

- (void)yg_setCenterX:(CGFloat)yg_centerX
{
    CGPoint p = self.center;
    p.x = yg_centerX;
    self.center = p;
}

- (CGFloat)yg_centerY
{
    return self.center.y;
}

- (void)yg_setCenterY:(CGFloat)yg_centerY
{
    CGPoint p = self.center;
    p.y = yg_centerY;
    self.center = p;
}

@end
