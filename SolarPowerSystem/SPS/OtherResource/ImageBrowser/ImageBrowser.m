//
//  ImageBrowser.m
//  Golf
//
//  Created by 黄希望 on 15/7/20.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "ImageBrowser.h"
#import "ImageCollectController.h"
#import "SDPhotoGroup.h"
#import "SDPhotoItem.h"
#import "SDWebImageManager.h"
#import "SDPhotoBrowser.h"
#import "DDAsset.h"

@implementation ImageBrowser

+ (void)hide{
    [[[GolfAppDelegate shareAppDelegate].window subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[SDPhotoBrowser class]]) {
            [obj removeFromSuperview];
            *stop = YES;
        }
    }];
}

/**
 *  在当前视图上弹出一个浏览层
 *
 *  @param  aImages             图片链接地址
 *  @param  isCollection        是否以collection的形式展示
 *  @param  currentIndex        点击图片的索引值,isCollection为YES时不用传
 *  @param  initRect            图片弹出的初始位置,isCollection为YES时不用传
 *  @param  initRects           图片弹出的位置集
 *  @param  isEdit              是否支持编辑(删除)
 *  @param  highQuality         是否需要高清大图
 *  @param  actionTitle         底部工具栏单个按钮的标题
 *  @param  blockAction         底部工具栏单个按钮的回调
 *  @param  vc                  当前的视图控制器
 *  @param  backRtBlock         点击消失回到原界面时index所对应的图片的位置
 *  @param  completion          回调处理
 */

+ (void)IBWithImages:(NSArray*)aImages
        isCollection:(BOOL)isCollection
        currentIndex:(NSInteger)currentIndex
              initRt:(CGRect)initRect
              isEdit:(BOOL)isEdit
         highQuality:(BOOL)highQuality
                  vc:(BaseNavController*)vc
         actionTitle:(NSString *)actionTitle
         blockAction:(BlockReturn)blockAction
         backRtBlock:(CGRect(^)(NSInteger index))backRtBlock
          completion:(void(^)(id handler))completion{
    UIScrollView *sv = nil;
    for (UIView *view in vc.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            sv = (UIScrollView*)view;
            sv.scrollsToTop = NO;
            break;
        }
    }
    
    if (isCollection) {
        ImageCollectController *sdTable = [[ImageCollectController alloc] init];
        sdTable.srcStringArray = [NSMutableArray arrayWithArray:aImages];
        sdTable.isCollection = isCollection;
        sdTable.isEdit = isEdit;
        sdTable.highQuality = highQuality;
        sdTable.blockReturn = ^(id obj){
            sv.scrollsToTop = YES;
            if (completion) {
                completion (obj);
            }
        };
        [vc pushViewController:sdTable title:[NSString stringWithFormat:@"图片浏览(%d)",(int)aImages.count] hide:YES];
    }else{
        SDPhotoGroup *sdPhotoGroup = [[SDPhotoGroup alloc] init];
        sdPhotoGroup.hidden = YES;
        sdPhotoGroup.center = vc.view.center;
        sdPhotoGroup.isCollection = isCollection;
        sdPhotoGroup.initRt = initRect;
        sdPhotoGroup.highQuality = highQuality;
        sdPhotoGroup.isEdit = isEdit;
        sdPhotoGroup.backRtBlock = backRtBlock;
        sdPhotoGroup.actionTitle = actionTitle;
        sdPhotoGroup.blockAction = ^(id data) {
            if (blockAction) {
                blockAction(nil);
            }
        };
        sdPhotoGroup.blockReturn = ^(id obj){
            sv.scrollsToTop = YES;
            SDPhotoGroup *sdPhotoGroup = (SDPhotoGroup*)obj;
            if (completion) {
                completion (obj);
            }
            if ([sdPhotoGroup isKindOfClass:[UIView class]]) {
                if ([sdPhotoGroup superview]) {
                    [sdPhotoGroup removeFromSuperview];
                }
            }
            
        };
        
        NSMutableArray *temp = [NSMutableArray array];
        [aImages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SDPhotoItem *item = [[SDPhotoItem alloc] init];
            item.thumbnail_pic = obj;
            [temp addObject:item];
        }];
        
        sdPhotoGroup.photoItemArray = [temp mutableCopy];
        
        [vc.view addSubview:sdPhotoGroup];
        
        if (currentIndex < aImages.count) {
            id obj = aImages[currentIndex];
            if ([obj isKindOfClass:[NSString class]]) {
                NSURL *url = [NSURL URLWithString:obj];
                if ([[SDWebImageManager sharedManager] cachedImageExistsForURL:url]) {
                    [sdPhotoGroup click:(int)currentIndex delay:0];
                }else{
                    [sdPhotoGroup click:(int)currentIndex delay:0.5];
                }
            }else if ([obj isKindOfClass:[UIImage class]]){
                [sdPhotoGroup click:(int)currentIndex delay:0];
            }
        }
    }
}

/**
 *  在当前视图上弹出一个浏览层
 *
 *  @param  aImages         图片链接地址
 *  @param  isCollection    是否以collection的形式展示
 *  @param  currentIndex    点击图片的索引值,isCollection为YES时不用传
 *  @param  initRect        图片弹出的初始位置,isCollection为YES时不用传
 *  @param  isEdit          是否支持编辑(删除)
 *  @param  highQuality     是否需要高清大图
 *  @param  vc              当前的视图控制器
 *  @param  showCollectionView  是否显示图集按钮在底部工具栏右边
 *  @param  blockCollectionView  图集按钮点击回调
 *  @param  completion      回调处理
 */
+ (void)IBWithImages:(NSArray*)aImages
        isCollection:(BOOL)isCollection
        currentIndex:(NSInteger)currentIndex
              initRt:(CGRect)initRect
              isEdit:(BOOL)isEdit
         highQuality:(BOOL)highQuality
                  vc:(BaseNavController*)vc
  showCollectionView:(BOOL)showCollectionView
 blockCollectionView:(BlockReturn)blockCollectionView
         backRtBlock:(CGRect(^)(NSInteger index))backRtBlock
          completion:(void(^)(id handler))completion{
    UIScrollView *sv = nil;
    for (UIView *view in vc.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            sv = (UIScrollView*)view;
            sv.scrollsToTop = NO;
            break;
        }
    }
    
    if (isCollection) {
        ImageCollectController *sdTable = [[ImageCollectController alloc] init];
        sdTable.srcStringArray = [NSMutableArray arrayWithArray:aImages];
        sdTable.isCollection = isCollection;
        sdTable.isEdit = isEdit;
        sdTable.highQuality = highQuality;
        sdTable.blockReturn = ^(id obj){
            sv.scrollsToTop = YES;
            if (completion) {
                completion (obj);
            }
        };
        [vc pushViewController:sdTable title:[NSString stringWithFormat:@"图片浏览(%d)",(int)aImages.count] hide:YES];
    }else{
        SDPhotoGroup *sdPhotoGroup = [[SDPhotoGroup alloc] init];
        sdPhotoGroup.hidden = YES;
        sdPhotoGroup.center = vc.view.center;
        sdPhotoGroup.isCollection = isCollection;
        sdPhotoGroup.initRt = initRect;
        sdPhotoGroup.highQuality = highQuality;
        sdPhotoGroup.isEdit = isEdit;
        sdPhotoGroup.backRtBlock = backRtBlock;
        sdPhotoGroup.showCollectionButton = showCollectionView;
        sdPhotoGroup.blockCollectionView = blockCollectionView;
        sdPhotoGroup.blockReturn = ^(id obj){
            sv.scrollsToTop = YES;
            SDPhotoGroup *sdPhotoGroup = (SDPhotoGroup*)obj;
            if (completion) {
                completion (obj);
            }
            if ([sdPhotoGroup isKindOfClass:[UIView class]]) {
                if ([sdPhotoGroup superview]) {
                    [sdPhotoGroup removeFromSuperview];
                }
            }
            
        };
        
        NSMutableArray *temp = [NSMutableArray array];
        [aImages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SDPhotoItem *item = [[SDPhotoItem alloc] init];
            item.thumbnail_pic = obj;
            [temp addObject:item];
        }];
        
        sdPhotoGroup.photoItemArray = [temp mutableCopy];
        
        [vc.view addSubview:sdPhotoGroup];
        
        if (currentIndex < aImages.count) {
            id obj = aImages[currentIndex];
            if ([obj isKindOfClass:[NSString class]]) {
                NSURL *url = [NSURL URLWithString:obj];
                if ([[SDWebImageManager sharedManager] cachedImageExistsForURL:url]) {
                    [sdPhotoGroup click:(int)currentIndex delay:0];
                }else{
                    [sdPhotoGroup click:(int)currentIndex delay:0.5];
                }
            }else if ([obj isKindOfClass:[UIImage class]]){
                [sdPhotoGroup click:(int)currentIndex delay:0];
            }
        }
    }
}



/**
 *  在当前视图上弹出一个浏览层
 *
 *  @param  aImages         图片链接地址
 *  @param  isCollection    是否以collection的形式展示
 *  @param  currentIndex    点击图片的索引值,isCollection为YES时不用传
 *  @param  initRect        图片弹出的初始位置,isCollection为YES时不用传
 *  @param  isEdit          是否支持编辑(删除)
 *  @param  highQuality     是否需要高清大图
 *  @param  vc              当前的视图控制器
 *  @param  completion      回调处理
 */
+ (void)IBWithImages:(NSArray*)aImages
        currentIndex:(NSInteger)currentIndex
              initRt:(CGRect)initRect
              isEdit:(BOOL)isEdit
         highQuality:(BOOL)highQuality
                  vc:(BaseNavController*)vc
         backRtBlock:(CGRect(^)(NSInteger index))backRtBlock
          blockDelete:(void(^)(NSDictionary *info))blockDelete{
    
    UIScrollView *sv = nil;
    for (UIView *view in vc.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            sv = (UIScrollView*)view;
            sv.scrollsToTop = NO;
            break;
        }
    }
    
    SDPhotoGroup *sdPhotoGroup = [[SDPhotoGroup alloc] init];
    sdPhotoGroup.hidden = YES;
    sdPhotoGroup.center = vc.view.center;
    sdPhotoGroup.isCollection = NO;
    sdPhotoGroup.initRt = initRect;
    sdPhotoGroup.highQuality = highQuality;
    sdPhotoGroup.isEdit = isEdit;
    sdPhotoGroup.backRtBlock = backRtBlock;
    sdPhotoGroup.deleteTwoConfirm = blockDelete != nil;
    sdPhotoGroup.blockReturn = ^(id obj){
        sv.scrollsToTop = YES;
        if (blockDelete) {
            blockDelete (obj);
        }            
    };
    
    NSMutableArray *temp = [NSMutableArray array];
    [aImages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SDPhotoItem *item = [[SDPhotoItem alloc] init];
        item.thumbnail_pic = obj;
        [temp addObject:item];
    }];
    
    sdPhotoGroup.photoItemArray = [temp mutableCopy];
    
    [vc.view addSubview:sdPhotoGroup];
    
    if (currentIndex < aImages.count) {
        id obj = aImages[currentIndex];
        if ([obj isKindOfClass:[NSString class]]) {
            NSURL *url = [NSURL URLWithString:obj];
            if ([[SDWebImageManager sharedManager] cachedImageExistsForURL:url]) {
                [sdPhotoGroup click:(int)currentIndex delay:0];
            }else{
                [sdPhotoGroup click:(int)currentIndex delay:0.5];
            }
        }else if ([obj isKindOfClass:[UIImage class]]){
            [sdPhotoGroup click:(int)currentIndex delay:0];
        }
    }
}


/**
 *  在当前视图上弹出一个浏览层
 *
 *  @param  aImages         图片链接地址
 *  @param  isCollection    是否以collection的形式展示
 *  @param  currentIndex    点击图片的索引值,isCollection为YES时不用传
 *  @param  initRect        图片弹出的初始位置,isCollection为YES时不用传
 *  @param  isEdit          是否支持编辑(删除)
 *  @param  highQuality     是否需要高清大图
 *  @param  vc              当前的视图控制器
 *  @param  completion      回调处理
 */
+ (void)IBWithImages:(NSArray*)aImages
        isCollection:(BOOL)isCollection
        currentIndex:(NSInteger)currentIndex
              initRt:(CGRect)initRect
              isEdit:(BOOL)isEdit
         highQuality:(BOOL)highQuality
    noCloseAnimation:(BOOL)noCloseAnimation
                  vc:(UIViewController *)vc
         backRtBlock:(CGRect(^)(NSInteger index))backRtBlock
          completion:(void(^)(id handler))completion{
    UIScrollView *sv = nil;
    for (UIView *view in vc.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            sv = (UIScrollView*)view;
            sv.scrollsToTop = NO;
            break;
        }
    }
    
    if (isCollection) {
        ImageCollectController *sdTable = [[ImageCollectController alloc] init];
        sdTable.srcStringArray = [NSMutableArray arrayWithArray:aImages];
        sdTable.isCollection = isCollection;
        sdTable.isEdit = isEdit;
        sdTable.highQuality = highQuality;
        sdTable.blockReturn = ^(id obj){
            sv.scrollsToTop = YES;
            if (completion) {
                completion (obj);
            }
        };
        sdTable.title = [NSString stringWithFormat:@"图片浏览(%d)",(int)aImages.count];
        sdTable.hidesBottomBarWhenPushed = YES;
        [vc.navigationController pushViewController:sdTable animated:YES];
    }else{
        SDPhotoGroup *sdPhotoGroup = [[SDPhotoGroup alloc] init];
        sdPhotoGroup.hidden = YES;
        sdPhotoGroup.center = vc.view.center;
        sdPhotoGroup.isCollection = isCollection;
        sdPhotoGroup.noCloseAnimation = noCloseAnimation;
        sdPhotoGroup.initRt = initRect;
        sdPhotoGroup.highQuality = highQuality;
        sdPhotoGroup.isEdit = isEdit;
        sdPhotoGroup.backRtBlock = backRtBlock;
        sdPhotoGroup.blockReturn = ^(id obj){
            sv.scrollsToTop = YES;
            SDPhotoGroup *sdPhotoGroup = (SDPhotoGroup*)obj;
            if (completion) {
                completion (obj);
            }
            if ([sdPhotoGroup isKindOfClass:[UIView class]]) {
                if ([sdPhotoGroup superview]) {
                    [sdPhotoGroup removeFromSuperview];
                }
            }
            
        };
        
        NSMutableArray *temp = [NSMutableArray array];
        [aImages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SDPhotoItem *item = [[SDPhotoItem alloc] init];
            item.thumbnail_pic = obj;
            [temp addObject:item];
        }];
        
        sdPhotoGroup.photoItemArray = [temp mutableCopy];
        
        [vc.view addSubview:sdPhotoGroup];
        
        if (currentIndex < aImages.count) {
            id obj = aImages[currentIndex];
            if ([obj isKindOfClass:[NSString class]]) {
                NSURL *url = [NSURL URLWithString:obj];
                if ([[SDWebImageManager sharedManager] cachedImageExistsForURL:url]) {
                    [sdPhotoGroup click:(int)currentIndex delay:0];
                }else{
                    [sdPhotoGroup click:(int)currentIndex delay:0.5];
                }
            }else if ([obj isKindOfClass:[UIImage class]]){
                [sdPhotoGroup click:(int)currentIndex delay:0];
            }
        }
    }
}


+ (void)IBWithImages:(NSArray*)aImages
        isCollection:(BOOL)isCollection
        currentIndex:(NSInteger)currentIndex
              initRt:(CGRect)initRect
              isEdit:(BOOL)isEdit
         highQuality:(BOOL)highQuality
                  vc:(BaseNavController*)vc
         backRtBlock:(CGRect(^)(NSInteger index))backRtBlock
          completion:(void(^)(id handler))completion{
    
    UIScrollView *sv = nil;
    for (UIView *view in vc.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            sv = (UIScrollView*)view;
            sv.scrollsToTop = NO;
            break;
        }
    }
    
    if (isCollection) {
        ImageCollectController *sdTable = [[ImageCollectController alloc] init];
        sdTable.srcStringArray = [NSMutableArray arrayWithArray:aImages];
        sdTable.isCollection = isCollection;
        sdTable.isEdit = isEdit;
        sdTable.highQuality = highQuality;
        sdTable.blockReturn = ^(id obj){
            sv.scrollsToTop = YES;
            if (completion) {
                completion (obj);
            }
        };
        [vc pushViewController:sdTable title:[NSString stringWithFormat:@"图片浏览(%d)",(int)aImages.count] hide:YES];
    }else{
        SDPhotoGroup *sdPhotoGroup = [[SDPhotoGroup alloc] init];
        sdPhotoGroup.hidden = YES;
        sdPhotoGroup.center = vc.view.center;
        sdPhotoGroup.isCollection = isCollection;
        sdPhotoGroup.initRt = initRect;
        sdPhotoGroup.highQuality = highQuality;
        sdPhotoGroup.isEdit = isEdit;
        sdPhotoGroup.backRtBlock = backRtBlock;
        sdPhotoGroup.blockReturn = ^(id obj){
            sv.scrollsToTop = YES;
            SDPhotoGroup *sdPhotoGroup = (SDPhotoGroup*)obj;
            if (completion) {
                completion (obj);
            }
            if ([sdPhotoGroup isKindOfClass:[UIView class]]) {
                if ([sdPhotoGroup superview]) {
                    [sdPhotoGroup removeFromSuperview];
                }
            }
            
        };
        
        NSMutableArray *temp = [NSMutableArray array];
        [aImages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SDPhotoItem *item = [[SDPhotoItem alloc] init];
            item.thumbnail_pic = obj;
            [temp addObject:item];
        }];
        
        sdPhotoGroup.photoItemArray = [temp mutableCopy];
        
        [vc.view addSubview:sdPhotoGroup];
        
        if (currentIndex < aImages.count) {
            id obj = aImages[currentIndex];
            if ([obj isKindOfClass:[NSString class]]) {
                NSURL *url = [NSURL URLWithString:obj];
                if ([[SDWebImageManager sharedManager] cachedImageExistsForURL:url]) {
                    [sdPhotoGroup click:(int)currentIndex delay:0];
                }else{
                    [sdPhotoGroup click:(int)currentIndex delay:0.5];
                }
            }else if ([obj isKindOfClass:[UIImage class]]){
                [sdPhotoGroup click:(int)currentIndex delay:0];
            }
        }
    }
}


/**
 *  返回一个collectView,可以插入到需要的地方
 *
 *  @param  aImages         图片链接地址
 *  @param  size            单个图片的长宽
 *  @param  rowCount        每行显示图片数
 *  @param  initRect        SDPhotoGroup的初始位置
 *  @param  isEdit          是否支持编辑(删除)
 *  @param  highQuality     是否需要高清大图
 *  @param  needAdd         是否需要添加按钮
 *  @param  completion      回调处理
 *  @param  addBlock        点击添加图片的回调
 */
+ (SDPhotoGroup*)viewWithImages:(NSArray*)aImages
                           size:(CGFloat)size
                       rowCount:(NSInteger)rowCount
                         initRt:(CGRect)initRect
                    imageMargin:(CGFloat)imageMargin
                         isEdit:(BOOL)isEdit
                    highQuality:(BOOL)highQuality
                        needAdd:(BOOL)needAdd
                     completion:(void(^)(id handler))completion
                       addBlock:(void(^)(id addHandler))addBlock{
    
    return [self viewWithImages:aImages size:size rowCount:rowCount initRt:initRect imageMargin:imageMargin isEdit:isEdit highQuality:highQuality needAdd:needAdd delete:nil completion:completion addBlock:addBlock];
}

+ (SDPhotoGroup*)viewWithImages:(NSArray*)aImages
                           size:(CGFloat)size
                       rowCount:(NSInteger)rowCount
                         initRt:(CGRect)initRect
                    imageMargin:(CGFloat)imageMargin
                         isEdit:(BOOL)isEdit
                    highQuality:(BOOL)highQuality
                        needAdd:(BOOL)needAdd
                         delete:(BlockReturn)deleteBlock
                     completion:(void(^)(id handler))completion
                       addBlock:(void(^)(id addHandler))addBlock{
    
    SDPhotoGroup *sdPhotoGroup = [[SDPhotoGroup alloc] init];
    sdPhotoGroup.isCollection = YES;
    sdPhotoGroup.imageSize = size;
    sdPhotoGroup.rowCount = rowCount;
    sdPhotoGroup.imageMargin = 10;
    sdPhotoGroup.frame = initRect;
    sdPhotoGroup.isEdit = isEdit;
    sdPhotoGroup.highQuality = highQuality;
    sdPhotoGroup.imagesBlock = ^(id obj){
        if (completion) {
            completion (obj);
        }
    };
    sdPhotoGroup.blockDeleteAction = deleteBlock;
    
    NSMutableArray *temp = [NSMutableArray array];
    __block BOOL isKindImage = NO;
    [aImages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SDPhotoItem *item = [[SDPhotoItem alloc] init];
        if (([obj isKindOfClass:[UIImage class]] || [obj isKindOfClass:[DDAsset class]]) && !isKindImage){
            isKindImage = YES;
        }
        item.thumbnail_pic = obj;
        [temp addObject:item];
    }];
    
    if (needAdd && isKindImage) {
        sdPhotoGroup.isAddPic = needAdd;
        sdPhotoGroup.addBlock = addBlock;
    }
    
    sdPhotoGroup.photoItemArray = [temp mutableCopy];
    return sdPhotoGroup;
}

@end
