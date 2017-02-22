//
//  YGArticleImagesDetailViewCtrl.m
//  Golf
//
//  Created by bo wang on 16/6/12.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGArticleImagesDetailViewCtrl.h"
#import "YGYueduImageDetailCell.h"
#import "YGYueduImageDescView.h"
#import "YGYueduCommon.h"
#import "YGYueduShareHelper.h"
#import "JZNavigationExtension.h"

@interface YGArticleImagesDetailViewCtrl () <UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSUInteger _currentIndex;
    BOOL _initializationFlag;
}
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowlayout;
@property (weak, nonatomic) IBOutlet YGYueduImageDescView *descContainer;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGestureRecoginzer;
@property (strong, nonatomic) YueduArticleBean *articleBean;
@property (assign, nonatomic) BOOL assistViewHidden;
@end

@implementation YGArticleImagesDetailViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
    [self loadData];
    
    // 打开了文章详情的埋点统计
    YGPostBuriedPoint(YGYueduStatistics_ArticleDetail);
    self.statisticsToken = YueduPage_ArticleDetail;
}

- (void)initUI
{
    [self leftNavButtonImg:@"ic_nav_back_light"];
    self->_assistViewHidden = YES;
    self.flowlayout.itemSize = CGSizeMake(Device_Width, Device_Height);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self displayAssistViewIfNeed];
}

#pragma mark - Data
- (void)loadData
{
    [YGRequest fetchArticleDetail:self.articleId success:^(BOOL suc, id object) {
        YueduArticleDetail *detail = object;
        if (suc) {
            self.articleBean = detail.article;
            self.likeBtn.selected = self.articleBean.likeFlag;
            [self.collectionView reloadData];
            [self displayAssistViewIfNeed];
        }else{
            [SVProgressHUD showImage:nil status:detail.err.errorMsg];
        }
    } failure:^(Error *err) {
        [SVProgressHUD showImage:nil status:@"当前网络不可用"];
    }];
}

#pragma mark - Actions

- (IBAction)tapAction:(UITapGestureRecognizer *)gr
{
    [self setAssistViewHidden:!_assistViewHidden];
}

- (void)displayAssistViewIfNeed
{
    if (!_initializationFlag && self.articleBean) {
        _initializationFlag = YES;
        RunAfter(.2f, ^{
            self.descContainer.articleBean = self.articleBean;
            [self.descContainer updateToIndex:0];
            self.assistViewHidden = NO;
        });
    }
}

- (void)setAssistViewHidden:(BOOL)assistViewHidden
{
    if (!_initializationFlag) {
        return;
    }
    
    _assistViewHidden = assistViewHidden;
    if (!_assistViewHidden) {
        self.descContainer.hidden = NO;
    }
    [UIView animateWithDuration:.2f animations:^{
        self.descContainer.alpha = _assistViewHidden?0.f:1.f;
        self.jz_wantsNavigationBarVisible = _assistViewHidden?NO:YES;
    } completion:^(BOOL finished) {
        if (_assistViewHidden) {
            self.descContainer.hidden = YES;
        }
    }];
}

#pragma mark - Actions
- (IBAction)like:(UIButton *)sender
{
    if (!self.articleBean) return;
    
    sender.enabled = NO;
    
    void (^begin)(void) = ^{
        sender.selected = !self.articleBean.likeFlag;
        ygweakify(self);
        [self.articleBean changeLike:^(BOOL suc, NSString *msg) {
            ygstrongify(self);
            if (suc) {
                [SVProgressHUD showImage:nil status:msg];
            }else{
                [SVProgressHUD showInfoWithStatus:msg];
                self.likeBtn.selected = self.articleBean.likeFlag;
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

- (IBAction)share:(UIButton *)sender
{
    if (!self.articleBean) return;
    
    NSString *desc = [[self.articleBean.pictures firstObject] desc];
    [YGYueduShareHelper shareArticle:self.articleBean content:desc fromViewController:self];
}

#pragma mark - UICollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.articleBean.pictures.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YGYueduImageDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kYGYueduImageDetailCell forIndexPath:indexPath];
    if (!iOS8) {
        [self collectionView:collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
    }
    
    [self.tapGestureRecoginzer requireGestureRecognizerToFail:cell.doubleTapGestureRecognizer];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(YGYueduImageDetailCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    YueduArticleImageBean *imageBean = self.articleBean.pictures[indexPath.item];
    [cell configureWithImage:imageBean];
    self.descContainer.imageZoomScrollView = cell.imageZoomScrollView;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    NSUInteger index = offset.x/CGRectGetWidth(scrollView.frame);
    if (index != _currentIndex) {
        _currentIndex = index;
        [self.descContainer updateToIndex:index];
    }
}

@end
