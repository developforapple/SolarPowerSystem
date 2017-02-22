//
//  VIPhotoView.h
//  VIPhotoViewDemo
//
//  Created by Vito on 1/7/15.
//  Copyright (c) 2015 vito. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VIPhotoView : UIScrollView

@property (nonatomic,copy) BlockReturn blockSingleTap;
- (instancetype)initWithFrame:(CGRect)frame andImage:(UIImage *)image;

@property (nonatomic, assign) BOOL hasLoadedImage;

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

// 使用 setImage:方法设置图片。直接设置imageView的图片将不会自动调整大小
@property (nonatomic, strong) UIImageView *imageView;
- (void)setImage:(UIImage *)image;
- (UIImage *)image;

@end
