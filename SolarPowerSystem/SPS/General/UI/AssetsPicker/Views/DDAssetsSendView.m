//
//  DDSendView.m
//  QuizUp
//
//  Created by Normal on 15/12/9.
//  Copyright © 2015年 Bo Wang. All rights reserved.
//

#import "DDAssetsSendView.h"

@implementation DDAssetsSendView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.assetsCountLabel.layer.masksToBounds = YES;
    self.assetsCountLabel.layer.cornerRadius = 11.f;
    self.assetsCountLabel.backgroundColor = RGBColor(36,157,243,1);
    self.assetsCountLabel.hidden = YES;
}

- (void)startMonitoringSelectedAssets:(DDAssetsManager *)manager
{
    if (!manager) {
        return;
    }
    [self updateWithAssetsCount:manager.selectedAssets.count];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedAssetsCountDidChanged:) name:kDDAssetsManagerSelectedAssetsCountChangedNotification object:nil];
}

- (void)endMonitoring:(DDAssetsManager *)manager
{
    if (!manager) {
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateWithAssetsCount:(NSUInteger)count
{
    if (count == 0) {
        self.assetsCountLabel.hidden = YES;
        self.sendLabel.textColor = MainTintColor;
        self.backBtn.enabled = NO;
        return;
    }
    
    self.assetsCountLabel.text = @(count).description;
    
    self.assetsCountLabel.transform = CGAffineTransformMakeScale(.5f, .5f);
    self.assetsCountLabel.hidden = NO;
    self.sendLabel.textColor = RGBColor(36,157,243,1);
    self.backBtn.enabled = YES;
    
    [UIView animateWithDuration:.6f delay:0.f usingSpringWithDamping:.6f initialSpringVelocity:.6f options:UIViewAnimationOptionCurveLinear animations:^{
        self.assetsCountLabel.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)send:(id)sender
{
    if (self.sendAction) {
        self.sendAction();
    }
}

- (void)selectedAssetsCountDidChanged:(NSNotification *)noti
{
    [self updateWithAssetsCount:[noti.object integerValue]];
}

@end
