//
//  StarView.m
//  Golf
//
//  Created by user on 13-6-5.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import "StarView.h"
#import "Star.h"

@implementation StarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)setNib{
    self.backgroundColor = [UIColor clearColor];
    [self createFiveStars];
}

- (void)createFiveStars{
    [self layoutIfNeeded];
    for (int i=0; i<5; i++) {
        Star *star = [Star buttonWithType:UIButtonTypeCustom];
        [star setFrame:CGRectMake(self.frame.size.width/5.*i, 0, 36, 36)];
        [star addTarget:self action:@selector(clickStar:) forControlEvents:UIControlEventTouchUpInside];
        star.tag = i+1;
        [self addSubview:star];
    }
}

- (void)clickStar:(id)sender{
    int value = 0;
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    NSArray *subView = [self subviews];
    for(UIButton *button in subView){
        if (btn.selected) {
            if (button.tag <= btn.tag) {
                button.selected = btn.selected;
            }
            else{
                button.selected = !btn.selected;
            }
        }else{
            if (button.tag > btn.tag) {
                button.selected = btn.selected;
            }
        }
        value += button.selected;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@(self.tag) forKey:@"viewtag"];
    [dic setValue:@(value) forKey:@"viewvalue"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkStarButtonClick" object:dic];
}

@end
