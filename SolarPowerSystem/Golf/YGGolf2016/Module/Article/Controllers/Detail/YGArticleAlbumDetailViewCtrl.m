//
//  YGArticleAlbumDetailViewCtrl.m
//  Golf
//
//  Created by bo wang on 16/6/14.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGArticleAlbumDetailViewCtrl.h"
#import "YGYueduDataProvider.h"
#import "YGYueduCell.h"
#import "YGArticleDetailViewCtrl.h"
#import "YGArticleViewModel.h"
#import "YGRefreshComponent.h"
#import "YGUIKitCategories.h"
#import "YGYueduShareHelper.h"
#import "JZNavigationExtension.h"
#import "YYWebImage.h"
#import "ReactiveCocoa.h"
#import "MXParallaxHeader.h"

@interface YGArticleAlbumDetailViewCtrl () <UITableViewDelegate,UITableViewDataSource>
{
    BOOL _loadDataFlag;
    BOOL _darkNavTintColor;
}

// 专题图片的容器
@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *albumHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *albumTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *albumSubtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *albumDescLabel;
@property (weak, nonatomic) IBOutlet UIButton *albumCategoryBtn;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property (strong, nonatomic) YGYueduDataProvider *provider;
@property (strong, nonatomic) YueduAlbumBean *albumBean;
@end

@implementation YGArticleAlbumDetailViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
    [self initData];
    
    // 打开了专题详情的埋点统计
    YGPostBuriedPoint(YGYueduStatistics_AlbumDetail);
    self.statisticsToken = YueduPage_AlbumDetail;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!_loadDataFlag) {
        _loadDataFlag = YES;
        [self loadData];
    }
}

#pragma mark - UI
- (void)initUI
{
    [self leftNavButtonImg:@"ic_nav_back_light"];
    
    ygweakify(self);
    [YGYueduCell registerYueDuCellsInTableView:self.tableView];
    [self.tableView setRefreshCallback:^(YGRefreshType type) {
        ygstrongify(self);
        if (type == YGRefreshTypeFooter) {
            [self.provider loadMoreData];
        }
    }];
    self.tableView.hidden = YES;
    
    CGFloat headerHeight = ceilf(520.f/640.f*Device_Width) + 10.f;
    self.albumHeaderView.frame = CGRectMake(0, 0, Device_Width, headerHeight);
    self.tableView.parallaxHeader.view = self.albumHeaderView;
    self.tableView.parallaxHeader.height = headerHeight;
    self.tableView.parallaxHeader.minimumHeight = 0.f;
    self.tableView.parallaxHeader.mode = MXParallaxHeaderModeFill;
}

- (void)updateUI
{
    self.tableView.refreshFooterEnable = YES;
    
    // 底部80的间距。上面根据设备调整
//    CGFloat headerHeight = ceilf(520.f/640.f*Device_Width) + 10.f;
//    self.albumHeaderView.frame = CGRectMake(0, 0, Device_Width, headerHeight);
    
    [self.albumImageView yy_setImageWithURL:[NSURL URLWithString:self.albumBean.cover.name]
                                placeholder:nil
                                    options:YYWebImageOptionProgressiveBlur | YYWebImageOptionAllowBackgroundTask
                                 completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                                 }];
//    self.tableView.tableHeaderView = self.albumHeaderView;
    self.albumTitleLabel.text = self.albumBean.name;
    self.albumSubtitleLabel.text = [NSString stringWithFormat:@"%d 内容",self.albumBean.articleCount];
    self.albumDescLabel.text = self.albumBean.des;
    [self.albumCategoryBtn setTitle:self.albumBean.category.name forState:UIControlStateNormal];
    self.likeBtn.selected = self.albumBean.likeFlag;
    [self.tableView setHidden:NO animated:YES];
    [self.loadingIndicator stopAnimating];
    [UIView animateWithDuration:.2f animations:^{
        self.jz_navigationBarBackgroundAlpha = 0.f;
    }];
}

#pragma mark - Data
- (void)initData
{
    ygweakify(self);
    self.provider = [[YGYueduDataProvider alloc] initWithAlbum:self.albumId];
    self.provider.isSimpleMode = YES;
    [self.provider setUpdateCallback:^(BOOL suc, BOOL isMore) {
        ygstrongify(self);
        if (suc) {
            [self.tableView reloadData];
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

- (void)loadData
{
    ygweakify(self);
    [self.provider fetchAlbumWithCompletion:^(BOOL suc) {
        ygstrongify(self);
        if (suc) {
            [self updateUI];
            [self.provider refresh];
        }else{
            [SVProgressHUD showErrorWithStatus:self.provider.lastErrorMessage];
        }
        [self.loadingIndicator stopAnimating];
    }];
}

- (YueduAlbumBean *)albumBean
{
    return self.provider.albumBean;
}

#pragma mark - Actions
- (IBAction)share:(UIButton *)sender
{
    if (!self.albumBean) return;
    
    NSString *desc = self.albumBean.des;
    if (desc.length == 0) {
        YueduArticleBean *firstArticle = [self.provider articleAtIndex:0];
        desc = firstArticle.name;
    }
    [YGYueduShareHelper shareAlbum:self.albumBean content:desc fromViewController:self];
}

- (IBAction)like:(UIButton *)sender
{
    if (!self.albumBean) return;
    
    sender.enabled = NO;
    
    void (^begin)(void) = ^{
        sender.selected = !self.provider.albumBean.likeFlag;
        ygweakify(self);
        [self.albumBean changeLike:^(BOOL suc, NSString *msg) {
            ygstrongify(self);
            if (suc) {
                [SVProgressHUD showImage:nil status:msg];
            }else{
                [SVProgressHUD showInfoWithStatus:msg];
                self.likeBtn.selected = self.provider.albumBean.likeFlag;
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

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.provider.articleCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YueduArticleBean *articleBean = [self.provider articleAtIndex:indexPath.row];
    YGYueduCellType cellType = [articleBean cellType];
    NSString *identifier = [YGYueduCell cellIdentifierForType:cellType];
    YGYueduCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    [cell configureWithArticle:articleBean];
    cell.viewCtrl = self;  
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YueduArticleBean *articleBean = [self.provider articleAtIndex:indexPath.row];
    return [articleBean.viewModel containerHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat scrollOffset = scrollView.contentOffset.y;
    CGFloat alpha = scrollOffset/(CGRectGetHeight(self.albumHeaderView.bounds));
    alpha = MAX(0, MIN(1, alpha));
    BOOL showTitle = alpha >= 0.5f;
    
    self.jz_navigationBarBackgroundAlpha = alpha;
    if (showTitle!=_darkNavTintColor) {
        _darkNavTintColor = showTitle;
        self.navigationItem.title = showTitle?self.albumBean.name:nil;
        self.jz_navigationBarBackgroundAlpha = alpha;
        [self updateNaviBarItem:showTitle];
    }
}

- (void)updateNaviBarItem:(BOOL)isDark
{
    [self leftNavButtonImg:isDark?@"ic_nav_back":@"ic_nav_back_light"];
    [self.likeBtn setImage:[UIImage imageNamed:isDark?@"icon_title_collect_grey":@"icon_title_collect"] forState:UIControlStateNormal];
    [self.shareBtn setImage:[UIImage imageNamed:isDark?@"icon_title_share_grey":@"icon_title_share"] forState:UIControlStateNormal];
}

@end
