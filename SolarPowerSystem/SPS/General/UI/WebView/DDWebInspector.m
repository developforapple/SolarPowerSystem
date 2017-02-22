//
//  DDPostWebInspector.m
//  QuizUp
//
//  Created by Normal on 16/4/15.
//  Copyright © 2016年 zhenailab. All rights reserved.
//

#import "DDWebInspector.h"
#import <WebKit/WebKit.h>

@interface DDWebInspector ()<UIWebViewDelegate,WKNavigationDelegate>

@property (strong, nonatomic) UIView *container;
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) WKWebView *wkWebView;

@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *infuseJSCode;
@property (strong, nonatomic) NSString *executeJSCode;
@property (copy, nonatomic) void (^completion)(BOOL suc,id object);

@end

@implementation DDWebInspector

+ (instancetype)shared
{
    static DDWebInspector *shared;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        shared = [DDWebInspector new];
        shared.container = [[UIView alloc] initWithFrame:CGRectMake(-500, -500, 1, 1)];
        [[[UIApplication sharedApplication] keyWindow] addSubview:shared.container];
        [shared initWebView];
    });
    return shared;
}

- (void)inspectionURL:(NSString *)URLString
         infuseJSCode:(NSString *)JSCode
          executeCode:(NSString *)executeCode
           completion:(void (^)(BOOL suc,id object)) completion
{
    if (!completion) {
        return;
    }
    
    self.url = URLString;
    self.infuseJSCode = JSCode;
    self.executeJSCode = executeCode;
    self.completion = completion;
    
    NSLog(@"预备获取网页资源内容，原始链接：%@",URLString);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    if (request) {
        if (self.wkWebView) {
            [self.wkWebView stopLoading];
            [self.wkWebView loadRequest:request];
        }else{
            [self.webView stopLoading];
            [self.webView loadRequest:request];
        }
    }else{
        completion(NO,@"无效的链接");
    }
}

- (void)initWebView
{
    if (Device_SysVersion >= 8.f) {
        self.wkWebView = [[WKWebView alloc] initWithFrame:self.container.bounds];
        self.wkWebView.navigationDelegate = self;
        [self.container addSubview:self.wkWebView];
    }else{
        self.webView = [[UIWebView alloc] initWithFrame:self.container.bounds];
        self.webView.delegate = self;
        [self.container addSubview:self.webView];
    }
}

- (void)clean
{
    self.completion = nil;
    self.infuseJSCode = nil;
    self.executeJSCode = nil;
    self.url = nil;
    if (self.wkWebView) {
        [self.wkWebView stopLoading];
        [self.wkWebView loadHTMLString:@"" baseURL:nil];
    }else{
        [self.webView stopLoading];
        [self.webView loadHTMLString:@"" baseURL:nil];
    }
}

#pragma mark - WKWebView
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.4f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self willStartShareContent];
    });
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self completionWithSuccess:NO object:@"当前网络不可用"];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self completionWithSuccess:NO object:@"当前网络不可用"];
}

#pragma mark - UIWebView
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self willStartShareContent];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self completionWithSuccess:NO object:@"当前网络不可用"];
}

#pragma mark - Completion
- (void)completionWithSuccess:(BOOL)suc object:(id)object
{
    if (self.completion) {
        self.completion(suc,object);
    }
}

#pragma mark - Capture
- (void)willStartShareContent
{
    ygweakify(self);
    
    if (self.wkWebView) {
        [self.wkWebView evaluateJavaScript:self.infuseJSCode completionHandler:^(id object, NSError *error) {
            ygstrongify(self);
            if (!error) {
                if (self.executeJSCode.length == 0) {
                    [self completionWithSuccess:YES object:object];
                }else{
                    [self didStartShareContent];
                }
                
            }else{
                [self completionWithSuccess:NO object:@"获取失败"];
            }
        }];
    }else{
        NSString *object = [self.webView stringByEvaluatingJavaScriptFromString:self.infuseJSCode];
        if (self.executeJSCode.length == 0) {
            [self completionWithSuccess:YES object:object];
        }else{
            [self didStartShareContent];
        }
    }
}

- (void)didStartShareContent
{
    ygweakify(self);
    if (self.wkWebView) {
        [self.wkWebView evaluateJavaScript:self.executeJSCode completionHandler:^(id object, NSError *error) {
            ygstrongify(self);
            if (!error) {
                [self completionWithSuccess:YES object:object];
            }else{
                [self completionWithSuccess:NO object:@"获取失败"];
            }
        }];
    }else{
        NSString *result = [self.webView stringByEvaluatingJavaScriptFromString:self.executeJSCode];
        [self completionWithSuccess:YES object:result];
    }
}

@end
