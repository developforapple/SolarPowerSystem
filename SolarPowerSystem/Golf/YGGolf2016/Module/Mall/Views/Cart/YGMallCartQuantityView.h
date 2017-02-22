

#import <UIKit/UIKit.h>

/**
 商城中设置数量的步进控件
 */
@interface YGMallCartQuantityView : UIView

@property (nonatomic,assign) BOOL isMantainQuantity; // 如果是购物车值为yes 否则为no
@property (nonatomic,strong) CommodityModel *cm;
@property (nonatomic,copy) BlockReturn refreshBlock;

@end
