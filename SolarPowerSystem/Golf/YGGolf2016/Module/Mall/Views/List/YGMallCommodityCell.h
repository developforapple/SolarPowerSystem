

#import <UIKit/UIKit.h>


/**
 单个商品cell
 */
@interface YGMallCommodityCell : UITableViewCell

@property (nonatomic,strong) IBOutlet UILabel *commodityNameLabel;
@property (nonatomic,strong) IBOutlet UIImageView *photoImageView;
@property (nonatomic,strong) IBOutlet UIImageView *ruhsingImageView;
@property (nonatomic,strong) IBOutlet UILabel *sellingPriceLabel;
@property (nonatomic,strong) IBOutlet UILabel *originalPriceLabel;
@property (nonatomic,strong) IBOutlet UILabel *soldQuantityLabel;
@property (nonatomic,strong) IBOutlet UILabel *rebateLabel;
@property (nonatomic,strong) IBOutlet UILabel *soldOverLabel;
@property (nonatomic,strong) IBOutlet UILabel *freightLabel;
@property (nonatomic,strong) IBOutlet UILabel *yunbiLabel;
@property (nonatomic,strong) IBOutlet UIImageView *hengxianImgView;

- (void)handleCellData;
@end
