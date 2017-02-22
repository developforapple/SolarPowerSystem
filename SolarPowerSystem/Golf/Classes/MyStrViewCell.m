//
//  MyStrViewCell.m
//  test2
//
//  Created by 廖瀚卿 on 15/6/3.
//  Copyright (c) 2015年 额度. All rights reserved.
//

#import "MyStrViewCell.h"
#import "UIView+AutoLayout.h"

@interface MyStrViewCell()

@property (nonatomic,strong) UIView *containerView;
@property (nonatomic,strong) UILabel *labelTitle;

@end

@implementation MyStrViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:MDSpreadViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        if (Device_SysVersion >= 8.0) {
            _containerView = [UIView autoLayoutView];
            [self addSubview:_containerView];
            
            [_containerView pinToSuperviewEdges:(JRTViewPinAllEdges) inset:6];
            [_containerView.layer setCornerRadius:(47 - 12 )/2];
            [_containerView setClipsToBounds:YES];
            
            _labelTitle = [UILabel autoLayoutView];
            [_containerView addSubview:_labelTitle];
            _labelTitle.textColor = [UIColor whiteColor];
            _labelTitle.font = [UIFont systemFontOfSize:14.0];
            _labelTitle.textAlignment = NSTextAlignmentCenter;
            [_labelTitle pinToSuperviewEdges:(JRTViewPinTopEdge) inset:2];
            [_labelTitle pinToSuperviewEdges:(JRTViewPinLeftEdge) inset:0];
            [_labelTitle pinToSuperviewEdges:(JRTViewPinRightEdge) inset:0];
            
            _labelCount = [UILabel autoLayoutView];
            [_containerView addSubview:_labelCount];
            _labelCount.textColor = [UIColor whiteColor];
            _labelCount.font = [UIFont systemFontOfSize:12.0];
            _labelCount.textAlignment = NSTextAlignmentCenter;
            [_labelCount pinToSuperviewEdges:(JRTViewPinBottomEdge) inset:2];
            [_labelCount pinToSuperviewEdges:(JRTViewPinLeftEdge) inset:0];
            [_labelCount pinToSuperviewEdges:(JRTViewPinRightEdge) inset:0];
        }else{
            CGRect f = CGRectMake(6, 6, 47 - 12, 47 -12);
            _containerView = [[UIView alloc] initWithFrame:f];
            [_containerView.layer setCornerRadius:(47 - 12 )/2];
            [_containerView setClipsToBounds:YES];
            
            _labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, _containerView.size.width, 15)];
            _labelTitle.textColor = [UIColor whiteColor];
            _labelTitle.backgroundColor = [UIColor clearColor];
            _labelTitle.font = [UIFont systemFontOfSize:14.0];
            _labelTitle.textAlignment = NSTextAlignmentCenter;
            [_containerView addSubview:_labelTitle];
            
            
            _labelCount = [[UILabel alloc] initWithFrame:CGRectMake(0, _labelTitle.origin.y + _labelTitle.size.height, _containerView.size.width, 14)];
            _labelCount.textColor = [UIColor whiteColor];
            _labelCount.backgroundColor = [UIColor clearColor];
            _labelCount.font = [UIFont systemFontOfSize:12.0];
            _labelCount.textAlignment = NSTextAlignmentCenter;
            [_containerView addSubview:_labelCount];
            
            [self addSubview:_containerView];
        }
    }
    
    return self;
}

-(void)setCourseType:(CourseType)courseType{
    _courseType = courseType;
    switch (courseType) {
        case CourseTypeGroup:
            _containerView.backgroundColor = [UIColor colorWithRed:255/255.0 green:144/255.0 blue:144/255.0 alpha:1.0];
            _labelTitle.text = @"团";
            break;
        case CourseTypePublic:
            _containerView.backgroundColor = [UIColor colorWithRed:143/255.0 green:181/255.0 blue:227/255.0 alpha:1.0];
            _labelTitle.text = @"公";
            break;
        default:
            _containerView.backgroundColor = [UIColor whiteColor];
            break;
    }
}

@end
