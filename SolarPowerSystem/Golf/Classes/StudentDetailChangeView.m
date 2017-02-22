//
//  StudentDetailChangeView.m
//  Golf
//
//  Created by 黄希望 on 15/6/8.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "StudentDetailChangeView.h"

@interface StudentDetailChangeView()

@property (nonatomic,weak) IBOutlet UILabel *leftLabel;
@property (nonatomic,weak) IBOutlet UILabel *rightLabel;
@property (nonatomic,weak) IBOutlet UIView *leftView;
@property (nonatomic,weak) IBOutlet UIView *rightView;
@property (nonatomic,weak) IBOutlet UIView *lineView;

@end

@implementation StudentDetailChangeView

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self];
    if (CGRectContainsPoint(_leftView.frame, pt)) {
        if (_blockReturn) {
            [self move:1];
            _blockReturn (@(1));
        }
    }else if (CGRectContainsPoint(_rightView.frame, pt)){
        if (_blockReturn) {
            [self move:2];
            _blockReturn (@(2));
        }
    }
}

- (void)move:(NSInteger)index{
    if (index == 1) {
        _leftLabel.textColor = MainHighlightColor;
        _rightLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    }else{
        _leftLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _rightLabel.textColor = MainHighlightColor;
    }
    
    for (NSLayoutConstraint *lct in self.constraints) {
        if (lct.firstAttribute == NSLayoutAttributeLeading && lct.firstItem == _lineView) {
            ygweakify(lct);
            ygweakify(self);
            [UIView animateWithDuration:0.3 animations:^{
                ygstrongify(lct);
                ygstrongify(self);
                if (index == 1) {
                    lct.constant = 0.;
                }else{
                    lct.constant = Device_Width/2.;
                }
                [self layoutIfNeeded];
            }];
            break;
        }
    }
}

@end
