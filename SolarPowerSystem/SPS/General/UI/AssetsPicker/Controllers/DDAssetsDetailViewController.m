//
//  DDAssetsDetailViewController.m
//  QuizUp
//
//  Created by Normal on 15/12/9.
//  Copyright © 2015年 Bo Wang. All rights reserved.
//

#import "DDAssetsDetailViewController.h"
#import "DDAssetsPreviewController.h"
#import "DDAssetsSendView.h"

@interface DDAssetsDetailViewController ()

@property (strong, nonatomic) DDAssetsPreviewController *previewController;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet DDAssetsSendView *assetSendView;

@property (weak, nonatomic) IBOutlet UIButton *selectedBtn;

@property (strong, nonatomic) DDAsset *curAsset;   //当前asset

@end

@implementation DDAssetsDetailViewController

- (void)dealloc
{
    [self.assetSendView endMonitoring:self.manager];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _initUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)_initUI
{
    ddweakify(self);
    [self.assetSendView setSendAction:^{
        ddstrongify(self);
        [self next];
    }];
    [self.assetSendView startMonitoringSelectedAssets:self.manager];
    
    self.titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void)fullDisplay:(BOOL)isFullDisplay
{
    [self.navigationController setNavigationBarHidden:isFullDisplay animated:YES];
    [self.bottomBar setHidden:isFullDisplay animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:isFullDisplay withAnimation:UIStatusBarAnimationFade];
}

#pragma mark - Actions
- (IBAction)pop:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)select:(id)sender
{
    BOOL isSelcted = self.selectedBtn.selected;
    if (isSelcted) {
        self.selectedBtn.selected = NO;
        if (self.assetSelectedChanged) {
            self.assetSelectedChanged(self.curAsset,NO);
        }
    }else{
        BOOL shouldSelect = [self.manager canSelectMoreAsset];
        if (shouldSelect) {
            self.selectedBtn.selected = YES;
            if (self.assetSelectedChanged) {
                self.assetSelectedChanged(self.curAsset,YES);
            }
        }
    }
}

- (void)next
{
    if (self.sendAction) {
        self.sendAction();
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ddweakify(self);
    self.previewController = segue.destinationViewController;
    self.previewController.tapAction = ^(DDAssetsPreviewController *ctrl,DDAsset *asset){
        ddstrongify(self);
        [self fullDisplay:![self.navigationController isNavigationBarHidden]];
    };
    self.previewController.willDisplayAsset = ^(DDAssetsPreviewController *ctrl,DDAsset *asset){
        ddstrongify(self);
        self.curAsset = asset;
        self.selectedBtn.selected = [self.manager isAssetSelected:asset];
        NSUInteger idx = [ctrl.assets indexOfObject:asset];
        self.titleLabel.text = [NSString stringWithFormat:@"%ld / %lu",idx+1,(unsigned long)[ctrl.assets count]];
    };
    self.previewController.longPressAction = ^(DDAssetsPreviewController *ctrl,DDAsset *asset){
//        ddstrongify(self);
        
    };
    self.previewController.firstIndex = self.firstDisplayedIndex;
    if (self.onlyDisplaySelectedAssets) {
        self.previewController.assets = [NSArray arrayWithArray:self.manager.selectedAssets];
    }else{
        self.previewController.assets = self.manager.curAssets;
    }
}

@end
