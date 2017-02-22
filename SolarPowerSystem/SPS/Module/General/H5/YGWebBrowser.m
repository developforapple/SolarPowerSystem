//
//  YGWebBrowser.m
//  Golf
//
//  Created by bo wang on 2016/9/29.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGWebBrowser.h"
#import "DDWebViewController.h"

@interface YGWebBrowser () <DDWebViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *container;
@property (strong, nonatomic) IBOutletCollection(UIBarButtonItem) NSArray *normalBarButtonItems;
@property (strong, nonatomic) IBOutletCollection(UIBarButtonItem) NSArray *extraBarButtonItems;
@property (weak, nonatomic) IBOutlet UIButton *gobackBtn;
@property (weak, nonatomic) IBOutlet UIButton *gofowardBtn;
@property (weak, nonatomic) IBOutlet UIButton *refreshBtn;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (strong, nonatomic) DDWebViewController *webViewCtrl;
@property (strong, nonatomic) NSURL *URL;

@end

@implementation YGWebBrowser

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *jsPath = [[[NSBundle mainBundle] pathForResource:@"webResource" ofType:@"bundle"] stringByAppendingPathComponent:iOS8?@"Yuedu_iOS8.js":@"Yuedu_iOS7.js"];
    self.webViewCtrl = [[DDWebViewController alloc] initWithJSPath:jsPath];
    self.webViewCtrl.delegate = self;
    [self addChildViewController:self.webViewCtrl];
    [self.container addSubview:self.webViewCtrl.view];
    
    [self.webViewCtrl addJSMessageName:@"user_info"];
    
    self.webViewCtrl.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[web]-0-|" options:kNilOptions metrics:nil views:@{@"web":self.webViewCtrl.view}]];
    [self.container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[web]-0-|" options:kNilOptions metrics:nil views:@{@"web":self.webViewCtrl.view}]];
    
    self.webViewCtrl.tintColor = RGBColor(159, 227, 255, 1);
    
    if (self.URL) {
        [self.toolBar setItems:self.normalBarButtonItems];
        self.baiduMobStatName = self.URL.host;
        [self.webViewCtrl loadURL:self.URL];
    }else{
        [self checkActivityContent];
    }
}

- (void)dealloc
{
    [self.webViewCtrl removeAllJSMessage];
}

- (void)loadURL:(NSURL *)url
{
    self.URL = url;
    [self.webViewCtrl loadURL:self.URL];
}

- (void)doRightNavAction
{
    [SVProgressHUD show];
    
    ygweakify(self);
    [self.webViewCtrl runJSCode:@"YGShareContent()" completion:^(id obj, NSError *err) {
        ygstrongify(self);
        if (err){
            [self fetchShareDataFailed:err];
        }else{
            [self fetchShareDataCompleted:obj];
        }
    }];
}

- (void)fetchShareDataFailed:(NSError *)error
{
    RunOnMainQueue(^{
        [SVProgressHUD showErrorWithStatus:@"获取分享内容失败"];
    });
}

- (void)fetchShareDataCompleted:(NSString *)jsString
{
    RunOnGlobalQueue(^{
        NSData *data = [jsString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (!jsonDict) {
            [self fetchShareDataFailed:error];
            return;
        }
        
        NSString *title = jsonDict[@"title"];
        NSString *desc = jsonDict[@"desc"];
        NSString *link = jsonDict[@"link"];
        NSString *imgUrl = jsonDict[@"imgUrl"];
        
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]]];
        if (!image) {
            image = [UIImage imageNamed:@"logo"];
        }
        if (title.length == 0) {
            title = @"推荐一个高尔夫人士必备APP";
        }
        if (desc.length == 0) {
            desc = @"球场预订，精选商城，教练在线，球文阅读...更多便捷即刻拥有！";
        }
        if (link.length == 0) {
            link = @"https://m.bookingtee.com/wx/";
        }
        
        RunOnMainQueue(^{
            
        });
    });
}

#pragma mark - Activity

- (void)checkActivityContent
{
   
}

- (void)handleActivityCmdEvent:(NSDictionary *)dic
{
    
}

- (void)loginButtonPressed:(id)sender{
   
}

#pragma mark - Update
- (void)updateBtns
{
    self.gobackBtn.enabled = [self.webViewCtrl canGoBack];
    self.gofowardBtn.enabled = [self.webViewCtrl canGoForward];
    self.refreshBtn.enabled = YES;
}

- (IBAction)goback:(id)sender
{
    [self.webViewCtrl goBack];
}

- (IBAction)goforward:(id)sender
{
    [self.webViewCtrl goForward];
}

- (IBAction)refresh:(id)sender
{
    [self.webViewCtrl reload];
}

- (IBAction)book:(id)sender
{
    
}

- (void)showImageBrowser:(NSArray *)URLs curURL:(NSString *)URL rect:(CGRect)rect
{
    if (URLs.count == 0 || URL.length == 0) {
        return;
    }
    
    NSUInteger idx = [URLs indexOfObject:URL];
    if (idx != NSNotFound) {
        
        
    }
}


#pragma mark -
- (void)webViewController:(DDWebViewController *)vc didStartLoadingURL:(NSURL *)URL
{
    [self updateBtns];
}

- (void)webViewController:(DDWebViewController *)vc didFinishLoadingURL:(NSURL *)URL
{
    [self updateBtns];
    
    [vc runJSCode:@"document.title" completion:^(id obj, NSError *err) {
        if ([obj isKindOfClass:[NSString class]]) {
            self.navigationItem.title = obj;
        }
    }];
    
    [self rightNavButtonImg:@"icon_title_share_grey"];
    
    NSString *jsPath = [[[NSBundle mainBundle] pathForResource:@"webResource" ofType:@"bundle"] stringByAppendingPathComponent:iOS8?@"Yuedu_iOS8.js":@"Yuedu_iOS7.js"];
    NSString *js = [NSString stringWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:nil];
    [vc runJSCode:js completion:nil];
    // 图片抓取
    [vc addJSMessageName:@"getImgSrc"];
}

- (void)webViewController:(DDWebViewController *)vc didFailToLoadURL:(NSURL *)URL error:(NSError *)error
{
    [self updateBtns];
    
    [vc runJSCode:@"document.title" completion:^(id obj, NSError *err) {
        if ([obj isKindOfClass:[NSString class]]) {
            self.navigationItem.title = obj;
        }
    }];
}

- (DDWebViewActionPolcy)webViewController:(DDWebViewController *)vc decidePolictForScheme:(NSString *)scheme requestURL:(NSURL *)URL actionType:(DDWebViewActionType)actionType
{
    if ([scheme isEqualToString:@"golfapi"]) {
//        NSDictionary *params = [Utilities webLinkParamParser:URL.absoluteString];
//        NSString *cmd = params[@"cmd"];
//        if ([cmd isEqualToString:@"bookTeeTime"] || [cmd isEqualToString:@"activity"]) {
//            [self handleActivityCmdEvent:params];
//        }else{
//            [[GolfAppDelegate shareAppDelegate] handlePushControllerWithData:params];
//        }
        return DDWebViewActionPolcyCancel;
    }else{
        return DDWebViewActionPolcyAllow;
    }
}

- (void)webViewController:(DDWebViewController *)vc didReceiveMessage:(NSString *)name content:(id)object
{
//    if ([name isEqualToString:@"getImgSrc"]) {
//        
//        CGRect rect;
//        NSString *src;
//        
//        if ([object isKindOfClass:[NSDictionary class]]) {
//            CGFloat x = [object[@"x"] floatValue];
//            CGFloat y = [object[@"y"] floatValue];
//            CGFloat w = [object[@"w"] floatValue];
//            CGFloat h = [object[@"h"] floatValue];
//            
//            rect = CGRectMake(x, y, w, h);
//            src = object[@"src"];
//        }else if([object isKindOfClass:[NSArray class]]){
//            NSDictionary *jsv = [[object firstObject] toDictionary];
//            CGFloat x = [jsv[@"x"] floatValue];
//            CGFloat y = [jsv[@"y"] floatValue];
//            CGFloat w = [jsv[@"w"] floatValue];
//            CGFloat h = [jsv[@"h"] floatValue];
//            
//            rect = CGRectMake(x, y, w, h);
//            src = jsv[@"src"];
//        }else{
//            rect = CGRectZero;
//        }
//        
//        UIScrollView *scrollView = vc.scrollView;
//        rect = [scrollView convertRect:rect toView:scrollView.window];
//        
//        ygweakify(self);
//        [vc runJSCode:@"getAllImg()" completion:^(id obj, NSError *err) {
//            if (!err && [obj isKindOfClass:[NSString class]]) {
//                ygstrongify(self);
//                NSArray *URLs = [NSJSONSerialization JSONObjectWithData:[obj dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
//                [self showImageBrowser:URLs curURL:src rect:rect];
//            }
//            
//        }];
//    }else if ([name isEqualToString:@"user_info"]){
//        NSString *funcName;
//        BOOL autoLogin = true;
//        if ([object isKindOfClass:[NSString class]]) {
//            funcName = object;
//        }else if([object isKindOfClass:[NSDictionary class]]){
//            funcName = object[@"func"];
//            autoLogin = [object[@"auto_login"] boolValue];
//        }
//        
////        [[LoginManager sharedManager] loginIfNeed:self doSomething:^(id data) {
////            NSString *userInfoString = [self userInfoString];
////            NSString *jscODE = [NSString stringWithFormat:@"%@(%@)",funcName,userInfoString];
////            [vc runJSCode:jscODE completion:^(id obj, NSError *err) {
////                NSLog(@"");
////            }];
////        }];
//    }
}

//- (NSString *)userInfoString{
//    NSString *osName = [[UIDevice currentDevice] systemName];
//    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
//    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//    NSMutableDictionary *mutDic = [NSMutableDictionary dictionary];
//    [mutDic setObject:@([LoginManager sharedManager].session.memberId) forKey:@"member_id"];
//    [mutDic setObject:[LoginManager sharedManager].session.mobilePhone forKey:@"mobile_phone"];
//    [mutDic setObject:@([LoginManager sharedManager].currLongitude) forKey:@"longitude"];
//    [mutDic setObject:@([LoginManager sharedManager].currLatitude) forKey:@"latitude"];
//    [mutDic setObject:[osVersion stringByAppendingFormat:@",%@",appVersion] forKey:@"os_version"];
//    [mutDic setObject:osName forKey:@"os_name"];
//    NSData *data = [NSJSONSerialization dataWithJSONObject:mutDic options:kNilOptions error:nil];
//    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    return string;
//}

@end
