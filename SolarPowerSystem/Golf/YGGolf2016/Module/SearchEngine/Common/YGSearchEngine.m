//
//  YGSearchEngine.m
//  Golf
//
//  Created by bo wang on 16/7/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGSearchEngine.h"
#import "YGThriftRequestManager.h"
#import "YGThrift+SeatchEngine.h"

@interface YGSearchEngine ()
{
    void *_lastPointer;
}
@property (strong, readwrite, nullable, nonatomic) NSDictionary<NSNumber *,NSArray *> *resultData;
@property (strong, nonatomic) NSDictionary *isMoreMap;
@end

@implementation YGSearchEngine

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self reset];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self reset];
}

- (void)search:(YGSearchCondition *)condition
{
    if (!condition || condition.keywords.length == 0 || condition == self.condition) {
        return;
    }
    
    YGSearchType type = condition.type;
    NSUInteger typeValue = SearchQueryValue(type);
    
    // 取指针地址拿来识别是否是最新的搜索
    void *pointer = &condition;
    _lastPointer = pointer;
    
    CGFloat longitude = [LoginManager sharedManager].currLongitude;
    CGFloat latitude = [LoginManager sharedManager].currLatitude;
    
    ygweakify(self);
    [YGRequest generalSearch:condition.keywords
                        type:@(typeValue)
                        page:@(condition.pageNo)
                   longitude:longitude
                    latitude:latitude
                     success:^(BOOL suc, id object) {
                         ygstrongify(self);
                         if (!self) return;
                         
                         void *pointer2 = pointer;
                         if (pointer2 != self->_lastPointer) {
                             return;
                         }
                         [self handleSearchResult:object condition:condition];
                         [self callback:suc :[condition isMore]];
                     } failure:^(Error *err) {
                         [self callback:NO :[condition isMore]];
                     }];
}

- (void)loadMore
{
    [self search:[YGSearchCondition nextPage:self.condition]];
}

- (void)handleSearchResult:(SearchResultList *)list condition:(YGSearchCondition *)condition
{
    self->_condition = condition;
    
    [self createViewModel:list.courseList];
    [self createViewModel:list.commodityList];
    [self createViewModel:list.topicList];
    [self createViewModel:list.memberList];
    [self createViewModel:list.headLineList];
    [self createViewModel:list.coachList];
    
    YGSearchType type = condition.type;
    
    if ([condition isAll]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@(YGSearchTypeCourse)]     = list.courseList.count==0    ? nil : list.courseList;
        dict[@(YGSearchTypeCommodity)]  = list.commodityList.count==0 ? nil : list.commodityList;
        dict[@(YGSearchTypeFeed)]       = list.topicList.count==0     ? nil : list.topicList;
        dict[@(YGSearchTypeUser)]       = list.memberList.count==0    ? nil : list.memberList;
        dict[@(YGSearchTypeYuedu)]      = list.headLineList.count==0  ? nil : list.headLineList;
        dict[@(YGSearchTypeCoach)]      = list.coachList.count==0     ? nil : list.coachList;
        self.resultData = dict;
        self.isMoreMap = list.isMoreMap;
    }else{
        NSArray *data,*resultData;
        switch (type) {
            case YGSearchTypeAll:       {                               break;}
            case YGSearchTypeFeed:      {   data = list.topicList;      break;}
            case YGSearchTypeUser:      {   data = list.memberList;     break;}
            case YGSearchTypeCoach:     {   data = list.coachList;      break;}
            case YGSearchTypeCourse:    {   data = list.courseList;     break;}
            case YGSearchTypeCommodity: {   data = list.commodityList;  break;}
            case YGSearchTypeYuedu:     {   data = list.headLineList;   break;}
        }
        self->_noMoreData = data.count==0;
        if ([condition isMore]) {
            NSMutableArray *tmp = [NSMutableArray arrayWithArray:self.resultData[@(type)]];
            [tmp addObjectsFromArray:data];
            resultData = tmp;
        }else{
            resultData = data;
        }
        if (resultData.count != 0) {
            self.resultData = @{@(type):resultData};
        }else{
            self.resultData = nil;
        }
    }
}

- (void)createViewModel:(NSArray *)resultBeans
{
    if (!resultBeans) return;
    
    for (id<YGSearchViewModelProtocol> bean in resultBeans) {
        if ([bean respondsToSelector:@selector(createViewModel:)]) {
            [bean createViewModel:self.condition.keywords];
        }
    }
}

- (void)reset
{
    self->_condition = nil;
    self.resultData = nil;
    self.isMoreMap = nil;
    self->_noMoreData = YES;
}

- (NSArray<NSNumber *> *)resultTypeList
{
    NSArray *types = self.resultData.allKeys;
    NSArray *list = [types sortedArrayUsingComparator:^NSComparisonResult(NSNumber *obj1,NSNumber *obj2) {
        return [obj1 compare:obj2];
    }];
    return list;
}

- (BOOL)hasMoreDataOfType:(YGSearchType)type
{
    NSUInteger v = SearchQueryValue(type);
    NSNumber *hasMore = self.isMoreMap[@(v)];
    return [hasMore boolValue];
}

- (void)callback:(BOOL)suc :(BOOL)isMore
{
    if (self.updateCallback) {
        self.updateCallback(suc,isMore);
    }
}

@end

#import "YYModel.h"

@implementation YGSearchCondition
- (instancetype)initWithType:(YGSearchType)type keywords:(NSString *)keywords pageNo:(NSUInteger)pageNo;
{
    self = [super init];
    if (self) {
        self->_type = type;
        self->_keywords = [keywords stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        self->_pageNo = pageNo;
    }
    return self;
}

+ (instancetype)nextPage:(YGSearchCondition *)c
{
    if (!c || [c isAll]) return nil;
    return [[YGSearchCondition alloc] initWithType:c.type keywords:c.keywords pageNo:c.pageNo+1];
}

- (BOOL)isAll
{
    return YGSearchTypeAll==self.type;
}

- (BOOL)isMore
{
    return ![self isAll] && self.pageNo>1;
}

@end
