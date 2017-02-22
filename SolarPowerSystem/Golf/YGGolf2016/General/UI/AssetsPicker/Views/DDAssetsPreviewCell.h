//
//  DDAssetsPreviewCell.h
//  Golf
//
//  Created by bo wang on 16/8/30.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDAsset.h"
#import "YYImage.h"

#define kDDAssetsPreviewCell @"DDAssetsPreviewCell"

@interface DDAssetsPreviewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) YYAnimatedImageView *imageView;
@property (assign, nonatomic) BOOL animatedWhenAssetDisplay;

@property (readonly, strong, nonatomic) DDAsset *asset;
- (void)configureWithALAssset:(DDAsset *)asset;

@property (copy, nonatomic) void (^tapAction)(DDAsset *asset);

@end
