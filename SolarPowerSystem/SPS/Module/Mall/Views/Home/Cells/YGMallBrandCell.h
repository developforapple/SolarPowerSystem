

#import <UIKit/UIKit.h>

@class YGMallBrandUnit;

UIKIT_EXTERN NSString *const kYGMallBrandCell;  //通用
UIKIT_EXTERN NSString *const kYGMallBrandCell1; //全部品牌列表中额外用到的cellid

/**
 商城商品品牌列表cell
 */
@interface YGMallBrandCell : UITableViewCell
@property (strong, nonatomic) IBOutletCollection(YGMallBrandUnit) NSArray *brandUnits;

@property (strong, readonly, nonatomic) NSArray *brands;
- (void)configureWithBrands:(NSArray<YGMallBrandModel *> *)brands;


@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;



@end

/**
 商城商品品牌单元
 */
@interface YGMallBrandUnit : UIView

@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) YGMallBrandModel *brand;

@end
