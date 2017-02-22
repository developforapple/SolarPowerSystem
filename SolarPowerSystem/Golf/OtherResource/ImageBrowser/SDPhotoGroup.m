//
//  SDPhotoGroup.m
//  SDPhotoBrowser
//
//  Created by 黄希望 on 15/7/20.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "SDPhotoGroup.h"
#import "SDPhotoItem.h"
#import "UIButton+WebCache.h"
#import "SDPhotoBrowser.h"

#import "DDAsset.h"

#define SDPhotoGroupImageMargin 8

@interface SDPhotoGroup () <SDPhotoBrowserDelegate>

@end

@implementation SDPhotoGroup 

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"");
}

- (void)setPhotoItemArray:(NSMutableArray *)photoItemArray
{
    _photoItemArray = photoItemArray;
    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:photoItemArray];
    if (_isAddPic) {
        SDPhotoItem *item = [[SDPhotoItem alloc] init];
        UIImage *addImg = [UIImage imageNamed:@"ic_add_pic"];
        item.thumbnail_pic = addImg;
        [tempArr addObject:item];
    }
    
    [tempArr enumerateObjectsUsingBlock:^(SDPhotoItem *obj, NSUInteger idx, BOOL *stop) {
        UIButton *btn = [[UIButton alloc] init];
        btn.layer.cornerRadius = 1.5;
        btn.clipsToBounds = YES;
        btn.backgroundColor = [Utilities R:240 G:240 B:240];
        
        
        if (obj.thumbnail_pic) {
            if ([obj.thumbnail_pic isKindOfClass:[NSString class]]) {
                NSString *pic_str = (NSString *)obj.thumbnail_pic;
                [btn sd_setImageWithURL:[NSURL URLWithString:pic_str] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"pic_zhanwei"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    btn.imageView.contentMode = UIViewContentModeScaleToFill;
                }];
            }else if ([obj.thumbnail_pic isKindOfClass:[UIImage class]]){
                [btn setImage:obj.thumbnail_pic forState:UIControlStateNormal];
            }else if ([obj.thumbnail_pic isKindOfClass:[DDAsset class]]){
                DDAsset *asset = obj.thumbnail_pic;
                
                if (asset.URLAsset) { // 网络图片
                    [btn sd_setImageWithURL:asset.URLAsset forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"pic_zhanwei"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        btn.imageView.contentMode = UIViewContentModeScaleToFill;
                    }];
                    
                } else { // 本地选择的图片
                    [asset thumbnailImage:^(UIImage *image) {
                        [btn setImage:image forState:UIControlStateNormal];
                    }];
                }
                
            }
        }
        btn.tag = idx;
        btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }];
}

- (void)setImageSize:(CGFloat)imageSize{
    _imageSize = imageSize;
    if (Device_Width == 375.) {
        _imageSize *= 375./320;
    }else if (Device_Width == 414.){
        _imageSize *= 414./320;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    long imageCount = self.subviews.count;
    NSInteger perRowImageCount = self.rowCount>0 ? self.rowCount : ((imageCount == 4) ? 2 : 4);
    
    CGFloat perRowImageCountF = (CGFloat)perRowImageCount;
    int totalRowCount = ceil(imageCount / perRowImageCountF);
    
    CGFloat w = 0,h=0;
    if (self.imageSize>0&&self.rowCount>0&&self.imageMargin) {
        w = self.imageSize;
        h = self.imageSize;
    }else{
        w = !_isCollection && self.initRt.size.width > 0 ? self.initRt.size.width : (Device_Width-SDPhotoGroupImageMargin*5)/4.;
        h = !_isCollection && self.initRt.size.width > 0 ? self.initRt.size.height : w;
        self.imageMargin = SDPhotoGroupImageMargin;
    }
    
    [self.subviews enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL *stop) {
        if (idx == self.photoItemArray.count) {
            btn.hidden = self.photoItemArray.count >= 9 ? YES : NO;
        }
        long rowIndex = idx / perRowImageCount;
        NSInteger columnIndex = idx % perRowImageCount;
        CGFloat x = _isCollection ? columnIndex * (w + self.imageMargin) : 0;
        CGFloat y = _isCollection ? rowIndex * (h + self.imageMargin) : 0;
        btn.frame = CGRectMake(x, y, w, h);
        btn.tag = idx;
    }];
    
    CGRect rt = self.frame;
    if (_isCollection) {
        if (rt.size.width == 0) {
            rt.origin.x = self.imageMargin;
            rt.origin.y = self.imageMargin;
            rt.size.width = Device_Width-self.imageMargin*2;
        }
        rt.size.height = totalRowCount * (self.imageMargin + h);
    }else{
        if (self.initRt.size.width>0) {
            rt = self.initRt;
        }else{
            self.center = self.superview.center;
            rt.size.width = w;
            rt.size.height = h;
        }
    }
    self.frame = rt;
}

- (void)buttonClick:(UIButton *)button
{
    self.currentIndex = button.tag;
    if (self.isAddPic && self.currentIndex == self.photoItemArray.count) {
        if (self.addBlock) {
            self.addBlock (nil);
        }
    }else{
        [self click:(int)self.currentIndex delay:0];
    }
}

- (void)click:(int)index delay:(float)delay{
    if (_hideKeyboard) {
        _hideKeyboard();
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ygweakify(self);
        SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
        browser.sourceImagesContainerView = self; // 原图的父控件
        browser.imageCount = self.photoItemArray.count; // 图片总数
        browser.currentImageIndex = index;
        browser.delegate = self;
        browser.isEdit = self.isEdit;
        browser.initRt = self.initRt;
        browser.highQuality = self.highQuality;
        browser.isCollection = self.isCollection;
        browser.noCloseAnimation = self.noCloseAnimation;
        browser.showCollectionButton = self.showCollectionButton;
        browser.blockCollectionView = self.blockCollectionView;
        browser.backRtBlock = self.backRtBlock;
        browser.blockAction = self.blockAction;
        browser.actionTitle = self.actionTitle;
        browser.deleteTwoConfirm = self.deleteTwoConfirm;
        browser.blockDeleteAction = self.blockDeleteAction;
        browser.blockReturn = ^(id obj){
            ygstrongify(self);
            if (self.isEdit && obj) {
                if (self.deleteTwoConfirm) {
                    BlockReturn b = ^(id data){
                        NSInteger index = [obj[@"index"] integerValue];
                        if (self.photoItemArray.count > 0 && index < self.photoItemArray.count) {
                            [self.photoItemArray removeObjectAtIndex:index];
                        }
                        if (self.subviews.count > 0 && index < self.subviews.count) {
                            UIButton *btn = nil;
                            if (index == 0) {
                                btn = [self.subviews firstObject];
                            }else{
                                btn = self.subviews[index];
                            }
                            if (btn) {
                                [btn removeFromSuperview];
                            }
                        }
                        if (self.imagesBlock) {
                            NSMutableArray *tpImageList = [NSMutableArray array];
                            [self.photoItemArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                SDPhotoItem *sdpt = (SDPhotoItem*)obj;
                                [tpImageList addObject:sdpt.thumbnail_pic];
                            }];
                            self.imagesBlock (tpImageList);
                        }
                    };
                    if (self.blockReturn) {
                        NSMutableDictionary *nd = [[NSMutableDictionary alloc] initWithDictionary:obj];
                        [nd setObject:b forKey:@"removeBlock"];
                        self.blockReturn(nd);
                    }
                    
                }else{
                    NSInteger index = [obj integerValue];
                    if (self.photoItemArray.count > 0 && index < self.photoItemArray.count) {
                        [self.photoItemArray removeObjectAtIndex:index];
                    }
                    if (self.subviews.count > 0 && index < self.subviews.count) {
                        UIButton *btn = nil;
                        if (index == 0) {
                            btn = [self.subviews firstObject];
                        }else{
                            btn = self.subviews[index];
                        }
                        if (btn) {
                            [btn removeFromSuperview];
                        }
                    }
                    if (self.blockReturn) {
                        self.blockReturn (obj);
                    }
                    if (self.imagesBlock) {
                        NSMutableArray *tpImageList = [NSMutableArray array];
                        [self.photoItemArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            SDPhotoItem *sdpt = (SDPhotoItem*)obj;
                            [tpImageList addObject:sdpt.thumbnail_pic];
                        }];
                        self.imagesBlock (tpImageList);
                    }
                }
            }else{
                if (self.blockReturn) {
                    self.blockReturn (obj);
                }
            }
        };
        [browser show];
    });
}

#pragma mark - photobrowser代理方法

// 返回临时占位图片（即原来的小图）
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    return [self.subviews[index] currentImage];
}


// 返回高质量图片的url
- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    id thumbnailPic = [self.photoItemArray[index] thumbnail_pic];
    if ([thumbnailPic isKindOfClass:[NSString class]]) {
        NSString *urlStr = [Utilities formatImageUrlWithStr:thumbnailPic withFormatStr:@"l"];
        return [NSURL URLWithString:urlStr];
    }
    return nil;
}

- (void)photoBrowser:(SDPhotoBrowser *)browser requestHighQualityImageForIndex:(NSInteger)index completion:(void (^)(UIImage *))completion
{
    id thumbnailPic = [self.photoItemArray[index] thumbnail_pic];
    if (completion && [thumbnailPic isKindOfClass:[DDAsset class]]) {
        DDAsset *asset = thumbnailPic;
        [asset previewImage:completion];
    }
}

@end
