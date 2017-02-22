

#import "YGMallViewCtrl.h"
#import "YGMallCategoryCell.h"
#import "YGMallSearchViewCtrl.h"
#import "YGMallPromotionCell.h"
#import "YGMallHotThemeCell.h"
#import "YGMallCommodityGridCell.h"
#import "YGMallCartViewCtrl.h"
#import "CommodityCategory.h"
#import "YGMallBrandCell.h"
#import "YGMallSectionTitleView.h"
#import "YGMallBrandListViewCtrl.h"
#import "YGMallFlashSaleListViewCtrl.h"
#import "YGMallFlashSaleCell.h"

@interface YGMallViewCtrl ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>

@property (nonatomic,weak) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSArray *categoryList;
@property (nonatomic,strong) NSArray *activityList; // 活动列表
@property (nonatomic,strong) NSArray *themeList; // 主题列表
@property (nonatomic,strong) NSMutableArray *ouyuList; // 偶遇列表
@property (nonatomic,strong) NSArray *brandList; //品牌列表
@property (nonatomic,strong) NSArray<YGMallSectionHeaderModel *> *sectionHeaderList; //每个section的头部model

@property (nonatomic,assign) NSInteger pageNo;
@property (nonatomic,assign) NSInteger pageSize;

@property (assign, nonatomic) int loadingMask;

@end

@implementation YGMallViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loadingMask = 0b000000;
    
    ygweakify(self);
    [self.tableView setRefreshHeaderEnable:YES footerEnable:YES callback:^(YGRefreshType type) {
        ygstrongify(self);
        if (type == YGRefreshTypeHeader) {
            [self refresh];
        }else{
            [self fetchOuyuData];
        }
    }];
    
    [YGMallFlashSaleCell registerIn:self.tableView];
    [YGMallSectionTitleView registerIn:self.tableView];
    [YGMallCommodityGridCell registerIn:self.tableView];
    
    // 已经设置了控制器不自动调整insets。这里手动调整为top为63. 因为tableHeaderView的高度为1
    _tableView.contentInset = UIEdgeInsetsMake(63.f, 0, 0, 0);
    _ouyuList = [NSMutableArray array];
    self.sectionHeaderList = [YGMallSectionHeaderModel defaultSectionHeaders:^(YGMallSectionHeaderModel *header) {
        ygstrongify(self);
        [self handleSectionHeaderAction:header];
    }];
    
    _pageNo = 1;
    _pageSize = 20;
    
    [self fetchAllData];
    
    YGPostBuriedPoint(YGMallPointMall);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self rightButtonsView:[self navButtonImage:[UIImage imageNamed:@"shopping_trolley"] IconNum:[GolfAppDelegate shareAppDelegate].systemParamInfo.shoppingCartQuantity isRight:YES]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CommodityTimerStop" object:nil];
}

- (void)reloadSection:(NSInteger)section
{
    self.loadingMask |= 1<<section;
    [self.tableView reloadData];
    
    int mask = 0b1111;
    if ((self.loadingMask & mask) == mask) {
        // 分类、抢拍、品牌、活动 4项都已加载完成
        [self.tableView setHidden:NO animated:YES];
        [self.tableView.mj_header endRefreshing];
    }
}

#pragma mark - Data
- (void)refresh{
    _loadingMask = 0b000000;
    _pageNo = 1;
    [self fetchAllData];
}

- (void)fetchAllData
{
    [self fetchSystemTime];
    [self fetchCategoryList];
    [self fetchAuctionData];
    [self fetchHotBrandList];
    [self fetchActivityList];
    [self fetchHotThemeList];
    [self fetchOuyuData];
}

- (void)fetchSystemTime
{
    if ([LoginManager sharedManager].timeInterGab == KDefaultTimeInterGab) {
        [ServerService getServerTimeWithSuccess:^(NSTimeInterval timeInterval) {
            [LoginManager sharedManager].timeInterGab = timeInterval;
        } failure:nil];
    }
}

- (void)fetchCategoryList{
    [ServerService commodityCategoryWithSuccess:^(NSArray *list) {
        self.categoryList = list;
        [self reloadSection:0];
    } failure:^(id error) {
        [self reloadSection:0];
    }];
}

- (void)fetchAuctionData
{
    // 数据放cell中请求
    [self reloadSection:1];
}

- (void)fetchHotBrandList
{
    [ServerService commodityHotBrandWithSuccess:^(NSArray *list) {
        self.brandList = list;
        [self reloadSection:2];
    } failure:^(id error) {
        [self reloadSection:2];
    }];
}

- (void)fetchActivityList
{
    [[ServiceManager serviceManagerWithDelegate:self] getActivityListByLongitude:[LoginManager sharedManager].currLongitude
                                                                        latitude:[LoginManager sharedManager].currLatitude
                                                                         putArea:6
                                                                      resolution:1 needGroup:NO preventError:NO];
}

- (void)fetchHotThemeList
{
    [ServerService commodityThemeWithSuccess:^(NSArray *list) {
        self.themeList = list;
        [self reloadSection:4];
    } failure:^(id error) {
        [self reloadSection:4];
    }];
}

- (void)fetchOuyuData
{
    [ServerService commodityThemeCommodity:0 gender:[LoginManager sharedManager].session.gender pageNo:_pageNo pageSize:_pageSize success:^(NSArray *list) {
        if (self.pageNo == 1) {
            [self.ouyuList removeAllObjects];
        }
        [self.ouyuList addObjectsFromArray:list];
        
        BOOL isOver = list.count < self.pageSize;
        if (isOver) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }else{
            [self.tableView.mj_footer endRefreshing];
        }
        [self reloadSection:5];
        self.pageNo++;
    } failure:^(id error) {
    }];
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag
{
    NSArray *arr = (NSArray*)data;
    if (Equal(flag, @"activity_list")){
        
        self.activityList = arr;
        [self reloadSection:3];
    }
}

- (void)doRightNavAction
{
    [[LoginManager sharedManager] loginIfNeed:self doSomething:^(id data) {
        YGMallCartViewCtrl *vc = [YGMallCartViewCtrl instanceFromStoryboard];
        [self pushViewController:vc title:@"购物车" hide:YES];
    }];
}

- (void)handleSectionHeaderAction:(YGMallSectionHeaderModel *)header
{
    if (header.type == YGMallSectionTypeBrand) {
        YGMallBrandListViewCtrl *vc = [YGMallBrandListViewCtrl instanceFromStoryboard];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Search
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    YGMallSearchViewCtrl *coachSearch = [[YGMallSearchViewCtrl alloc] init];
    coachSearch.searchType = 4;
    [self pushViewController:coachSearch title:@" " hide:YES animated:YES];
    return NO;
}

#pragma mark - UITableView dataSource && delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    switch (section) {
        case 0: count = 1;  break;  //分类
        case 1: count = 1;  break; //抢拍
        case 2: count = self.brandList.count>0?1:0;  break;  //品牌
        case 3: count = self.activityList.count>0?1:0;  break;  //活动
        case 4: count = ceilf(self.themeList.count/3.f);    break;//热主题
        case 5: count = ceilf(self.ouyuList.count/2.f); break;  //偶遇
        default:break;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:{
            YGMallCategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:kYGMallCategoryCell forIndexPath:indexPath];
            [cell configureWithCategories:self.categoryList];
            return cell;
        }   break;
        case 1:{
            YGMallFlashSaleCell *cell = [tableView dequeueReusableCellWithIdentifier:kYGMallFlashSaleCell forIndexPath:indexPath];
            if (!cell.flashSale) {
                cell.flashSale = [[YGMallFlashSaleLogic alloc] initWithScene:YGMallFlashSaleSceneMallIndex];
            }
            ygweakify(self);
            [cell setDidFinishLoadCallback:^{
                ygstrongify(self);
                [self reloadSection:1];
            }];
            return cell;
        }   break;
        case 2:{
            YGMallBrandCell *cell = [tableView dequeueReusableCellWithIdentifier:kYGMallBrandCell forIndexPath:indexPath];
            [cell configureWithBrands:self.brandList];
            return cell;
        }   break;
        case 3:{
            YGMallPromotionCell *cell = [tableView dequeueReusableCellWithIdentifier:kYGMallPromotionCell forIndexPath:indexPath];
            cell.activityList = _activityList;
            return cell;
        }   break;
        case 4:{
            YGMallHotThemeCell *cell = [tableView dequeueReusableCellWithIdentifier:kYGMallHotThemeCell forIndexPath:indexPath];
            cell.startPoint = indexPath.row==0?YGMallPointHotTheme1:YGMallPointHotTheme4;
            cell.hideLine = indexPath.row == 0;
            cell.themes = [_themeList subarrayWithRange:NSMakeRange(indexPath.row*3, (indexPath.row+1)*3>_themeList.count?_categoryList.count%3:3)];
            return cell;
        }   break;
        case 5:{
            NSInteger index1 = indexPath.row * 2;
            NSInteger index2 = indexPath.row * 2 + 1;
            NSMutableArray *list = [NSMutableArray arrayWithObject:self.ouyuList[index1]];
            if (index2 < self.ouyuList.count) {
                [list addObject:self.ouyuList[index2]];
            }
            YGMallCommodityGridCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YGMallCommodityGridCell" forIndexPath:indexPath];
            [cell configureWithCommodities:list];
            return cell;
        }   break;
        default:
            break;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
//        [[API shareInstance] statisticalNewWithBuriedpoint:50 objectID:0 Success:nil failure:nil];//埋点
//        [[GolfAppDelegate shareAppDelegate] pushToCommodityWithType:4 dataId:-1 extro:@"" controller:self];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.f;
    
    switch (indexPath.section) {
        case 0:{
            height = 172.f;
        }   break;
        case 1:{
            height = [YGMallFlashSaleCell cellSize].height;
//            height = 95.f;
        }   break;
        case 2:{
            height = 108.f;
        }   break;
        case 3:{
            // 设计320的宽度下 高度为 184.f
            height = ceilf(184.f / 320.f * Device_Width);
        }   break;
        case 4:{
            // 设计320的宽度下 高度为146.f
            height = ceilf(146.f / 320.f * Device_Width);
        }   break;
        case 5:{
            return [YGMallCommodityGridCell preferredHeight];
        }   break;
        default:
            break;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = .1f;
    switch (section) {
        case 2:{
            height = self.brandList.count>0?kDefaultHeaderHeight:.1f;
        }   break;
        case 3:{
            height = self.activityList.count>0?kDefaultHeaderHeight:.1f;
        }   break;
        case 4:{
            height = self.themeList.count>0?kDefaultHeaderHeight:.1f;
        }   break;
        case 5:{
            height = self.ouyuList.count>0?kDefaultHeaderHeight:.1f;
        }   break;
        default:break;
    }
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    YGMallSectionHeaderModel *header = self.sectionHeaderList[section];
    
    switch (section) {
        case 2: {
            if (self.brandList.count > 0) {
                YGMallSectionTitleView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kYGMallSectionTitleView];
                header.showMoreBtn = YES;
                [view configureWithHeader:header];
            return view;
            }
        }   break;
        case 3: {
            if (self.activityList.count > 0) {
                YGMallSectionTitleView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kYGMallSectionTitleView];
                [view configureWithHeader:header];
                return view;
            }
        }   break;
        case 4: {
            if (_themeList.count > 0) {
                YGMallSectionTitleView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kYGMallSectionTitleView];
                [view configureWithHeader:header];
                return view;
            }
        }   break;
        case 5: {
            if (_ouyuList.count > 0) {
                YGMallSectionTitleView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kYGMallSectionTitleView];
                [view configureWithHeader:header];
                return view;
            }
        }   break;
        default:break;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = 0.1f;
    switch (section) {
        case 0: height = 10.f;  break;
        case 1: height = 10.f;  break;
        case 2: height = self.brandList.count>0 ? 10.f : .1f;   break;
        case 3: height = self.activityList.count>0 ? 10.f : .1f;break;
        case 4: height = self.themeList.count>0 ? 10.f : .1f;   break;
        case 5: height = self.ouyuList.count>0 ? 10.f : .1f;    break;
        default:break;
    }
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

@end
