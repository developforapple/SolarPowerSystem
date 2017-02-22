//
//  YGArticleDetailHeaderViewCtrl.m
//  Golf
//
//  Created by bo wang on 16/6/13.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGArticleDetailHeaderViewCtrl.h"
#import "DDWebViewController.h"
#import "YGWebBrowser.h"
#import "YGArticleDetailHeaderViewModel.h"
#import "YGThriftInclude.h"
#import "YGCollectionViewLayout.h"
#import "YGArticleSearchViewCtrl.h"
#import "ImageBrowser.h"
#import <JavaScriptCore/JavaScriptCore.h>

static NSString *const kYGArticleDetailHeaderTagCell = @"YGArticleDetailHeaderTagCell";

@interface YGArticleDetailHeaderViewCtrl () <DDWebViewControllerDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>

// 顶部的视频区域
@property (weak, nonatomic) IBOutlet UIView *videoContainer;
// 视频区域的高度。不是视频内容时为0，是视频内容时根据 320:200 的比例计算。
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoHeightConstraint;
// 视频图片
@property (weak, nonatomic) IBOutlet UIImageView *videoImageView;
// 视频播放按钮
@property (weak, nonatomic) IBOutlet UIButton *videoPlayBtn;

// 上部标题区域
@property (weak, nonatomic) IBOutlet UIView *headerContainer;
// 计算标题区域高度时用于估算的view
@property (weak, nonatomic) IBOutlet UIView *estimateReferView;
// 标题区域的高度。根据标题行数动态调整
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeightConstraint;
// 标题
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
// 左侧子标题
@property (weak, nonatomic) IBOutlet UILabel *leftSubtitleLabel;
// 右侧子标题
@property (weak, nonatomic) IBOutlet UILabel *rightSubtitleLabel;

// 下载区域
@property (weak, nonatomic) IBOutlet UIView *downloadView;
// 下载区域的宽度。
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *downloadViewWidthConstraint;
// 下载按钮
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;

// html区域
@property (weak, nonatomic) IBOutlet UIView *contentContainer;
// html区域的高度。html加载完成后使用js获取
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeightConstraint;
// html加载的webview
@property (strong, nonatomic) DDWebViewController *webViewController;

// 底部标签区域
@property (weak, nonatomic) IBOutlet UIView *footerContainer;
@property (weak, nonatomic) IBOutlet UICollectionView *tagCollectionView;
@property (weak, nonatomic) IBOutlet YGLeftAlignmentFlowLayout *tagFlowLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagCollectionViewHeightConstraint;//标签高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *footerHeightConstraint;//底部高度

// 链接到内容来源地址
@property (weak, nonatomic) IBOutlet UIButton *sourceLinkerBtn;

@property (strong, nonatomic) YGArticleDetailHeaderViewModel *viewModel;

// 分享的内容。在web加载完成后使用js获取一次
@property (strong, nonatomic) NSString *shareContent;

@end

@implementation YGArticleDetailHeaderViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
}

- (void)dealloc
{
    [self.webViewController removeAllJSMessage];
}

- (void)initUI
{
    self.webViewController = [DDWebViewController webViewInstance];
    self.webViewController.delegate = self;
    self.webViewController.scrollView.scrollEnabled = NO;
    self.webViewController.scrollView.scrollsToTop = NO;
    self.webViewController.progressViewHidden = YES;
    [self addChildViewController:self.webViewController];
    [self.contentContainer addSubview:self.webViewController.view];
    self.webViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = @{@"web":self.webViewController.view};
    [self.contentContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[web]-0-|" options:kNilOptions metrics:nil views:views]];
    [self.contentContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[web]-0-|" options:kNilOptions metrics:nil views:views]];
    
    self.titleLabel.preferredMaxLayoutWidth = Device_Width-30.f;
    
    self.tagFlowLayout.maximumInteritemSpacing = 10.f;
}

- (void)updateUI
{
    // web
    
    NSURL *baseURL = [[NSBundle mainBundle] URLForResource:@"webResource" withExtension:@"bundle"];
    [self.webViewController loadHTML:self.viewModel.html baseURL:baseURL];

    // video
    self.videoContainer.hidden = self.viewModel.videoHidden;
    if ([self.article isVideo]) {
        [self.videoImageView sd_setImageWithURL:self.viewModel.videoImageURL];
    }
    
    // header title
    self.titleLabel.text = self.viewModel.title;
    
    BOOL hasAlbum = self.article.album != nil;
    self.leftSubtitleLabel.text = self.article.source;
    self.rightSubtitleLabel.text = hasAlbum?@"":[self.article articleCreateTimeDescription];
    
    self.downloadView.hidden = !self.viewModel.downloadVisible;
    self.downloadViewWidthConstraint.constant = self.viewModel.downloadWidth;
    
    // height
    [self.viewModel estimateHeaderHeightInContainerView:self.estimateReferView];
    
    self.headerHeightConstraint.constant = self.viewModel.headerHeight;
    self.videoHeightConstraint.constant = self.viewModel.videoHeight;
    self.contentHeightConstraint.constant = self.viewModel.contentHeight;
    self.footerHeightConstraint.constant = self.viewModel.footerHeight;
    
    [self.tagCollectionView reloadData];
    [self.view layoutIfNeeded];
}

- (void)updateHeight
{
    [self.viewModel estimateHeaderHeightInContainerView:self.estimateReferView];
    self.headerHeightConstraint.constant = self.viewModel.headerHeight;
    self.videoHeightConstraint.constant = self.viewModel.videoHeight;
    self.contentHeightConstraint.constant = self.viewModel.contentHeight;
    self.footerHeightConstraint.constant = self.viewModel.footerHeight;
    self.tagCollectionViewHeightConstraint.constant = self.viewModel.tagHeight;
    
    [self.view layoutIfNeeded];
    
    CGFloat height = [self.viewModel containerHeight];
    if (self.refreshHeightCallback) {
        self.refreshHeightCallback(height);
    }
}

- (void)setArticle:(YueduArticleBean *)article
{
    _article = article;
    self.viewModel = [YGArticleDetailHeaderViewModel viewModelWithEntity:article];
    [self updateUI];
}

#pragma mark - WebView
- (void)openURL:(NSURL *)URL
{
    YGWebBrowser *browser = [YGWebBrowser instanceFromStoryboard];
    [browser loadURL:URL];
    [self.navigationController pushViewController:browser animated:YES];
}

#pragma mark - Actions
- (IBAction)showOriginWebsite:(id)sender
{
    NSURL *url = self.viewModel.sourceLink;
    [self openURL:url];
}

- (IBAction)playVideo:(id)sender
{
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [SVProgressHUD show];
    [self.article playVideoFromViewController:self completion:^(BOOL suc, NSString *msg) {
        if (suc) {
            [SVProgressHUD dismiss];
        }else{
            [SVProgressHUD showErrorWithStatus:msg];
        }
    }];
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

#pragma mark - UICollectioView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.viewModel.tagList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kYGArticleDetailHeaderTagCell forIndexPath:indexPath];
    UILabel *label = [cell viewWithTag:10086];
    label.text = self.viewModel.tagList[indexPath.item];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSValue *v = self.viewModel.tagSizes[indexPath.item];
    return [v CGSizeValue];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *tag = self.viewModel.tagList[indexPath.item];
    YGArticleSearchViewCtrl *vc = [YGArticleSearchViewCtrl instanceFromStoryboard];
    vc.beginKeywords = tag;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - webView
- (void)webViewController:(DDWebViewController *)vc didStartLoadingURL:(NSURL *)URL
{
    if (self.viewModel.html) {
        ygweakify(self);
        NSLog(@"didStartLoadingURL 预备获取高度");
        // 获取高度
        [vc runJSCode:@"document.body.scrollHeight" completion:^(id obj, NSError *err) {
            ygstrongify(self);
            if ([obj respondsToSelector:@selector(floatValue)]) {
                [self.viewModel setWebContentHeight:[obj floatValue]];
                [self updateHeight];
            }
        }];
    }
}

- (void)webViewController:(DDWebViewController *)vc didFinishLoadingURL:(NSURL *)URL
{
    if (self.viewModel.html) {
        ygweakify(self);
        NSLog(@"didFinishLoadingURL 预备获取高度");
        // 获取高度
        [vc runJSCode:@"document.body.scrollHeight" completion:^(id obj, NSError *err) {
            ygstrongify(self);
            if ([obj respondsToSelector:@selector(floatValue)]) {
                [self.viewModel setWebContentHeight:[obj floatValue]];
                [self updateHeight];
            }
        }];
        
        // 分享的内容
        [vc runJSCode:@"getShareContent(100)" completion:^(id obj, NSError *err) {
            ygstrongify(self);
            self.shareContent = obj;
        }];
        
        // 图片抓取
        [vc addJSMessageName:@"getImgSrc"];
    }else{
        [self updateHeight];
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
    }
}

- (void)webViewController:(DDWebViewController *)vc didFailToLoadURL:(NSURL *)URL error:(NSError *)error
{}

- (DDWebViewActionPolcy)webViewController:(DDWebViewController *)vc decidePolictForActionURL:(NSURL *)url actionType:(DDWebViewActionType)actionType
{
    DDWebViewActionPolcy polcy = DDWebViewActionPolcyCancel;
    switch (actionType) {
        case DDWebViewActionTypeLinkClicked:
        case DDWebViewActionTypeFormSubmitted:
        case DDWebViewActionTypeBackforward:
        case DDWebViewActionTypeReload:
        case DDWebViewActionTypeFormResubmitted: {
            polcy = DDWebViewActionPolcyCancel;
            break;
        }
        case DDWebViewActionTypeOther: {
            polcy = DDWebViewActionPolcyAllow;
            break;
        }
    }
    
    if (polcy == DDWebViewActionPolcyCancel) {
        [self openURL:url];
    }
    return polcy;
}

@end
