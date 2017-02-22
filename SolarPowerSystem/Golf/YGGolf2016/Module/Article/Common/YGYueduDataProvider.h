//
//  YGArticlesProvider.h
//  Golf
//
//  Created by wwwbbat on 16/5/27.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGYueduCommon.h"
#import "YGThriftInclude.h"

typedef NS_ENUM(NSUInteger, YGYueduSearchType) {
    YGYueduSearchTypeAll,       //搜索全部
    YGYueduSearchTypeArticle,   //仅搜索文章
    YGYueduSearchTypeAlbum,     //仅搜索主题
};

// 为悦读功能提供数据源。“并不是所有的数据都是来自这里”
@interface YGYueduDataProvider : NSObject

// 设置缓存失效时间隔。默认为 30*60
+ (void)setupCacheExpiredInterval:(NSTimeInterval)interval;

#pragma mark - Column
// 某个栏目下的内容,包括文章或专题。将会同步读取缓存。
- (instancetype)initWithColumn:(YueduColumnBean *)columnBean;
// 某个专题
- (instancetype)initWithAlbum:(NSNumber *)albumId;
// 创建一个搜索
- (instancetype)initWithSearchType:(YGYueduSearchType)searchType;
// 某个文章相关的数据。包括文章详情和文章相关文章列表
- (instancetype)initWithArticle:(NSNumber *)articleId;
// 我的悦读收藏文章
- (instancetype)initForMyLikedArticle;
// 我的悦读收藏专题
- (instancetype)initForMyLikedAlbum;
// 需要使用特定的方法初始化
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

#pragma mark - Configure
// 栏目
@property (strong, readonly, nonatomic) YueduColumnBean *columnBean;
// 内容分类
@property (strong, readonly, nonatomic) YueduCategoryBean *categoryBean;
// 专题
@property (strong, readonly, nonatomic) YueduAlbumBean *albumBean;
// 单个文章
@property (strong, readonly, nonatomic) YueduArticleBean *articleBean;
// 搜索的关键词
@property (strong, readonly, nonatomic) NSString *keywords;
// 搜索方式
@property (assign, readonly, nonatomic) YGYueduSearchType searchType;
// 关键词搜索时当前的页数。
@property (assign, readonly, nonatomic) NSUInteger pageNo;
// 每次请求数据时的数据量大小。默认20
@property (assign, nonatomic) NSUInteger pageSize;

// 是否为简单模式。在主列表是为NO，其他地方需要设置为YES。
// 需要在获取数据前就进行设置
// 简单模式下 将会生成不同的viewmodel 和cellType
@property (assign, nonatomic) BOOL isSimpleMode;

#pragma mark - Data
// 文章列表
@property (strong, readonly, nonatomic) YueduArticleList *articleList;
// 文章数量
@property (assign, readonly, nonatomic) NSUInteger articleCount;
// 专题列表
@property (strong, readonly, nonatomic) YueduAlbumList *albumList;
// 专题数量
@property (assign, readonly, nonatomic) NSUInteger albumCount;
// 是否有更多的数据。
@property (assign, readonly, nonatomic) BOOL noMoreData;
// 当前数据是否是缓存的旧数据
@property (assign, readonly, nonatomic) BOOL isCacheData;

// 根据索引获取文章
- (YueduArticleBean *)articleAtIndex:(NSUInteger)index;
// 根据索引获取专题
- (YueduAlbumBean *)albumAtIndex:(NSUInteger)index;
// 移除一个文章。返回这个文章所处的index。文章不在列表时返回 NSNotFound。不会触发updateCallback
- (NSUInteger)removeArticle:(NSNumber *)articleId;
// 插入一个文章。返回是否成功。index超出当前大小时返回NO。不会触发updateCallback
- (BOOL)insertArticle:(YueduArticleBean *)article atIndex:(NSUInteger)index;
// 移除一个专题。返回这个专题所处的index。文章不在列表时返回 NSNotFound。不会触发updateCallback
- (NSUInteger)removeAlbum:(NSNumber *)albumId;
// 插入一个专题。返回是否成功。index超出当前大小时返回NO。不会触发updateCallback
- (BOOL)insertAlbum:(YueduAlbumBean *)album atIndex:(NSUInteger)index;

#pragma mark - Update
// 最新的错误信息
@property (strong, readonly, nonatomic) NSString *lastErrorMessage;
// 更新回调
@property (copy, nonatomic) void (^updateCallback)(BOOL suc, BOOL isMoreData);

// 根据新的分类刷新数据。会先在updateCallback返回缓存。
- (void)refreshCategory:(YueduCategoryBean *)category;
// 根据新的关键词刷新数据
- (void)refreshKeywords:(NSString *)keywords;
// 根据当前配置刷新数据，优先级：categoryBean > albumBean > keywords
- (void)refresh;
// 获取更多数据
- (void)loadMoreData;
// 请求文章的详细数据
- (void)fetchArticleWithCompletion:(void(^)(BOOL suc))completion;
// 请求专题的详细数据
- (void)fetchAlbumWithCompletion:(void(^)(BOOL suc))completion;

#pragma mark - Cache
// 某个分类是否存在缓存数据
- (BOOL)haveCacheData:(YueduCategoryBean *)category;
// 某个分类的数据是否已过期
- (BOOL)dataExpiredOfCategory:(YueduCategoryBean *)category;
// 读取缓存数据进行更新。触发 updateCallback 回调
- (void)updateUsingCacheData:(YueduCategoryBean *)category;

@end
