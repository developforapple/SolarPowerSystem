//
//  YGYueduImageDetailCell.m
//  Golf
//
//  Created by bo wang on 16/6/12.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGYueduImageDetailCell.h"
#import "yueduService.h"
#import "CCActionSheet.h"
#import "YYWebImage.h"


@interface YGYueduImageDetailCell () <UIScrollViewDelegate>

@end

@implementation YGYueduImageDetailCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self->_doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
    self->_doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [self.imageZoomScrollView addGestureRecognizer:self.doubleTapGestureRecognizer];
    
    self->_longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self.imageZoomScrollView addGestureRecognizer:self.longPressGestureRecognizer];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self adjustFrames];
}

- (YYAnimatedImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[YYAnimatedImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.imageZoomScrollView addSubview:_imageView];
    }
    return _imageView;
}

- (void)configureWithImage:(YueduArticleImageBean *)imageBean
{
    _imageBean = imageBean;
    
    [self resetUI];
    
    [self.loadingIndicator startAnimating];
    
    ygweakify(self);
    self.imageView.alpha = 0.f;
    [self.imageView yy_setImageWithURL:[NSURL URLWithString:imageBean.name] placeholder:nil options:YYWebImageOptionProgressiveBlur|YYWebImageOptionAllowBackgroundTask completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
        ygstrongify(self);
        [UIView animateWithDuration:.2f animations:^{
            self.imageView.alpha = 1.f;
        }];
        [self.loadingIndicator stopAnimating];
        [self adjustFrames];
    }];
}

- (void)adjustFrames
{
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
    self.imageZoomScrollView.contentSize = contentSize;
    self.imageZoomScrollView.contentOffset = offset;
    self.imageZoomScrollView.minimumZoomScale = minZoomScale;
    self.imageZoomScrollView.maximumZoomScale = maxZoomScale;
    self.imageZoomScrollView.zoomScale = zoomScale;
}

- (void)resetUI
{
    self.imageZoomScrollView.zoomScale = 1.f;
    self.imageZoomScrollView.minimumZoomScale = .6f;
    self.imageZoomScrollView.maximumZoomScale = 2.f;
    self.imageZoomScrollView.contentSize = self.contentView.bounds.size;
    self.imageZoomScrollView.contentOffset = CGPointZero;
    self.imageView.frame = self.contentView.bounds;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
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

- (void)doubleTapAction:(UITapGestureRecognizer *)gr
{
    if (!self.imageView.image || self.imageZoomScrollView.isZooming || self.imageZoomScrollView.isZoomBouncing) {
        return;
    }
    
    CGFloat scale = self.imageZoomScrollView.zoomScale;
    if (scale != 1) {
        [self.imageZoomScrollView setZoomScale:1 animated:YES];
    }else{
        [self.imageZoomScrollView setZoomScale:self.imageZoomScrollView.maximumZoomScale animated:YES];
    }
}

- (void)longPressAction:(UILongPressGestureRecognizer *)gr
{
    if (!self.imageView.image || gr.state != UIGestureRecognizerStateBegan) return;
    
    CCActionSheet *sheet = [[CCActionSheet alloc] initWithTitle:nil];
    [sheet addDestructiveButtonWithTitle:@"保存到手机" block:^{
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
        [SVProgressHUD show];
        [self.imageView.image yy_saveToAlbumWithCompletionBlock:^(NSURL * _Nullable assetURL, NSError * _Nullable error) {
            [SVProgressHUD showImage:[UIImage imageNamed:@"icon_share_success"] status:@"保存成功"];
        }];
    }];
    [sheet addCancelButtonWithTitle:@"取消"];
    [sheet showInView:self];
}

#pragma mark - 
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    self.imageView.center = [self centerOfScrollViewContent:scrollView];
}

@end

NSString *const kYGYueduImageDetailCell = @"YGYueduImageDetailCell";
