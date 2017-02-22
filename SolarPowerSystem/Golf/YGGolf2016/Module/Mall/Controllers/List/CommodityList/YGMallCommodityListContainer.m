

#import "YGMallCommodityListContainer.h"
#import "YGMallCommoditySortView.h"
#import "YGMallSearchViewCtrl.h"
#import "YGMallCommodityAllCategoryView.h"
#import "YGMallBrandTitleView.h"

@interface YGMallCommodityListContainer ()<YGMallSlideSwitchViewDelegate,YGMallCommoditySortViewDelegate,YGMallCommodityAllCategoryViewDelegate>{
    BOOL isFirstLoad;
    BOOL isMoreAppear;
}

@property (nonatomic,strong) NSMutableArray *categoryList;
@property (nonatomic,strong) NSMutableArray *viewControllers;
@property (nonatomic,strong) NSMutableArray *titleList;
@property (nonatomic,strong) NSArray *titleStrArray;
@property (nonatomic,strong) NSMutableArray *iconArray;
@property (nonatomic) int orderBy;
@property (nonatomic) int brandId;
@property (nonatomic) int lastOrderBy;
@property (nonatomic) int lastSelectIndex;
@property (nonatomic) int dataId;
@property (nonatomic,strong) YGMallCommoditySortView *sortView;
@property (nonatomic,strong) YGMallCommodityAllCategoryView *moreView;

@end

@implementation YGMallCommodityListContainer

- (void)dealloc{
    if (self.moreView.superview) {
        [self.moreView.superview removeFromSuperview];
        [self.moreView removeFromSuperview];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    YGPostBuriedPoint(YGMallPointCommodityList);
    
    // 这里不需要自动调整
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.clipsToBounds = YES;
    
    if (self.data) {
        [self changeData:self.data];
    }
}

- (void)changeData:(NSDictionary *)dic{
    int subType = [dic[@"sub_type"] intValue];
    int dataId = [dic[@"data_id"] intValue];
    if (subType == 2) { // 商品列表
        self.brandId = 0;
        self.dataId = dataId;
        [self resetWithBrandId:0 brandName:nil];
    }else if (subType == 3){// 品牌列表
        self.dataId = 0;
        NSString *extro = dic[@"extro"];
        if (extro.length==0) {
            extro = @"品牌优惠";
        }
        [self resetWithBrandId:dataId brandName:extro];
    }else if (subType == 4){
        self.brandId = 0;
        self.dataId = dataId;
        [self resetWithBrandId:0 brandName:nil];
    }
}

- (void)initization{
    [self.navigationItem setRightBarButtonItems:[self twoButtonItems:@[@"coach_sea2",@"commodity_select_icon_1"]]];
    isFirstLoad = NO;
    self.categoryList = [NSMutableArray array];
    self.viewControllers  = [NSMutableArray array];
    self.titleList = [NSMutableArray array];
    
    self.titleStrArray = [NSArray arrayWithObjects:@"推荐排序",@"销量最高",@"价格最低",@"价格最高",@"折扣最低",@"最新上架", nil];
    
    self.iconArray = [NSMutableArray array];
    for (int i=0; i<6; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"commodity_select_icon_0%d",i+1]];
        [self.iconArray addObject:image];
    }
    
    [self getCommodityCategoryInService];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.selectIndex == 1) {
        if (!isFirstLoad) {
            isFirstLoad = YES;
            return;
        }
        CommodityCategory *category = [self.categoryList objectAtIndex:self.selectIndex];
        YGMallCommodityListViewCtrl *qc = [self.viewControllers objectAtIndex:self.selectIndex];
        [qc refreshListViewData:category orderBy:self.orderBy brandId:self.brandId index:self.selectIndex];
    }else{
        isFirstLoad = YES;
    }
}

- (void)getCommodityCategoryInService{
    if (self.brandId>0) {
        [[ServiceManager serviceManagerWithDelegate:self] commodityBrandCategory:self.brandId];
    }else{
        [[ServiceManager serviceManagerWithDelegate:self] getCommodityCategoryData];
    }
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray*)data;
    if (array && array.count > 0) {
        if (Equal(flag, @"commodity_category")) {
            int i = 0;
            NSMutableArray *arr = [NSMutableArray array];
            
            CommodityCategory *category1 = [[CommodityCategory alloc] init];
            category1.categoryId = 0;
            category1.categoryName = @"推荐";
            [arr addObject:category1];
            
            if (self.brandId == 0) {
//                CommodityCategory *category2 = [[CommodityCategory alloc] init];
//                category2.categoryId = -1;
//                category2.categoryName = @"抢购";
//                [arr addObject:category2];
            }
            [arr addObjectsFromArray:array];
            [_categoryList removeAllObjects];
            for (CommodityCategory *category in arr) {
                if (category.categoryId == -100 || category.categoryId == -200) {
                    i++;
                    continue;
                }
                [_categoryList addObject:category];
                if (_dataId != 0 && _dataId == category.categoryId) {
                    _selectIndex = i;
                }
                i++;
            }
            if (self.selectIndex>=self.categoryList.count) {
                self.selectIndex = 0;
            }
        }else if (Equal(flag, @"commodity_brand_category")){
            [self.categoryList addObjectsFromArray:array];
            if (self.selectIndex >= self.categoryList.count) {
                self.selectIndex = 0;
            }
        }
    }
    [self buildNib];
}

- (void)buildNib{
    self.slideSwitchView = [[YGMallSlideSwitchView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.slideSwitchView.selectViewControllerIndex = self.selectIndex;
    self.slideSwitchView.slideSwitchViewDelegate = self;
    [self.view addSubview:self.slideSwitchView];
    
    self.slideSwitchView.tabItemNormalColor = [UIColor blackColor];
    self.slideSwitchView.tabItemSelectedColor = MainHighlightColor; //[Utilities R:6 G:156 B:216];
    self.slideSwitchView.heightOfTopScrollView = 40.0;
    self.slideSwitchView.widthOfButtonMargin = 26.0;
    self.slideSwitchView.isCommodityList = YES;
    
    for (int i=0; i<self.categoryList.count; i++) {
        YGMallCommodityListViewCtrl *qc = [[YGMallCommodityListViewCtrl alloc] init];
        qc.qcSlideSwitchView = self.slideSwitchView;
        [self.viewControllers addObject:qc];
    }
    
    [self.slideSwitchView buildUI];
    
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    moreBtn.frame = CGRectMake(self.view.frame.size.width-51, 64, 51, 40);
    [moreBtn setBackgroundImage:[UIImage imageNamed:@"more.png"] forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:moreBtn];
}

- (void)moreAction{
    isMoreAppear = !isMoreAppear;
    
    if (isMoreAppear) {
        if (self.moreView.superview) {
            [self.moreView removeFromSuperview];
            self.moreView = nil;
        }
        self.moreView = [YGMallCommodityAllCategoryView moreViewWithFrame:CGRectMake(0, 40+64.f, Device_Width, CGRectGetHeight(self.view.frame)-64.f-40.f) items:self.titleList delegate:self];
        self.moreView.selectIndex = self.selectIndex;
        [self.view addSubview:self.moreView];
    }else{
        [self.moreView close];
    }
}

- (void)ccMoreView:(YGMallCommodityAllCategoryView *)ccMoreView selectIndex:(NSInteger)index{
    isMoreAppear = NO;
    CGRect rt = ccMoreView.moreTableView.frame;
    rt.origin.x = Device_Width;
    [UIView animateWithDuration:0.4 delay:0.4 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        ccMoreView.moreTableView.frame = rt;
    } completion:^(BOOL finished) {
        [ccMoreView.moreTableView removeFromSuperview];
        [ccMoreView removeFromSuperview];
    }];
    
    [self.slideSwitchView changeViewWithIndex:index];
}

#pragma mark - 滑动tab视图代理方法

- (NSUInteger)numberOfTab:(YGMallSlideSwitchView *)view
{
    return self.categoryList.count;
}

- (UIViewController *)slideSwitchView:(YGMallSlideSwitchView *)view viewOfTab:(NSUInteger)number
{
    CommodityCategory *category = [self.categoryList objectAtIndex:number];
    YGMallCommodityListViewCtrl *qc = [self.viewControllers objectAtIndex:number];
    qc.title = category.categoryName;
    if (self.titleList.count<self.viewControllers.count) {
        [self.titleList addObject:qc.title];
    }
    return qc;
}

- (void)slideSwitchView:(YGMallSlideSwitchView *)view didselectTab:(NSUInteger)number
{
    if (self.moreView.superview) {
        [self.moreView removeFromSuperview];
        self.moreView = nil;
    }
    self.selectIndex = [@(number) intValue];
//    if (self.selectIndex == 1&&self.brandId == 0) {
//        [self.navigationItem setRightBarButtonItems:[self twoButtonItems:@[@"",@""]]];
//    }else{
        NSString *iamgeName = [NSString stringWithFormat:@"commodity_select_icon_%d.png",self.orderBy+1];
        [self.navigationItem setRightBarButtonItems:[self twoButtonItems:@[@"coach_sea2",iamgeName]]];
//    }
    [self changeSelectViewWithSelectIndex:self.selectIndex orderBy:self.orderBy brandId:self.brandId];
}

- (void)changeSelectViewWithSelectIndex:(int)aSelectIndex orderBy:(int)aOrderBy brandId:(int)brandId{
    if (self.categoryList.count == 0 || self.viewControllers.count == 0) {
        return;
    }
    CommodityCategory *category = [self.categoryList objectAtIndex:aSelectIndex];
    YGMallCommodityListViewCtrl *qc = [self.viewControllers objectAtIndex:aSelectIndex];
    if (self.lastSelectIndex != aSelectIndex || (self.selectIndex==0 && self.lastSelectIndex == 0)) {
        self.lastSelectIndex = aSelectIndex;
        [qc refreshListViewData:category orderBy:self.orderBy brandId:brandId index:self.selectIndex];
        return;
    }
    
    if (aOrderBy != self.lastOrderBy) {
        self.lastOrderBy = aOrderBy;
        [qc refreshListViewData:category orderBy:self.orderBy brandId:brandId index:self.selectIndex];
    }
}

- (void)rightItemsButtonAction:(UIButton*)button{
    if (button.tag == 1) {
        YGMallSearchViewCtrl *coachSearch = [[YGMallSearchViewCtrl alloc] init];
        coachSearch.searchType = 4;
        [self pushViewController:coachSearch title:@"" hide:YES];
    }else{
        [self doRightNavAction];
    }
}

- (void)doRightNavAction{
    if (self.sortView) {
        [self.sortView.superview removeFromSuperview];
        self.sortView = nil;
        return;
    }
    
    self.sortView = [YGMallCommoditySortView shareSortView:CGRectMake(Device_Width-188, 64.f+8.f, 145, 245) delegate:self titles:_titleStrArray icons:_iconArray selectIndex:self.orderBy];
    [self.sortView showInView:self.view coverFrame:[UIScreen mainScreen].bounds];
}

- (void)sortView:(YGMallCommoditySortView *)sortView tapIndex:(NSInteger)aTapIndex{
    [sortView.superview removeFromSuperview];
    sortView = nil;
    self.sortView = nil;
    
    self.orderBy = [@(aTapIndex) intValue];
    NSString *iamgeName = [NSString stringWithFormat:@"commodity_select_icon_%tu.png",aTapIndex+1];
    [self.navigationItem setRightBarButtonItems:[self twoButtonItems:@[@"coach_sea2",iamgeName]]];
    [self changeSelectViewWithSelectIndex:self.selectIndex orderBy:self.orderBy brandId:self.brandId];
}

- (void)loginButtonPressed:(id)sender{
    [self doRightNavAction];
}

- (void)resetWithBrandId:(int)brandId brandName:(NSString*)brandName{
    self.categoryList = nil;
    self.viewControllers = nil;
    self.titleList = nil;
    self.titleStrArray = nil;
    self.iconArray = nil;
    self.orderBy = 0;
    self.brandId = brandId;
    self.lastOrderBy = 0;
    self.lastSelectIndex = 0;
    self.selectIndex = 0;
    self.moreView = nil;
    isFirstLoad = NO;
    isMoreAppear = NO;
    if (self.moreView.superview) {
        [self.moreView removeFromSuperview];
        self.moreView = nil;
    }
    if (self.brandId>0 && brandName.length>0) {
        [self.navigationItem setTitleView:[YGMallBrandTitleView shareInstance:brandName completion:^(YGMallBrandTitleView *brandNavView) {
            [brandNavView removeFromSuperview];
            brandNavView = nil;
            [self.navigationItem setTitleView:nil];
            self.title = @"精选商城";
            
            self.brandId = 0;
            self.selectIndex = 0;
            [self initization];
        }]];
        [self initization];
    }else{
        [self initization];
    }
    
}

@end
