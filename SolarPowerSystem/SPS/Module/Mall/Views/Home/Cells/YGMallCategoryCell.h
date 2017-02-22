

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const kYGMallCategoryCell;

/**
 商城首页分类列表cell
 */
@interface YGMallCategoryCell : UITableViewCell
@property (strong, readonly, nonatomic) NSArray<CommodityCategory *> *categories;
- (void)configureWithCategories:(NSArray<CommodityCategory *> *)categories;
@end


UIKIT_EXTERN NSString *const kYGMallCategoryUnit;

/**
 商城首页单个分类
 */
@interface YGMallCategoryUnit : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *categoryImageView;
@property (weak, nonatomic) IBOutlet UILabel *categoryNameLabel;

@property (strong, readonly, nonatomic) CommodityCategory *category;
- (void)configureWithCategory:(CommodityCategory *)category;

@end
