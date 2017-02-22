//
//  DDAssetsCell.m
//  QuizUp
//
//  Created by Normal on 15/12/7.
//  Copyright © 2015年 Bo Wang. All rights reserved.
//

#import "DDAssetsCell.h"

@implementation DDAssetsCell

- (void)configureWithAsset:(DDAsset *)asset
{
    _asset = asset;
    
    ddweakify(self);
    
    self.assetContainer.hidden = NO;
    [self.assetContainer configureWithAsset:asset];
    
    [self.assetContainer setShouldSelectedAsset:^BOOL(DDAsset *theAsset) {
        ddstrongify(self);
        BOOL should = YES;
        if (self.shouldSelectedAsset) {
            should = self.shouldSelectedAsset(theAsset);
        }
        return should;
    }];
    
    [self.assetContainer setAssetSelectedChanged:^(DDAsset *theAsset, BOOL isSelected) {
        ddstrongify(self);
        
        if (self.assetSelectedChanged) {
            self.assetSelectedChanged(theAsset,isSelected);
        }
    }];
    
    [self.assetContainer setAssetWillPreviewBlock:^(DDAsset *theAsset) {
        ddstrongify(self);
        if (self.assetWillPreviewBlock) {
            self.assetWillPreviewBlock(theAsset);
        }
    }];
    self.assetContainer.assetSelected = [self.manager isAssetSelected:asset];
}

@end
