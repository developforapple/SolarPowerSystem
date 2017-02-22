//
//  YGYueduAlbumCell.h
//  Golf
//
//  Created by bo wang on 16/6/16.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YueduAlbumBean;

FOUNDATION_EXTERN NSString *const kYGYueduAlbumCellID;

@interface YGYueduAlbumCell : UICollectionViewCell

+ (void)registerCellInCollectionView:(UICollectionView *)collectionView;

@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;
@property (weak, nonatomic) IBOutlet UILabel *albumTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *albumCountLabel;

@property (strong, readonly, nonatomic) YueduAlbumBean *albumBean;
- (void)configureWithAlbum:(YueduAlbumBean *)albumBean;

@end
