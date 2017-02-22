//
//  BaseCoverView.m
//  Golf
//
//  Created by 黄希望 on 14-7-21.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "BaseCoverView.h"

static BaseCoverView *coverViewInstance = nil;

@implementation BaseCoverView

+ (void)viewWithFrame:(CGRect)frame color:(UIColor*)color alpha:(CGFloat)alpha sbFrame:(CGRect)sbFrame sbView:(UIView*)sb spView:(UIView*)sp{
    coverViewInstance = [[self alloc] initWithFrame:frame color:color alpha:alpha sbFrame:sbFrame sbView:sb spView:sp];
}

- (id)initWithFrame:(CGRect)frame color:(UIColor*)color alpha:(CGFloat)alpha sbFrame:(CGRect)sbFrame sbView:(UIView*)sb spView:(UIView*)sp
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UIControl *control = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        if (color) {
            control.backgroundColor = color;
            control.alpha = alpha;
        }
        control.tag = 10101;
        [control addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:control];
        
        sb.tag = 10102;
        sb.frame = sbFrame;
        [self addSubview:sb];
        
        [sp addSubview:self];
    }
    return self;
}

- (void)remove{
    UIView *sp = self.superview;
    UIView *view = [sp viewWithTag:10101];
    UIView *view_1 = [sp viewWithTag:10102];
    if (view) {
        [view removeFromSuperview];
        view = nil;
    }
    if (view_1) {
        [view_1 removeFromSuperview];
        view_1 = nil;
    }
    [self removeFromSuperview];
}

@end
