//
//  DDAssetsPreviewCell.m
//  Golf
//
//  Created by bo wang on 16/8/30.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "DDAssetsPreviewCell.h"
#import "DDAssetsInclude.h"
#import "UIScrollView+EmptyDataSet.h"

@interface DDAssetsPreviewCell () <UIScrollViewDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
@property (assign, nonatomic) BOOL loading;
@end

@implementation DDAssetsPreviewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.numberOfTapsRequired = 1;
    UITapGestureRecognizer *dTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    dTap.numberOfTapsRequired = 2;
    
    [tap requireGestureRecognizerToFail:dTap];
    
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addGestureRecognizer:tap];
    [self.imageView addGestureRecognizer:dTap];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self adjustFrames];
}

- (void)configureWithALAssset:(DDAsset * )asset
{
    _asset = asset;
    [self _updateUI];
}

- (YYAnimatedImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[YYAnimatedImageView alloc] initWithFrame:self.scrollView.frame];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.scrollView addSubview:_imageView];
    }
    return _imageView;
}

#pragma mark - UIScrollView Delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    self.imageView.center = [self centerOfScrollViewContent:scrollView];
}

#pragma mark - Adjust
- (void)adjustFrames
{
    // 正在Loading时
    if (self.loading) {
        UIImage *image = self.imageView.image;
        CGSize size = image.size;
        
        self.scrollView.contentSize = size;
        self.scrollView.contentOffset = CGPointMake(0, 0);
        self.scrollView.minimumZoomScale = 1;
        self.scrollView.maximumZoomScale = 1;
        self.scrollView.zoomScale = 1;
        
        self.imageView.frame = CGRectMake(0, 0, size.width, size.height);
        self.imageView.center = [self centerOfScrollViewContent:self.scrollView];
        return;
    }
    
    CGRect imageFrame;
    CGSize contentSize;
    CGPoint offset;
    CGFloat minZoomScale,maxZoomScale,zoomScale;
    
    CGRect frame = self.contentView.frame;
    UIImage *image = self.imageView.image;
    
    if (image) {
        
        CGFloat width = CGRectGetWidth(frame);
        CGFloat height = CGRectGetHeight(frame);
        CGFloat ratio = height/width;
        
        CGFloat imageW = image.size.width;
        CGFloat imageH = image.size.height;
        CGFloat imageRatio = imageH/imageW;
        
        if (imageRatio < 1){
            imageFrame = CGRectMake(0, 0, width, height);;
            contentSize = CGSizeMake(width, height);
            offset = CGPointZero;
            minZoomScale = .5f;
            maxZoomScale = 2.f;
            zoomScale = 1.f;
        }else{
            CGFloat targetW,targetH;
            CGFloat offsetX,offsetY;
            
            if (imageRatio > ratio) {
                targetW = width;
                targetH = imageRatio * targetW;
                offsetX = offsetY = 0.f;
            }else{
                targetW = width;
                targetH = height;
                offsetX = 0.f;
                offsetY = 0.f;
            }
            
            imageFrame = CGRectMake(0, 0, ceil(targetW), ceil(targetH));
            contentSize = imageFrame.size;
            offset = CGPointMake(ceil(offsetX), ceil(offsetY));
            
            minZoomScale = .5f;
            maxZoomScale = 2.f;
            zoomScale = 1.f;
        }
    }else{
        imageFrame = frame;
        contentSize = frame.size;
        offset = CGPointZero;
        minZoomScale = 1.f;
        maxZoomScale = 1.f;
        zoomScale = 1.f;
    }
    
    self.imageView.frame = imageFrame;
    self.scrollView.contentSize = contentSize;
    self.scrollView.contentOffset = offset;
    self.scrollView.minimumZoomScale = minZoomScale;
    self.scrollView.maximumZoomScale = maxZoomScale;
    self.scrollView.zoomScale = zoomScale;
}

- (void)resetUI
{
    [UIView performWithoutAnimation:^{
        self.scrollView.zoomScale = 1.f;
        self.scrollView.minimumZoomScale = 1;
        self.scrollView.maximumZoomScale = 1;
        self.scrollView.contentSize = CGSizeZero;
        self.scrollView.contentOffset = CGPointZero;
        self.scrollView.delegate = self;
        self.imageView.frame = self.animatedWhenAssetDisplay?CGRectZero:self.bounds;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }];
}

- (void)_updateUI
{
    [self resetUI];
    
    ddweakify(self);
    self.imageView.image = nil;
    self.loading = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.asset thumbnailImage:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ddstrongify(self);
                if (self.loading) {
                    self.imageView.image = image;
                    [self adjustFrames];
                }
            });
        }];
        
        [self.asset previewImage:^(UIImage *image) {
            ddstrongify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.loading = NO;
                self.imageView.alpha = 0.f;
                [self adjustFrames];
                [UIView animateWithDuration:.2f animations:^{
                    self.imageView.image = image;
                    self.imageView.alpha = 1.f;
                }];
            });
        }];
    });
}

- (CGPoint)centerOfScrollViewContent:(UIScrollView *)scrollView
{
    CGRect frame = self.contentView.bounds;
    CGSize size = scrollView.contentSize;
    
    CGFloat centerX,centerY;
    if (CGRectGetWidth(frame) > size.width) {
        centerX = CGRectGetWidth(frame)/2;
    }else{
        centerX = size.width/2;
    }
    if (CGRectGetHeight(frame) > size.height) {
        centerY = CGRectGetHeight(frame)/2;
    }else{
        centerY = size.height/2;
    }
    return CGPointMake(centerX, centerY);
}

#pragma mark - Actions
- (void)tap:(UITapGestureRecognizer *)gr
{
    if (self.tapAction) {
        self.tapAction(self.asset);
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)gr
{
    if (!self.imageView.image || self.scrollView.isZooming || self.scrollView.isZoomBouncing) {
        return;
    }
    
    CGFloat scale = self.scrollView.zoomScale;
    if (scale != 1) {
        [self.scrollView setZoomScale:1 animated:YES];
    }else{
        [self.scrollView setZoomScale:self.scrollView.maximumZoomScale animated:YES];
    }
}

#pragma mark - Empty
- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView
{
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [indicator setHidesWhenStopped:YES];
    [indicator startAnimating];
    return indicator;
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return _loading;
}

- (void)setLoading:(BOOL)loading
{
    _loading = loading;
    [self.scrollView reloadEmptyDataSet];
}

@end
