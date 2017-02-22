//
//  YGArticlesProvider.m
//  Golf
//
//  Created by wwwbbat on 16/5/27.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGYueduDataProvider.h"
#import "YGThriftRequestManager.h"
#import "YGArticleViewModel.h"
#import "YYCache.h"

static NSTimeInterval kCacheExpiredInterval = 15*60.f;

@interface YGYueduDataProvider ()
{
    BOOL _myLikedArticleFlag;
    BOOL _myLikedAlbumFlag;
    NSNumber *_articleID;
    NSNumber *_albumID;
}
@property (strong, nonatomic) YYCache *cache;//栏目下的文章或专题数据缓存
@property (assign, readwrite, nonatomic) BOOL noMoreData;
@end

@implementation YGYueduDataProvider

+ (void)setupCacheExpiredInterval:(NSTimeInterval)interval
{
    kCacheExpiredInterval = fabs(interval);
}

- (void)setup
{
    self.noMoreData = NO;
    self->_pageSize = 20;
    self->_albumCount = 0;
    self->_articleCount = 0;
    self->_pageNo = 0;
    self->_articleList = [[YueduArticleList alloc] initWithArticleList:[NSMutableArray array] err:nil];
    self->_albumList = [[YueduAlbumList alloc] initWithAlbumList:[NSMutableArray array] err:nil];
}

- (instancetype)initWithColumn:(YueduColumnBean *)columnBean
{
    self = [super init];
    if (self) {
        self->_columnBean = columnBean;
        [self setup];
        
        self->_cache = [YYCache cacheWithName:[NSString stringWithFormat:@"%d",columnBean.id]];
        self->_cache.memoryCache.costLimit = 50 * 2014 * 2014;
//        [self updateUsingCacheData:[columnBean.categoryList firstObject]];
    }
    return self;
}

- (instancetype)initWithAlbum:(NSNumber *)albumId
{
    self = [super init];
    if (self) {
        self->_albumID = albumId;
        [self setup];
    }
    return self;
}

- (instancetype)initWithSearchType:(YGYueduSearchType)searchType
{
    self = [super init];
    if (self) {
        self->_searchType = searchType;
        [self setup];
    }
    return self;
}

- (instancetype)initWithArticle:(NSNumber *)articleId
{
    self = [super init];
    if (self) {
        self->_articleID = articleId;
        [self setup];
    }
    return self;
}

- (instancetype)initForMyLikedArticle
{
    self = [super init];
    if (self) {
        self->_myLikedArticleFlag = YES;
        [self setup];
    }
    return self;
}

- (instancetype)initForMyLikedAlbum
{
    self = [super init];
    if (self) {
        self->_myLikedAlbumFlag = YES;
        [self setup];
    }
    return self;
}

#pragma mark - Cache
- (NSString *)dataCacheKey:(YueduCategoryBean *)category
{
    if (!category) return nil;
    return [NSString stringWithFormat:@"%d",category.id];
}

- (NSString *)dataUpdateKey:(YueduCategoryBean *)category
{
    if (!category) return nil;
    return [NSString stringWithFormat:@"%d_date",category.id];
}

- (BOOL)dataExpiredOfCategory:(YueduCategoryBean *)category
{
    NSDate *date = (id)[self.cache objectForKey:[self dataUpdateKey:category]];
    if (!date) return YES;
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:date];
    return interval > kCacheExpiredInterval;
}

// 异步更新缓存
- (void)refreshCache
{
    if (!self.cache || !self.categoryBean || !self.columnBean) {
        return;
    }
    NSString *k = [self dataCacheKey:self.categoryBean];
    enum DefaultShowType showType = self.columnBean.defaultShowType;
    switch (showType) {
        case DefaultShowType_ARTICLE: {
            [self.cache setObject:self.articleList forKey:k withBlock:nil];
            break;
        }
        case DefaultShowType_ALBUM: {
            [self.cache setObject:self.albumList forKey:k withBlock:nil];
            break;
        }
    }
    [self.cache setObject:[NSDate date] forKey:[self dataUpdateKey:self.categoryBean] withBlock:nil];
}

- (BOOL)haveCacheData:(YueduCategoryBean *)category
{
    if (!self.cache || !category || !self.columnBean) return NO;
    id object = [self.cache objectForKey:[self dataCacheKey:category]];
    return (BOOL)object;
}

- (void)updateUsingCacheData:(YueduCategoryBean *)category
{
    if (!self.cache || !category || !self.columnBean) return;
    self->_categoryBean = category;
    
    id object = [self.cache objectForKey:[self dataCacheKey:category]];
    enum DefaultShowType showType = self.columnBean.defaultShowType;
    switch (showType) {
        case DefaultShowType_ARTICLE: {
            // viewModel也进行了缓存
            self->_articleList = object;
            self->_articleCount = self.articleList.articleList.count;
            break;
        }
        case DefaultShowType_ALBUM: {
            self->_albumList = object;
            self->_albumCount = self.albumList.albumList.count;
            break;
        }
    }
    self->_isCacheData = YES;
    self->_lastErrorMessage = nil;
    [self callback:YES :NO];
}

#pragma mark - Update
- (void)refreshCategory:(YueduCategoryBean *)category
{
    self->_categoryBean = category;
    YGYueduListShowType showType = self.columnBean.defaultShowType;
    
    switch (showType) {
        case YGYueduListShowTypeArticle: {
            [self fetchArticleList:NO];
            break;
        }
        case YGYueduListShowTypeAlbum: {
            [self fetchAblumList:NO];
            break;
        }
    }
}

- (void)refreshKeywords:(NSString *)keywords
{
    self->_keywords = keywords;
    [self fetchSearchResult:NO];
}

- (void)refresh
{
    if (self.categoryBean) {
        [self refreshCategory:self.categoryBean];
    }else if (self.albumBean){
        [self fetchAblumContentArticleList:NO];
    }else if (self.keywords){
        [self refreshKeywords:self.keywords];
    }else if(_myLikedArticleFlag){
        [self fetchMyArticles:NO];
    }else if (_myLikedAlbumFlag){
        [self fetchMyLikedAlbums:NO];
    }else if (_articleID){
        [self fetchRelationArticles:NO];
    }
}

- (void)loadMoreData
{
    if (self.categoryBean) {
        YGYueduListShowType showType = self.columnBean.defaultShowType;
        switch (showType) {
            case YGYueduListShowTypeArticle: {
                [self fetchArticleList:YES];
                break;
            }
            case YGYueduListShowTypeAlbum: {
                [self fetchAblumList:YES];
                break;
            }
        }
    }else if (self.albumBean){
        [self fetchAblumContentArticleList:YES];
    }else if (self.keywords){
        [self fetchSearchResult:YES];
    }else if(_myLikedArticleFlag){
        [self fetchMyArticles:YES];
    }else if (_myLikedAlbumFlag){
        [self fetchMyLikedAlbums:YES];
    }else if (_articleID){
        [self fetchRelationArticles:YES];
    }
}

#pragma mark - Fetch
- (void)fetchArticleList:(BOOL)isLoadMore
{
    NSNumber *lastArticleId;
    if (isLoadMore) {
        YueduArticleBean *lastArticle = [self.articleList.articleList lastObject];
        if (lastArticle) {
            lastArticleId = @(lastArticle.id);
        }
    }
    
    int32_t idTmp = self.categoryBean.id;
    
    [YGRequest fetchArticleListInColumn:@(self.columnBean.id)
                               category:@(self.categoryBean.id)
                                albumId:nil
                            lastArticle:lastArticleId
                               pageSize:@(self.pageSize)
                                success:^(BOOL suc, id object) {
                                    
                                    if (self.categoryBean.id != idTmp) return;
                                    
                                    YueduArticleList *list = object;
                                    for (YueduArticleBean *article in list.articleList) {
                                        [article createViewModelWithSimpleMode:self.isSimpleMode];
                                    }
                                    if (isLoadMore) {
                                        [self.articleList.articleList addObjectsFromArray:list.articleList];
                                    }else{
                                        self->_articleList = list;
                                        [self refreshCache];
                                    }
                                    self->_articleCount = self.articleList.articleList.count;
                                    self.noMoreData = list.articleList.count<self.pageSize;
                                    self->_isCacheData = NO;
                                    self->_lastErrorMessage = list.err.errorMsg;
                                    [self callback:suc :isLoadMore];
                                }
                                failure:^(Error *err) {
                                    if (self.categoryBean.id != idTmp) return;
                                    self->_lastErrorMessage = @"当前网络不可用";
                                    [self callback:NO :isLoadMore];
                                }];
}

- (void)fetchAblumList:(BOOL)isLoadMore
{
    NSNumber *lastAblumId;
    if (isLoadMore) {
        YueduAlbumBean *lastAlbum = [self.albumList.albumList lastObject];
        if (lastAlbum) {
            lastAblumId = @(lastAlbum.id);
        }
    }
    int32_t idTmp = self.categoryBean.id;
    [YGRequest fetchAlbumList:@(self.categoryBean.id)
                    lastAlbum:lastAblumId
                     pageSize:@(self.pageSize)
                      success:^(BOOL suc, id object) {
                          
                          if (self.categoryBean.id != idTmp) return;
                          
                          YueduAlbumList *list = object;
                          if (isLoadMore) {
                              [self.albumList.albumList addObjectsFromArray:list.albumList];
                          }else{
                              self->_albumList = list;
                              [self refreshCache];
                          }
                          self->_albumCount = self.albumList.albumList.count;
                          self.noMoreData =  list.albumList.count<self.pageSize;
                          self->_isCacheData = NO;
                          self->_lastErrorMessage = list.err.errorMsg;
                          [self callback:suc :isLoadMore];
                      }
                      failure:^(Error *err) {
                          if (self.categoryBean.id != idTmp) return;
                          self->_lastErrorMessage = @"当前网络不可用";
                          [self callback:NO :isLoadMore];
                      }];
}

- (void)fetchAblumContentArticleList:(BOOL)isLoadMore
{
    NSNumber *lastArticleId;
    if (isLoadMore) {
        YueduArticleBean *article = [self.articleList.articleList lastObject];
        if (article) {
            lastArticleId = @(article.id);
        }
    }
    [YGRequest fetchArticleListInColumn:nil
                               category:nil
                                albumId:@(self.albumBean.id)
                            lastArticle:lastArticleId
                               pageSize:@(self.pageSize)
                                success:^(BOOL suc, id object) {
                                    YueduArticleList *list = object;
                                    for (YueduArticleBean *articleBean in list.articleList) {
                                        [articleBean createViewModelInAlbumDetail];
                                    }
                                    if (isLoadMore) {
                                        [self.articleList.articleList addObjectsFromArray:list.articleList];
                                    }else{
                                        self->_articleList = list;
                                    }
                                    self->_articleCount = self.articleList.articleList.count;
                                    self.noMoreData = list.articleList.count<self.pageSize;
                                    self->_lastErrorMessage = list.err.errorMsg;
                                    [self callback:suc :isLoadMore];
                                }
                                failure:^(Error *err) {
                                    self->_lastErrorMessage = @"当前网络不可用";
                                    [self callback:NO :isLoadMore];
                                }];
}

- (void)fetchSearchResult:(BOOL)isLoadMore
{
    NSUInteger pageNo = isLoadMore?self.pageNo+1:1;
    
    NSString *kTmp = self.keywords.copy;
    NSUInteger pTmp = self.pageNo;
    
    [YGRequest yueduSearch:self.keywords
                      type:@(self.searchType)
                    pageNo:@(pageNo)
                  pageSize:@(self.pageSize)
                   success:^(BOOL suc, id object) {
                       
                       // 数据返回时不再是当初的条件。则忽略此次请求结果。
                       if (![kTmp isEqualToString:self.keywords] || pTmp != self.pageNo) {
                           return;
                       }
                       
                       if (suc) {
                           self->_pageNo = pageNo;
                       }
                       
                       YueduSearchResult *result = object;
                       for (YueduArticleBean *article in result.articleList) {
                           [article createViewModelWithSimpleMode:self.isSimpleMode];
                       }
                       
                       if (isLoadMore) {
                           [self.articleList.articleList addObjectsFromArray:result.articleList];
                           // LoadMore 时不更新专题数据
                       }else{
                           self.articleList.articleList = result.articleList;
                           self.albumList.albumList = result.albumList;
                       }
                       
                       self->_articleCount = self.articleList.articleList.count;
                       self->_albumCount = self.albumList.albumList.count;
                       self.noMoreData = result.articleList.count<self.pageSize;
                       self->_lastErrorMessage = result.err.errorMsg;
                       [self callback:suc :isLoadMore];
                   }
                   failure:^(Error *err) {
                       if (![kTmp isEqualToString:self.keywords] || pTmp != self.pageNo) {
                           return;
                       }
                       self->_lastErrorMessage = @"当前网络不可用";
                       [self callback:NO :isLoadMore];
                   }];
}

- (void)fetchArticleWithCompletion:(void(^)(BOOL suc))completion
{
    if (!_articleID) return;
    [YGRequest fetchArticleDetail:_articleID
                          success:^(BOOL suc, id object) {
                              YueduArticleDetail *detail = object;
                              self->_articleBean = detail.article;
                              
                              self->_lastErrorMessage = detail.err.errorMsg;
                              completion?completion(suc):0;
                          }
                          failure:^(Error *err) {
                              self->_lastErrorMessage = @"当前网络不可用";
                              completion?completion(NO):0;
                          }];
}

- (void)fetchAlbumWithCompletion:(void(^)(BOOL suc))completion
{
    if (!_albumID) return;
    [YGRequest fetchAlbumDetail:_albumID
                        success:^(BOOL suc, id object) {
                            YueduAlbumDetail *detail = object;
                            self->_albumBean = detail.albumBean;
                            self->_lastErrorMessage = detail.err.errorMsg;
                            completion?completion(suc):0;
                        }
                        failure:^(Error *err) {
                            self->_lastErrorMessage = @"当前网络不可用";
                            completion?completion(NO):0;
                        }];
}

- (void)fetchRelationArticles:(BOOL)isLoadMore
{
    NSNumber *lastArticleId;
    if (isLoadMore) {
        YueduArticleBean *article = [self.articleList.articleList lastObject];
        if (article) {
            lastArticleId = @(article.id);
        }
    }
    [YGRequest fetchRelationArticles:_articleID
                             lastOne:lastArticleId
                            pageSize:@(self.pageSize)
                             success:^(BOOL suc, id object) {
                                 YueduArticleList *list = object;
                                 for (YueduArticleBean *article in list.articleList) {
                                     [article createViewModelWithSimpleMode:self.isSimpleMode];
                                 }
                                 if (isLoadMore) {
                                     [self->_articleList.articleList addObjectsFromArray:list.articleList];
                                 }else{
                                     self->_articleList = list;
                                 }
                                 self->_articleCount = self.articleList.articleList.count;
                                 self.noMoreData = list.articleList.count<self.pageSize;
                                 self->_lastErrorMessage = list.err.errorMsg;
                                 [self callback:suc :isLoadMore];
                             } failure:^(Error *err) {
                                 self->_lastErrorMessage = @"当前网络不可用";
                                 [self callback:NO :isLoadMore];
                             }];
}

- (void)fetchMyArticles:(BOOL)isLoadMore
{
    NSNumber *lastArticleId;
    if (isLoadMore) {
        YueduArticleBean *article = [self.articleList.articleList lastObject];
        if (article) {
            lastArticleId = @(article.id);
        }
    }
    [YGRequest fetchLikedArticles:lastArticleId
                         pageSize:@(self.pageSize)
                          success:^(BOOL suc, id object) {
                              YueduArticleList *list = object;
                              for (YueduArticleBean *article in list.articleList) {
                                  [article createViewModelWithSimpleMode:self.isSimpleMode];
                              }
                              if (isLoadMore) {
                                  [self.articleList.articleList addObjectsFromArray:list.articleList];
                              }else{
                                  self->_articleList = list;
                              }
                              self->_articleCount = self.articleList.articleList.count;
                              self.noMoreData = list.articleList.count<self.pageSize;
                              self->_lastErrorMessage = list.err.errorMsg;
                              [self callback:suc :isLoadMore];
                          }
                          failure:^(Error *err) {
                              self->_lastErrorMessage = @"当前网络不可用";
                              [self callback:NO :isLoadMore];
                          }];
}

- (void)fetchMyLikedAlbums:(BOOL)isLoadMore
{
    NSNumber *lastAlbumId;
    if (isLoadMore) {
        YueduAlbumBean *album = [self.albumList.albumList lastObject];
        lastAlbumId = @(album.id);
    }
    [YGRequest fetchLikedAlbums:lastAlbumId
                       pageSize:@(self.pageSize)
                        success:^(BOOL suc, id object) {
                            YueduAlbumList *list = object;
                            if (isLoadMore) {
                                [self.albumList.albumList addObjectsFromArray:list.albumList];
                            }else{
                                self->_albumList = list;
                                [self refreshCache];
                            }
                            self->_albumCount = self.albumList.albumList.count;
                            self.noMoreData =  list.albumList.count<self.pageSize;
                            self->_lastErrorMessage = list.err.errorMsg;
                            [self callback:suc :isLoadMore];
                        }
                        failure:^(Error *err) {
                            self->_lastErrorMessage = @"当前网络不可用";
                            [self callback:NO :isLoadMore];
                        }];
}

#pragma mark -
- (void)callback:(BOOL)suc :(BOOL)isMore
{
    RunOnMainQueue(^{
        if (self.updateCallback) {
            self.updateCallback(suc,isMore);
        }
    });
}

- (YueduArticleBean *)articleAtIndex:(NSUInteger)index
{
    if (index < self.articleCount) {
        return self.articleList.articleList[index];
    }
    return nil;
}

- (YueduAlbumBean *)albumAtIndex:(NSUInteger)index
{
    if (index < self.albumCount) {
        return self.albumList.albumList[index];
    }
    return nil;
}

- (NSUInteger)removeArticle:(NSNumber *)articleId
{
    int32_t theId = articleId.intValue;
    NSUInteger index = NSNotFound;
    for (YueduArticleBean *article in self.articleList.articleList) {
        if (article.id == theId) {
            index = [self.articleList.articleList indexOfObject:article];
            break;
        }
    }
    if (index != NSNotFound) {
        [self.articleList.articleList removeObjectAtIndex:index];
        self->_articleCount = self.articleList.articleList.count;
    }
    return index;
}

- (BOOL)insertArticle:(YueduArticleBean *)article atIndex:(NSUInteger)index
{
    if (!article || index > self.articleList.articleList.count) {
        return NO;
    }
    [article createViewModelWithSimpleMode:self.isSimpleMode];
    [self.articleList.articleList insertObject:article atIndex:index];
    self->_articleCount = self.articleList.articleList.count;
    return YES;
}

- (NSUInteger)removeAlbum:(NSNumber *)albumId
{
    int32_t theId = albumId.intValue;
    NSUInteger index = NSNotFound;
    for (YueduAlbumBean *album in self.albumList.albumList) {
        if (album.id == theId) {
            index = [self.albumList.albumList indexOfObject:album];
            break;
        }
    }
    if (index != NSNotFound) {
        [self.albumList.albumList removeObjectAtIndex:index];
        self->_albumCount = self.albumList.albumList.count;
    }
    return index;
}

- (BOOL)insertAlbum:(YueduAlbumBean *)album atIndex:(NSUInteger)index
{
    if (!album || index > self.albumList.albumList.count) {
        return NO;
    }
    [self.albumList.albumList insertObject:album atIndex:index];
    self->_albumCount = self.albumList.albumList.count;
    return YES;
}

@end
