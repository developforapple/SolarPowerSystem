//
//  SDPhotoBrowser.m
//  photobrowser
//
//  Created by aier on 15-2-6.
//  Copyright (c) 2015年 GSD. All rights reserved.
//

#import "SDPhotoBrowser.h"
#import "UIImageView+WebCache.h"
#import "VIPhotoView.h"
#import "SDPhotoBrowserConfig.h"
#import "CCActionSheet.h"
#import "MyButton.h"

@interface SDPhotoBrowser ()
@property (strong, nonatomic) UIScrollView *scrollView;
@end

@implementation SDPhotoBrowser 
{
    BOOL _hasShowedFistView;
    UILabel *_indexLabel;
    UIView *bgCoverView;
    UIView *bgView;
    UIView *toolBar;
    UIActivityIndicatorView *_indicatorView;
    UILongPressGestureRecognizer *longPress;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        bgCoverView = [[UIView alloc] initWithFrame:self.bounds];
        bgCoverView.backgroundColor = SDPhotoBrowserBackgrounColor;
        [self addSubview:bgCoverView];
        bgCoverView.alpha = 1.0;
    }
    return self;
}


- (void)didMoveToSuperview
{
    [self setupScrollView];
}

- (void)dealloc
{
    [[UIApplication sharedApplication].keyWindow removeObserver:self forKeyPath:@"frame"];
}

- (void)setupToolbars
{
    toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.height-44, Device_Width, 44)];
    toolBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self addSubview:toolBar];
    
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Device_Width, 44)];
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0.0;
    [toolBar addSubview:bgView];
    
    // 1. 序标
    UILabel *indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 7, 80, 30)];
    indexLabel.textAlignment = NSTextAlignmentLeft;
    indexLabel.textColor = [UIColor whiteColor];
    indexLabel.font = [UIFont systemFontOfSize:20];
    indexLabel.backgroundColor = [UIColor clearColor];
    indexLabel.clipsToBounds = YES;
    indexLabel.text = [NSString stringWithFormat:@"%d/%ld",self.currentImageIndex + 1, (long)self.imageCount];
    _indexLabel = indexLabel;
    [toolBar addSubview:indexLabel];
    
    if (_isEdit) {
        // 2.删除按钮
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
        deleteButton.frame = CGRectMake(Device_Width-65, 7, 50, 30);
        [deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [deleteButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
        [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        deleteButton.backgroundColor = [UIColor clearColor];
        [deleteButton addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
        [toolBar addSubview:deleteButton];
    }else if(_showCollectionButton){
        //图集按钮
        UIButton *btnFoursquare = [UIButton buttonWithType:UIButtonTypeCustom];
        btnFoursquare.frame = CGRectMake(Device_Width - 55, 0, 44, 44);
        [btnFoursquare setImage:[UIImage imageNamed:@"ic_foursquare"] forState:(UIControlStateNormal)];//ic_foursquare
        [btnFoursquare addTarget:self action:@selector(showCollectionView) forControlEvents:(UIControlEventTouchUpInside)];
        [toolBar addSubview:btnFoursquare];
    }
    
}

- (void)showCollectionView{
    if (_blockCollectionView) {
        _blockCollectionView(nil);
    }
}

//在界面中间下边加多一个按钮
- (void)initActionButton{
    MyButton *btn = [MyButton autoLayoutView];
    btn.layer.cornerRadius = 3;
    btn.layer.borderWidth = .5f;
    btn.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:.4f].CGColor;
    btn.clipsToBounds = YES;
    btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    btn.highlightedColor = [UIColor colorWithHexString:@"#CCCCCC"];
    [btn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [btn addTarget:self action:@selector(btnAction) forControlEvents:(UIControlEventTouchUpInside)];
    [btn setTitle:self.actionTitle forState:(UIControlStateNormal)];
    [self addSubview:btn];
    [btn pinToSuperviewEdges:(JRTViewPinBottomEdge) inset:8];
    [btn centerInContainerOnAxis:(NSLayoutAttributeCenterX)];
    [btn constrainToSize:CGSizeMake(90, 30)];
}

- (void)btnAction{
    if (_blockAction) {
        _blockAction(nil);
    }
}

// 删除图片
- (void)deleteImage:(UIButton*)sender{
    
//    NSUInteger imageCount = [self.collectionView numberOfItemsInSection:0];
    if (self.currentImageIndex < 0 || self.currentImageIndex >= self.scrollView.subviews.count) {
        return;
    }
    sender.enabled = NO;
    
    if (self.deleteTwoConfirm) {
        CCActionSheet *sheet = [[CCActionSheet alloc] initWithTitle:@"确认删除？"];
        [sheet addDestructiveButtonWithTitle:@"删除" block:^{
            if (_blockReturn) {
                BlockReturn block = ^(id data){
                    
                    
                    
                    
                    VIPhotoView *imageView = _scrollView.subviews[_currentImageIndex];
                    if (self.imageCount == 1) {
                        [UIView animateWithDuration:0.3 animations:^{
                            imageView.yg_y = -imageView.height;
                        } completion:^(BOOL finished) {
                            [imageView removeFromSuperview];
                            if (_currentImageIndex == self.imageCount-1&&self.imageCount>1) {  // 当前在最后一张
                                _currentImageIndex --;
                            }
                            _imageCount --;
                            _indexLabel.text = [NSString stringWithFormat:@"%d/%d", _currentImageIndex + 1, (int)self.imageCount];
                            [UIView animateWithDuration:SDPhotoBrowserHideImageAnimationDuration animations:^{
                                bgCoverView.alpha = 0.0;
                                bgView.alpha = 0.0;
                            } completion:^(BOOL finished) {
                                [self removeFromSuperview];
                            }];
                        }];
                    }else{
                        VIPhotoView *nextImageView = (_currentImageIndex == self.imageCount-1&&self.imageCount>1) ? _scrollView.subviews[_currentImageIndex-1] : _scrollView.subviews[_currentImageIndex+1];
                        
                        [self setupImageOfImageViewForIndex:nextImageView.tag];
                        
                        CGPoint center = imageView.center;
                        [UIView animateWithDuration:0.3 animations:^{
                            imageView.yg_y = -imageView.height;
                        } completion:^(BOOL finished) {
                            [imageView removeFromSuperview];
                            [UIView animateWithDuration:0.3 animations:^{
                                nextImageView.center = center;
                            } completion:^(BOOL finished) {
                                sender.enabled = YES;
                                if (_currentImageIndex == self.imageCount-1&&self.imageCount>1) {  // 当前在最后一张
                                    _currentImageIndex --;
                                }
                                _imageCount --;
                                _indexLabel.text = [NSString stringWithFormat:@"%d/%d", _currentImageIndex + 1, (int)self.imageCount];
                                [self layoutSubviews];
                            }];
                        }];
                    }
                };
                
                _blockReturn(@{@"index":@(_currentImageIndex),@"block":block});
            }
            
        }];
        [sheet addCancelButtonWithTitle:@"取消"];
        [sheet showInView:self];
    }else{
        VIPhotoView *imageView = _scrollView.subviews[_currentImageIndex];
        if (self.imageCount == 1) {
            [UIView animateWithDuration:0.3 animations:^{
                imageView.yg_y = -imageView.height;
            } completion:^(BOOL finished) {
                [imageView removeFromSuperview];
                if (_blockReturn) {
                    _blockReturn(@(_currentImageIndex));
                }
                if (_blockDeleteAction) {
                    _blockDeleteAction(@(_currentImageIndex));
                }
                
                if (_currentImageIndex == self.imageCount-1&&self.imageCount>1) {  // 当前在最后一张
                    _currentImageIndex --;
                }
                _imageCount --;
                _indexLabel.text = [NSString stringWithFormat:@"%d/%d", _currentImageIndex + 1, (int)self.imageCount];
                [UIView animateWithDuration:SDPhotoBrowserHideImageAnimationDuration animations:^{
                    bgCoverView.alpha = 0.0;
                    bgView.alpha = 0.0;
                } completion:^(BOOL finished) {
                    [self removeFromSuperview];
                }];
            }];
        }else{
            VIPhotoView *nextImageView = (_currentImageIndex == self.imageCount-1&&self.imageCount>1) ? _scrollView.subviews[_currentImageIndex-1] : _scrollView.subviews[_currentImageIndex+1];
            
            [self setupImageOfImageViewForIndex:nextImageView.tag];
            
            CGPoint center = imageView.center;
            [UIView animateWithDuration:0.3 animations:^{
                imageView.yg_y = -imageView.height;
            } completion:^(BOOL finished) {
                [imageView removeFromSuperview];
                [UIView animateWithDuration:0.3 animations:^{
                    nextImageView.center = center;
                } completion:^(BOOL finished) {
                    sender.enabled = YES;
                    if (_blockReturn) {
                        _blockReturn(@(_currentImageIndex));
                    }
                    if (_blockDeleteAction) {
                        _blockDeleteAction(@(_currentImageIndex));
                    }
                    if (_currentImageIndex == self.imageCount-1&&self.imageCount>1) {  // 当前在最后一张
                        _currentImageIndex --;
                    }
                    _imageCount --;
                    _indexLabel.text = [NSString stringWithFormat:@"%d/%d", _currentImageIndex + 1, (int)self.imageCount];
                    [self layoutSubviews];
                }];
            }];
        }
    }
}


- (void)saveImage
{
    int index = _scrollView.contentOffset.x / _scrollView.bounds.size.width;
    VIPhotoView *viphotoView = _scrollView.subviews[index];
    
    UIImageWriteToSavedPhotosAlbum(viphotoView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    indicator.center = self.center;
    _indicatorView = indicator;
    [[UIApplication sharedApplication].keyWindow addSubview:indicator];
    [indicator startAnimating];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    [_indicatorView removeFromSuperview];
    if (error) {
        [SVProgressHUD showErrorWithStatus:@"保存失败"];
    } else {
        [SVProgressHUD showSuccessWithStatus:@"保存成功"];
    }
}

- (void)setupScrollView
{
    if (!_isCollection && CGRectGetWidth(self.initRt) > 0) {
        bgCoverView.alpha = 1.0;
        bgView.alpha = 0.5;
    }
    
    if (!longPress) {
        longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(popActionSheet:)];
        [self addGestureRecognizer:longPress];
    }
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    [self addSubview:_scrollView];
    
    ygweakify(self);
    for (int i = 0; i < self.imageCount; i++) {
        VIPhotoView *viphotoView = [[VIPhotoView alloc] initWithFrame:CGRectMake(i*Device_Width, 0, Device_Width, Device_Height) andImage:[self placeholderImageForIndex:i]];
        viphotoView.tag = i;
        viphotoView.blockSingleTap = ^(id obj){
            if (obj) {
                ygstrongify(self);
                VIPhotoView *vi = (VIPhotoView*)obj;
                [self photoClick:vi];
            }
        };

        [_scrollView addSubview:viphotoView];
    }
    
    [self setupImageOfImageViewForIndex:self.currentImageIndex];
    
}

- (void)popActionSheet:(UILongPressGestureRecognizer*)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CCActionSheet *sheet = [[CCActionSheet alloc] initWithTitle:nil];
        [sheet addDestructiveButtonWithTitle:@"保存到手机" block:^{
            [self saveImage];
        }];
        [sheet addCancelButtonWithTitle:@"取消" block:nil];
        [sheet showInView:self];
    }
}

// 加载图片
- (void)setupImageOfImageViewForIndex:(NSInteger)index
{
    if (index < _scrollView.subviews.count) {
        VIPhotoView *viphotoView = _scrollView.subviews[index];

        if (viphotoView.hasLoadedImage) return;
        
        if (self.highQuality) {
            NSURL *highQualityUrl = [self highQualityImageURLForIndex:index];
            if (highQualityUrl ) {
                [viphotoView setImageWithURL:highQualityUrl placeholderImage:[self placeholderImageForIndex:index]];
                viphotoView.hasLoadedImage = YES;
            } else {
                // 异步获取高清图片
                ygweakify(self);
                BOOL hadImage = [self highQualityImageForIndex:index completion:^(UIImage *image) {
                    ygstrongify(self);
                    VIPhotoView *viphotoView2 = self.scrollView.subviews[index];
                    viphotoView2.image = image;
                }];
                if (!hadImage) {
                    viphotoView.image = [self placeholderImageForIndex:index];
                }
            }
        }else{
            viphotoView.image = [self placeholderImageForIndex:index];
        }
    }
}

- (void)photoClick:(VIPhotoView *)viphotoView
{
    _scrollView.hidden = YES;
    toolBar.hidden = YES;
    
    if (self.noCloseAnimation) {
        [UIView animateWithDuration:SDPhotoBrowserHideImageAnimationDuration animations:^{
            bgCoverView.alpha = 0.0;
            bgView.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (_blockReturn) {
                _blockReturn (nil);
            }
            [self removeFromSuperview];
            NSArray *subviews = [GolfAppDelegate shareAppDelegate].window.subviews;
            for (UIView *view in subviews) {
                if ([view isKindOfClass:[SDPhotoBrowser class]]) {
                    [view removeFromSuperview];
                    break;
                }
            }
        }];
    }else{
        
        NSInteger currentIndex = viphotoView.tag;
        
        UIButton *buttonItemView = self.sourceImagesContainerView.subviews[currentIndex];
        CGRect targetTemp = [buttonItemView convertRect:buttonItemView.imageView.frame toView:[GolfAppDelegate shareAppDelegate].window];
        
        UIImageView *tempView = [[UIImageView alloc] init];
        tempView.contentMode = UIViewContentModeScaleAspectFill;
        tempView.clipsToBounds = YES;
        tempView.image = viphotoView.image;
        CGFloat h = (self.bounds.size.width / viphotoView.image.size.width) * viphotoView.image.size.height;
        
        if (!viphotoView.image) {
            h = self.bounds.size.height;
        }
        
        tempView.bounds = CGRectMake(0, 0, self.bounds.size.width, h);
        tempView.center = self.center;
        
        [self addSubview:tempView];
        
        CGRect backRt = CGRectZero;
        if (_backRtBlock) {
            backRt = _backRtBlock (self.currentImageIndex);
        }
        
        [UIView animateWithDuration:SDPhotoBrowserHideImageAnimationDuration animations:^{
            tempView.frame = backRt.size.width>0 ? backRt : (self.initRt.size.width>0 ? self.initRt : targetTemp);
            bgCoverView.alpha = 0.0;
            bgView.alpha = 0.0;
        } completion:^(BOOL finished) {
            tempView.hidden = YES;
            if (_blockReturn) {
                _blockReturn (nil);
            }
            [self removeFromSuperview];
            NSArray *subviews = [GolfAppDelegate shareAppDelegate].window.subviews;
            for (UIView *view in subviews) {
                if ([view isKindOfClass:[SDPhotoBrowser class]]) {
                    [view removeFromSuperview];
                    break;
                }
            }
        }];
    }
    
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    bgCoverView.frame = rect;
    rect.size.width += SDPhotoBrowserImageViewMargin * 2;
    
    _scrollView.bounds = rect;
    _scrollView.center = self.center;
    
    CGFloat y = 0;
    CGFloat w = _scrollView.frame.size.width - SDPhotoBrowserImageViewMargin * 2;
    CGFloat h = _scrollView.frame.size.height;
    
    [_scrollView.subviews enumerateObjectsUsingBlock:^(VIPhotoView *obj, NSUInteger idx, BOOL *stop) {
        CGFloat x = SDPhotoBrowserImageViewMargin + idx * (SDPhotoBrowserImageViewMargin * 2 + w);
        obj.frame = CGRectMake(x, y, w, h);
        obj.tag = idx;
    }];
    
    _scrollView.contentSize = CGSizeMake(_scrollView.subviews.count * _scrollView.frame.size.width, 0);
    _scrollView.contentOffset = CGPointMake(self.currentImageIndex * _scrollView.frame.size.width, 0);
    
    if (!_hasShowedFistView) {
        [self showFirstImage];
    }
}

- (void)show
{
    NSArray *subviews = [GolfAppDelegate shareAppDelegate].window.subviews;
    for (UIView *view in subviews) {
        if ([view isKindOfClass:[SDPhotoBrowser class]]) {
            [view removeFromSuperview];
            break;
        }
    }
    
    UIWindow *window = [GolfAppDelegate shareAppDelegate].window;
    self.frame = window.bounds;
    [window addObserver:self forKeyPath:@"frame" options:0 context:nil];
    [window addSubview:self];
    [UIView animateWithDuration:0.5 animations:^{
        bgCoverView.alpha = 1.0;
        bgView.alpha = 0.5;
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(UIView *)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"]) {
        self.frame = object.bounds;
    }
}

- (void)showFirstImage
{
    if (self.currentImageIndex < self.sourceImagesContainerView.subviews.count) {
        
        UIButton *buttonItemView = self.sourceImagesContainerView.subviews[self.currentImageIndex];
        
        UIImageView *tempView = [[UIImageView alloc] init];
        tempView.clipsToBounds = YES;
        tempView.contentMode = UIViewContentModeScaleAspectFit;
        tempView.image = [self placeholderImageForIndex:self.currentImageIndex];
        [self addSubview:tempView];
        
        VIPhotoView *viphotoView = _scrollView.subviews[self.currentImageIndex];
        CGRect targetTemp = viphotoView.imageView.frame;
        CGRect converRect = [buttonItemView convertRect:buttonItemView.imageView.frame toView:self];
        tempView.frame = self.initRt.size.width>0 ? self.initRt : converRect;
        
        _scrollView.hidden = YES;
        
        [UIView animateWithDuration:SDPhotoBrowserShowImageAnimationDuration animations:^{
            tempView.frame = targetTemp;
            tempView.center = [GolfAppDelegate shareAppDelegate].window.center;
        } completion:^(BOOL finished) {
            _hasShowedFistView = YES;
            [tempView removeFromSuperview];
            _scrollView.hidden = NO;
            if (self.imageCount > 1 || self.isEdit == YES) { //一张图片就不显示页码了。
                [self setupToolbars];
            }
            if (_blockAction) {
                [self initActionButton];
            }
        }];
    }
}

- (UIImage *)placeholderImageForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:placeholderImageForIndex:)]) {
        return [self.delegate photoBrowser:self placeholderImageForIndex:index];
    }
    return nil;
}

- (NSURL *)highQualityImageURLForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:highQualityImageURLForIndex:)]) {
        return [self.delegate photoBrowser:self highQualityImageURLForIndex:index];
    }
    return nil;
}

- (BOOL)highQualityImageForIndex:(NSInteger)index completion:(void(^)(UIImage *))completion
{
    if (completion && [self.delegate respondsToSelector:@selector(photoBrowser:requestHighQualityImageForIndex:completion:)]) {
        [self.delegate photoBrowser:self requestHighQualityImageForIndex:index completion:completion];
        return YES;
    }
    return NO;
}

#pragma mark - scrollview代理方法

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int index = (scrollView.contentOffset.x + _scrollView.bounds.size.width * 0.5) / _scrollView.bounds.size.width;
    
    if (self.currentImageIndex != index) {
        self.currentImageIndex = index;
        
        // 有过缩放的图片在拖动一定距离后清除缩放
        CGFloat margin = 150;
        CGFloat x = scrollView.contentOffset.x;
        if ((x - index * self.bounds.size.width) > margin || (x - index * self.bounds.size.width) < - margin) {
            if (index<_scrollView.subviews.count) {
                VIPhotoView *viphotoView = _scrollView.subviews[index];
                [UIView animateWithDuration:0.5 animations:^{
                    viphotoView.imageView.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                    //[imageView eliminateScale];
                }];
            }
        }
        
        _indexLabel.text = [NSString stringWithFormat:@"%d/%ld", index + 1, (long)self.imageCount];
        [self setupImageOfImageViewForIndex:index];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self setSubScrollViewScrollenable:NO];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self setSubScrollViewScrollenable:YES];
}

- (void)setSubScrollViewScrollenable:(BOOL)enable{
    for (UIView *view in _scrollView.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView*)view).scrollEnabled=enable;
        }
    }
}

@end
