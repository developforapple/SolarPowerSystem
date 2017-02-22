//
//  DDAssetCategory.h
//  JuYouQu
//
//  Created by Normal on 15/12/10.
//  Copyright © 2015年 Bo Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/PHCollection.h>
#import <Photos/PHFetchResult.h>

@protocol DDGroupProtocol <NSObject>
@required
- (NSUInteger)numberOfAssets;
- (NSString *)groupTitle;
- (void)posterImage:(void(^)(CGImageRef))callback;
@end

@interface ALAssetsGroup (Protocol)<DDGroupProtocol>
@end

@interface PHAssetCollection (Protocol)<DDGroupProtocol>
@end

@interface PHFetchResult (Utils)
- (NSArray *)allObjects;
@end
