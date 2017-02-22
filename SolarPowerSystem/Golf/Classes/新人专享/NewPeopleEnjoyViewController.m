//
//  NewPeopleEnjoyViewController.m
//  Golf
//
//  Created by liangqing on 16/3/30.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "NewPeopleEnjoyViewController.h"

@interface NewPeopleEnjoyViewController ()<UIWebViewDelegate>
@property(nonatomic,strong) UIWebView *webView;
@property(nonatomic,strong) UIActivityIndicatorView *activityView;
@end

@implementation NewPeopleEnjoyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, Device_Width, Device_Height - 64)];
    ((UIScrollView *)[self.webView.subviews objectAtIndex:0]).showsHorizontalScrollIndicator = NO;
    ((UIScrollView *)[self.webView.subviews objectAtIndex:0]).showsVerticalScrollIndicator = NO;
    self.webView.delegate = self;
    self.webView.opaque = NO;
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.scalesPageToFit = YES;
    [self.view addSubview:self.webView];
    
    self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.activityView.center = CGPointMake(Device_Width * 0.5, Device_Height * 0.5 - 64);
    self.activityView.color = [UIColor lightGrayColor];
    [self.webView addSubview:self.activityView];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.skipUrl]]];
    [self.activityView startAnimating];
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.activityView stopAnimating];
    self.activityView.hidden = YES;
}

- (void)doRightNavAction{
    [super doRightNavAction];
    if ([LoginManager sharedManager].loginState) {
        if ([self needPerfectMemberData]) {
            return;
        }
    }
    [GolfAppDelegate shareAppDelegate].currentController = self;
}

@end
