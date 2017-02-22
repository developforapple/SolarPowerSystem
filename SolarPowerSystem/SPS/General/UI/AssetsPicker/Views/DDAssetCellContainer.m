//
//  DDAssetCellContainer.m
//  JuYouQu
//
//  Created by Normal on 15/12/10.
//  Copyright © 2015年 Bo Wang. All rights reserved.
//

#import "DDAssetCellContainer.h"
#import "DDAssetsInclude.h"

@implementation DDAssetCellContainer

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.assetSelectedView.userInteractionEnabled = YES;
    [self.assetSelectedView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(assetWillSelected:)]];
    
    self.assetsImageView.userInteractionEnabled = YES;
    [self.assetsImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(assetWillPreviewed:)]];
}

- (void)configureWithAsset:(DDAsset *)asset
{
    _asset = asset;
    
    [self layoutIfNeeded];
    
    ddweakify(self);
    self.assetsImageView.image = nil;
    
    // 这里获取缩略图的block是同步的。所以将生成缩略图的操作放子线程里，以免阻塞主线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.asset thumbnailImageWithSize:self.bounds.size completion:^(UIImage *image) {
            ddstrongify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.assetsImageView) {
                    self.assetsImageView.image = image;
                }
            });
        }];
    });
    self.gifIndicator.hidden = ![asset isGif];
}

- (void)assetWillSelected:(UITapGestureRecognizer *)gr
{
    BOOL didSelected = self.assetSelected;
    if (didSelected) {
        //当前已经被选中，直接取消选中。
        self.assetSelected = NO;
        if (self.assetSelectedChanged) {
            self.assetSelectedChanged(self.asset,NO);
        }
    }else{
        //当前为未选中状态。
        BOOL shouldSelected = YES;  //默认可选
        if (self.shouldSelectedAsset) {
            shouldSelected = self.shouldSelectedAsset(self.asset);
        }
        //是否可选。
        if (shouldSelected) {
            //可选，则选择
            self.assetSelected = YES;
            if (self.assetSelectedChanged) {
                self.assetSelectedChanged(self.asset,YES);
            }
        }else{
            //什么都不做
        }
    }
}

- (void)assetWillPreviewed:(UITapGestureRecognizer *)gr
{
    if (self.assetWillPreviewBlock) {
        self.assetWillPreviewBlock(self.asset);
    }
}

- (void)setAssetSelected:(BOOL)assetSelected
{
    _assetSelected = assetSelected;
    
    if (!assetSelected) {
        self.assetSelectIndicator.highlighted = NO;
    }else{
        
        self.assetSelectIndicator.transform = CGAffineTransformMakeScale(.5f, .5f);
        self.assetSelectIndicator.highlighted = YES;
        
        [UIView animateWithDuration:.6f delay:0.f usingSpringWithDamping:.6f initialSpringVelocity:0.6f options:UIViewAnimationOptionCurveLinear animations:^{
            
            self.assetSelectIndicator.transform = CGAffineTransformIdentity;
            
        } completion:^(BOOL finished) {
        }];
    }
}

@end
