

#import "YGMallSearchViewCtrl.h"
#import "LoginManager.h"
#import "YGMallCommodityCell.h"
#import "YG_MallCommodityViewCtrl.h"
#import "CalendarClass.h"

@interface YGMallSearchViewCtrl (){
    BOOL _isSearch;
    int _pageNo;
    BOOL _isRefresh;
    BOOL _isPull;
    BOOL _isload;
}
@property (nonatomic,strong) NSMutableArray *searchCoachList;
@property (nonatomic,strong) NSMutableArray *localList;
@property (nonatomic,strong) NSIndexPath *lastIndexPath;
@end

@implementation YGMallSearchViewCtrl

-(void)awakeFromNib{
    [super awakeFromNib];
    [self.view layoutIfNeeded];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self noLeftButton];
    [self rightButtonAction:@"取消"];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.searchCoachList = [NSMutableArray array];
    self.localList = [NSMutableArray array];
    _isSearch = NO;
    
    _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    ygweakify(self);
    [_tableView setRefreshHeaderEnable:YES footerEnable:YES callback:^(YGRefreshType type) {
        ygstrongify(self);
        [self refresh:type];
    }];
    [self.view addSubview:_tableView];
    [self setExtraCellLineHidden:_tableView];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_searchBar resignFirstResponder];
    _searchBar.hidden = YES;
}

- (void)doRightNavAction{
    [_searchBar resignFirstResponder];
    [_searchBar removeFromSuperview];
    _searchBar = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.searchType == 4){
        _searchBar.placeholder = @"按商品名称搜索";
    }else if (self.searchType == 5){
        _searchBar.placeholder = @"Golf文章热门词";
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (!_searchBar){
        [self.navigationController.navigationBar layoutIfNeeded];
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(8, 0, Device_Width-65, 44)];
        _searchBar.delegate = self;
        _searchBar.showsCancelButton = NO;
        [_searchBar setBarTintColor:[Utilities R:246.0 G:244.0 B:236.0]];
        [_searchBar setTintColor:MainHighlightColor];
        [self.navigationController.navigationBar addSubview:_searchBar];
    }
    
    _searchBar.hidden = NO;
    
    NSString *key = nil;
    if (self.searchType == 4){
        key = @"CommoditySearchList";
    }else if (self.searchType == 5){
        key = @"ArticleSearchList";
    }
    
    if (!_isSearch) {
        [_searchBar becomeFirstResponder];
        NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        if (array && array.count>0) {
            [self.localList removeAllObjects];
            [self.localList addObjectsFromArray:array];
        }
        _isRefresh = NO;
        _isPull = NO;
        _pageNo = 0;
        [_tableView reloadData];
    }else{
        if (self.localList.count>0) {
            _searchBar.text = [self.localList objectAtIndex:0];
        }
    }
}

- (void)refresh:(YGRefreshType)type
{
    BOOL isMore = type==YGRefreshTypeFooter;
    if (isMore) {
        _isPull = YES;
        [self getSearchCoachList];
    }else{
        _isRefresh = YES;
        _pageNo = 0;
        [self getSearchCoachList];
    }
}

- (void)getSearchCoachList{
    _pageNo ++;
    
    double longitude = [LoginManager sharedManager].currLongitude;
    double latitude = [LoginManager sharedManager].currLatitude;
    if (longitude==0&&latitude==0) {
        longitude = 114.0;
        latitude = 22.0;
    }
    
    if (_searchBar.text.length == 0) {
        [_tableView.mj_header endRefreshing];
        [_tableView.mj_footer resetNoMoreData];
        return;
    }
    
    if (self.searchType == 4){
        [[ServiceManager serviceManagerWithDelegate:self] getCommodityInfoList:0 brandId:0 subCategoryId:0 orderBy:0 longitude:longitude latitude:latitude keyWord:_searchBar.text pageNo:_pageNo];
    }else if (self.searchType == 5){
        [[ServiceManager serviceManagerWithDelegate:self] articleInfo:0 pageNo:1 pageSize:50 keyWord:_searchBar.text];
    }
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray *)data;
    if (Equal(flag, @"search_coach")||Equal(flag, @"search_academy")||Equal(flag, @"search_driving_range")||Equal(flag, @"commodity_info")||Equal(flag, @"article_info")) {
        _isload = YES;
        if (array && array.count > 0) {
            if (_pageNo == 1) {
                [_searchCoachList removeAllObjects];
            }
            if (_isPull) {
                _isPull = NO;
                [self.searchCoachList addObjectsFromArray:array];
            }
            else if (_isRefresh) {
                _isRefresh = NO;
                [self.searchCoachList removeAllObjects];
                [self.searchCoachList addObjectsFromArray:array];
            }else{
                [self.searchCoachList removeAllObjects];
                [self.searchCoachList addObjectsFromArray:array];
            }
        }
    }
    [_tableView.mj_footer endRefreshing];
    [_tableView.mj_header endRefreshing];
    [_tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_isSearch) {
        return self.searchCoachList.count==0 ? 1 : self.searchCoachList.count;
    }else{
        return self.localList.count>0 ? self.localList.count : 1;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_isSearch) {
        if (self.searchCoachList.count == 0) {
            if (_isload) {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.font = [UIFont systemFontOfSize:14];
                cell.textLabel.textColor = [Utilities R:138 G:138 B:138];
                cell.textLabel.text = @"无匹配的结果";
                return cell;
            }
        }
        if (self.searchType == 4){
            YGMallCommodityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YGMallCommodityCell"];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"YGMallCommodityCell" owner:self options:nil] lastObject];
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                cell.textLabel.font = [UIFont systemFontOfSize:14];
            }
            cell.textLabel.text = @"";
            cell.hengxianImgView.hidden = NO;
            cell.photoImageView.hidden = NO;
            
            CommodityInfoModel *model = [self.searchCoachList objectAtIndex:indexPath.row];
            [cell.photoImageView sd_setImageWithURL:[NSURL URLWithString:model.photoImage] placeholderImage:self.defaultImage];
        
            cell.commodityNameLabel.text = model.commodityName;
            cell.sellingPriceLabel.text = [NSString stringWithFormat:@"¥ %d",model.sellingPrice];
            cell.originalPriceLabel.text = [NSString stringWithFormat:@"¥ %d",model.originalPrice];
            cell.soldQuantityLabel.text = [NSString stringWithFormat:@"已售%d件",model.soldQuantity];
            cell.yunbiLabel.text = [NSString stringWithFormat:@"返%d",model.yunbi];
            
            float rebate = ((float)model.sellingPrice/MAX(model.originalPrice, 1)) * 10;
            cell.rebateLabel.text = [NSString stringWithFormat:@"%.01f折",rebate];
            
            if (model.auctionTime.length>0) {
                cell.ruhsingImageView.hidden = NO;
                NSDate *auctionDate = [Utilities getDateFromString:model.auctionTime WithFormatter:@"yyyy-MM-dd HH:mm:ss"];
                NSDate *currentDate = [CalendarClass dateForStandardTodayAll];
                if ([currentDate timeIntervalSinceDate:auctionDate] >= 0) {
                    cell.ruhsingImageView.image = [UIImage imageNamed:@"rushing.png"];
                }else{
                    cell.ruhsingImageView.image = [UIImage imageNamed:@"will_rushing.png"];
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
                cell.yunbiLabel.hidden = model.yunbi>0 ? NO : YES;
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
        }else if (self.searchType == 5){

            return nil;
        }
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if (self.localList.count>0) {
            cell.textLabel.text = [self.localList objectAtIndex:indexPath.row];
        }else{
            cell.textLabel.text = @"无历史搜索记录";
            cell.textLabel.font = [UIFont systemFontOfSize:14];
        }
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (Device_SysVersion<7.0) {
        return 0;
    }
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_isSearch) {
        if (self.searchCoachList.count>0) {
            if (self.searchType == 4){
                return 107;
            }else if (self.searchType == 5){
                return 84;
            }
        }else{
            return 60;
        }
    }else{
        if (self.localList.count>0) {
            return 40;
        }else{
            return 60;
        }
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (!_isSearch) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Device_Width, 40)];
        view.backgroundColor = [UIColor whiteColor];
        
        if (self.localList.count>0) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.backgroundColor = [UIColor clearColor];
            btn.frame = CGRectMake(0, 1, Device_Width, 40);
            [btn setTitle:@"清空搜索记录" forState:UIControlStateNormal];
            [btn setTitleColor:[Utilities R:6 G:156 B:216] forState:UIControlStateNormal];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:15]];
            [btn addTarget:self action:@selector(clearHistoryList:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:btn];
        }

        return view;
        
    }else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (!_isSearch&&self.localList.count>0) {
        return 40;
    }else{
        if (Device_SysVersion<7.0) {
            return 0;
        }
        return 0.1;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!_isSearch) {
        _isSearch = YES;
        [_searchBar resignFirstResponder];
        if (self.localList.count == indexPath.row || self.localList.count == 0) {
            return;
        }
        NSString *str = [self.localList objectAtIndex:indexPath.row];
        _searchBar.text = str;
        _pageNo = 0;
        [self getSearchCoachList];
    }else {
        if (self.searchCoachList.count==0) {
            return;
        }
        if (self.searchType == 4){
            // 数据上报采集点
            [[BaiduMobStat defaultStat] logEvent:@"commodityHistroySearch" eventLabel:@"商品历史搜索点击"];
            [MobClick event:@"commodityHistroySearch" label:@"商品历史搜索点击"];
            CommodityInfoModel *model = [self.searchCoachList objectAtIndex:indexPath.row];
            
            YG_MallCommodityViewCtrl *vc = [YG_MallCommodityViewCtrl instanceFromStoryboard];
//            vc.commodityId = model.commodityId;
            vc.cid = model.commodityId;
            [self.navigationController pushViewController:vc animated:YES];

        }else if (self.searchType == 5){
            //旧版文章已去除
        }
    }
}

- (void)clearHistoryList:(UIButton*)button{
    NSString *key = nil;
    if (self.searchType == 4){
        key = @"CommoditySearchList";
    }else if (self.searchType == 5){
        key = @"ArticleSearchList";
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];

    [self.localList removeAllObjects];
    _isSearch = NO;
    _isRefresh = NO;
    _pageNo = 0;
    [_tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchBar.text.length==0) {
        _isSearch = NO;
    }else{
        _isSearch = YES;
    }
    
    if (!_isSearch) {
        [self.searchCoachList removeAllObjects];
        [_tableView reloadData];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    if (searchBar.text.length>0) {
        _isSearch = YES;
        _pageNo = 0;
        if ([self.localList containsObject:searchBar.text]) {
            [self.localList removeObject:searchBar.text];
        }
        [self.localList insertObject:searchBar.text atIndex:0];

        NSString *key = nil;
        if (self.searchType == 4){
            // 数据上报采集点
            [[BaiduMobStat defaultStat] logEvent:@"btnCommoditySearch" eventLabel:@"商品搜索按钮点击"];
            [MobClick event:@"btnCommoditySearch" label:@"商品搜索按钮点击"];
            key = @"CommoditySearchList";
        }else if (self.searchType == 5){
            key = @"ArticleSearchList";
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:self.localList forKey:key];

        [self getSearchCoachList];
    }else{
        [SVProgressHUD showInfoWithStatus:@"请输入搜索内容"];
    }
}

- (void)refreshList{
    _pageNo = 0;
    _isRefresh = YES;
    [self getSearchCoachList];
}

@end
