//
//  AwardView.m
//  Golf
//
//  Created by 黄希望 on 14-7-21.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "AwardView.h"
#import "SharePackage.h"

#define BOUND     [GolfAppDelegate shareAppDelegate].window.bounds

@interface AwardView ()

@property (nonatomic,strong) AwardModel *awardModel;
- (void)viewSetAwardCount;
@end

@implementation AwardView
@synthesize awardModel ;
@synthesize delegate ;


+ (AwardView *)viewWithFrame:(CGRect)frame model:(AwardModel*)awardModel_ delegate:(id<AwardViewDelegate>)aDelegate{
    AwardView *awardView = [[[NSBundle mainBundle] loadNibNamed:@"AwardView" owner:self options:nil] lastObject];
    awardView.awardModel = awardModel_;
    awardView.delegate = aDelegate;
    [awardView viewSetAwardCount];
    awardView.frame = CGRectMake((BOUND.size.width-frame.size.width)/2, (BOUND.size.height-frame.size.height)/2, frame.size.width, frame.size.height);
    return awardView;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self.layer setMasksToBounds:YES];
        [self.layer setCornerRadius:10];
    }
    return self;
}

- (void)viewSetAwardCount{
    [awardCountLabel setText:[NSString stringWithFormat:@"恭喜您获得%d个红包",self.awardModel.totalQuantity]];
}

- (id)initWithFrame:(CGRect)frame model:(AwardModel*)awardModel_
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self.layer setMasksToBounds:YES];
        [self.layer setCornerRadius:10];
        
        [awardCountLabel setText:[NSString stringWithFormat:@"%d",self.awardModel.totalQuantity]];
    }
    return self;
}

- (IBAction)orangeBtnAction:(id)sender{
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(awardViewCallBackWithData:)]) {
            [self.delegate awardViewCallBackWithData:self.awardModel];
        }
        [self.superview removeFromSuperview];
        [self removeFromSuperview];
    }];
}

- (IBAction)whiteBtnAction:(id)sender{
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self.superview removeFromSuperview];
        [self removeFromSuperview];
    }];
}

@end
