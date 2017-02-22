

#import "YGMallBrandCell.h"

NSString *const kYGMallBrandCell = @"YGMallBrandCell";
NSString *const kYGMallBrandCell1 = @"YGMallBrandCell1";

@interface YGMallBrandCell() <UICollectionViewDelegate,UICollectionViewDataSource>
@property (strong, readwrite, nonatomic) NSArray *brands;
@end

@implementation YGMallBrandCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if (self.flowLayout) {
        NSInteger count = 3;
        CGFloat w = (Device_Width - self.flowLayout.sectionInset.left - self.flowLayout.sectionInset.right - (count-1) * self.flowLayout.minimumLineSpacing) / count;
        self.flowLayout.itemSize = CGSizeMake((int)w, self.flowLayout.itemSize.height);
    }
}

- (void)configureWithBrands:(NSArray<YGMallBrandModel *> *)brands
{
    if (_brands != brands) {
        _brands = brands;
        
        if (self.collectionView) {
            [self.collectionView reloadData];
        }else{
            for (YGMallBrandUnit *unit in self.brandUnits) {
                NSUInteger idx = [self.brandUnits indexOfObject:unit];
                if (idx < brands.count) {
                    unit.brand = brands[idx];
                }else{
                    unit.brand = nil;
                }
            }
        }
    }
}

#pragma mark - UICollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.brands.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YGMallBrandCellUnitCell" forIndexPath:indexPath];
    YGMallBrandUnit *unit = [cell viewWithTag:10086];
    unit.brand = self.brands[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [[BaiduMobStat defaultStat] logEvent:@"brankIconClick" eventLabel:@"品牌图标点击"];
    [MobClick event:@"brankIconClick" label:@"品牌图标点击"];
    YGMallBrandModel *brand = self.brands[indexPath.item];
    [[GolfAppDelegate shareAppDelegate] pushToCommodityWithType:3 dataId:brand.brand_id extro:brand.brand_name controller:[self viewController]];
}

@end

@implementation YGMallBrandUnit

- (IBAction)btnAction:(id)sender
{
    if (self.brand ) {
        [[BaiduMobStat defaultStat] logEvent:@"brankIconClick" eventLabel:@"品牌图标点击"];
        [MobClick event:@"brankIconClick" label:@"品牌图标点击"];
        [[GolfAppDelegate shareAppDelegate] pushToCommodityWithType:3 dataId:self.brand.brand_id extro:self.brand.brand_name controller:[self viewController]];
    }
}

- (void)setBrand:(YGMallBrandModel *)brand
{
    _brand = brand;
    
    if (brand) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:brand.brand_logo] placeholderImage:[UIImage imageNamed:@"pinpai_default"]];
        self.titleLabel.text = brand.brand_name;
        self.hidden = NO;
    }else{
        self.hidden = YES;
    }
}
@end
