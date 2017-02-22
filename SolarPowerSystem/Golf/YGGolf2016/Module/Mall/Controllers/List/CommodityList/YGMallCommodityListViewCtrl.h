

#import "BaseNavController.h"
#import "YGMallSlideSwitchView.h"
#import "YGMallCommodityListContainer.h"

/**
 精选商城商品列表
 */
@interface YGMallCommodityListViewCtrl : BaseNavController

@property (nonatomic,strong) YGMallSlideSwitchView *qcSlideSwitchView;

//- (void)refreshListViewDataWithID:(int)aId orderBy:(int)orderBy;

- (void)refreshListViewData:(CommodityCategory*)category orderBy:(int)orderBy brandId:(int)brandId index:(int)index;

@end
