

#import "BaseNavController.h"

/**
 热主题商品列表
 */
@interface YGMallHotSellListViewCtrl : BaseNavController

@property (nonatomic, assign) NSInteger themeId;

// 反馈cell是否不可见。默认为NO，可见。
@property (nonatomic, assign) BOOL feedbackInvisible;

@end
