//
//  MyHeaderViewCell.m
//  test2
//
//  Created by 廖瀚卿 on 15/6/2.
//  Copyright (c) 2015年 额度. All rights reserved.
//

#import "MyHeaderViewCell.h"
#import "UIView+AutoLayout.h"


@interface MyHeaderViewCell()

@end

@implementation MyHeaderViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:MDSpreadViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        if (Device_SysVersion >= 8.0) {
            if (_labelWeek == nil) {
                _labelWeek = [UILabel autoLayoutView];
                [self addSubview:_labelWeek];
            }
            
            _labelWeek.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
            _labelWeek.font = [UIFont systemFontOfSize:12.0];
            _labelWeek.textAlignment = NSTextAlignmentCenter;
            [_labelWeek pinToSuperviewEdges:(JRTViewPinTopEdge) inset:10.0];
            [_labelWeek pinToSuperviewEdges:(JRTViewPinLeftEdge) inset:0];
            [_labelWeek pinToSuperviewEdges:(JRTViewPinRightEdge) inset:0];
            
            if (_labelDay == nil) {
                _labelDay = [UILabel autoLayoutView];
                [self addSubview:_labelDay];
            }
            
            _labelDay.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
            _labelDay.textAlignment = NSTextAlignmentCenter;
            _labelDay.font = [UIFont systemFontOfSize:16.0];
            [_labelDay pinToSuperviewEdges:(JRTViewPinLeftEdge) inset:0];
            [_labelDay pinToSuperviewEdges:(JRTViewPinRightEdge) inset:0];
            [_labelDay pinAttribute:(NSLayoutAttributeTop) toAttribute:(NSLayoutAttributeBottom) ofItem:_labelWeek withConstant:6 relation:NSLayoutRelationEqual];
            
            if (_labelCount == nil) {
                _labelCount = [UILabel autoLayoutView];
                [self addSubview:_labelCount];
            }
            
            _labelCount.font = [UIFont systemFontOfSize:14.0];
            _labelCount.textAlignment = NSTextAlignmentCenter;
            _labelCount.textColor = MainHighlightColor;
            [_labelCount pinAttribute:(NSLayoutAttributeTop) toAttribute:(NSLayoutAttributeBottom) ofItem:_labelDay withConstant:6 relation:NSLayoutRelationEqual];
            
            [_labelCount pinToSuperviewEdges:(JRTViewPinLeftEdge) inset:0];
            [_labelCount pinToSuperviewEdges:(JRTViewPinRightEdge) inset:0];
            
            if (_btnAction == nil) {
                _btnAction = [MyButton autoLayoutView];
                [self addSubview:_btnAction];
            }
            [_btnAction setHighlightedColor:[UIColor colorWithHexString:@"#e6e6e6"]];
            [_btnAction addTarget:self action:@selector(btnPressed) forControlEvents:UIControlEventTouchUpInside];
            [_btnAction pinToSuperviewEdgesWithInset:UIEdgeInsetsMake(0, 0, 0, 0)];
            [self layoutIfNeeded];
        }else{
            if (_labelWeek == nil) {
                _labelWeek = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 47, 15)];
                [self addSubview:_labelWeek];
            }
            _labelWeek.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
            _labelWeek.font = [UIFont systemFontOfSize:12.0];
            _labelWeek.textAlignment = NSTextAlignmentCenter;
            
            
            if (_labelDay == nil) {
                _labelDay = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 47, 20)];
                [self addSubview:_labelDay];
            }
            
            _labelDay.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
            _labelDay.textAlignment = NSTextAlignmentCenter;
            _labelDay.font = [UIFont systemFontOfSize:16.0];
            
            
            if (_labelCount == nil) {
                _labelCount = [[UILabel alloc] initWithFrame:CGRectMake(0, 53, 47, 20)];
                [self addSubview:_labelCount];
            }
            
            _labelCount.font = [UIFont systemFontOfSize:14.0];
            _labelCount.textAlignment = NSTextAlignmentCenter;
            _labelCount.textColor = MainHighlightColor;
            
            if (_btnAction == nil) {
                _btnAction = [[MyButton alloc]initWithFrame:CGRectMake(0, 0, 47+15, 76)];
                [self addSubview:_btnAction];
            }
            [_btnAction setHighlightedColor:[UIColor colorWithHexString:@"#e6e6e6"]];
            [_btnAction addTarget:self action:@selector(btnPressed) forControlEvents:(UIControlEventTouchUpInside)];

        }
    }
    return self;
}

-(void)btnPressed{
    if (_blockReturn) {
        _blockReturn(_data);
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
}

@end
