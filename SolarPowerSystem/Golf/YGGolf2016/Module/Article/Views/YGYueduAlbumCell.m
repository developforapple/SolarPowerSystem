//
//  YGYueduAlbumCell.m
//  Golf
//
//  Created by bo wang on 16/6/16.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGYueduAlbumCell.h"
#import "yueduService.h"

@implementation YGYueduAlbumCell

+ (void)registerCellInCollectionView:(UICollectionView *)collectionView
{
    [collectionView registerNib:[UINib nibWithNibName:@"YGYueduAlbumCell" bundle:nil] forCellWithReuseIdentifier:kYGYueduAlbumCellID];
}

- (void)configureWithAlbum:(YueduAlbumBean *)albumBean
{
    _albumBean = albumBean;
    
    self.albumTitleLabel.text = albumBean.name;
    self.albumCountLabel.text = [NSString stringWithFormat:@"%d 内容",albumBean.articleCount];
    
    ygweakify(self);
    self.albumImageView.contentMode = UIViewContentModeCenter;
    [self.albumImageView sd_setImageWithURL:[NSURL URLWithString:albumBean.cover.name] placeholderImage:[UIImage imageNamed:@"icon_read_img_default"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        ygstrongify(self);
        self.albumImageView.contentMode = UIViewContentModeScaleAspectFill;
    }];
}

@end

NSString *const kYGYueduAlbumCellID = @"YGYueduAlbumCell";
