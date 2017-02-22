//
//  PublicCourseJoinView.m
//  Golf
//
//  Created by 黄希望 on 15/5/14.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "PublicCourseJoinView.h"

static PublicCourseJoinView *PUBLIC_COURSE_JOIN_VIEW_INSTANCE;

@interface PublicCourseJoinView()<YGLoginViewCtrlDelegate>

@property (nonatomic,weak) IBOutlet UITextField *phoneNumField;
@property (nonatomic,weak) IBOutlet UIView *phoneView;
@property (nonatomic,weak) IBOutlet UIView *bgView;
@property (nonatomic,weak) IBOutlet UIButton *joinBtn;
@property (nonatomic,weak) IBOutlet UILabel *lineView;

@property (nonatomic,copy) void(^completion)(NSString *phoneNum,NSInteger actionTag);

@end

@implementation PublicCourseJoinView

+ (void)popWithSupView:(UIView*)aView price:(int)price completion:(void(^)(NSString *phoneNum,NSInteger actionTag))completion{
    if (PUBLIC_COURSE_JOIN_VIEW_INSTANCE) {
        if (PUBLIC_COURSE_JOIN_VIEW_INSTANCE.superview) {
            [PUBLIC_COURSE_JOIN_VIEW_INSTANCE removeFromSuperview];
        }
        PUBLIC_COURSE_JOIN_VIEW_INSTANCE = nil;
    }
    UIControl *control = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, Device_Width, Device_Height)];
    control.backgroundColor = [UIColor blackColor];
    control.alpha = 0.4;
    
    PUBLIC_COURSE_JOIN_VIEW_INSTANCE = [[[NSBundle mainBundle] loadNibNamed:@"PublicCourseJoinView" owner:self options:nil] lastObject];
    PUBLIC_COURSE_JOIN_VIEW_INSTANCE.frame = CGRectMake(0, 0, Device_Width, Device_Height);
    [aView addSubview:PUBLIC_COURSE_JOIN_VIEW_INSTANCE];
    [PUBLIC_COURSE_JOIN_VIEW_INSTANCE insertSubview:control atIndex:0];
    [control addTarget:PUBLIC_COURSE_JOIN_VIEW_INSTANCE action:@selector(hideView:) forControlEvents:UIControlEventTouchUpInside];
    
    [Utilities drawView:PUBLIC_COURSE_JOIN_VIEW_INSTANCE.phoneView radius:3 bordLineWidth:0.5 borderColor:[UIColor colorWithHexString:@"#C8C8C8"]];
    PUBLIC_COURSE_JOIN_VIEW_INSTANCE.phoneNumField.text = [[NSUserDefaults standardUserDefaults] objectForKey:KGolfSessionPhone];
    
    if (price > 0) {
        [PUBLIC_COURSE_JOIN_VIEW_INSTANCE.joinBtn setTitle:[NSString stringWithFormat:@"确认报名，去支付¥%d",price] forState:UIControlStateNormal];
    }
    
    if (Device_Height == 480) {
        for (NSLayoutConstraint *c  in [PUBLIC_COURSE_JOIN_VIEW_INSTANCE constraints]) {
            if (c.firstAttribute == NSLayoutAttributeCenterY) {
                c.constant += 40;
                [PUBLIC_COURSE_JOIN_VIEW_INSTANCE layoutIfNeeded];
                break;
            }
        }
    }
    
    for (NSLayoutConstraint *c  in [PUBLIC_COURSE_JOIN_VIEW_INSTANCE.lineView constraints]) {
        if (c.firstAttribute == NSLayoutAttributeHeight) {
            c.constant = 0.5;
            [PUBLIC_COURSE_JOIN_VIEW_INSTANCE.lineView layoutIfNeeded];
            break;
        }
    }
    PUBLIC_COURSE_JOIN_VIEW_INSTANCE.completion = completion;
}

- (void)hideView:(UIView*)view{
    [self.phoneNumField resignFirstResponder];
    [UIView animateWithDuration:0.07 animations:^{
        PUBLIC_COURSE_JOIN_VIEW_INSTANCE.alpha = 0.;
    } completion:^(BOOL finished) {
        [PUBLIC_COURSE_JOIN_VIEW_INSTANCE removeFromSuperview];
        PUBLIC_COURSE_JOIN_VIEW_INSTANCE = nil;
    }];
}

- (IBAction)joinAction:(id)sender{
    [self.phoneNumField resignFirstResponder];
    if ([Utilities isBlankString:self.phoneNumField.text]) {
        [SVProgressHUD showInfoWithStatus:@"请输入手机号"];
        return;
    }else if (![Utilities phoneNumMatch:self.phoneNumField.text]){
        [SVProgressHUD showErrorWithStatus:@"手机号输入错误"];
        return;
    }
    
    if (![LoginManager sharedManager].loginState) {
        [[LoginManager sharedManager] loginWithDelegate:self controller:[GolfAppDelegate shareAppDelegate].currentController animate:YES];
        return;
    }
    
    // 报名
    self.completion(self.phoneNumField.text,1);
    [self hideView:nil];
}

- (void)loginButtonPressed:(id)sender{
    [self joinAction:nil];
}

- (IBAction)closeAction:(id)sender{
    self.completion(nil,3);
    [self hideView:nil];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self];
    if (!CGRectContainsPoint(self.phoneNumField.frame, pt)) {
        [self.phoneNumField resignFirstResponder];
    }
}

@end
