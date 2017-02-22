//
//  KDCycleBannerViewCell.m
//  Golf
//
//  Created by Main on 16/7/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "KDCycleBannerViewCell.h"
#import "ActivityModel.h"

@interface KDCycleBannerViewCell()<KDCycleBannerViewDataource, KDCycleBannerViewDelegate>

@property (weak, nonatomic) IBOutlet KDCycleBannerView *cycleBannerViewTop;
@property (nonatomic,strong) NSMutableArray *imageArr;
@property (nonatomic,strong) NSArray *activityArr;
@property (nonatomic,strong) NSArray *bannerArr;
@end
 

@implementation KDCycleBannerViewCell{
    NSArray *datas;
    UIImage *zhanweiImage;
}

- (NSMutableArray *)imageArr{
    if (!_imageArr) {
        _imageArr = [NSMutableArray array];
    }
    return _imageArr;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    self.cycleBannerViewTop.autoPlayTimeInterval = 5.0f;
    self.cycleBannerViewTop.continuous = YES;
    zhanweiImage = [UIImage imageNamed:@"defeat_banner_"];
}



-(void)loadDatas:(NSArray *)arr{
    if (self.bannerArr == arr && arr != nil) {
        return;
    }
    self.bannerArr = arr;
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString *filename=[path stringByAppendingPathComponent:@"GolfActivityData.plist"];
    NSArray *localArray = [NSArray arrayWithContentsOfFile:filename];
    if (arr.count <= 0) {
        NSMutableArray *list = [NSMutableArray array];
        for (id obj in localArray){
            ActivityModel *model = [[ActivityModel alloc] initWithDic:obj];
            [list addObject:model];
        }
        [self.imageArr removeAllObjects];
        for (ActivityModel *model in list) {
            [self.imageArr addObject:model.activityPicture];
        }
        datas = self.imageArr;
        self.activityArr = list;
    }else{
        [self.imageArr removeAllObjects];
        for (ActivityModel *model in arr) {
            [self.imageArr addObject:model.activityPicture];
        }
        datas = self.imageArr;
        self.activityArr = arr;
    }
    [self.cycleBannerViewTop reloadDataWithCompleteBlock:^{
        for (int i = 0; i < self.cycleBannerViewTop.subviews.count; i ++) {
            if ([self.cycleBannerViewTop.subviews[i] isKindOfClass:[UIScrollView class]]) {
                UIScrollView *scrollView = self.cycleBannerViewTop.subviews[i];
                for (int i = 0; i < scrollView.subviews.count; i ++) {
                    if ([scrollView.subviews[i] isKindOfClass:[UIImageView class]]) {
                        UIImageView *imageView = scrollView.subviews[i];
                        if (datas.count == 0) {
                            imageView.contentMode = UIViewContentModeCenter;
                        }
                        imageView.clipsToBounds = YES;
                    }
                }
            }else if (datas.count == 1){
                if ([self.cycleBannerViewTop.subviews[i] isKindOfClass:[UIPageControl class]]) {
                    UIPageControl *pageControl = self.cycleBannerViewTop.subviews[i];
                    pageControl.hidden = YES;
                }
            }
        }
    }];
}

#pragma mark - KDCycleBannerViewDataSource

- (NSArray *)numberOfKDCycleBannerView:(KDCycleBannerView *)bannerView {
    if (datas.count == 1) {
        self.cycleBannerViewTop.continuous = NO;
    }else{
        self.cycleBannerViewTop.continuous = YES;
    }
    return datas;
}

- (UIViewContentMode)contentModeForImageIndex:(NSUInteger)index {
    UIImageView *imageView = [[UIImageView alloc] init];
    __block int a;
    for (int i = 0; i < datas.count; i ++) {
        NSString *imageUrl = datas[i];
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (!image) {
                a = i;
            }
        }];
    }
    if (index == a + 1) {
        return UIViewContentModeCenter;
    }else{
        return UIViewContentModeScaleAspectFill;
    }
}

- (UIImage *)placeHolderImageOfZeroBannerView {
    
    return zhanweiImage;
}

- (UIImage *)placeHolderImageOfBannerView:(KDCycleBannerView *)bannerView atIndex:(NSUInteger)index{
    return zhanweiImage;
}

#pragma mark - KDCycleBannerViewDelegate

- (void)cycleBannerView:(KDCycleBannerView *)bannerView didSelectedAtIndex:(NSUInteger)index {
    
    ActivityModel *model = [self.activityArr objectAtIndex:index];
    if (_blockSelected) {
        _blockSelected(model);
    }
    [[API shareInstance] statisticalNewWithBuriedpoint:18 objectID:[NSString stringWithFormat:@"%d",model.activityId] Success:nil failure:nil];
}
@end
