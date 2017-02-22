//
//  DDAssetCategory.m
//  JuYouQu
//
//  Created by Normal on 15/12/10.
//  Copyright © 2015年 Bo Wang. All rights reserved.
//

#import "DDAssetCategory.h"
#import "DDAsset.h"

@implementation ALAssetsGroup (Protocol)
- (NSString *)groupTitle
{
    return [self valueForProperty:ALAssetsGroupPropertyName];
}

- (void)posterImage:(void(^)(CGImageRef))callback
{
    if (callback) {
        callback(self.posterImage);
    }
}

@end

#import <Photos/Photos.h>

@implementation PHAssetCollection (Protocol)

- (NSString *)groupTitle
{
    return self.localizedTitle;
}

- (NSUInteger)numberOfAssets
{
    NSUInteger count = self.estimatedAssetCount;
    if (count == NSNotFound) {
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i",PHAssetMediaTypeImage];
        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:self options:options];
        count = result.count;
    }
    return count;
}

- (void)posterImage:(void(^)(CGImageRef))callback
{
    PHAsset *asset = [[PHAsset fetchAssetsInAssetCollection:self options:nil] lastObject];
    DDAsset *ddasset = [DDAsset assetWithPHAsset:asset];
    [ddasset thumbnailImageRef:callback];
}

@end

@implementation PHFetchResult (Utils)

- (NSArray *)allObjects
{
    NSMutableArray *array = [NSMutableArray array];
    for (id object in self) {
        [array addObject:object];
    }
    return array;
}

@end