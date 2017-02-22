

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const kYGMallCommodityGridCell;

/**
 商城首页“偶遇”栏目商品列表cell。以单元格形式显示2个商品。
 */
@interface YGMallCommodityGridCell : UITableViewCell


+ (void)registerIn:(UITableView *)tableView;

/**
 外观高度，根据设备进行了适配
 */
+ (CGFloat)preferredHeight;

@property (strong, readonly, nonatomic) NSArray<CommodityModel *> *commodities;
- (void)configureWithCommodities:(NSArray<CommodityModel *> *)commodities;

@end


/**
 商城商品单元格
 */
@interface YGMallCommodityUnit : UIView

+ (CGFloat)preferredHeight;

@property (strong, readonly, nonatomic) CommodityModel *commodity;
- (void)configureWithCommodity:(CommodityModel *)commodity;

@end
