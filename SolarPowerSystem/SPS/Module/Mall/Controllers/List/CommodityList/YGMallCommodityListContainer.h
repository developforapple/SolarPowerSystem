

#import "BaseNavController.h"
#import "YGMallSlideSwitchView.h"
#import "YGMallCommodityListViewCtrl.h"

/**
 精选商城商品列表容器
 */
@interface YGMallCommodityListContainer : BaseNavController

@property (nonatomic,strong) YGMallSlideSwitchView *slideSwitchView;
@property (nonatomic) int selectIndex;
@property (nonatomic,strong) NSDictionary *data;

@end
