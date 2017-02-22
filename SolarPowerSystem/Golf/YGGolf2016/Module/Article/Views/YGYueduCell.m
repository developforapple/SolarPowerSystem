//
//  YGArticleCell.m
//  Golf
//
//  Created by wwwbbat on 16/5/27.
//  Copyright © 2016年 云高科技. All rights reserved.
//

/*
    image 图片 t 标题 s 来源 d 日期 c 分类 l 视频长度 a 专题名称
 
    1 图文 只有一种cell
        主列表下             普通详情页          专题下
        |-------| t         |-------| t       |-------| t
        | image |           | image |         | image |
        |-------| s d   c   |-------| s d  c  |-------| a @"专题"
 
    2 多图 只有一种cell
        主列表下
        t
        |-----||-----||-----|
        |image||image||image|
        |-----||-----||-----|
        s d                c
 
    3 视频 有两种cell
        主列表下              普通详情页         专题下
        |-------------|     |-------| t       |-------| t
        |    image    |     | image |         | image |
        |-------------|     |-------| s d c   |-------| a   @"专题"
               t
        s d          c
 */

#import "YGYueduCell.h"
#import "YGCommon.h"
#import "YGThriftInclude.h"
#import "YGArticleDetailViewCtrl.h"
#import "YGArticleImagesDetailViewCtrl.h"
#import "YGArticleAlbumDetailViewCtrl.h"
#import "YGArticleViewModel.h"
#import "YYWebImage.h"

@implementation YGYueduCell

#pragma mark - Class Method
+ (void)registerYueDuCellsInTableView:(UITableView *)tableView
{
    [tableView registerNib:[UINib nibWithNibName:@"YGYueduNormalCell" bundle:nil] forCellReuseIdentifier:kYGYueduNormalCellID];
    [tableView registerNib:[UINib nibWithNibName:@"YGYueduImagesCell" bundle:nil] forCellReuseIdentifier:kYGYueduImageCellID];
    [tableView registerNib:[UINib nibWithNibName:@"YGYueduVideoCell"  bundle:nil] forCellReuseIdentifier:kYGYueduVideoCellID];
    [tableView registerNib:[UINib nibWithNibName:@"YGYueduVideoCell2" bundle:nil] forCellReuseIdentifier:kYGYueduVideoCellID2];
}

+ (NSDictionary *)_cellIdentifierDict
{
    static NSDictionary *cellIdentifierMapping;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cellIdentifierMapping = @{kYGYueduNormalCellID: @(YGYueduCellTypeNormal),
                                  kYGYueduImageCellID:  @(YGYueduCellTypeImage),
                                  kYGYueduVideoCellID:  @(YGYueduCellTypeVideo),
                                  kYGYueduVideoCellID2: @(YGYueduCellTypeVideo2)};
    });
    return cellIdentifierMapping;
}

+ (NSString *)cellIdentifierForType:(YGYueduCellType)type
{
    NSDictionary *dict = [self _cellIdentifierDict];
    for (NSString *identifier in dict) {
        if ([dict[identifier] integerValue] == type) {
            return identifier;
        }
    }
    return kYGYueduNormalCellID;
}

+ (YGYueduCellType)cellTypeForIdentifier:(NSString *)identifier
{
    return (YGYueduCellType)[[self _cellIdentifierDict][identifier] integerValue];
}

#pragma mark - Instance Method
- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)configureWithArticle:(YueduArticleBean *)article
{
    self->_article = article;
    self.articleID = article.id;
    BOOL isInAlbum = self.article.album != nil;
    
    __kindof YGArticleViewModel *viewModel = self.article.viewModel;
    
    [self updateTextColor];
    
    self.articleTitleLabel.text = viewModel.title;
    self.articleCategoryLabel.text = viewModel.categoryName;
    self.articleDateLabel.text = viewModel.dateString;
    self.articleSourceLabel.text = viewModel.sourceName;
    
    switch (article.cellType) {
        case YGYueduCellTypeNormal:{
            YGArticleNormalViewModel *vm = viewModel;
            [self loadImageWithURL:vm.imageURL inImageView:self.articleImageViews.firstObject];
            if (isInAlbum) {
                self.articleDateLabel.hidden = YES;
                self.articleSourceLabel.text = article.album.name;
                self.articleCategoryLabel.text = @"专题";
            }else{
                self.articleDateLabel.hidden = NO;
            }
            break;
        }
        case YGYueduCellTypeImage: {
            YGArticleImagesViewModel *vm = viewModel;
            for (NSUInteger i = 0; i<self.articleImageViews.count; i++) {
                if (i < vm.imageURLs.count) {
                    [self loadImageWithURL:vm.imageURLs[i] inImageView:self.articleImageViews[i]];
                }
            }
            break;
        }
        case YGYueduCellTypeVideo: {
            YGArticleVideoViewModel *vm = viewModel;
            [self loadImageWithURL:vm.imageURL inImageView:self.articleImageViews.firstObject];
            break;
        }
        case YGYueduCellTypeVideo2: {
            YGArticleVideo2ViewModel *vm = viewModel;
            [self loadImageWithURL:vm.imageURL inImageView:self.articleImageViews.firstObject];
            if (isInAlbum) {
                if (!vm.isInAlbumDetail) {  //普通的专题视频
                    self.articleDateLabel.hidden = YES;
                    self.articleCategoryLabel.hidden = NO;
                    self.articleVideoLengthLabel.hidden = YES;
                    self.articleSourceLabel.text = article.album.name;
                    self.articleCategoryLabel.text = @"专题";
                }else{  //专题详情页的视频
                    self.articleDateLabel.hidden = YES;
                    self.articleCategoryLabel.hidden = YES;
                    self.articleVideoLengthLabel.hidden = NO;
                    self.articleVideoLengthLabel.text = vm.videoLengthString;
                }
            }else{      //普通视频
                self.articleDateLabel.hidden = NO;
                self.articleCategoryLabel.hidden = NO;
                self.articleVideoLengthLabel.hidden = YES;
            }
            break;
        }
    }
    [self.contentView setNeedsLayout];
}

- (void)updateTextColor
{
    BOOL readed = [YueduArticleBean articleIsReaded:self.article.id];
    
    if (readed) {
        self.articleTitleLabel.textColor = RGBColor(153, 153, 153, 1);
    }else{
        self.articleTitleLabel.textColor = RGBColor(51, 51, 51, 1);
    }
}

- (void)loadImageWithURL:(NSURL *)url inImageView:(UIImageView *)imageView
{
    if (!imageView) return;
    
    BOOL exist = [[YYImageCache sharedCache] containsImageForKey:[[YYWebImageManager sharedManager] cacheKeyForURL:url]];
    imageView.alpha = exist?1.f:0.f;
    imageView.contentMode = UIViewContentModeCenter;
    [imageView yy_setImageWithURL:url
                      placeholder:[UIImage imageNamed:@"icon_read_img_default"]
                          options:YYWebImageOptionProgressiveBlur|YYWebImageOptionAllowBackgroundTask
                       completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                           imageView.contentMode = UIViewContentModeScaleAspectFill;
                           [UIView animateWithDuration:.2f animations:^{
                               imageView.alpha = 1.f;
                           }];
                       }];
}

- (void)categoryTapped:(UITapGestureRecognizer *)gr
{
    if (self.categoryActionEnabled && self.categoryAction) {
        self.categoryAction(self.article);
    }
}

#pragma mark - Video
- (IBAction)play:(id)sender
{
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [SVProgressHUD show];
    [self.article playVideoFromViewController:self.viewCtrl completion:^(BOOL suc, NSString *msg) {
        if (suc) {
            [SVProgressHUD dismiss];
        }else{
            [SVProgressHUD showErrorWithStatus:msg];
        }
    }];
}

#pragma mark - Selected
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (!selected) return;

    YGYueduCellType cellType = [YGYueduCell cellTypeForIdentifier:self.reuseIdentifier];
    switch (cellType) {
        case YGYueduCellTypeNormal:
        case YGYueduCellTypeVideo:
        case YGYueduCellTypeVideo2:{
            YGArticleDetailViewCtrl *detailVC = [YGArticleDetailViewCtrl instanceFromStoryboard];
            detailVC.articleId = @(self.articleID);
            [self segueToDetailViewController:detailVC];
            break;
        }
        case YGYueduCellTypeImage: {
            YGArticleImagesDetailViewCtrl *detailVC = [YGArticleImagesDetailViewCtrl instanceFromStoryboard];
            detailVC.articleId = @(self.articleID);
            [self segueToDetailViewController:detailVC];
            break;
        }
    }
    [YueduArticleBean setArticleReaded:self.articleID];
    [self updateTextColor];
}

- (void)segueToDetailViewController:(UIViewController *)detailVC
{
    [self.viewCtrl.navigationController pushViewController:detailVC animated:YES];
}

@end

NSString *const kYGYueduNormalCellID    = @"YGYueduNormalCellID";
NSString *const kYGYueduImageCellID     = @"YGYueduImageCellID";
NSString *const kYGYueduVideoCellID     = @"YGYueduVideoCellID";
NSString *const kYGYueduVideoCellID2    = @"YGYueduVideoCellID2";
