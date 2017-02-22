//
//  DDAssetsManager.m
//  QuizUp
//
//  Created by Normal on 15/12/7.
//  Copyright © 2015年 Bo Wang. All rights reserved.
//

#import "DDAssetsManager.h"
#import <Photos/Photos.h>

@interface DDAssetsManager ()

@property (assign, readwrite, nonatomic) NSUInteger maxSelectCount;
@property (strong, readwrite, nonatomic) NSMutableArray<DDAsset *> *selectedAssets;
@property (strong, readwrite, nonatomic) NSNumber *kvoCount;

@end

@implementation DDAssetsManager

+ (BOOL)usePHPhoto
{
    return iOS8;
}

+ (ALAssetsLibrary *)defaultAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

+ (BOOL)isPermissionDenied
{
    if ([self usePHPhoto]) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        return status==PHAuthorizationStatusDenied || status==PHAuthorizationStatusRestricted;
    }
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    return status==ALAuthorizationStatusDenied || status==ALAuthorizationStatusRestricted;
}

+ (void)loadAssetsGroupsWithCompletion:(void (^)(NSArray<id <DDGroupProtocol>> *,NSError *error))completion
{
    if ([self usePHPhoto]) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            RunOnMainQueue(^{
                if (status == PHAuthorizationStatusAuthorized) {
                    NSMutableArray<PHAssetCollection *> *tmp = [NSMutableArray array];
                    
                    PHFetchOptions *options = [[PHFetchOptions alloc] init];
                    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"localizedTitle" ascending:YES]];
                    
                    PHFetchResult<PHAssetCollection *> *result1 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:options];
                    for (PHAssetCollection *collection in result1) {
                        NSUInteger counts = [collection numberOfAssets];
                        if (counts != 0) {
                            [tmp addObject:collection];
                        }
                    }
                    
                    PHFetchResult<PHAssetCollection *> *result2 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:options];
                    for (PHAssetCollection *collection in result2) {
                        NSUInteger counts = [collection numberOfAssets];
                        if (counts != 0) {
                            [tmp addObject:collection];
                        }
                    }
                    
                    [tmp sortUsingComparator:^NSComparisonResult(PHAssetCollection *obj1,PHAssetCollection *obj2) {
                        return [@([obj2 numberOfAssets]) compare:@([obj1 numberOfAssets])];
                    }];
                    
                    completion?completion(tmp,nil):0;
                }
            });
        }];
    }else{
        NSMutableArray *tmp = [NSMutableArray array];
        [[self defaultAssetsLibrary] enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                [tmp addObject:group];
            }else{
                completion?completion(tmp,nil):0;
            }
        } failureBlock:^(NSError *error) {
            completion?completion(nil,error):0;
        }];
    }
}

+ (void)loadAssetsGroupType:(NSUInteger)type completion:(void (^)(id<DDGroupProtocol>, NSError *error))completion
{
    if ([self usePHPhoto]) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            RunOnMainQueue(^{
                if (status == PHAuthorizationStatusAuthorized) {
                    PHAssetCollectionType mainType = type>=200?PHAssetCollectionTypeSmartAlbum:PHAssetCollectionTypeAlbum;
                    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:mainType subtype:type options:nil];
                    PHAssetCollection *collection = [result firstObject];
                    completion?completion(collection,nil):0;
                }else{
                    completion?completion(nil,nil):0;
                }
            });
        }];
    }else{
        [[self defaultAssetsLibrary] enumerateGroupsWithTypes:type usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            completion?completion(group,nil):0;
        } failureBlock:^(NSError *error) {
            completion?completion(nil,error):0;
        }];
    }
}

+ (void)loadAssetsWithGroup:(id<DDGroupProtocol>)group completion:(void (^)(NSArray<DDAsset *> *)) completion
{
    if ([self usePHPhoto]) {
        
        if (![group isKindOfClass:[PHAssetCollection class]]) return;
        
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
        
        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)group options:options];

        NSMutableArray *array = [NSMutableArray array];
        for (PHAsset *asset in result) {
            DDAsset *ddasset = [DDAsset assetWithPHAsset:asset];
            [array addObject:ddasset];
        }
        completion?completion(array):0;
        
    }else{
        if (![group isKindOfClass:[ALAssetsGroup class]]) return;
        
        ALAssetsGroup *theGroup = (ALAssetsGroup *)group;
        
        [theGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
        NSInteger count = [theGroup numberOfAssets];
        
        __block NSMutableArray *tmp = [NSMutableArray array];
        
        if (count == 0) {
            completion?completion(tmp):0;
        }
        
        [theGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                DDAsset *a = [DDAsset assetWithALAsset:result];
                [tmp insertObject:a atIndex:0];
            }
            if (index == count-1 && completion) {
                completion(tmp);
            }
        }];
    }
}

#pragma mark -
- (instancetype)initWithExistAssets:(NSArray<DDAsset *> *)assets maxCount:(NSUInteger )count
{
    self = [super init];
    if (self) {
        
        NSMutableArray *array = [NSMutableArray arrayWithArray:assets];
        self.selectedAssets = array;
        self.curGroupType = [DDAssetsManager usePHPhoto]?PHAssetCollectionSubtypeSmartAlbumUserLibrary:ALAssetsGroupSavedPhotos;
        self.maxSelectCount = count;
        [self updateKVOCount];
    }
    return self;
}

- (NSUInteger)maxSelectCount
{
    return _maxSelectCount;
}

- (NSMutableArray *)selectedAssets
{
    return _selectedAssets;
}

- (NSNumber *)kvoCount
{
    return _kvoCount;
}

- (void)updateAsset:(DDAsset *)asset select:(BOOL)isSelect
{
    if (isSelect) {
        [self selectAsset:asset];
    }else{
        [self deselectAsset:asset];
    }
    [self updateKVOCount];
}

- (BOOL)isAssetSelected:(DDAsset *)asset
{
    BOOL contain = [self.selectedAssets containsObject:asset];
    if (!contain) {
        for (DDAsset *a in self.selectedAssets) {
            if ([asset isEqualToAsset:a]) {
                contain = YES;
                break;
            }
        }
    }
    return contain;
}

- (DDAsset *)selectedAssetAtIndex:(NSInteger)index
{
    if (index < self.selectedAssets.count) {
        return self.selectedAssets[index];
    }
    return nil;
}

- (BOOL)canSelectMoreAsset
{
    NSInteger count = self.selectedAssets.count;
    NSInteger maxCount = self.maxSelectCount;
    BOOL a = maxCount == 0;
    BOOL b = count < maxCount;
    BOOL can = a || b;
    if (!a && !b) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"最多选择%ld张图片",(long)maxCount]];
    }
    return can;
}

- (DDAsset *)assetAtIndex:(NSUInteger)index
{
    if (index < self.curAssets.count) {
        return self.curAssets[index];
    }
    return nil;
}

- (NSUInteger)indexOfAsset:(DDAsset *)asset
{
    if ([self.curAssets containsObject:asset]) {
        return [self.curAssets indexOfObject:asset];
    }
    NSInteger idx = [self.curAssets indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^BOOL(DDAsset *obj, NSUInteger idx, BOOL *stop) {
        BOOL equal = [obj isEqualToAsset:asset];
        *stop = equal;
        return equal;
    }];
    return idx;
}

#pragma mark - Private Method
- (void)updateKVOCount
{
    NSInteger count = self.selectedAssets.count;
    _kvoCount = @(count);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDDAssetsManagerSelectedAssetsCountChangedNotification object:_kvoCount];
}

- (void)selectAsset:(DDAsset *)asset
{
    [self deselectAsset:asset];
    [self.selectedAssets addObject:asset];
}

- (void)deselectAsset:(DDAsset *)asset
{
    if ([self.selectedAssets containsObject:asset]) {
        [self.selectedAssets removeObject:asset];
        return;
    }
    
    NSUInteger index = [self.selectedAssets indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^BOOL(DDAsset *obj, NSUInteger idx, BOOL *stop) {
        BOOL equal = [obj isEqualToAsset:asset];
        *stop = equal;
        return equal;
    }];
    
    if (index != NSNotFound) {
        [self.selectedAssets removeObjectAtIndex:index];
    }
}

@end
