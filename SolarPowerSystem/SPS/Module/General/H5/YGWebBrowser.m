//
//  YGWebBrowser.m
//  Golf
//
//  Created by bo wang on 2016/9/29.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGWebBrowser.h"
#import "DDWebViewController.h"
#import "ClubMainViewController.h"
#import "ClubListViewController.h"
#import "YG_MallCommodityViewCtrl.h"
#import "ImageBrowser.h"
#import "YGPackageDetailViewCtrl.h"
#import "ActivityModel.h"
#import "SearchProvinceModel.h"
#import "SharePackage.h"
#import "PackageDetailModel.h"

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

@property (strong, nonatomic) SharePackage *share;

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
        self.baiduMobStatName = self.activityModel.activityName;
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
            [SVProgressHUD dismiss];
            
            self.share = [[SharePackage alloc] initWithTitle:title content:desc img:image url:link];
            ygweakify(self);
            [self.share shareInfoForView:self.view callback:^(DDShareType type) {
                ygstrongify(self);
                // 分享时回调给网页分享类型。网页中可以实现这个js函数接收分享类型。
                [self.webViewCtrl runJSCode:[NSString stringWithFormat:@"getShareAnalysis(%lu)",(unsigned long)type] completion:nil];
            }];
        });
    });
}

#pragma mark - Activity

- (void)checkActivityContent
{
    if (self.activityModel) {
        if (!self.myCondition) {
            self.myCondition = [ConditionModel new];
        }
        self.myCondition.date = self.activityModel.actionDate;
        self.myCondition.time = self.activityModel.actionTime;
        
        if (self.activityModel.activityAction == 0) {
            [self.toolBar setItems:self.normalBarButtonItems];
        }
        
        if (self.activityPage.length == 0) {
            self.activityPage = self.activityModel.activityPage;
        }
        NSURL *URL = [NSURL URLWithString:self.activityPage];
        [self loadURL:URL];
    }else{
        [[ServiceManager serviceManagerWithDelegate:self] activityDetail:self.activityId];
    }
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray*)data;
    if (array&&array.count>0) {
        if (Equal(flag, @"activity_detail")) {
            self.activityModel = [array firstObject];
            if (self.activityModel) {
                [self checkActivityContent];
            }
        }
        if (Equal(flag, @"package_detail")) {
            PackageDetailModel *model = [array objectAtIndex:0];
            
            YGPackageDetailViewCtrl *vc = [YGPackageDetailViewCtrl instanceFromStoryboard];
            vc.packageId = model.packageId;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)handleActivityCmdEvent:(NSDictionary *)dic
{
    // 旧代码
    NSString *cmd = dic[@"cmd"];
    if(cmd && [cmd isEqualToString:@"bookTeeTime"]) {
        NSString *date = [dic objectForKey:@"date"];
        NSString *clubName = [dic objectForKey:@"club_name"];
        int clubId = [[dic objectForKey:@"club_id"] intValue];
        int agentId = [[dic objectForKey:@"agent_id"] intValue];
        
        ConditionModel *nextCondition = [self.myCondition copy];
        nextCondition.clubId = clubId;
        nextCondition.date = date;
        nextCondition.time = @"07:30";
        nextCondition.clubName = clubName;
        
        [self pushWithStoryboard:@"BookTeetime" title:clubName identifier:@"ClubMainViewController" completion:^(BaseNavController *controller) {
            ClubMainViewController *vc = (ClubMainViewController*)controller;
            vc.cm = nextCondition;
            vc.agentId = agentId;
        }];
        
    }
    else if (cmd && [cmd isEqualToString:@"activity"]){
        self.activityCode = [dic objectForKey:@"activity_code"];
        if (self.activityCode) {
            if (![LoginManager sharedManager].loginState) {
                if ([[NSUserDefaults standardUserDefaults] objectForKey:KGolfSessionPhone]) {
                    [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES];
                }
            }else{
                [self joinActivity];
            }
        }
    }
}

- (void)loginButtonPressed:(id)sender{
    [self joinActivity];
}

- (void)joinActivity{
    [[ServiceManager serviceManagerInstance] joinActivityWithSessionId:[[LoginManager sharedManager] getSessionId] activityCode:self.activityCode callBack:^(NSString *callBackString) {
        if (callBackString.length>0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:callBackString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }
    }];
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
    if (self.activityModel.activityAction == 1) {
        self.myCondition.clubId = self.activityModel.actionId;
        
        ConditionModel *nextCondition = [_myCondition copy];
        [self pushWithStoryboard:@"BookTeetime" title:@"" identifier:@"ClubMainViewController" completion:^(BaseNavController *controller) {
            ClubMainViewController *vc = (ClubMainViewController*)controller;
            vc.cm = nextCondition;
            vc.agentId = -1;
        }];
        
    }else if (self.activityModel.activityAction == 2){
        [[ServiceManager serviceManagerWithDelegate:self] getPackageDetail:self.activityModel.actionId];
    }else if (self.activityModel.activityAction == 3 || self.activityModel.activityAction == 4){
        ConditionModel *nextModel = [self.myCondition copy];
        NSString *title = nil;
        NSString *date = [Utilities formatDate:self.activityModel.actionDate time:self.activityModel.actionTime];
        if (self.activityModel.activityAction == 3) {
            nextModel.cityId = 0;
            nextModel.provinceId = self.activityModel.actionId;
            SearchProvinceModel *provinceModel = [SearchProvinceModel getProvinceModelWithProvinceId:self.activityModel.actionId];
            if (provinceModel.provinceName.length>0) {
                title = [NSString stringWithFormat:@"%@ %@",provinceModel.provinceName,date];
            }else{
                title = [NSString stringWithFormat:@"%@",date];
            }
        }else{
            nextModel.cityId = self.activityModel.actionId;
            nextModel.provinceId = 0;
            SearchCityModel *cityModel = [SearchCityModel getCityModelWithCityId:self.activityModel.actionId];
            if (cityModel.cityName.length>0) {
                title = [NSString stringWithFormat:@"%@ %@",cityModel.cityName,date];
            }else{
                title = [NSString stringWithFormat:@"%@",date];
            }
        }
        [self pushWithStoryboard:@"BookTeetime" title:@"" identifier:@"ClubListViewController" completion:^(BaseNavController *controller) {
            ClubListViewController *vc = (ClubListViewController*)controller;
            vc.cm = nextModel;
        }];
    }else if (self.activityModel.activityAction == 5){
        YG_MallCommodityViewCtrl *vc = [YG_MallCommodityViewCtrl instanceFromStoryboard];
//        vc.commodityId = self.activityModel.actionId;
        vc.cid = self.activityModel.actionId;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (self.activityModel.activityAction == 6){
        [[GolfAppDelegate shareAppDelegate] pushToCommodityWithType:2 dataId:self.activityModel.actionId extro:@"" controller:self];
    }
}

- (void)showImageBrowser:(NSArray *)URLs curURL:(NSString *)URL rect:(CGRect)rect
{
    if (URLs.count == 0 || URL.length == 0) {
        return;
    }
    
    NSUInteger idx = [URLs indexOfObject:URL];
    if (idx != NSNotFound) {
        
        [ImageBrowser IBWithImages:URLs currentIndex:idx initRt:rect isEdit:NO highQuality:NO vc:(BaseNavController *)self.parentViewController backRtBlock:^CGRect(NSInteger index) {
            if (idx == index) {
                return rect;
            }
            return CGRectMake(Device_Width/2, Device_Height/2, 1, 1);
        } blockDelete:nil];
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
        NSDictionary *params = [Utilities webLinkParamParser:URL.absoluteString];
        NSString *cmd = params[@"cmd"];
        if ([cmd isEqualToString:@"bookTeeTime"] || [cmd isEqualToString:@"activity"]) {
            [self handleActivityCmdEvent:params];
        }else{
            [[GolfAppDelegate shareAppDelegate] handlePushControllerWithData:params];
        }
        return DDWebViewActionPolcyCancel;
    }else{
        return DDWebViewActionPolcyAllow;
    }
}

- (void)webViewController:(DDWebViewController *)vc didReceiveMessage:(NSString *)name content:(id)object
{
    if ([name isEqualToString:@"getImgSrc"]) {
        
        CGRect rect;
        NSString *src;
        
        if ([object isKindOfClass:[NSDictionary class]]) {
            CGFloat x = [object[@"x"] floatValue];
            CGFloat y = [object[@"y"] floatValue];
            CGFloat w = [object[@"w"] floatValue];
            CGFloat h = [object[@"h"] floatValue];
            
            rect = CGRectMake(x, y, w, h);
            src = object[@"src"];
        }else if([object isKindOfClass:[NSArray class]]){
            NSDictionary *jsv = [[object firstObject] toDictionary];
            CGFloat x = [jsv[@"x"] floatValue];
            CGFloat y = [jsv[@"y"] floatValue];
            CGFloat w = [jsv[@"w"] floatValue];
            CGFloat h = [jsv[@"h"] floatValue];
            
            rect = CGRectMake(x, y, w, h);
            src = jsv[@"src"];
        }else{
            rect = CGRectZero;
        }
        
        UIScrollView *scrollView = vc.scrollView;
        rect = [scrollView convertRect:rect toView:scrollView.window];
        
        ygweakify(self);
        [vc runJSCode:@"getAllImg()" completion:^(id obj, NSError *err) {
            if (!err && [obj isKindOfClass:[NSString class]]) {
                ygstrongify(self);
                NSArray *URLs = [NSJSONSerialization JSONObjectWithData:[obj dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                [self showImageBrowser:URLs curURL:src rect:rect];
            }
            
        }];
    }else if ([name isEqualToString:@"user_info"]){
        NSString *funcName;
        BOOL autoLogin = true;
        if ([object isKindOfClass:[NSString class]]) {
            funcName = object;
        }else if([object isKindOfClass:[NSDictionary class]]){
            funcName = object[@"func"];
            autoLogin = [object[@"auto_login"] boolValue];
        }
        
        [[LoginManager sharedManager] loginIfNeed:self doSomething:^(id data) {
            NSString *userInfoString = [self userInfoString];
            NSString *jscODE = [NSString stringWithFormat:@"%@(%@)",funcName,userInfoString];
            [vc runJSCode:jscODE completion:^(id obj, NSError *err) {
                NSLog(@"");
            }];
        }];
    }
}

- (NSString *)userInfoString{
    NSString *osName = [[UIDevice currentDevice] systemName];
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSMutableDictionary *mutDic = [NSMutableDictionary dictionary];
    [mutDic setObject:@([LoginManager sharedManager].session.memberId) forKey:@"member_id"];
    [mutDic setObject:[LoginManager sharedManager].session.mobilePhone forKey:@"mobile_phone"];
    [mutDic setObject:@([LoginManager sharedManager].currLongitude) forKey:@"longitude"];
    [mutDic setObject:@([LoginManager sharedManager].currLatitude) forKey:@"latitude"];
    [mutDic setObject:[osVersion stringByAppendingFormat:@",%@",appVersion] forKey:@"os_version"];
    [mutDic setObject:osName forKey:@"os_name"];
    NSData *data = [NSJSONSerialization dataWithJSONObject:mutDic options:kNilOptions error:nil];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return string;
}

@end
