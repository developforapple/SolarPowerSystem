//
//  YGArticleDetailHeaderViewCtrl.h
//  Golf
//
//  Created by bo wang on 16/6/13.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGBaseViewController.h"

@class YueduArticleBean;

// 文章详情页的内容区域
@interface YGArticleDetailHeaderViewCtrl : YGBaseViewController

// 高度刷新的回调
@property (copy, nonatomic) void (^refreshHeightCallback)(CGFloat height);

// 显示文章
@property (strong, nonatomic) YueduArticleBean *article;

// 分享的内容
- (NSString *)shareContent;

@end
