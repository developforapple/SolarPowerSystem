//
//  YGYueduCommon.h
//  Golf
//
//  Created by bo wang on 16/6/1.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#ifndef YGYueduCommon_h
#define YGYueduCommon_h

#import "YGThriftInclude.h"
#import "YGYueduStatistics.h"

typedef NS_ENUM(NSUInteger, YGYueduCellType) {
    YGYueduCellTypeNormal = ArticleType_NORMAL,     //常规文本cell
    YGYueduCellTypeImage = ArticleType_PICTURE,     //多图cell
    YGYueduCellTypeVideo = ArticleType_VIDEO,       //视频cell
    
    YGYueduCellTypeVideo2 = 100,                    //视频cell的简单样式
};

typedef NS_ENUM(NSUInteger, YGYueduListShowType) {
    YGYueduListShowTypeArticle = DefaultShowType_ARTICLE, //文章列表
    YGYueduListShowTypeAlbum = DefaultShowType_ALBUM,     //专题列表
};

// 成功收藏了某文章
FOUNDATION_EXTERN NSString *const kYGYueduDidLikedArticleNotification;
// 成功取消收藏了某文章
FOUNDATION_EXTERN NSString *const kYGYueduDidDislikedArticleNotification;
// 成功收藏了某专题
FOUNDATION_EXTERN NSString *const kYGYueduDidLikedAlbumNotification;
// 成功取消收藏了某专题
FOUNDATION_EXTERN NSString *const kYGYueduDidDislikedAlbumNotification;

#endif /* YGYueduCommon_h */
