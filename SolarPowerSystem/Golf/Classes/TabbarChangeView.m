//
//  TabbarChangeView.m
//  Golf
//
//  Created by 黄希望 on 15/11/13.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "TabbarChangeView.h"

@interface TabbarChangeView()
{
    NSNumber *_blurFlag;
}
@property (nonatomic,weak) IBOutlet UIView *lineView;
@property (nonatomic,strong) IBOutletCollection(UIButton) NSArray *btns;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbarBg;
@property (weak, nonatomic) IBOutlet UIView *viewContainer;

@end

@implementation TabbarChangeView

- (void)awakeFromNib{
    [super awakeFromNib];
    [self layoutIfNeeded];
    [self changeLineView:1 animated:NO];
}

- (void)changeBlur:(BOOL)flag{
    if (!_blurFlag || _blurFlag.boolValue != flag) {
        _blurFlag = @(flag);
        if (flag) {
            self.toolbarBg.hidden = NO;
            self.viewContainer.backgroundColor = [UIColor clearColor];
        }else{
            self.toolbarBg.hidden = YES;
            self.viewContainer.backgroundColor = [UIColor whiteColor];
        }
    }
}

- (void)changeLineView:(NSInteger)index animated:(BOOL)animated
{
    [self layoutIfNeeded];
    CGFloat lx = (Device_Width-56*2)/3.-7;   //lineview的x坐标
    CGFloat lc = lx+_lineView.width/2.;         //lineview的center的x坐标
    CGFloat gab = lc - Device_Width/4.;
    
    // 调整按钮的title的位置
    if (!animated) {
        for (UIButton *btn in _btns) {
            if (btn.tag == 1) {
                [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, gab, 0, -gab)];
            }else{
                [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -gab, 0, gab)];
            }
        }
    }
    
    for (NSLayoutConstraint *lc in _lineView.superview.constraints) {
        if (lc.firstAttribute == NSLayoutAttributeLeading&&lc.firstItem == _lineView) {
            lc.constant = index == 1 ? lx : Device_Width*3/4-gab-70/2.;
            if (animated) {
                [UIView animateWithDuration:.5 delay:0 usingSpringWithDamping:1.8 initialSpringVelocity:1.8 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
                    [_lineView.superview layoutIfNeeded];
                } completion:nil];
            }else{
                [_lineView.superview layoutIfNeeded];
            }
        }
    }
    
    for (UIButton *btn in _btns) {
        btn.selected = index == btn.tag;
    }
}

- (IBAction)buttonAction:(UIButton*)sender{
    for (UIButton *btn in _btns) {
        btn.selected = NO;
    }
    sender.selected = YES;
    [self changeLineView:sender.tag animated:YES];
    if (_clickBlock) {
        _clickBlock (@(sender.tag));
    }
}

@end
