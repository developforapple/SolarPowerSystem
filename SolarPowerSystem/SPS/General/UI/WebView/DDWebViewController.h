//
//  DDWebViewController.h
//  QuizUp
//
//  Created by Normal on 15/11/19.
//  Copyright © 2015年 Bo Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@class DDWebViewController;

typedef NS_ENUM(NSUInteger, DDWebViewActionPolcy) {
    DDWebViewActionPolcyAllow,
    DDWebViewActionPolcyCancel,
};

typedef NS_ENUM(NSInteger, DDWebViewActionType) {
    DDWebViewActionTypeLinkClicked,
    DDWebViewActionTypeFormSubmitted,
    DDWebViewActionTypeBackforward,
    DDWebViewActionTypeReload,
    DDWebViewActionTypeFormResubmitted,
    DDWebViewActionTypeOther
};

@protocol DDWebViewControllerDelegate <NSObject>
@optional
- (void)webViewController:(DDWebViewController *)vc didStartLoadingURL:(NSURL *)URL;
- (void)webViewController:(DDWebViewController *)vc didFinishLoadingURL:(NSURL *)URL;
- (void)webViewController:(DDWebViewController *)vc didFailToLoadURL:(NSURL *)URL error:(NSError *)error;

- (DDWebViewActionPolcy)webViewController:(DDWebViewController *)vc decidePolictForScheme:(NSString *)scheme requestURL:(NSURL *)URL actionType:(DDWebViewActionType)actionType;
- (DDWebViewActionPolcy)webViewController:(DDWebViewController *)vc decidePolictForActionURL:(NSURL *)url actionType:(DDWebViewActionType)actionType;

/*!
 *  @brief 收到了js传过来的消息
 *
 *  @param vc
 *  @param name   消息名
 *  @param object 消息体。在iOS8以上消息体为发消息的参数。在iOS7中消息体为发消息的参数的数组。
 */
- (void)webViewController:(DDWebViewController *)vc didReceiveMessage:(NSString *)name content:(id)object;
@end

typedef void(^DDEvaluateJSCompletion)(id obj,NSError *err);

@interface DDWebViewController : UIViewController <UIWebViewDelegate,WKNavigationDelegate,WKUIDelegate>

+ (instancetype)webViewInstance;

// iOS8可用
- (instancetype)initWithJSPath:(NSString *)jsPath;

#pragma mark - WebView
@property (strong, readonly, nonatomic) UIWebView *uiWebView;
@property (strong, readonly, nonatomic) WKWebView *wkWebView;
@property (strong, readonly, nonatomic) UIScrollView *scrollView;

@property (strong, readonly, nonatomic) NSString *URL;

@property (weak, nonatomic) id<DDWebViewControllerDelegate> delegate;

#pragma mark - ProgressView
/*!
 *  是否隐藏进度条。默认为NO
 */
@property (assign, nonatomic) BOOL progressViewHidden;
/**
 *  进度条
 */
@property (strong, nonatomic) UIProgressView *progressView;
/**
 *  进度条显示的view。默认是导航栏
 */
@property (strong, nonatomic) UIView *progressDisplayedInView;

#pragma mark - Control
- (void)stopLoading;
- (void)reload;
- (BOOL)canGoForward;
- (void)goForward;
- (BOOL)canGoBack;
- (void)goBack;
- (void)loadURL:(NSURL *)URL;
- (void)loadURLString:(NSString *)URLString;
- (void)loadHTML:(NSString *)html;
- (void)loadHTML:(NSString *)html baseURL:(NSURL *)baseURL;

- (void)removeDelegates;

#pragma mark - Style
@property (strong, nonatomic) UIColor *tintColor;

#pragma mark - js
/*!
 *  @brief 运行一段js代码
 *
 *  @param js         js代码
 *  @param completion 回调
 */
- (void)runJSCode:(NSString *)js completion:(DDEvaluateJSCompletion)completion;

/*!
 *  @brief 注册一个js消息名。代理将会收到js中的该函数调用。成对调用 否则会出现内存泄露
 *
 *  @param name 函数名
 */
- (void)addJSMessageName:(NSString *)name;
/*!
 *  @brief 移除所有注册消息
 */
- (void)removeAllJSMessage;

@end
