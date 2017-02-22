//
//  UILabel+Hxw.m
//  Table
//
//  Created by user on 13-4-24.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import "UILabel+Hxw.h"

@implementation UILabel (Hxw)

+ (UILabel *)labelWithFrame:(CGRect)frame text:(NSString *)text textColor:(UIColor*)color font:(float)size{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:size];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.textColor = !color ? [UIColor blackColor] : color;
    label.text = text;
    return label;
}

+ (CGRect)doubleLabelsWithFrame:(CGRect)frame title:(NSString*)title text:(NSString*)text font:(float)fontSize lineBreak:(BOOL)lineBreak contentColor:(UIColor*)color forView:(UIView *)view {
    CGSize size = [Utilities getSize:title withFont:[UIFont systemFontOfSize:fontSize] withWidth:Device_Width];
    UILabel *titleLabel = [UILabel labelWithFrame:CGRectMake(frame.origin.x, frame.origin.y, size.width, size.height) text:title textColor:[UIColor blackColor] font:fontSize];
    [view addSubview:titleLabel];
    
    if (lineBreak) {
        size = [Utilities getSize:text withFont:[UIFont systemFontOfSize:fontSize] withWidth:frame.size.width-size.width-5];
        //size = [text sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(frame.size.width-size.width-5, 100) lineBreakMode:NSLineBreakByWordWrapping];
    }
    else{
        CGSize tempSize = size;
        size = [Utilities getSize:text withFont:[UIFont systemFontOfSize:fontSize] withWidth:Device_Width];
        size.width = MIN(size.width, frame.size.width - tempSize.width-5);
    }
    
    UILabel *contentLabel = [UILabel labelWithFrame:CGRectMake(frame.origin.x+titleLabel.frame.size.width+5, frame.origin.y, size.width, size.height) text:text textColor:color ? color : [UIColor blackColor] font:fontSize];
    [view addSubview:contentLabel];
    CGRect rt = CGRectMake(frame.origin.x, frame.origin.y + size.height + 2, frame.size.width, size.height);
    
    return rt;
}

+ (CGRect)labelColumnWithFrame:(CGRect)frame titleArray:(NSArray*)titleArr textArray:(NSArray*)textArr font:(float)fontSize lineBreak:(BOOL)lineBreak forView:(UIView*)view{
    if (!titleArr || !textArr || titleArr.count == textArr.count == 0 || titleArr.count != textArr.count) {
       // NSLog(@"error: illegal to create labels");
        return CGRectZero;
    }
    CGRect rt = frame;
    NSInteger index ;
    for(NSString *title in titleArr){
        index = [titleArr indexOfObject:title];
        rt = [UILabel doubleLabelsWithFrame:rt title:title text:[textArr objectAtIndex:index] font:fontSize lineBreak:lineBreak contentColor:nil forView:view];
    }
    return CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, rt.origin.y - frame.origin.y);
}

+ (CGRect)labelColumnWithFrame:(CGRect)frame titleArray:(NSArray*)titleArr textArray:(NSArray*)textArr font:(float)fontSize lineBreak:(BOOL)lineBreak forView:(UIView*)view contentColor:(UIColor*)color{
    if (!titleArr || !textArr || titleArr.count == textArr.count == 0 || titleArr.count != textArr.count) {
      //  NSLog(@"error: illegal to create labels");
        return CGRectZero;
    }
    CGRect rt = frame;
    NSInteger index ;
    for(NSString *title in titleArr){
        index = [titleArr indexOfObject:title];
        rt = [UILabel doubleLabelsWithFrame:rt title:title text:[textArr objectAtIndex:index] font:fontSize lineBreak:lineBreak contentColor:color forView:view];
    }
    return CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, rt.origin.y - frame.origin.y);
}

+ (CGRect)labelDoubleColumnWithFrame:(CGRect)frame titleArray:(NSArray*)titleArr textArray:(NSArray*)textArr font:(float)fontSize lineBreak:(BOOL)lineBreak forView:(UIView*)view{
    if (!titleArr || !textArr || titleArr.count == textArr.count == 0 || titleArr.count != textArr.count) {
      //  NSLog(@"error: illegal to create labels");
        return CGRectZero;
    }
    CGRect rt1 = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width/2-5, frame.size.height);
    CGRect rt2 = CGRectMake(frame.origin.x + frame.size.width/2 + 5, frame.origin.y, frame.size.width/2, frame.size.height);
    NSInteger index ;
    for(NSString *title in titleArr){
        index = [titleArr indexOfObject:title];
        if (index % 2 == 0) {
            rt1 = [UILabel doubleLabelsWithFrame:rt1 title:title text:[textArr objectAtIndex:index] font:fontSize lineBreak:lineBreak contentColor:nil forView:view];
        }
        else{
            rt2 = [UILabel doubleLabelsWithFrame:rt2 title:title text:[textArr objectAtIndex:index] font:fontSize lineBreak:lineBreak contentColor:nil forView:view];
        }
    }
    return CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, rt1.origin.y - frame.origin.y);
}

+ (CGRect)labelDoubleColumnWithFrame:(CGRect)frame titleArray:(NSArray*)titleArr textArray:(NSArray*)textArr font:(float)fontSize lineBreak:(BOOL)lineBreak forView:(UIView*)view contentColor:(UIColor*)color{
    if (!titleArr || !textArr || titleArr.count == textArr.count == 0 || titleArr.count != textArr.count) {
       // NSLog(@"error: illegal to create labels");
        return CGRectZero;
    }
    CGRect rt1 = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width/2-5, frame.size.height);
    CGRect rt2 = CGRectMake(frame.origin.x + frame.size.width/2 + 5, frame.origin.y, frame.size.width/2, frame.size.height);
    NSInteger index ;
    for(NSString *title in titleArr){
        index = [titleArr indexOfObject:title];
        if (index % 2 == 0) {
            rt1 = [UILabel doubleLabelsWithFrame:rt1 title:title text:[textArr objectAtIndex:index] font:fontSize lineBreak:lineBreak contentColor:color forView:view];
        }
        else{
            rt2 = [UILabel doubleLabelsWithFrame:rt2 title:title text:[textArr objectAtIndex:index] font:fontSize lineBreak:lineBreak contentColor:color forView:view];
        }
    }
    return CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, rt1.origin.y - frame.origin.y);
}

@end
