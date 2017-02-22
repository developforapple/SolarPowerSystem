//
//  YGYueduShareHelper.h
//  Golf
//
//  Created by bo wang on 16/6/24.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YueduArticleBean;
@class YueduAlbumBean;

typedef void(^YGShareCompletion)(void);

@interface YGYueduShareHelper : NSObject

/*!
 *  @brief 分享文章
 *
 *  @param article    文章
 *  @param content    正文内容。普通文章是用js抓取的正文60字。多图和视频类型时，为Slogan。为nil时，使用Slogan。
 *  @param vc         分享来自的控制器
 */
+ (void)shareArticle:(YueduArticleBean *)article
             content:(NSString *)content
  fromViewController:(UIViewController *)vc;

/*!
 *  @brief 分享专题
 *
 *  @param album   专题
 *  @param content 可以外部传入一个正文内容。为nil时取专题的描述
 *  @param vc
 */
+ (void)shareAlbum:(YueduAlbumBean *)album
           content:(NSString *)content
fromViewController:(UIViewController *)vc;

@end
