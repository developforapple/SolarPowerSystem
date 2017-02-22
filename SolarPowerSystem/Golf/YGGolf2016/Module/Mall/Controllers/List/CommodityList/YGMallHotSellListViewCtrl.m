

#import "YGMallHotSellListViewCtrl.h"
#import "YGMallCommodityCell.h"
#import "YG_MallCommodityViewCtrl.h"
#import "YGMallFeedbackViewCtrl.h"
#import "YGPopoverItemsViewCtrl.h"
#import "YGMallViewCtrl.h"
#import "YGMallCartViewCtrl.h"
#import "YGMallCommodityListContainer.h"

@interface YGMallHotSellListViewCtrl ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,assign) int pageNo;
@property (nonatomic,assign) int pageSize;
@property (nonatomic,strong) NSMutableArray *commodityArr;
@property (nonatomic,assign) BOOL isOver;

@end

@implementation YGMallHotSellListViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    YGPostBuriedPoint(YGMallPointThemeDetail);
    
    _pageNo = 1;
    _pageSize = 20;
    _commodityArr = [NSMutableArray array];
    _isOver = NO;
    [_tableView registerNib:[UINib nibWithNibName:@"YGMallCommodityCell" bundle:nil] forCellReuseIdentifier:@"YGMallCommodityCell"];
    [self getThemeList];
    
    [self rightNavButtonImg:@"icon_mall_index_more"];
}

- (void)getThemeList{
    [ServerService commodityThemeCommodity:_themeId gender:[LoginManager sharedManager].session.gender pageNo:_pageNo pageSize:_pageSize success:^(NSArray *list) {
        if (_pageNo == 1) {
            [_commodityArr removeAllObjects];
        }
        [_commodityArr addObjectsFromArray:list];
        if (list.count < _pageSize) {
            _isOver = YES;
        }
        [_tableView reloadData];
        _pageNo ++;
    } failure:^(id error) {
        
    }];
}

- (void)doRightNavAction
{
    NSInteger idx = [self.navigationController.viewControllers indexOfObject:self]-1;
    UIViewController *previousViewCtrl = [self.navigationController.viewControllers objectAtIndex:idx];
    NSMutableArray *items = [NSMutableArray array];
    if (idx != 0) {
        //前面不是首页
        [items addObject:[YGPopoverItem itemWithType:YGPopoverItemTypeHome]];
    }
    if (![previousViewCtrl isKindOfClass:[YGMallViewCtrl class]]) {
        //前面不是商城首页
        [items addObject:[YGPopoverItem itemWithType:YGPopoverItemTypeMall]];
    }
    
    [items addObject:[YGPopoverItem itemWithType:YGPopoverItemTypeMallList]];
    [items addObject:[YGPopoverItem itemWithType:YGPopoverItemTypeMallCart]];
    
    ygweakify(self);
    YGPopoverItemsViewCtrl *vc = [YGPopoverItemsViewCtrl instanceFromStoryboard];
    [vc setupItems:items callback:^(YGPopoverItem *item) {
        ygstrongify(self);
        [YGPopoverItem performDefaultOpeaterOfItem:item fromNavi:self.navigationController];
    }];
    [vc show];
}

// 是否是最后一个cell
- (BOOL)isLastCell:(NSIndexPath *)indexPath
{
    NSUInteger count = [self tableView:self.tableView numberOfRowsInSection:indexPath.section];
    return indexPath.row + 1 == count;
}

// 是否是反馈cell
- (BOOL)isFeedbackCell:(NSIndexPath *)indexPath
{
    return !self.feedbackInvisible && self.isOver && [self isLastCell:indexPath];
}

// 谁否是显示loading的cell
- (BOOL)isLoadingCell:(NSIndexPath *)indexPath
{
    return  !self.isOver && [self isLastCell:indexPath];
}

#pragma mark - UITableView 相关
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger count = self.commodityArr.count;
    if (!_isOver || !self.feedbackInvisible) {  //未加载完，显示loading。加载完了而且外部需要，显示反馈。
        count ++;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isLoadingCell:indexPath]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell" forIndexPath:indexPath];
        return cell;
    }
    
    if ([self isFeedbackCell:indexPath]) {
        UITableViewCell *cell_s = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        cell_s.selectionStyle = UITableViewCellSelectionStyleGray;
        cell_s.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell_s.imageView.image = [UIImage imageNamed:@"yaya"];
        cell_s.textLabel.font = [UIFont systemFontOfSize:14];
        cell_s.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell_s.detailTextLabel.textColor = [Utilities R:138 G:138 B:138];
        cell_s.textLabel.textColor = [Utilities R:6 G:156 B:216];
        cell_s.textLabel.text = @"没找到想要的商品？在这里告诉我们";
        cell_s.detailTextLabel.text = @"我们将尽快为您上架";
        return cell_s;
    }
    
    YGMallCommodityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YGMallCommodityCell" forIndexPath:indexPath];
    cell.textLabel.text = @"";
    cell.hengxianImgView.hidden = NO;
    cell.photoImageView.hidden = NO;
    
    CommodityModel *model = [_commodityArr objectAtIndex:indexPath.row];
    [cell.photoImageView sd_setImageWithURL:[NSURL URLWithString:model.photoImage] placeholderImage:self.defaultImage];
    cell.commodityNameLabel.text = model.commodityName;
    cell.sellingPriceLabel.text = [NSString stringWithFormat:@"¥ %d",model.sellingPrice];
    cell.originalPriceLabel.text = [NSString stringWithFormat:@"¥ %d",model.originalPrice];
    cell.soldQuantityLabel.text = [NSString stringWithFormat:@"已售%d件",model.soldQuantity];
    cell.yunbiLabel.text = [NSString stringWithFormat:@"返%d",model.giveYunbi];
    
    float rebate = ((float)model.sellingPrice/MAX(model.originalPrice, 1)) * 10;
    cell.rebateLabel.text = [NSString stringWithFormat:@"%.01f折",rebate];
    
    if (model.auctionTime.length>0) {
        cell.ruhsingImageView.hidden = NO;
        NSDate *auctionDate = [Utilities getDateFromString:model.auctionTime WithFormatter:@"yyyy-MM-dd HH:mm:ss"];
        NSComparisonResult result = [[NSDate date] compare:auctionDate];
        if (result == NSOrderedAscending) {
            cell.ruhsingImageView.image = [UIImage imageNamed:@"will_rushing.png"];
        }else {
            cell.ruhsingImageView.image = [UIImage imageNamed:@"rushing.png"];
        }
    }else{
        cell.ruhsingImageView.hidden = YES;
    }
    
    if (model.soldQuantity == model.stockQuantity) {
        cell.soldOverLabel.hidden = NO;
        cell.sellingPriceLabel.textColor = [Utilities R:191 G:191 B:191];
    }else{
        cell.soldOverLabel.hidden = YES;
        cell.sellingPriceLabel.textColor = [Utilities R:255 G:109 B:0];
    }
    
    if (cell.soldOverLabel.hidden == YES) {
        cell.yunbiLabel.hidden = model.giveYunbi>0 ? NO : YES;
        if (model.freight<0) {
            cell.freightLabel.hidden = YES;
        }else if (model.freight==0){
            cell.freightLabel.hidden = NO;
            cell.freightLabel.text = @"免运费";
        }else{
            cell.freightLabel.hidden = NO;
            cell.freightLabel.text = [NSString stringWithFormat:@"运费%d元",model.freight];
        }
    }else{
        cell.freightLabel.hidden = YES;
        cell.yunbiLabel.hidden = YES;
    }
    
    [cell handleCellData];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self isLoadingCell:indexPath]) {
        return 40.f;
    }
    if ([self isFeedbackCell:indexPath]) {
        return 60.f;
    }
    return 107.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self isLoadingCell:indexPath]) {
        return;
    }
    if ([self isFeedbackCell:indexPath]) {
        YGMallFeedbackViewCtrl *feedBack = [[YGMallFeedbackViewCtrl alloc] init];
        feedBack.isCommodity = YES;
        [self pushViewController:feedBack title:@"想要的商品" hide:YES];
        return;
    }
    
    CommodityModel *model = [_commodityArr objectAtIndex:indexPath.row];
    
    YG_MallCommodityViewCtrl *vc = [YG_MallCommodityViewCtrl instanceFromStoryboard];
//    vc.commodityId = (int)model.commodityId;
    vc.cid = model.commodityId;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
