//
//  SelectPeopleView.m
//  Golf
//
//  Created by 黄希望 on 13-12-30.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import "SelectPeopleView.h"

@implementation SelectPeopleView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) selectPeopleWithRemainMans:(int)remainMans minBuyQuantity:(int)minBuyQuantity curMans:(int)curMans{
    _remainMans = remainMans;
    _minBuyQuantity = minBuyQuantity;
    _peopleCount = curMans;
    [self setButtonStatus];
}

- (void)setButtonStatus{
    decreaseBtn.enabled = YES;
    addBtn.enabled = YES;
    [decreaseBtn setBackgroundImage:[UIImage imageNamed:@"btn_jian_02"] forState:UIControlStateNormal];
    [addBtn setBackgroundImage:[UIImage imageNamed:@"btn_jia_02"] forState:UIControlStateNormal];
    
    if (_peopleCount < MAX(_minBuyQuantity, 1)){
        _peopleCount = MAX(_minBuyQuantity, 1);
    }else if (_peopleCount > _remainMans){
        _peopleCount = _remainMans;
    }
    
    if (_peopleCount >= _remainMans) {
        addBtn.enabled = NO;
        [addBtn setBackgroundImage:[UIImage imageNamed:@"btn_jia_01"] forState:UIControlStateNormal];
    }
    
    if (_peopleCount <= MAX(_minBuyQuantity, 1)) {
        decreaseBtn.enabled = NO;
        [decreaseBtn setBackgroundImage:[UIImage imageNamed:@"btn_jian_01"] forState:UIControlStateNormal];
    }
    
    [peopleBtn setTitle:[NSString stringWithFormat:@"%d人",_peopleCount] forState:UIControlStateNormal];
}

- (IBAction)clickAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == 1)
        _peopleCount --;
    else
        _peopleCount ++;
    
    [self setButtonStatus];
    
    if ([_delegate respondsToSelector:@selector(selectPeopleViewDelegateWithCount:)]) {
        [_delegate selectPeopleViewDelegateWithCount:_peopleCount];
    }
}

@end
