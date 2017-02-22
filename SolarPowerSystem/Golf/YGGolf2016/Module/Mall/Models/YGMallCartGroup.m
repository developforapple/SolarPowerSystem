

#import "YGMallCartGroup.h"

@implementation YGMallCartGroup

- (instancetype)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        self.agentId = [dic[@"agentId"] integerValue];
        self.agentName = dic[@"agentName"];
        
        NSMutableArray *commodities = [NSMutableArray array];
        for (id obj in dic[@"commodity"]) {
            CommodityModel *cm = [[CommodityModel alloc] initWithDic:obj];
            cm.agentId = self.agentId;
            cm?[commodities addObject:cm]:0;
        }
        self.commodity = commodities;
    }
    
    return self;
}

+ (NSArray<CommodityModel *> *)commoditiesAtGroup:(NSArray<YGMallCartGroup *> *)groups
{
    NSMutableArray *tmp = [NSMutableArray array];
    for (YGMallCartGroup *group in groups) {
        [tmp addObjectsFromArray:group.commodity];
    }
    return tmp;
}

+ (NSArray<CommodityModel *> *)buyableCommoditiesAtGroup:(NSArray<YGMallCartGroup *> *)groups
{
    NSMutableArray *tmp = [NSMutableArray array];
    for (YGMallCartGroup *group in groups) {
        for (CommodityModel *commodity in group.commodity) {
            if (commodity.sellingStatus == 1) {
                [tmp addObject:commodity];
            }
        }
    }
    return tmp;
}

@end
