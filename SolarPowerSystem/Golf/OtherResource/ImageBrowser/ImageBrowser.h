//
//  ImageBrowser.h
//  Golf
//
//  Created by 黄希望 on 15/7/20.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDPhotoGroup.h"

@interface ImageBrowser : NSObject


//隐藏当前的预览
+ (void)hide;

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
          completion:(void(^)(id handler))completion;


/**
 *  在当前视图上弹出一个浏览层
 *
 *  @param  aImages         图片链接地址
 *  @param  isCollection    是否以collection的形式展示
 *  @param  currentIndex    点击图片的索引值,isCollection为YES时不用传
 *  @param  initRect        图片弹出的初始位置,isCollection为YES时不用传
 *  @param  initRects       图片弹出的位置集
 *  @param  isEdit          是否支持编辑(删除)
 *  @param  highQuality     是否需要高清大图
 *  @param  vc              当前的视图控制器
 *  @param  backRtBlock     点击消失回到原界面时index所对应的图片的位置
 *  @param  completion      回调处理
 */

+ (void)IBWithImages:(NSArray*)aImages
        isCollection:(BOOL)isCollection
        currentIndex:(NSInteger)currentIndex
              initRt:(CGRect)initRect
              isEdit:(BOOL)isEdit
         highQuality:(BOOL)highQuality
                  vc:(BaseNavController*)vc
         backRtBlock:(CGRect(^)(NSInteger index))backRtBlock
          completion:(void(^)(id handler))completion;

+ (void)IBWithImages:(NSArray*)aImages
        isCollection:(BOOL)isCollection
        currentIndex:(NSInteger)currentIndex
              initRt:(CGRect)initRect
              isEdit:(BOOL)isEdit
         highQuality:(BOOL)highQuality
    noCloseAnimation:(BOOL)noCloseAnimation
                  vc:(UIViewController *)vc
         backRtBlock:(CGRect(^)(NSInteger index))backRtBlock
          completion:(void(^)(id handler))completion;

/**
 *  在当前视图上弹出一个浏览层
 *
 *  @param  aImages         图片链接地址
 *  @param  currentIndex    点击图片的索引值,isCollection为YES时不用传
 *  @param  initRect        图片弹出的初始位置,isCollection为YES时不用传
 *  @param  isEdit          是否支持编辑(删除)
 *  @param  highQuality     是否需要高清大图
 *  @param  vc              当前的视图控制器
 *  @param  completion      回调处理 删除回调
 */
+ (void)IBWithImages:(NSArray*)aImages
        currentIndex:(NSInteger)currentIndex
              initRt:(CGRect)initRect
              isEdit:(BOOL)isEdit
         highQuality:(BOOL)highQuality
                  vc:(BaseNavController*)vc
         backRtBlock:(CGRect(^)(NSInteger index))backRtBlock
          blockDelete:(void(^)(NSDictionary *info))blockDelete;

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
          completion:(void(^)(id handler))completion;


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
                       addBlock:(void(^)(id addHandler))addBlock;

// 同上面的方法。多增加一个delete的回调
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
                       addBlock:(void(^)(id addHandler))addBlock;


@end
