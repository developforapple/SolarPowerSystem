//
//  YGArticleDetailViewCtrl.m
//  Golf
//
//  Created by bo wang on 16/5/31.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGArticleDetailViewCtrl.h"
#import "YGYueduCommon.h"
#import "YGArticleDetailHeaderViewCtrl.h"
#import "YGYueduCell.h"
#import "YGArticleViewModel.h"
#import "YGYueduShareHelper.h"
#import "YGRefreshComponent.h"
#import "YGYueduDataProvider.h"
#import "YGArticleAlbumDetailViewCtrl.h"
#import "JZNavigationExtension.h"
#import "ReactiveCocoa.h"

#import "NJKScrollFullScreen.h"
#import "UIViewController+NJKFullScreenSupport.h"

static const CGFloat kDefaultSectionHeaderHeightForAlbumArticle = 64.f;
static const CGFloat kDefaultSectionHeaderHeightForNormalArticle = 15.f;

@interface YGArticleDetailViewCtrl () <UITableViewDelegate,UITableViewDataSource,NJKScrollFullscreenDelegate>
{
    BOOL _loadDataFlag;
    BOOL _darkNavTintColor;
    BOOL _shouldReloadRelationFlag;
    CGFloat _headerHeight;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIView *gradientView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;

@property (weak, nonatomic) IBOutlet UIView *headerContainer;
@property (strong, nonatomic) YGArticleDetailHeaderViewCtrl *headerViewCtrl;

@property (weak, nonatomic) IBOutlet UIView *sectionHeaderView;
@property (weak, nonatomic) IBOutlet UIView *albumContentHeaderView;
@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;
@property (weak, nonatomic) IBOutlet UILabel *albumTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *normalContentHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *normalTitleLabel;

@property (strong, nonatomic) YGYueduDataProvider *provider;

@property (nonatomic) NJKScrollFullScreen *scrollProxy;

@end

@implementation YGArticleDetailViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
    [self initData];
    
    // 打开了文章详情的埋点统计
    YGPostBuriedPoint(YGYueduStatistics_ArticleDetail);
    self.statisticsToken = YueduPage_ArticleDetail;
    
    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!_loadDataFlag) {
        _loadDataFlag = YES;
//        [self loadData];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self showNavigationBar:YES];
}

- (void)initUI
{
    [YGYueduCell registerYueDuCellsInTableView:self.tableView];
    ygweakify(self);
    self.tableView.refreshCallback = ^(YGRefreshType type){
        ygstrongify(self);
        if (type == YGRefreshTypeFooter) {
            [self.provider loadMoreData];
        }
    };
    
    [self.gradientView layoutIfNeeded];
    CAGradientLayer *gLayer = [CAGradientLayer layer];
    gLayer.colors = @[(id)[[UIColor blackColor] colorWithAlphaComponent:.5f].CGColor,
                      (id)[UIColor clearColor].CGColor];
    gLayer.startPoint = CGPointMake(.5f, 0);
    gLayer.endPoint = CGPointMake(.5f, 1);
    gLayer.locations = @[@0,@1];
    gLayer.frame = self.gradientView.bounds;
    [self.gradientView.layer addSublayer:gLayer];
    self.gradientView.hidden = YES;
}

- (void)initData
{
    ygweakify(self);
    self.provider = [[YGYueduDataProvider alloc] initWithArticle:self.articleId];
    self.provider.isSimpleMode = YES;
    self.provider.pageSize = 10;
    [self.provider setUpdateCallback:^(BOOL suc, BOOL isMore) {
        ygstrongify(self);
        if (suc) {
            if (!isMore) {
                [self reloadRelationIfNeed];
            }else{
                [self.tableView reloadData];
            }
        }else{
            [SVProgressHUD showErrorWithStatus:self.provider.lastErrorMessage];
        }
    }];
    [RACObserve(self.provider, noMoreData)
     subscribeNext:^(NSNumber *x) {
         ygstrongify(self);
         if (x.boolValue) {
             [self.tableView.mj_footer endRefreshingWithNoMoreData];
         }else{
             [self.tableView.mj_footer resetNoMoreData];
         }
     }];
}

- (void)updateUI
{
    if ([self.provider.articleBean isVideo]) {
        self.tableView.contentInset = UIEdgeInsetsZero;
        [UIView animateWithDuration:.2f animations:^{
            self.jz_navigationBarBackgroundAlpha = 0.f;
            [self.gradientView setHidden:NO animated:YES];
        }];
    }else{
        _scrollProxy = [[NJKScrollFullScreen alloc] initWithForwardTarget:self];
        _scrollProxy.downThresholdY = 1;
        self.tableView.delegate = (id)_scrollProxy;
        _scrollProxy.delegate = self;
    }
    
    self.likeBtn.selected = self.provider.articleBean.likeFlag;
    self.headerContainer.frame = CGRectMake(0, 0, Device_Width, _headerHeight);
    self.tableView.tableHeaderView = self.headerContainer;
    [self.tableView reloadData];
    self.tableView.hidden = NO;
    
    [self.loadingIndicator stopAnimating];
    [self updateNaviBarItem:![self.provider.articleBean isVideo]];
    [self reloadRelationIfNeed];
}

#pragma mark - Data
- (void)loadData
{
    ygweakify(self);
    [self.provider fetchArticleWithCompletion:^(BOOL suc) {
        ygstrongify(self);
        NSLog(@"fetch article content did completed");
        if (!suc) {
            [self.loadingIndicator stopAnimating];
            [SVProgressHUD showErrorWithStatus:self.provider.lastErrorMessage];
        }else{
            self.headerViewCtrl.article = self.provider.articleBean;
            self.likeBtn.selected = self.provider.articleBean.likeFlag;
            [self.provider refresh];
        }
    }];
}

// 让相关推荐的内容始终在 webView 加载完成了之后才出现。
- (void)reloadRelationIfNeed
{
    if (_shouldReloadRelationFlag) {
        [self.tableView reloadSection:0 withRowAnimation:UITableViewRowAnimationNone];
        self.tableView.refreshFooterEnable = YES;
    }else{
        _shouldReloadRelationFlag = YES;
    }
}

#pragma mark - Actions
- (IBAction)share:(UIButton *)sender
{
    if (!self.provider.articleBean) return;
    
    [YGYueduShareHelper shareArticle:self.provider.articleBean content:[self.headerViewCtrl shareContent] fromViewController:self];
}

- (IBAction)like:(UIButton *)sender
{
    if (!self.provider.articleBean) return;
    
    sender.enabled = NO;
    void (^begin)(void) = ^{
        sender.selected = !self.provider.articleBean.likeFlag;
        ygweakify(self);
        [self.provider.articleBean changeLike:^(BOOL suc, NSString *msg) {
            ygstrongify(self);
            if (suc) {
                [SVProgressHUD showImage:self.provider.articleBean.likeFlag?[UIImage imageNamed:@"icon_share_success"]:nil status:msg];
            }else{
                [SVProgressHUD showInfoWithStatus:msg];
                self.likeBtn.selected = self.provider.articleBean.likeFlag;
            }
            sender.enabled = YES;
        }];
    };
    
    if (![LoginManager sharedManager].loginState) {
        [[LoginManager sharedManager] loginWithDelegate:nil controller:self animate:YES blockRetrun:^(id data) {
            begin();
        } cancelReturn:^(id data) {
            sender.enabled = YES;
        }];
    }else{
        begin();
    }
}

- (IBAction)albumTitleTapAction:(UITapGestureRecognizer *)gr
{
    UIViewController *vc = self.jz_previousViewController;
    if (vc && [vc isKindOfClass:[YGArticleAlbumDetailViewCtrl class]]) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        
        YGArticleAlbumDetailViewCtrl *albumDetail = [YGArticleAlbumDetailViewCtrl instanceFromStoryboard];
        albumDetail.albumId = @(self.provider.articleBean.album.id);
        [self.navigationController pushViewController:albumDetail animated:YES];
    }
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.provider.articleCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YueduArticleBean *article = [self.provider articleAtIndex:indexPath.row];
    NSString *identifier = [YGYueduCell cellIdentifierForType:article.cellType];
    YGYueduCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    [cell configureWithArticle:article];
    cell.viewCtrl = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YueduArticleBean *article = [self.provider articleAtIndex:indexPath.row];
    return [article.viewModel containerHeight];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    BOOL hasAlbum = self.provider.articleBean.album != nil;
    self.albumContentHeaderView.hidden = !hasAlbum;
    self.normalContentHeaderView.hidden = hasAlbum;
    
    if (hasAlbum) {
        [self.albumImageView sd_setImageWithURL:[NSURL URLWithString:self.provider.articleBean.album.cover.name]];
        self.albumTitleLabel.text = self.provider.articleBean.album.name;
    }
    self.sectionHeaderView.frame = CGRectMake(0, 0, Device_Width, hasAlbum?kDefaultSectionHeaderHeightForAlbumArticle:kDefaultSectionHeaderHeightForNormalArticle);
    return self.sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.provider.articleBean.album?kDefaultSectionHeaderHeightForAlbumArticle:kDefaultSectionHeaderHeightForNormalArticle;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 相关推荐文章的点击埋点统计
    YGPostBuriedPoint(YGYueduStatistics_RelatedArticle);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.provider.articleBean isVideo]) {
        
        CGFloat scrollOffset = scrollView.contentOffset.y;
        CGFloat alpha = scrollOffset/64.f;
        alpha = MAX(0, MIN(1, alpha));
        BOOL showTitle = alpha >= 0.5f;
        
        self.jz_navigationBarBackgroundAlpha = alpha;
        if (showTitle!=_darkNavTintColor) {
            _darkNavTintColor = showTitle;
            self.jz_navigationBarBackgroundAlpha = alpha;
            self.gradientView.alpha = 1-alpha;
            [self updateNaviBarItem:showTitle];
        }
    }
}

- (void)updateNaviBarItem:(BOOL)isDark
{
    [self leftNavButtonImg:isDark?@"ic_nav_back":@"ic_nav_back_light"];
    [self.likeBtn setImage:[UIImage imageNamed:isDark?@"icon_title_collect_grey":@"icon_title_collect"] forState:UIControlStateNormal];
    [self.shareBtn setImage:[UIImage imageNamed:isDark?@"icon_title_share_grey":@"icon_title_share"] forState:UIControlStateNormal];
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"YGArticleDetailHeaderSegueID"]) {
        self.headerViewCtrl = segue.destinationViewController;
        ygweakify(self);
        [self.headerViewCtrl setRefreshHeightCallback:^(CGFloat h) {
            ygstrongify(self);
            self->_headerHeight = h;
            [self updateUI];
        }];
    }
}

#pragma mark -
#pragma mark NJKScrollFullScreenDelegate

- (void)scrollFullScreen:(NJKScrollFullScreen *)proxy scrollViewDidScrollUp:(CGFloat)deltaY
{
    [self moveNavigationBar:deltaY animated:YES];
}

- (void)scrollFullScreen:(NJKScrollFullScreen *)proxy scrollViewDidScrollDown:(CGFloat)deltaY
{
    [self moveNavigationBar:deltaY animated:YES];
}

- (void)scrollFullScreenScrollViewDidEndDraggingScrollUp:(NJKScrollFullScreen *)proxy
{
    [self hideNavigationBar:YES];
}

- (void)scrollFullScreenScrollViewDidEndDraggingScrollDown:(NJKScrollFullScreen *)proxy
{
    [self showNavigationBar:YES];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_scrollProxy reset];
    [self showNavigationBar:YES];
}

@end
