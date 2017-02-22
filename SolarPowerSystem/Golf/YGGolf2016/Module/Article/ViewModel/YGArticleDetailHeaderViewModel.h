//
//  YGArticleDetailHeaderViewModel.h
//  Golf
//
//  Created by bo wang on 16/6/13.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "DDViewModel.h"

@interface YGArticleDetailHeaderViewModel : DDViewModel

@property (assign, readonly, nonatomic) BOOL videoHidden;
@property (strong, readonly, nonatomic) NSURL *videoImageURL;
@property (assign, readonly, nonatomic) CGFloat videoHeight;

// 大标题
@property (strong, readonly, nonatomic) NSString *title;
// 左侧子标题。为文章来源。
@property (strong, readonly, nonatomic) NSString *subtitle1;
// 右侧子标题。为发布时间。
@property (strong, readonly, nonatomic) NSString *subtitle2;
// 头部的高度根据标题的行数需要动态调整
@property (assign, readonly, nonatomic) CGFloat headerHeight;

// webView加载的正文内容
@property (strong, readonly, nonatomic) NSString *html;
// 需要在webview加载完成后手动修改
@property (assign, readonly, nonatomic) CGFloat contentHeight;
// 是否有正文
@property (assign, readonly, nonatomic) BOOL hadContent;

// 标签列表
@property (strong, readonly, nonatomic) NSArray<NSString *> *tagList;
// 标签的尺寸
@property (strong, readonly, nonatomic) NSArray<NSValue *> *tagSizes;
// 标签内容的高度
@property (assign, readonly, nonatomic) CGFloat tagHeight;
// 底部标签区域的高度。标签高度+底部间距。有正文时底部间距50无正文时底部间距20
@property (assign, readonly, nonatomic) CGFloat footerHeight;

// 原链接地址
@property (strong, readonly, nonatomic) NSURL *sourceLink;

// 下载区域是否是显示的。现在不需要下载功能，因此总是隐藏。
@property (assign, readonly, nonatomic) BOOL downloadVisible;
// 下载区域的宽度。可见时为 60 不可见时为 15
@property (assign, readonly, nonatomic) CGFloat downloadWidth;

// 估算头部的高度。需要传入头部标题所在的view
- (void)estimateHeaderHeightInContainerView:(UIView *)view;

// 设置网页内容的高度。在网页加载完成后使用js获取。
- (void)setWebContentHeight:(CGFloat)height;

@end
