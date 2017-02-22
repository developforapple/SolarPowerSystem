//
//  YGArticleViewModel.h
//  Golf
//
//  Created by bo wang on 16/6/16.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "DDViewModel.h"

@interface YGArticleViewModel : DDViewModel <NSCoding,NSCopying>
@property (strong, readonly, nonatomic) NSString *title;        //标题内容
@property (strong, readonly, nonatomic) NSString *sourceName;   //来源
@property (strong, readonly, nonatomic) NSString *dateString;   //时间
@property (strong, readonly, nonatomic) NSString *categoryName; //分类
@end

@interface YGArticleNormalViewModel : YGArticleViewModel <NSCoding,NSCopying>
@property (strong, readonly, nonatomic) NSURL *imageURL;        //图片
@end

@interface YGArticleImagesViewModel : YGArticleViewModel <NSCoding,NSCopying>
@property (strong, readonly, nonatomic) NSArray<NSURL *> *imageURLs;//多个图片
@end

@interface YGArticleVideoViewModel : YGArticleViewModel <NSCoding,NSCopying>
@property (strong, readonly, nonatomic) NSURL *imageURL;        //图片
@end

@interface YGArticleVideo2ViewModel : YGArticleViewModel <NSCoding,NSCopying>
@property (strong, readonly, nonatomic) NSURL *imageURL;        //图片
@property (strong, readonly, nonatomic) NSString *videoLengthString;//视频时长
@property (assign, nonatomic) BOOL isInAlbumDetail;   //是否在专题详情页

@end