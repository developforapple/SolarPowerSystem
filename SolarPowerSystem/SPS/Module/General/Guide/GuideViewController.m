//
//  GuideViewController.m
//  Golf
//
//  Created by liangqing on 16/8/25.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "GuideViewController.h"
#import "EAIntroView.h"

@interface GuideViewController ()<EAIntroDelegate>
@property (nonatomic,strong) EAIntroView *intro;
@end

@implementation GuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showGuidPictures];
    });
}

/**
 加载引导页
 */
- (void)showGuidPictures
{
    NSMutableArray *pages = [NSMutableArray array];
    for (int i = 1; i < 4;i ++) {
        EAIntroPage *page = [EAIntroPage page];
        page.showTitleView = YES;
        page.titleIconPositionY = 0;
        if (IS_3_5_INCH_SCREEN) {
            page.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"guide480_%d",i]]];
        }else if (IS_4_0_INCH_SCREEN) {
            page.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"guide568_%d",i]]];
        }else if(IS_4_7_INCH_SCREEN) {
            page.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"guide750_%d",i]]];
        }else if (IS_5_5_INCH_SCREEN){
            page.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"guide1242_%d",i]]];
        }
        [pages addObject:page];
    }
    
    self.intro = [[EAIntroView alloc] initWithFrame:[[UIScreen mainScreen] bounds] andPages:pages];
    self.intro.scrollingEnabled = YES;
    self.intro.pageControl.pageIndicatorTintColor = [UIColor colorWithHexString:@"cccccc"];
    self.intro.pageControl.currentPageIndicatorTintColor = [UIColor colorWithHexString:@"676767"];
    if (IS_3_5_INCH_SCREEN) {
        self.intro.bgImage = [UIImage imageNamed:@"backgroud480"];
        self.intro.pageControlY = [UIScreen mainScreen].bounds.size.height - 105;
    }else if (IS_4_0_INCH_SCREEN) {
        self.intro.bgImage = [UIImage imageNamed:@"backgroud568"];
        self.intro.pageControlY = [UIScreen mainScreen].bounds.size.height - 130;
    }else if(IS_4_7_INCH_SCREEN) {
        self.intro.bgImage = [UIImage imageNamed:@"backgroud750"];
        self.intro.pageControlY = [UIScreen mainScreen].bounds.size.height - 170;
    }else if (IS_5_5_INCH_SCREEN){
        self.intro.bgImage = [UIImage imageNamed:@"backgroud1242"];
        self.intro.pageControlY = [UIScreen mainScreen].bounds.size.height - 170;
    }
    self.intro.delegate = self;
    
    // 悦读功能引导页
    self.intro.skipButton.hidden = YES;
    self.intro.tapToNext = YES;
    
    [self.intro showInView:self.view animateDuration:0.0];
}

#pragma mark --EAIntroDelegate

//- (void)intro
- (void)introDidFinish:(EAIntroView *)introView wasSkipped:(BOOL)wasSkipped
{
    [UIView animateWithDuration:.4 animations:^{
        CGRect rt = _intro.frame;
        rt.origin.x -= Device_Width;
        self.intro.frame = rt;
    } completion:^(BOOL finished) {
        [self.intro.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.intro removeFromSuperview];
        self.intro = nil;
        [GolfAppDelegate shareAppDelegate].window.rootViewController = [GolfAppDelegate shareAppDelegate].tabBarController;
        [[GolfAppDelegate shareAppDelegate] startRemoteNotification];
        [[GolfAppDelegate shareAppDelegate] startUpdateLocation];
    }];
}

@end
