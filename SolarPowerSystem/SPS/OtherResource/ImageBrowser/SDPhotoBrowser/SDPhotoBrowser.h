//
//  SDPhotoBrowser.h
//  photobrowser
//
//  Created by aier on 15-2-6.
//  Copyright (c) 2015年 GSD. All rights reserved.
//

#import <UIKit/UIKit.h>


@class SDButton, SDPhotoBrowser;

@protocol SDPhotoBrowserDelegate <NSObject>

@required

- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index;

@optional

- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index;

// 直接向代理请求高质量图片。异步回调
- (void)photoBrowser:(SDPhotoBrowser *)browser requestHighQualityImageForIndex:(NSInteger)index completion:(void(^)(UIImage *))completion;

@end


@interface SDPhotoBrowser : UIView <UIScrollViewDelegate>

@property (nonatomic, weak) UIView *sourceImagesContainerView;
@property (nonatomic, assign) int currentImageIndex;
@property (nonatomic, assign) NSInteger imageCount;
@property (nonatomic, assign) BOOL isCollection;
@property (nonatomic, assign) BOOL noCloseAnimation;
@property (nonatomic, assign) BOOL isEdit;
@property (nonatomic, assign) BOOL highQuality,deleteTwoConfirm;
@property (nonatomic, assign) BOOL showCollectionButton;
@property (nonatomic, assign) CGRect initRt;
@property (nonatomic,strong) NSString *actionTitle;
@property (nonatomic, copy) BlockReturn blockAction; //底部中间按钮的回调
@property (nonatomic, copy) BlockReturn blockReturn;
@property (nonatomic, copy) BlockReturn blockCollectionView;
@property (nonatomic, copy) BlockReturn blockDeleteAction;  //王波加 点击删除时调用。参数为删除的图片的index
@property (nonatomic, copy) CGRect (^backRtBlock)(NSInteger index);

@property (nonatomic, weak) id<SDPhotoBrowserDelegate> delegate;

- (void)show;

@end
