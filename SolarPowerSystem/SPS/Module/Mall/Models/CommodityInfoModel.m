//
//  CommodityInfoModel.m
//  Golf
//
//  Created by 黄希望 on 14-5-21.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "CommodityInfoModel.h"
#import "YYModel.h"

@interface CommodityInfoModel () <YYModel>

@end

@implementation CommodityInfoModel

+ (CommodityInfoModel *)instanceByNodes:(NSMutableDictionary *)nodes{
    CommodityInfoModel *m = [CommodityInfoModel new];
    NSString *photoImage = nodes[@"photoImage"];
    if (photoImage) {
        m.photoImage = photoImage;
    }
    NSString *commodityName = nodes[@"commodityName"];
    if (commodityName) {
        m.commodityName = commodityName;
    }
    NSString *auctionId = nodes[@"auctionId"];
    if (auctionId) {
        m.auctionId = [auctionId intValue];
    }
    NSString *commodityId = nodes[@"commodityId"];
    if (commodityId) {
        m.commodityId = [commodityId intValue];
    }
    NSString *sellingPrice = nodes[@"sellingPrice"];
    if (sellingPrice) {
        m.sellingPrice = [sellingPrice intValue];
    }
    return m;
}

- (void)updateAttrArrayBySelectedAttr:(NSArray<CommoditySpecAttr *> *) selectedAttrList
{
    NSMutableIndexSet *selectedAttrIds = [NSMutableIndexSet indexSet];
    for (CommoditySpecAttr *attr in selectedAttrList) {
        [selectedAttrIds addIndex:attr.attrId];
    }
    
    for (CommoditySpecAttrModel *attrModel in self.attrArray) {
        for (CommoditySpecAttr *attr in attrModel.attr) {
            attr.selectable = [attr selectableBySelectedAttr:selectedAttrList];
            if (!attr.selectable) {
                attr.selected = NO;
            }else{
                attr.selected = [selectedAttrIds containsIndex:attr.attrId];
            }
        }
    }
}

- (CommoditySpecSKUModel *)skuWithSelectedAttr:(NSArray<CommoditySpecAttr *> *)selectedAttrList
{
    if (selectedAttrList.count != self.attrArray.count) {
        return nil;
    }
    NSMutableArray *array = [NSMutableArray array];
    for (CommoditySpecAttr *attr in selectedAttrList) {
        [array addObject:@(attr.attrId)];
    }
    [array sortUsingSelector:@selector(compare:)];
    NSString *attrKey = [array componentsJoinedByString:@"-"];
    
    for (CommoditySpecSKUModel *sku in self.skuArray) {
        if ([sku.attrKey isEqualToString:attrKey]) {
            return sku;
        }
    }
    return nil;
}

- (NSString *)skuDescTitle:(CommoditySpecSKUModel *)sku
{
    if (!sku) return nil;
    
    NSIndexSet *attrIds = sku.attrIds;
    __block NSMutableArray *attrValues = [NSMutableArray array];
    [attrIds enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        for (CommoditySpecAttrModel *attrModel in self.attrArray) {
            for (CommoditySpecAttr *attr in attrModel.attr) {
                if (attr.attrId == idx) {
                    [attrValues addObject:attr.attrValue];
                    goto theBreakLabel;
                }
            }
        }
    theBreakLabel:;
    }];
    
    NSString *title = [attrValues componentsJoinedByString:@","];
    sku.skuName = title;
    return title;
}

- (CommoditySpecSKUModel *)skuWithId:(NSInteger)skuid
{
    for (CommoditySpecSKUModel *sku in self.skuArray) {
        if (sku.skuId == skuid) {
            return sku;
        }
    }
    return nil;
}

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper
{
    static NSDictionary *mapper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        //          属性名                      字段名
        mapper = @{
                   @"categoryId"            :@"category_id",
                   @"introduction"          :@"introduction",
                   @"originalPrice"         :@"original_price",
                   @"sellingPrice"          :@"selling_price",
                   @"commodityDetail"       :@"commodity_detail",
                   @"stockQuantity"         :@"stock_quantity",
                   @"soldQuantity"          :@"sold_quantity",
                   @"commentQuantity"       :@"comment_count",
                   @"buyLimit"              :@"buy_limit",
                   @"buyGuide"              :@"buy_guide",
                   @"highPraiseRate"        :@"high_praise_rate",
                   @"pictureList"           :@"picture_list",       //数组
                   @"auctionStatus"         :@"auction_status",
                   @"auctionTime"           :@"auction_time",
                   @"beginPrice"            :@"begin_price",
                   @"lastPrice"             :@"last_price",
                   @"nextInterval"          :@"next_interval",
                   @"commodityIntervalTime" :@"commodity_interval_time",
                   @"serverTime"            :@"server_time",
                   @"markdown"              :@"markdown",
                   @"auctionFreight"        :@"auction_freight",
                   @"sellingStatus"         :@"selling_status",
                   @"specId"                :@"spec_id",
                   @"submitTime"            :@"submit_time",
                   @"payDuration"           :@"pay_duration",
                   @"endTime"               :@"end_time",
                   @"yunbi"                 :@"give_yunbi",
                   @"relativeId"            :@"relative_id",
                   @"relativeType"          :@"relative_type",
                   @"agentId"               :@"agent_id",
                   @"commodityId"           :@"commodity_id",
                   @"commodityType"         :@"commodity_type",
                   @"commodityName"         :@"commodity_name",
                   @"photoImage"            :@"photo_image",
                   @"freight"               :@"freight",
                   @"auctionId"             :@"auction_id",
                   @"quantityList"          :@"quantity_list",  //数组
                   @"skuArray"              :@"skuArray",       //数组
                   @"attrArray"             :@"attrArray",       //数组
                   @"flash_sale"            :@"flash_sale",
                   };
    });
    return mapper;
}

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass
{
    static NSDictionary *dict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dict = @{
                 @"pictureList" :[NSString class],
                 @"skuArray"    :[CommoditySpecSKUModel class],
                 @"attrArray"   :[CommoditySpecAttrModel class]
                 };
    });
    return dict;
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic
{
    //转换价格到元
    self.originalPrice /= 100;
    self.sellingPrice /= 100;
    self.yunbi /= 100;
    self.beginPrice /= 100;
    self.lastPrice /= 100;
    self.markdown /= 100;
    self.auctionFreight /=100;
    self.freight /= 100;
    
    if (self.sellingStatus == 0) {
        self.sellingStatus = 1;
    }
    
    // 使用并发提高效率
    
    // 选出所有有效的配置
    NSIndexSet *allValidSKUIndexes = [self.skuArray indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(CommoditySpecSKUModel *obj, NSUInteger idx, BOOL *stop) {
        return obj.stock_quantity > obj.sold_quantity;//库存大于已售出时为有效
    }];
    NSArray *allValidSKUList = [self.skuArray objectsAtIndexes:allValidSKUIndexes];
    
    // 为每个规格列出适合它的有效的配置
    for (CommoditySpecAttrModel *attrModel in self.attrArray) {
        for (CommoditySpecAttr *attr in attrModel.attr) {
            NSInteger attrId = attr.attrId;
            NSIndexSet *validSKUIndexes = [allValidSKUList indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(CommoditySpecSKUModel *obj, NSUInteger idx, BOOL *stop) {
                return [obj.attrIds containsIndex:attrId];
            }];
            attr.validSKUList = [allValidSKUList objectsAtIndexes:validSKUIndexes];
        }
    }
    
    return YES;
}

- (id)initWithDic:(id)data
{
    self = [super init];
    if (![self yy_modelSetWithDictionary:data]) {
        return nil;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder { [self yy_modelEncodeWithCoder:aCoder]; }
- (id)initWithCoder:(NSCoder *)aDecoder { self = [super init]; return [self yy_modelInitWithCoder:aDecoder]; }
- (id)copyWithZone:(NSZone *)zone { return [self yy_modelCopy]; }
//- (NSUInteger)hash { return [self yy_modelHash]; }
//- (BOOL)isEqual:(id)object { return [self yy_modelIsEqual:object]; }


//- (id)initWithDic:(id)data{
//    if(!data || ![data isKindOfClass:[NSDictionary class]]){
//        return nil;
//    }
//    self = [super init];
//    if(!self) {
//        return nil;
//    }
//    NSDictionary *dic = (NSDictionary *)data;
//    if ([dic objectForKey:@"category_id"]) {
//        self.categoryId = [[dic objectForKey:@"category_id"] intValue];
//    }
//    if ([dic objectForKey:@"introduction"]) {
//        self.introduction = [dic objectForKey:@"introduction"];
//    }
//    if ([dic objectForKey:@"original_price"]) {
//        self.originalPrice = [[dic objectForKey:@"original_price"] intValue] / 100;
//    }
//    if ([dic objectForKey:@"selling_price"]) {
//        self.sellingPrice = [[dic objectForKey:@"selling_price"] intValue] / 100;
//    }
//    if ([dic objectForKey:@"give_yunbi"]) {
//        self.yunbi = [[dic objectForKey:@"give_yunbi"] intValue] / 100;
//    }
//    if ([dic objectForKey:@"commodity_detail"]) {
//        self.commodityDetail = [dic objectForKey:@"commodity_detail"];
//    }
//    if ([dic objectForKey:@"stock_quantity"]) {
//        self.stockQuantity = [[dic objectForKey:@"stock_quantity"] intValue];
//    }
//    if ([dic objectForKey:@"sold_quantity"]) {
//        self.soldQuantity = [[dic objectForKey:@"sold_quantity"] intValue];
//    }
//    if ([dic objectForKey:@"comment_count"]) {
//        self.commentQuantity = [[dic objectForKey:@"comment_count"] intValue];
//    }
//    if ([dic objectForKey:@"buy_guide"]) {
//        self.buyGuide = [dic objectForKey:@"buy_guide"];
//    }
//    if ([dic objectForKey:@"buy_limit"]) {
//        self.buyLimit = [[dic objectForKey:@"buy_limit"] intValue];
//    }
//    if ([dic objectForKey:@"high_praise_rate"]) {
//        self.highPraiseRate = [dic[@"high_praise_rate"] intValue];
//    }
//    if ([dic objectForKey:@"picture_list"]) {
//        self.pictureList = [dic objectForKey:@"picture_list"];
//    }
//    if ([dic objectForKey:@"quantity_list"]) {
//        self.quantityList = [dic objectForKey:@"quantity_list"];
//    }
//    if ([dic objectForKey:@"auction_time"]) {
//        self.auctionTime = [dic objectForKey:@"auction_time"];
//    }
//    if ([dic objectForKey:@"end_time"]) {
//        self.endTime = [dic objectForKey:@"end_time"];
//    }
//    if ([dic objectForKey:@"begin_price"]) {
//        self.beginPrice = [[dic objectForKey:@"begin_price"] intValue] / 100;
//    }
//    if ([dic objectForKey:@"last_price"]) {
//        self.lastPrice = [[dic objectForKey:@"last_price"] intValue] / 100;
//    }
//    if ([dic objectForKey:@"next_interval"]) {
//        self.nextInterval = [[dic objectForKey:@"next_interval"] intValue];
//    }
//    if ([dic objectForKey:@"commodity_interval_time"]) {
//        self.commodityIntervalTime = [dic[@"commodity_interval_time"] intValue];
//    }
//    if ([dic objectForKey:@"server_time"]) {
//        self.serverTime = [dic objectForKey:@"server_time"];
//    }
//    if ([dic objectForKey:@"auction_status"]) {
//        self.auctionStatus = [[dic objectForKey:@"auction_status"] intValue];
//    }
//    if ([dic objectForKey:@"markdown"]) {
//        self.markdown = [[dic objectForKey:@"markdown"] intValue] / 100;
//    }
//    if ([dic objectForKey:@"auction_freight"]) {
//        self.auctionFreight = [[dic objectForKey:@"auction_freight"] intValue] / 100;
//    }
//    if ([dic objectForKey:@"spec_id"]) {
//        self.specId = [[dic objectForKey:@"spec_id"] intValue];
//    }
//    if ([dic objectForKey:@"relative_id"]) {
//        self.relativeId = [[dic objectForKey:@"relative_id"] intValue];
//    }
//    if ([dic objectForKey:@"relative_type"]) {
//        self.relativeType = [[dic objectForKey:@"relative_type"] intValue];
//    }
//    if ([dic objectForKey:@"agent_id"]) {
//        self.agentId = [[dic objectForKey:@"agent_id"] intValue];
//    }
//    if ([dic objectForKey:@"commodity_id"]) {
//        self.commodityId = [[dic objectForKey:@"commodity_id"] intValue];
//    }
//    if ([dic objectForKey:@"commodity_name"]) {
//        self.commodityName = [dic objectForKey:@"commodity_name"];
//    }
//    if ([dic objectForKey:@"photo_image"]) {
//        self.photoImage = [dic objectForKey:@"photo_image"];
//    }
//    if ([dic objectForKey:@"freight"]) {
//        self.freight = [[dic objectForKey:@"freight"] intValue] / 100;
//    }
//    if ([dic objectForKey:@"commodity_type"]) {
//        self.commodityType = [[dic objectForKey:@"commodity_type"] intValue];
//    }
//    if ([dic objectForKey:@"auction_id"]) {
//        self.auctionId = [[dic objectForKey:@"auction_id"] intValue];
//    }
//    if ([dic objectForKey:@"quantity_list"]) {
//        NSArray *array = [dic objectForKey:@"quantity_list"];
//        if (array && array.count > 0) {
//            NSMutableArray *mutarray = [NSMutableArray array];
//            for (id obj in array) {
//                SoldModel *m = [[SoldModel alloc] initWithDic:obj];
//                [mutarray addObject:m];
//            }
//            self.quantityList = mutarray;
//        }
//    }
//    if ([dic objectForKey:@"selling_status"]) {
//        self.sellingStatus = [[dic objectForKey:@"selling_status"] intValue];
//    }
//    if (self.sellingStatus == 0) {
//        self.sellingStatus = 1;
//    }
//    
//    return self;
//}
//
-(BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    CommodityInfoModel *item = (CommodityInfoModel *)object;
    
    return self.commodityId == item.commodityId;
}

- (NSUInteger)hash
{
    return [NSNumber numberWithBool:self.commodityId].hash;
}

@end

@interface CommoditySpecSKUModel ()<YYModel>
@end
@implementation CommoditySpecSKUModel

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic
{
    NSArray *tmp = [self.attrKey componentsSeparatedByString:@"-"];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (NSString *attrId in tmp) {
        [indexSet addIndex:[attrId integerValue]];
    }
    self.attrIds = indexSet;
    return YES;
}

YYModelDefaultCode
@end

@interface CommoditySpecAttrModel () <YYModel>
@end
@implementation CommoditySpecAttrModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass
{
    return @{@"attr":[CommoditySpecAttr class]};
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic
{
    for (CommoditySpecAttr *attr in self.attr) {
        attr.propId = self.propId;
        attr.selectable = YES;
        attr.selected = NO;
    }
    return YES;
}

YYModelDefaultCode
@end


/**
 递归循环

 @param arr     原始数组
 @param result  结果数组
 @param start   开始位置，起始调用为0
 @param tmp     临时数组，存放索引位置。起始值应当为一个数组，数组大小为指定的元素个数
 @param count   待取的元素个数
 @param NUM     指定的元素个数
 @param arr_len 原始数组长度
 */
static void
combine_increase(NSArray *arr, NSMutableArray *result, int start, int *tmp, int count, const int NUM, const int arr_len)
{
    int i = 0;
    for (i = start; i < arr_len + 1 - count; i++)
    {
        tmp[count - 1] = i;
        if (count - 1 == 0)
        {
            int j;
            NSMutableArray *aResultElement = [NSMutableArray array];
            for (j = NUM - 1; j >= 0; j--){
                [aResultElement addObject:arr[tmp[j]]];
            }
            [result addObject:aResultElement];
        }
        else
            combine_increase(arr, result, i + 1, tmp, count - 1, NUM, arr_len);
    }
}


/**
 从数组中取出若指定个元素的全部组合结果

 @param originArray  原始数组
 @param elementCount 元素个数

 @return 组合结果
 */
static NSArray *
combine(NSArray *originArray, int elementCount){
    
    NSMutableArray *result = [NSMutableArray array];
    int tmp[elementCount];
    combine_increase(originArray, result, 0, tmp, elementCount, elementCount, (int)originArray.count);
    return result;
}

@implementation CommoditySpecAttr

- (NSArray<NSIndexSet *> *)validSKUAttrIdList
{
    if (!_validSKUAttrIdList) {
        NSMutableArray<NSIndexSet *> *validSKUAttrIdList = [NSMutableArray array];
        for (CommoditySpecSKUModel *sku in self.validSKUList) {
            [validSKUAttrIdList addObject:sku.attrIds];
        }
        _validSKUAttrIdList = validSKUAttrIdList;
    }
    return _validSKUAttrIdList;
}

- (NSArray<NSIndexSet *> *)possibleSet:(NSArray<CommoditySpecAttr *> *)selectedAttrList
{
    NSMutableArray *possibleArray = [NSMutableArray array];
    for (int i=1; i<selectedAttrList.count+1; i++) {
        NSArray<NSArray<CommoditySpecAttr *> *> *combineResult = combine(selectedAttrList,i);
        for (NSArray<CommoditySpecAttr *> *tmp in combineResult) {
            
            NSMutableIndexSet *propIds = [NSMutableIndexSet indexSet];
            NSMutableIndexSet *attrIds = [NSMutableIndexSet indexSet];
            for (CommoditySpecAttr *attr in tmp) {
                [propIds addIndex:attr.propId];
                [attrIds addIndex:attr.attrId];
            }
            
            if (![propIds containsIndex:self.propId]) {
                [possibleArray addObject:attrIds];
            }
        }
    }
    return possibleArray;
}

- (BOOL)selectableBySelectedAttr:(NSArray<CommoditySpecAttr *> *)selectedAttrList
{
    // 已选attr的可能组合。排除了和self同一个propId的组合
    //
    //  比如已选 Aa3
    //  组合有： A,a,3,Aa,A3,a3,Aa3, 当前为和A同级别的B，那么结果组合就是 a,3,a3
    NSArray<NSIndexSet *> *possibleAttrIds = [self possibleSet:selectedAttrList];
    
    //  开始检查self的sku列表是否包含possibleAttrIds内的组合
    BOOL selectable = YES;
    for (NSIndexSet *aAttrIds in possibleAttrIds) {
        BOOL find = NO;
        for (NSIndexSet *aValidSKUAttrIds in self.validSKUAttrIdList) {
            if ([aValidSKUAttrIds containsIndexes:aAttrIds]) {
                find = YES;
                break;
            }
        }
        if (!find) {
            selectable = NO;
            break;
        }
    }
    return selectable;
}



-(void)encodeWithCoder:(NSCoder*)aCoder{[self yy_modelEncodeWithCoder:aCoder];}
-(id)initWithCoder:(NSCoder*)aDecoder{self=[super init];return [self yy_modelInitWithCoder:aDecoder];}
-(id)copyWithZone:(NSZone *)zone{return[self yy_modelCopy];}
//-(NSUInteger)hash{return[self yy_modelHash];}
-(BOOL)isEqual:(id)object{return [self yy_modelIsEqual:object];}
@end
