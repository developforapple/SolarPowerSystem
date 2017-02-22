

#import "YGMallCategoryCell.h"
#import "CommodityCategory.h"
#import "YGCollectionViewLayout.h"

NSString *const kYGMallCategoryCell = @"YGMallCategoryCell";

@interface YGMallCategoryCell () <UICollectionViewDelegate,UICollectionViewDataSource>
@property (strong, readwrite, nonatomic) NSArray<CommodityCategory *> *categories;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet YGHorizontalPageableFlowLayout *flowLayout;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@end

@implementation YGMallCategoryCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.flowLayout.itemCountPerRow = 4;
    self.flowLayout.rowCount = 2;
    CGFloat spacing = (Device_Width - self.flowLayout.itemCountPerRow * self.flowLayout.itemSize.width)/self.flowLayout.itemCountPerRow;
    self.flowLayout.minimumLineSpacing = spacing;
    
    UIEdgeInsets insets = self.flowLayout.sectionInset;
    insets.left = spacing/2.f;
    insets.right = spacing/2.f;
    self.flowLayout.sectionInset = insets;
}

- (void)configureWithCategories:(NSArray<CommodityCategory *> *)categories
{
    self.categories = categories;
    self.pageControl.numberOfPages = [self pages];
    [self.collectionView reloadData];
}

#pragma mark -
- (NSInteger)pages
{
    NSInteger base = self.flowLayout.itemCountPerRow * self.flowLayout.rowCount;
    NSInteger dataCount = self.categories.count;
    return dataCount%base==0?dataCount/base:(dataCount/base+1);
}

- (NSInteger)itemsCount
{
    NSInteger base = self.flowLayout.itemCountPerRow * self.flowLayout.rowCount;
    return base * [self pages];
}

- (CommodityCategory *)categoryAtIndex:(NSUInteger)index
{
    if (index < self.categories.count) {
        return self.categories[index];
    }
    return nil;
}

#pragma mark - UICollectionView delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self itemsCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YGMallCategoryUnit *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kYGMallCategoryUnit forIndexPath:indexPath];
    [cell configureWithCategory:[self categoryAtIndex:indexPath.item]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CommodityCategory *category = [self categoryAtIndex:indexPath.item];
    if (category ) {
        [[BaiduMobStat defaultStat] logEvent:@"homeCommodityCategoryClick" eventLabel:@"首页商品类别点击"];
        [MobClick event:@"homeCommodityCategoryClick" label:@"首页商品类别点击"];
        [[GolfAppDelegate shareAppDelegate] pushToCommodityWithType:2 dataId:category.categoryId extro:@"" controller:[self viewController]];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetX = scrollView.contentOffset.x;
    self.pageControl.currentPage = offsetX/CGRectGetWidth(scrollView.frame);
}
@end

@implementation YGMallCategoryUnit
- (void)configureWithCategory:(CommodityCategory *)category
{
    _category = category;
    if (category) {
        [self.categoryImageView sd_setImageWithURL:[NSURL URLWithString:category.categoryIcon] placeholderImage:[UIImage imageNamed:@"moren_"]];
        self.categoryNameLabel.text = category.categoryName;
        self.hidden = NO;
    }else{
        self.hidden = YES;
    }
}
@end

NSString *const kYGMallCategoryUnit = @"YGMallCategoryUnit";
