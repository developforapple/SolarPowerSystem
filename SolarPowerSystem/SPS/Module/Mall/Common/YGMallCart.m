//
//  YGMallCart.m
//  Golf
//
//  Created by bo wang on 2016/10/10.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallCart.h"

@interface YGMallCart ()
@property (assign, readwrite, nonatomic) CGFloat price;   //当前被选中的商品的总价
@property (strong, readwrite, nonatomic) NSArray<YGMallCartGroup *> *originGroups;
@property (strong, readwrite, nonatomic) NSMutableArray<YGMallCartGroup *> *groups;          //分组列表
@property (strong, readwrite, nonatomic) NSMutableArray<YGMallCartGroup *> *editGroups;      //编辑状态下的分组列表
@property (strong, readwrite, nonatomic) NSMutableArray<CommodityModel *> *selectedList;     //选中商品列表
@property (strong, readwrite, nonatomic) NSMutableArray<CommodityModel *> *selectedEditList; //编辑状态下的选中商品列表

@property (strong, readwrite, nonatomic) NSString *lastError;

@property (strong, readwrite, nonatomic) NSMutableArray<CommodityModel *> *featuredCommodities;
@property (assign, readwrite, nonatomic) NSUInteger pageNo;
@property (assign, readwrite, nonatomic) NSUInteger pageSize;
@property (assign, readwrite, nonatomic) BOOL hasMore;

@end

@implementation YGMallCart

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hadNewCommodityJoined:) name:@"NewCommodityJoinCartListNotification" object:nil];
        
        _featuredCommodities = [NSMutableArray array];
        self.pageNo = 0;
        self.pageSize = 20;
        self.hasMore = YES;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)hadNewCommodityJoined:(NSNotification *)noti
{
    [self loadCartData];
}

- (void)loadCartData
{
    [ServerService shoppingCartList:[[LoginManager sharedManager] getSessionId] success:^(NSArray *list) {
        if (!list) {
            self.lastError = @"未知错误";
            [self callResetCallback:NO];
        }else{
            [self refreshUsingLatestData:list];
            [self callResetCallback:YES];
        }
    } failure:^(id error) {
        self.lastError = @"当前网络不可用";
        [self callResetCallback:NO];
    }];
}

- (NSArray<YGMallCartGroup *> *)prepareCrateOrder:(NSInteger)commodityType
{
    NSMutableDictionary *commodities = [NSMutableDictionary dictionary];
    for (CommodityModel *commodity in self.selectedList) {
        if (commodity.commodityType != commodityType) {
            continue;
        }
        NSInteger groupid = commodity.agentId;
        NSMutableArray *tmp = commodities[@(groupid)];
        if (!tmp) {
            tmp = [NSMutableArray array];
        }
        [tmp addObject:commodity];
        commodities[@(groupid)] = tmp;
    }
    
    NSMutableArray *groups = [NSMutableArray array];
    for (YGMallCartGroup *aGroup in self.originGroups) {
        NSInteger agentId = aGroup.agentId;
        NSMutableArray *tmp = commodities[@(agentId)];
        if (tmp) {
            YGMallCartGroup *newGroup = [YGMallCartGroup new];
            newGroup.agentId = aGroup.agentId;
            newGroup.agentName = aGroup.agentName;
            newGroup.commodity = tmp;
            [groups addObject:newGroup];
        }
    }
    return groups;
}

- (void)callResetCallback:(BOOL)suc
{
    if (self.cartResetCallbck) {
        self.cartResetCallbck(suc);
    }
}

- (void)callUpdateCallback
{
    if (self.updateCallback) {
        self.updateCallback();
    }
}

- (void)refreshUsingLatestData:(NSArray<YGMallCartGroup *> *)list
{
    self.originGroups = list;
    
    NSArray<CommodityModel *> *sortedCommodities = [self sortedCommoditiesInOriginGroups];
    NSArray *groups = [self createDataSourceGroups:sortedCommodities];
    
    self.groups = [NSMutableArray arrayWithArray:groups];
    self.editGroups = [NSMutableArray arrayWithArray:groups];
    self.selectedEditList = [NSMutableArray array];
    
    NSArray *buyable = [YGMallCartGroup buyableCommoditiesAtGroup:list];
    
    if (self.defaultSelectionInfo) {
        NSIndexSet *indexes = [buyable indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(CommodityModel *obj, NSUInteger idx, BOOL *stop) {
            NSString *identifier = [NSString stringWithFormat:@"%ld-%d",(long)obj.commodityId,obj.skuid];
            return [self.defaultSelectionInfo containsObject:identifier];
        }];
        self.selectedList = [NSMutableArray arrayWithArray:[buyable objectsAtIndexes:indexes]];
        self.defaultSelectionInfo = nil;
    }else{
        self.selectedList = [NSMutableArray arrayWithArray:buyable];
    }
    [self compute];
}

- (void)compute
{
    CGFloat price = 0.f;
    for (CommodityModel *commodity in self.selectedList) {
        price += commodity.sellingPrice * commodity.quantity;
    }
    self.price = price;
}

- (CGFloat)updatePrice
{
    [self compute];
    return self.price;
}

- (BOOL)isEmpty
{
    NSArray *groups = self.isEditing?self.groups:self.editGroups;
    NSInteger count = 0;
    for (YGMallCartGroup *g in groups) {
        count += g.commodity.count;
    }
    return count==0;
}

#pragma mark - Selection
- (BOOL)canSelectCommodity:(CommodityModel *)commodity
{
    return self.isEditing?:commodity.sellingStatus==1;
}

- (void)selectCommodity:(CommodityModel *)commodity    //选中一个商品
{
    if (![self canSelectCommodity:commodity]) return;
    
    NSMutableArray *array = self.isEditing?_selectedEditList:_selectedList;
    if (![array containsObject:commodity]) {
        [array addObject:commodity];
    }
    [self compute];
    [self callUpdateCallback];
}

- (void)justSelectCommodities:(NSArray<CommodityModel *> *)commodities
{
    if (self.editing) {
        self.selectedEditList = [NSMutableArray arrayWithArray:commodities];
    }else{
        self.selectedList = [NSMutableArray arrayWithArray:commodities];
    }
    [self compute];
    [self callUpdateCallback];
}

- (void)deselectCommodity:(CommodityModel *)commodity  //取消选中一个商品
{
    NSMutableArray *array = self.isEditing?_selectedEditList:_selectedList;
    [array removeObject:commodity];
    [self compute];
    [self callUpdateCallback];
}

- (void)convertSelection:(CommodityModel *)commodity
{
    if ([self isCommoditySelected:commodity]) {
        [self deselectCommodity:commodity];
    }else{
        [self selectCommodity:commodity];
    }
}

- (BOOL)canSelectGroup:(YGMallCartGroup *)group
{
    if (self.editing) {
        return YES;
    }
    for (CommodityModel *commodity in group.commodity) {
        if (![self canSelectCommodity:commodity]) {
            return NO;
        }
    }
    return YES;
}

- (void)selectGroup:(YGMallCartGroup *)group           //选中整个分组
{
    NSMutableArray *array = self.isEditing?_selectedEditList:_selectedList;
    for (CommodityModel *commodity in group.commodity) {
        if (![array containsObject:commodity] && [self canSelectCommodity:commodity]) {
            [array addObject:commodity];
        }
    }
    [self compute];
    [self callUpdateCallback];
}

- (void)deselectGroup:(YGMallCartGroup *)group         //取消选中整个分组
{
    NSMutableArray *array = self.isEditing?_selectedEditList:_selectedList;
    for (CommodityModel *commodity in group.commodity) {
        [array removeObject:commodity];
    }
    [self compute];
    [self callUpdateCallback];
}

- (void)convertGroupSelection:(YGMallCartGroup *)group
{
    if ([self isGroupSelectedAll:group]) {
        [self deselectGroup:group];
    }else{
        [self selectGroup:group];
    }
}

- (BOOL)canSelectAll
{
    if (self.isEditing) {
        return YES;
    }
    for (YGMallCartGroup *group in self.groups) {
        if (![self canSelectGroup:group]) {
            return NO;
        }
    }
    return YES;
}

- (void)selectAll                                      //选中全部商品
{
    if (!self.isEditing) {
        self.selectedList = [NSMutableArray arrayWithArray:[YGMallCartGroup buyableCommoditiesAtGroup:self.groups]];
    }else{
        self.selectedEditList = [NSMutableArray arrayWithArray:[YGMallCartGroup commoditiesAtGroup:self.editGroups]];
    }
    [self compute];
    [self callUpdateCallback];
}

- (void)deselectAll                                    //取消选中全部商品
{
    if (!self.isEditing) {
        [_selectedList removeAllObjects];
    }else{
        [_selectedEditList removeAllObjects];
    }
    [self compute];
    [self callUpdateCallback];
}

- (void)convertAllSelection
{
    if ([self isSelectedAll]) {
        [self deselectAll];
    }else{
        [self selectAll];
    }
}

- (BOOL)isSelectedAll  //目前是否已全部选中
{
    if (!self.isEditing) {
        NSUInteger count = 0;
        for (YGMallCartGroup *group in self.groups) {
            count += group.commodity.count;
        }
        return self.selectedList.count == count;
    }else{
        NSUInteger count = 0;
        for (YGMallCartGroup *group in self.editGroups) {
            count += group.commodity.count;
        }
        return self.selectedEditList.count == count;
    }
}

- (BOOL)isGroupSelectedAll:(YGMallCartGroup *)group //某个分组是否已全部选中
{
    if (!self.isEditing) {
        for (CommodityModel *commodity in group.commodity) {
            if (![self.selectedList containsObject:commodity]) {
                return NO;
            }
        }
    }else{
        for (CommodityModel *commodity in group.commodity) {
            if (![self.selectedEditList containsObject:commodity]) {
                return NO;
            }
        }
    }
    return YES;
}

- (BOOL)isCommoditySelected:(CommodityModel *)commodity
{
    if (!self.isEditing) {
        return [self.selectedList containsObject:commodity];
    }else{
        return [self.selectedEditList containsObject:commodity];
    }
}

- (NSArray<CommodityModel *> *)selectedCommoditiesOfType:(NSInteger)commodityType
{
    NSMutableArray *tmp = [NSMutableArray array];
    NSArray *list = self.editing?self.selectedEditList:self.selectedList;
    for (CommodityModel *commodity in list) {
        if (commodity.commodityType == commodityType && [self canSelectCommodity:commodity]) {
            [tmp addObject:commodity];
        }
    }
    return tmp;
}

- (NSInteger)selectedCommodityType
{
    NSArray *list = self.editing?self.selectedEditList:self.selectedList;
    NSInteger lastType = -1;
    for (CommodityModel *commodity in list) {
        if (lastType == -1 || commodity.commodityType == lastType) {
            lastType = commodity.commodityType;
        }else{
            return -1;
        }
    }
    return lastType;
}

#pragma mark - Edit
- (void)deleteCommodities:(NSArray<CommodityModel *> *)commodities
               completion:(void (^)(BOOL suc))completion
{
    NSMutableArray *commodityIds = [NSMutableArray array];
    NSMutableArray *specIds = [NSMutableArray array];
    NSMutableArray *quantities = [NSMutableArray array];
    
    for (CommodityModel *commodity in commodities) {
        [commodityIds addObject:@(commodity.commodityId)];
        [specIds addObject:@(commodity.skuid)];
        [quantities addObject:@(commodity.quantity)];
    }
    
    NSString *commodityIdsStr = [commodityIds componentsJoinedByString:@","];
    NSString *specIdsStr = [specIds componentsJoinedByString:@","];
    NSString *quantitiesStr = [quantities componentsJoinedByString:@","];
    
    [ServerService shoppingCartMaintain:[[LoginManager sharedManager] getSessionId] operation:2 commodityIds:commodityIdsStr specIds:specIdsStr quantitys:quantitiesStr success:^(NSArray *list) {
        
        if (list.count > 0) {
            //删除成功
            if (completion) completion(YES);
            [self loadCartData];
        }else{
            self.lastError = @"删除失败";
            if (completion) completion(NO);
        }
    } failure:^(id error) {
        self.lastError = @"当前网络不可用";
        if (completion) completion(NO);
    }];
}

#pragma mark - Sort 7.3.1 Add
// 7.3.1版本下每个商品都有独立的分组。因此需要先对服务器返回的分组中的商品进行拆分排序
- (NSArray<CommodityModel *> *)sortedCommoditiesInOriginGroups
{
    NSMutableArray *commodities = [NSMutableArray array];
    for (YGMallCartGroup *aGroup in self.originGroups) {
        [commodities addObjectsFromArray:aGroup.commodity];
    }
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"join_time" ascending:NO];
    [commodities sortUsingDescriptors:@[sortDescriptor]];
    return commodities;
}

// 7.3.1版本下每个商品都有独立的分组。所以这里为每个商品都创建一个分组，作为数据源
- (NSArray<YGMallCartGroup *> *)createDataSourceGroups:(NSArray<CommodityModel *> *)commodities
{
    NSMutableArray *groups = [NSMutableArray array];
    for (CommodityModel *commodity in commodities) {
        NSInteger agentId = commodity.agentId;
        for (YGMallCartGroup *aGroup in self.originGroups) {
            if (aGroup.agentId == agentId) {
                
                YGMallCartGroup *aNewGroup = [YGMallCartGroup new];
                aNewGroup.commodity =@[commodity];
                aNewGroup.agentId = agentId;
                aNewGroup.agentName = aGroup.agentName;

                [groups addObject:aNewGroup];
                break;
            }
        }
    }
    return groups;
}

#pragma mark - FeaturedCommodity
- (void)loadFeaturedCommodity:(void (^)(BOOL suc,BOOL hasMore))completion
{
    [ServerService commodityThemeCommodity:0 gender:[LoginManager sharedManager].session.gender pageNo:self.pageNo pageSize:self.pageSize success:^(NSArray *list) {
        
        [_featuredCommodities addObjectsFromArray:list];
        self.hasMore = list.count==self.pageSize;
        self.pageNo++;
        
        if (completion) {
            completion(YES,self.hasMore);
        }
    } failure:^(id error) {
        if (completion) {
            completion(NO,self.hasMore);
        }
    }];
}
@end
