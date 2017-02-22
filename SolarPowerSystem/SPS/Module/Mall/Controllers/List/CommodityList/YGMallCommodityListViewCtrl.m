

#import "YGMallCommodityListViewCtrl.h"
#import "YGMallCommodityCell.h"
#import "CommodityInfoModel.h"
#import "YGMallFeedbackViewCtrl.h"
#import "MenuHrizontal.h"
#import "SubCommodityCategory.h"
#import "YG_MallCommodityViewCtrl.h"
#import "CalendarClass.h"

@interface YGMallCommodityListViewCtrl ()<UITableViewDataSource, UITableViewDelegate,UIScrollViewDelegate,MenuHrizontalDelegate>{
    int _pageNo;
    BOOL _isLoadData;
    BOOL _isFeedBackShow;
    NSTimeInterval _lastCheckTime;
    UITableView *_tableViewList;
}

@property (nonatomic,strong) MenuHrizontal *mMenuHriZontal;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) NSMutableArray *callList;
@property (nonatomic,strong) NSMutableArray *subCategoryList;
@property (nonatomic) int tagId;
@property (nonatomic) int brandId;
@property (nonatomic) int subCategoryId;
@property (nonatomic) int orderBy;
@property (nonatomic) int selectedIndex;

@end

@implementation YGMallCommodityListViewCtrl{
    UIActivityIndicatorView *loadingView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    loadingView = [UIActivityIndicatorView autoLayoutView];
    loadingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:loadingView];
    [loadingView centerInView:self.view];
    [loadingView constrainToSize:CGSizeMake(20, 20)];
    [loadingView startAnimating];
    
    _tableViewList = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _tableViewList.delegate = self;
    _tableViewList.dataSource = self;
    _tableViewList.hidden = YES;
    _tableViewList.separatorColor = RGBColor(230, 230, 230, 1);
    CGFloat top = [self.qcSlideSwitchView topPanelHeight];
    _tableViewList.contentInset = UIEdgeInsetsMake(top, 0, 0, 0);
    
    @weakify(self);
    [_tableViewList setRefreshHeaderEnable:YES footerEnable:YES callback:^(YGRefreshType type) {
        @strongify(self);
        if (type == YGRefreshTypeHeader) {
             _pageNo = 0;
        }
       
        if (self.tagId > -1) {
            [self getCommodityInfoList:self.orderBy];
        }else{
            [self getCommodityRushingDataList];
        }
    }];
    [self.view addSubview:_tableViewList];
    [self setExtraCellLineHidden:_tableViewList];
    
    _pageNo = 0;
    
    self.dataArray = [NSMutableArray array];
    NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"CommodityCallSetting"];
    self.callList =  [NSMutableArray arrayWithArray:array];
}

- (void)refreshListViewData:(CommodityCategory*)category orderBy:(int)orderBy brandId:(int)brandId index:(int)index{
    [_tableViewList setContentOffset:CGPointMake(0, -_tableViewList.contentInset.top) animated:NO];
    
    _pageNo = 0;
    
    self.tagId = category.categoryId;
    self.brandId = brandId;
    
    if (self.selectedIndex != index || (self.selectedIndex==index&&self.orderBy == orderBy)) {
        self.subCategoryId = 0;
        [self createMenuWithArray:category.subCategoryList];
    }
    self.orderBy = orderBy;
    self.selectedIndex = index;
    
    if (self.tagId > -1) {
        [self getCommodityInfoList:self.orderBy];
    }else{
        _tableViewList.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self getCommodityRushingDataList];
    }
}

- (void)createMenuWithArray:(NSArray*)array{
    if (array.count == 0) {
        return;
    }
    if (self.mMenuHriZontal) {
        if (self.mMenuHriZontal.superview) {
            [self.mMenuHriZontal removeFromSuperview];
        }
        self.mMenuHriZontal = nil;
    }
    
    self.subCategoryList = [NSMutableArray arrayWithArray:array];
    
    NSMutableArray *vButtonItemArray = [NSMutableArray array];
    for (SubCommodityCategory *model in self.subCategoryList) {
        CGSize sz = [Utilities getSize:model.subCategoryName withFont:[UIFont systemFontOfSize:13] withWidth:100];
        CGFloat width = sz.width + 40;
        NSDictionary *dic = @{TITLEKEY:model.subCategoryName,
                              TITLEWIDTH:[NSNumber numberWithFloat:width]
                              };
        [vButtonItemArray addObject:dic];
    }
    
    self.mMenuHriZontal = [[MenuHrizontal alloc] initWithFrame:CGRectMake(0, [self.qcSlideSwitchView topPanelHeight], Device_Width, 36) ButtonItems:vButtonItemArray];
    self.mMenuHriZontal.delegate = self;
    [self.view addSubview:self.mMenuHriZontal];
    
    _tableViewList.contentInset = UIEdgeInsetsMake([self.qcSlideSwitchView topPanelHeight]+36.f, 0, 0, 0);
}


#pragma mark - MenuHrizontal delegate
-(void)didMenuHrizontalClickedButtonAtIndex:(NSInteger)aIndex selected:(BOOL)selected{
    SubCommodityCategory *sub = self.subCategoryList[aIndex];
    self.subCategoryId = selected ? sub.subCategoryId : 0;
    
    _pageNo = 0;
    if (self.tagId > -1) {
        [self getCommodityInfoList:self.orderBy];
    }else{
        _tableViewList.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self getCommodityRushingDataList];
    }
}

- (void)getCommodityInfoList:(int)orderBy{
    _pageNo ++;
    int longitude = [LoginManager sharedManager].currLongitude;
    int latitude = [LoginManager sharedManager].currLatitude;
    [[ServiceManager serviceManagerWithDelegate:self] getCommodityInfoList:self.tagId brandId:self.brandId subCategoryId:self.subCategoryId orderBy:orderBy longitude:longitude latitude:latitude keyWord:nil pageNo:_pageNo];
}

- (void)getCommodityRushingDataList{
    _pageNo ++;
    int longitude = [LoginManager sharedManager].currLongitude;
    int latitude = [LoginManager sharedManager].currLatitude;
    [[ServiceManager serviceManagerWithDelegate:self] getCommodityAuctionWithLongitude:longitude latitude:latitude pageNo:_pageNo pageSize:20];
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    _isLoadData = YES;
    _isFeedBackShow = NO;

    if (_pageNo == 1) {
        [self.dataArray removeAllObjects];
    }
    
    NSArray *array = (NSArray*)data;
    if (array && array.count > 0) {
        if (Equal(flag, @"commodity_info")) {
            [self.dataArray addObjectsFromArray:array];
        }else if (Equal(flag, @"commodity_auction")) {
            [self.dataArray addObjectsFromArray:array];
        }
        loadingView.hidden = YES;
        [_tableViewList reloadData];
        _tableViewList.hidden = NO;
        [_tableViewList.mj_footer endRefreshing];
        [_tableViewList.mj_header endRefreshing];
    }else{
        if (self.tagId>-1) {
            _isFeedBackShow = YES;
        }
        _tableViewList.hidden = NO;
        [_tableViewList reloadData];
    }
    
}

#pragma mark - 表格视图数据源代理方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = _isLoadData ? 1 : 0;
    
    if (self.tagId>-1) {
        return _isFeedBackShow ? self.dataArray.count+1 : self.dataArray.count;
    }else{
        return self.dataArray.count>0 ? self.dataArray.count : count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YGMallCommodityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YGMallCommodityCell"];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"YGMallCommodityCell" owner:self options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
    
    if (self.dataArray.count == indexPath.row) {
        UITableViewCell *cell_s = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        cell_s.selectionStyle = UITableViewCellSelectionStyleGray;
        cell_s.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell_s.imageView.image = [UIImage imageNamed:@"yaya"];
        cell_s.textLabel.font = [UIFont systemFontOfSize:14];
        cell_s.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell_s.detailTextLabel.textColor = [Utilities R:138 G:138 B:138];
        cell_s.textLabel.textColor = MainHighlightColor;
        cell_s.textLabel.text = @"没找到想要的商品？在这里告诉我们";
        cell_s.detailTextLabel.text = @"我们将尽快为您上架";
        return cell_s;
    }
    cell.textLabel.text = @"";
    cell.hengxianImgView.hidden = NO;
    cell.photoImageView.hidden = NO;
    
    CommodityInfoModel *model = [self.dataArray objectAtIndex:indexPath.row];
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
}

- (NSTimeInterval)timeIntervalWithCompareResult:(NSString*)time timeInterGab:(NSTimeInterval)timeInterGab{
    if (!time) {
        return -1;
    }
    NSDate *today = [CalendarClass dateForStandardTodayAll];
    today = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([today timeIntervalSinceReferenceDate] + timeInterGab)];
    NSDate *dt = [Utilities getDateFromString:time WithFormatter:@"yyyy-MM-dd HH:mm:ss"];
    return [dt timeIntervalSinceDate:today];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    YGMallCommodityListContainer *listVC = (YGMallCommodityListContainer *)[self controllerOfView:self.view];
    if (indexPath.row < self.dataArray.count) {
        
        YG_MallCommodityViewCtrl *vc = [YG_MallCommodityViewCtrl instanceFromStoryboard];
        CommodityInfoModel *model = [_dataArray objectAtIndex:indexPath.row];
//        vc.commodityId = model.commodityId;
//        vc.auctionId = _tagId>-1 ? 0 : model.auctionId;
//        vc.refrehCallListBlock = ^(id data){
//            [_callList removeAllObjects];
//            NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"CommodityCallSetting"];
//            self.callList =  [NSMutableArray arrayWithArray:array];
//            [_tableViewList reloadData];
//        };
        vc.cid = model.commodityId;
        [listVC.navigationController pushViewController:vc animated:YES];
    }else{
        YGMallFeedbackViewCtrl *feedBack = [[YGMallFeedbackViewCtrl alloc] init];
        feedBack.isCommodity = YES;
        [listVC pushViewController:feedBack title:@"想要的商品" hide:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.dataArray.count==indexPath.row ? 60 : 107;
}


- (void)addCallNum:(NSInteger)aCommodityId{ // 增加设置提醒的个数
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSArray *array = [userDefault objectForKey:@"CommodityCallSetting"];
    NSMutableArray *mutArray = nil;
    if (array && array.count > 0) {
        mutArray = [NSMutableArray arrayWithArray:array];
        [mutArray addObject:@(aCommodityId)];
    }else{
        mutArray = [NSMutableArray arrayWithObject:@(aCommodityId)];
    }
    self.callList = mutArray;
    [userDefault setObject:mutArray forKey:@"CommodityCallSetting"];
}

- (void)auctionRightNowAction:(UIButton *)button{
    YGMallCommodityListContainer *listVC = [self controllerOfView:self.view];
    CommodityInfoModel *model = [self.dataArray objectAtIndex:button.tag];

    YG_MallCommodityViewCtrl *vc = [YG_MallCommodityViewCtrl instanceFromStoryboard];
//    vc.commodityId = (int)model.commodityId;
//    vc.auctionId = model.auctionId;
//    vc.refrehCallListBlock = ^(id data){
//        [_callList removeAllObjects];
//        NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"CommodityCallSetting"];
//        self.callList =  [NSMutableArray arrayWithArray:array];
//        [_tableViewList reloadData];
//    };
    vc.cid = model.commodityId;
    [listVC.navigationController pushViewController:vc animated:YES];
}


@end
