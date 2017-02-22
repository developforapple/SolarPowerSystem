

#import <UIKit/UIKit.h>

@protocol YGMallCommodityAllCategoryViewDelegate;

/**
 商城商品分类列表页，右侧显示全部分类名称
 */
@interface YGMallCommodityAllCategoryView : UIView

@property (nonatomic,strong) UITableView *moreTableView;
@property (nonatomic) NSInteger selectIndex;
@property (nonatomic,weak) id<YGMallCommodityAllCategoryViewDelegate> delegate;

+ (YGMallCommodityAllCategoryView *)moreViewWithFrame:(CGRect)frame items:(NSArray*)itemsArray delegate:(id<YGMallCommodityAllCategoryViewDelegate>)aDelegate;
- (void)close;
@end

@protocol YGMallCommodityAllCategoryViewDelegate <NSObject>

- (void)ccMoreView:(YGMallCommodityAllCategoryView *)ccMoreView selectIndex:(NSInteger)index;

@end
