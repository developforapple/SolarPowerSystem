

#import <UIKit/UIKit.h>

@protocol YGMallCommoditySortViewDelegate;

/**
 商城商品列表右上排序功能
 */
@interface YGMallCommoditySortView : UIView

@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic,weak) id<YGMallCommoditySortViewDelegate> delegate;
@property (nonatomic,assign) BOOL fromTopic;

+ (YGMallCommoditySortView*)shareSortView:(CGRect)aFrame delegate:(id<YGMallCommoditySortViewDelegate>)aDelegate titles:(NSArray*)titles icons:(NSArray*)icons selectIndex:(NSInteger)aSelectIndex;

- (void)showInView:(UIView *)view coverFrame:(CGRect)frame;

@end

@protocol YGMallCommoditySortViewDelegate <NSObject>

- (void)sortView:(YGMallCommoditySortView *)sortView tapIndex:(NSInteger)aTapIndex;

@end
