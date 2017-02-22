//
//  ConfirmTeeTimeController.m
//  Golf
//
//  Created by 黄希望 on 15/10/29.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "ConfirmTeeTimeController.h"
#import "TeetimeSubViewController.h"

@interface ConfirmTeeTimeController ()

@property (nonatomic,strong) TeetimeSubViewController *vc;

@end

@implementation ConfirmTeeTimeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    // Do any additional setup after loading the view.
    UIControl *control = [[UIControl alloc] initWithFrame:[UIScreen mainScreen].bounds];
    control.backgroundColor = [UIColor blackColor];
    control.alpha = 0.5;
    [control addTarget:self action:@selector(clickAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:control atIndex:0];
    
    _vc = [self.childViewControllers firstObject];
    __weak typeof(self) ws = self;
    _vc.blockclick = ^(id data){
        ws.view.hidden = YES;
    };
}


- (void)show:(BOOL)show index:(NSInteger)index data:(TTModel*)data{
    if (show) {
        self.view.hidden = NO;
    }
    if (index>0) {
        _vc.ttm = data;
    }
    _vc.teetimes = _teetimes;
    _vc.isSpree = _isSpree;
    _vc.cm = _cm;
    _vc.club = _club;
    _vc.isVip = _isVip;
    _vc.canBack = _canBack;
    [_vc showView:show index:index];
}

- (void)clickAction{
    [self show:NO index:0 data:nil];
}

@end
