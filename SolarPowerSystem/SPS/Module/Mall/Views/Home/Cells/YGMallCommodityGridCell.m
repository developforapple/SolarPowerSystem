

#import "YGMallCommodityGridCell.h"
#import "YG_MallCommodityViewCtrl.h"

NSString *const kYGMallCommodityGridCell = @"YGMallCommodityGridCell";

@interface YGMallCommodityGridCell ()
@property (strong, readwrite, nonatomic) NSArray<CommodityModel *> *commodities;
@property (strong, nonatomic) IBOutletCollection(YGMallCommodityUnit) NSArray *units;
@end

@implementation YGMallCommodityGridCell

+ (void)registerIn:(UITableView *)tableView
{
    [tableView registerNib:[UINib nibWithNibName:@"YGMallCommodityGridCell" bundle:nil] forCellReuseIdentifier:kYGMallCommodityGridCell];
}

+ (CGFloat)preferredHeight
{
    return [YGMallCommodityUnit preferredHeight];
}

- (void)configureWithCommodities:(NSArray<CommodityModel *> *)commodities
{
    self.commodities = commodities;
    
    for (YGMallCommodityUnit *unit in self.units) {
        NSInteger idx = [self.units indexOfObject:unit];
        if (idx < commodities.count) {
            [unit configureWithCommodity:commodities[idx]];
        }else{
            [unit configureWithCommodity:nil];
        }
    }
    
}

@end


@interface YGMallCommodityUnit ()

@property (weak, nonatomic) IBOutlet UIButton *actionBtn;
@property (weak, nonatomic) IBOutlet UIImageView *commodityImageView;
@property (weak, nonatomic) IBOutlet UILabel *currentPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *originalPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *commodityNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *yunbiLabel;
@property (weak, nonatomic) IBOutlet UIImageView *yunbiView;

@property (strong, readwrite, nonatomic) CommodityModel *commodity;

@end

@implementation YGMallCommodityUnit

+ (CGFloat)preferredHeight
{
    return 76.f + ceilf(220.f/320.f*(Device_Width/2));
}

- (void)configureWithCommodity:(CommodityModel *)cm
{
    self.commodity = cm;
    
    if (cm) {
        [self.commodityImageView sd_setImageWithURL:[NSURL URLWithString:cm.photoImage] placeholderImage:[UIImage imageNamed:@"cgit_s"]];
        self.commodityNameLabel.text = cm.commodityName;
        self.currentPriceLabel.text = [NSString stringWithFormat:@"%d",cm.sellingPrice];
        self.originalPriceLabel.text = [NSString stringWithFormat:@" ¥%d ",cm.originalPrice];
        self.yunbiView.hidden = cm.giveYunbi<=0;
        self.hidden = NO;
    }else{
        self.hidden = YES;
    }
}

- (IBAction)btnAction:(id)sender
{
    if (self.commodity) {
        YGPostBuriedPoint(YGMallPointOuyu);
        YG_MallCommodityViewCtrl *vc = [YG_MallCommodityViewCtrl instanceFromStoryboard];
//        vc.commodityId = (int)self.commodity.commodityId;
        vc.cid = self.commodity.commodityId;
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }
}

@end
