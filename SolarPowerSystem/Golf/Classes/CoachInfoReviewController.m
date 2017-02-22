//
//  CoachInfoReviewController.m
//  Golf
//
//  Created by 黄希望 on 15/6/16.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CoachInfoReviewController.h"
#import "YGCapabilityHelper.h"

@interface CoachInfoReviewController ()

@property (nonatomic,weak) IBOutlet UIImageView *imageview;
@property (nonatomic,weak) IBOutlet UILabel *statusLabel;

@end

@implementation CoachInfoReviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.isReview) {
        self.imageview.image = [UIImage imageNamed:@"ic_wait"];
        self.statusLabel.text = @"正在审核";
    }else{
        self.imageview.image = [UIImage imageNamed:@"ic_right"];
        self.statusLabel.text = @"申请已提交";
    }
}

- (IBAction)phoneClick:(id)sender
{
    [YGCapabilityHelper call:[Utilities getGolfServicePhone] needConfirm:YES];
}

- (void)doLeftNavAction{
    if (self.isReview) {
        [super doLeftNavAction];
    }else{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end