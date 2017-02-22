//
//  YGYueduImageDetailCell.h
//  Golf
//
//  Created by bo wang on 16/6/12.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXTERN NSString *const kYGYueduImageDetailCell;

@class YueduArticleImageBean;
@class YYAnimatedImageView;

/*!
 *  @brief 图片详情页的cell
 */
@interface YGYueduImageDetailCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIScrollView *imageZoomScrollView;
//@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) YYAnimatedImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property (strong, readonly, nonatomic) UITapGestureRecognizer *doubleTapGestureRecognizer;
@property (strong, readonly, nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;

@property (strong, readonly, nonatomic) YueduArticleImageBean *imageBean;
- (void)configureWithImage:(YueduArticleImageBean *)imageBean;

@end
