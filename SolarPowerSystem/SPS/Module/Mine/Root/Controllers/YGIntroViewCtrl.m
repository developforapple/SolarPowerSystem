//
//  YGIntroViewCtrl.m
//  Golf
//
//  Created by 黄希望 on 14-3-18.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "YGIntroViewCtrl.h"

@interface YGIntroViewCtrl ()

@end

@implementation YGIntroViewCtrl
@synthesize isPressentModelView ;

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.isPressentModelView) {
        [self leftButtonAction:@"取消"];
    }
}

- (void)loadWebViewWithUrl:(NSString*)aUrl{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    NSURL *url = [NSURL URLWithString:aUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];//加载
    [self.view addSubview:webView];
}

- (void)loadWebViewWithUrl:(NSString*)aUrl title:(NSString*)title{    
    [self loadWebViewWithUrl:aUrl];
    self.title = title;
}

- (void)doLeftNavAction{
    if (isPressentModelView) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self back];
    }
}

@end
