//
//  YGSearchFeedCell.m
//  Golf
//
//  Created by bo wang on 16/7/27.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGSearchFeedCell.h"

@implementation YGSearchFeedCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.locationLabel.ignoreCommonProperties = YES;
    self.contentLabel.ignoreCommonProperties = YES;
    self.shareContentLabel.ignoreCommonProperties = YES;
    self.locationLabel.layer.opaque = YES;
    self.contentLabel.layer.opaque = YES;
    self.shareContentLabel.layer.opaque = YES;
}

- (UIImageView *)imageViewAtIndex:(NSUInteger)idx
{
    NSUInteger tag = 100 + idx;
    __block UIImageView *view;
    [self.imageViews enumerateObjectsUsingBlock:^(UIImageView *obj, NSUInteger idx, BOOL *stop) {
        if (obj.tag == tag) {
            view = obj;
            *stop = YES;
        }
    }];
    return view;
}

- (void)configureWithEntity:(__kindof YGSearchViewModel *)entity
{
    [super configureWithEntity:entity];
    
    YGSearchFeedViewModel *vm = entity;
    if (![vm isKindOfClass:[YGSearchFeedViewModel class]]) {
        return;
    }
    
    // 基本内容
    [self.userImageView sd_setImageWithURL:vm.userImageURL placeholderImage:[UIImage imageNamed:@"head_image"]];
    self.nicknameLabel.text = vm.nickName;
    self.dateLabel.text = vm.date;
    self.locationLabel.textLayout = vm.locationLayout;
    self.contentLabel.textLayout = vm.contentLayout;
    self.contentHeightConstraint.constant = vm.contentHeight;
    
    ygweakify(self);
    
    UIImage *placeholderImage = [YGSearchBaseCell defaultPlaceholder];
    
    // 额外内容
    switch (vm.type) {
        case YGSearchFeedTypeNormal: {
            // 单图、视频、纯文本情况
            self.imagePandel.hidden = vm.subType==YGSearchFeedSubTypeNormal;
            self.multiImagePanel.hidden = YES;
            self.sharePanel.hidden = YES;
            
            self.imageHeightConstraint.constant = vm.imageHeight;
            self.imageWidthConstraint.constant = vm.imageWidth;
            
            self.singleImageView.contentMode = UIViewContentModeCenter;
            [self.singleImageView sd_setImageWithURL:[vm.imageURLs firstObject] placeholderImage:placeholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                ygstrongify(self);
                if (image) {
                    self.singleImageView.contentMode = UIViewContentModeScaleAspectFill;
                }
            }];
            self.playImageView.hidden = vm.subType!=YGSearchFeedSubTypeVideo;
            
            break;
        }
        case YGSearchFeedTypeMultiImage: {
            
            self.imagePandel.hidden = YES;
            self.multiImagePanel.hidden = NO;
            self.sharePanel.hidden = YES;
            
            //多图情况
            NSUInteger count = vm.imageURLs.count;
            NSUInteger maxCount = self.imageViews.count;
            
            if (count <= maxCount) {
                //图片不足
                for (UIImageView *imageView in self.imageViews) {
                    NSUInteger tag = imageView.tag;
                    NSUInteger idx = tag-100;
                    if (idx < count) {
                        imageView.contentMode = UIViewContentModeCenter;
                        [imageView sd_setImageWithURL:vm.imageURLs[idx] placeholderImage:placeholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                            if (image) {
                                imageView.contentMode = UIViewContentModeScaleAspectFill;
                            }
                        }];
                        imageView.hidden = NO;
                    }else{
                        imageView.hidden = YES;
                    }
                }
                self.imageCountLabel.hidden = YES;
            }else{
                for (NSUInteger idx = 0; idx < maxCount-1; idx++) {
                    UIImageView *imageView = [self imageViewAtIndex:idx];
                    imageView.hidden = NO;
                    imageView.contentMode = UIViewContentModeCenter;
                    [imageView sd_setImageWithURL:vm.imageURLs[idx] placeholderImage:placeholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        if (image) {
                            imageView.contentMode = UIViewContentModeScaleAspectFill;
                        }
                    }];
                }
                UIImageView *lastImageView = [self imageViewAtIndex:maxCount-1];
                lastImageView.hidden = NO;
                lastImageView.image = nil;
                self.imageCountLabel.hidden = NO;
                self.imageCountLabel.text = [NSString stringWithFormat:@"共%lu张",(unsigned long)count];
            }
            break;
        }
        case YGSearchFeedTypeShare: {
            // 分享情况
            self.imagePandel.hidden = YES;
            self.multiImagePanel.hidden = YES;
            self.sharePanel.hidden = NO;
            
            self.shareImageView.image = [UIImage imageNamed:vm.shareImageName];
            self.shareContentLabel.textLayout = vm.shareInfoLayout;
            break;
        }
    }
    if (vm.pointCardVisible) {
        self.sharePanel.hidden = NO;
        
        self.shareImageView.image = [UIImage imageNamed:vm.shareImageName];
        self.shareContentLabel.textLayout = vm.shareInfoLayout;
    }
}

@end
