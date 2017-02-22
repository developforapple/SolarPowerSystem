//
//  CoachTableViewController.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/8.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CoachTableViewController.h"
#import "CoachTableViewCell.h"
#import "JXChooseTime.h"
#import "JXChooseSort.h"
#import "CoachDetailsViewController.h"
#import "CoachDetailCommentModel.h"
#import "GolfSearchRecordADM.h"
#import "BaiduMobStat.h"
#import "YGBaseNavigationController.h"

@interface CoachTableViewController ()<UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *viewActionContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnSort;
@property (weak, nonatomic) IBOutlet UIButton *btnTime;
@property (weak, nonatomic) IBOutlet UIImageView *imgLeft;
@property (weak, nonatomic) IBOutlet UIImageView *imgRight;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewActionTopConstraint;


@end

@implementation CoachTableViewController{
    BOOL showed;
    
    NSMutableArray *searchHistoryList;
    
    NSString *dateCondition;        //日期条件
    NSString *timeCondition;        //时间条件
    NSString *keywordCondition;     //关键字条件
    
    int size;
    int page;
    BOOL loading;
    BOOL hasMore;
    
    int _lastPosition;
    UIImage *imgPointGray,*imgPointBlue;
    
    UISearchBar *searchBar;
    BOOL canOpenKeyboard;
    NoResultView *noResultView;
}


#pragma mark - 逻辑方法
//加载教练分页数据
- (void)getCoachListByPage{
    loading = YES;
    [[ServiceManager serviceManagerWithDelegate:self] getCoachListByPageNo:page
                                                                  pageSize:size
                                                             withLongitude:[LoginManager sharedManager].currLongitude
                                                                  latitude:[LoginManager sharedManager].currLatitude
                                                                    cityId:(_selectedCityModel == nil ? 0:_selectedCityModel.cityId)
                                                                   orderBy:_sortCondition
                                                                      date:dateCondition
                                                                      time:timeCondition
                                                                   keyword:keywordCondition
                                                                 academyId:_academyId productId:_productId];
}

- (void)serviceResult:(ServiceManager*)serviceManager Data:(id)data flag:(NSString*)flag{
    [self.tableView.mj_header endRefreshing];
    
    NSArray *arr = (NSArray*)data;
    if (Equal(flag, @"teaching_coach_info")) {
        if (page == 1) {
            if (!_useControls){
                [_tableView setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
            }
            [_datas removeAllObjects];
        }
        if (arr && arr.count > 0) {
            if (_useControls) { //只有需要展示控件的需求时才对控件做控制
                [_viewActionContainer setHidden:NO];
            }
            [_datas addObjectsFromArray:arr];
            page++;
            hasMore = YES;
        }else{
            hasMore = NO;
        }
        [noResultView show:_datas.count == 0];
    }
    [_loadingView stopAnimating];
    [self.tableView reloadData];
    loading = NO;
}

- (void)getFirstPage{
    page = 1;
    size = 20;
    hasMore = YES;
    [self getCoachListByPage];
}

#pragma mark - UI交互部分

- (void)viewDidLoad {
    [super viewDidLoad];
    
    YGPostBuriedPoint(YGTeachPointCoachList);
    
    if (_datas == nil) {
        _datas = [[NSMutableArray alloc] init];
    }else{
        [self.loadingView stopAnimating];
    }
    
    size = _datas.count > 0 ? [@(_datas.count) intValue]:20;
    page = _datas.count > 0 ? 2:1;
    hasMore = YES;
    
    if (_hasSearchButton) {
        [self rightButtonActionWithImg:@"search"];
    }
    
    _viewActionContainer.hidden = !_useControls;
    
    if (self.isSearchViewController) {
        
        searchHistoryList = [[NSMutableArray alloc] init];
        [searchHistoryList addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:[[CoachTableViewController class] description]]];
        [self createRecordListView];
    }else{
        
        imgPointGray = [UIImage imageNamed:@"ic_down_gray_sj"];
        imgPointBlue = [UIImage imageNamed:@"icon_arrow_down_small_blue"];
        ygweakify(self);
        [self.tableView setRefreshHeaderEnable:YES footerEnable:NO callback:^(YGRefreshType type) {
            ygstrongify(self);
            [self getFirstPage];
        }];
        
        [self.tableView setContentInset:UIEdgeInsetsMake(108, 0, 0, 0)];
        
        if (_datas.count == 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self getCoachListByPage];
            });
        }else{
            _tableView.hidden = NO;
        }
    }
    
    __weak CoachTableViewController *weakSelf = self;
    noResultView = [NoResultView text:@"筛选不到满足条件的教练" type:NoResultTypeList superView:self.view show:^{
        weakSelf.tableView.hidden = YES;
    } hide:^{
        weakSelf.tableView.hidden = NO;
    }];
}

- (void)doRightNavAction{
    CoachTableViewController *vc = (CoachTableViewController *)[[UIStoryboard storyboardWithName:@"Teach" bundle:NULL] instantiateViewControllerWithIdentifier:@"CoachTableViewController"];
    vc.useControls = NO;
    vc.hasSearchButton = NO;
    vc.isSearchViewController = YES;
    vc.selectedCityModel = _selectedCityModel;
    vc.blockCancel = ^(id data){
        if (_datas == nil || _datas.count == 0) {
            [noResultView show:YES];
        }
    };
    
    YGBaseNavigationController *nav = [[YGBaseNavigationController alloc] initWithRootViewController:vc];
    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;;
    [self presentViewController:nav animated:YES completion:nil];
}



-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.isSearchViewController) {
        searchBar.hidden = YES;
    }
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.isSearchViewController) {
        [self showSearchBar];
    }
}

- (void)showSearchBar{
    [self addCancelButton];
    if (!searchBar){
        searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(8, 0, Device_Width - (IS_4_0_INCH_SCREEN ? 65:60), 44)];
        searchBar.delegate = self;
        searchBar.showsCancelButton = NO;
        if ([searchBar respondsToSelector:@selector(setReturnKeyType:)]) {
            searchBar.returnKeyType = UIReturnKeySearch;
        }
        
        searchBar.placeholder = @"按教练名字查找";
        [searchBar setTintColor:[Utilities R:246.0 G:244.0 B:236.0]];
        [self.navigationController.navigationBar addSubview:searchBar];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [searchBar becomeFirstResponder];
        });
    }
    searchBar.hidden = NO;
}


- (void)cancelSearchBar{
    if (searchBar) {
        [searchBar resignFirstResponder];
    }
    if (_blockCancel) {
        _blockCancel(nil);
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)addCancelButton {
    if (self.navigationItem.rightBarButtonItem.action == @selector(cancelSearchBar)) {
        return;
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelSearchBar)];
}

#pragma mark - 搜索视图相关

- (void)createRecordListView{
    if (self.loadingView) {
        [self.loadingView removeFromSuperview];
    }
    [GolfSearchRecordADM recordListWithCacheName:[[CoachTableViewController class] description] controller:self completion:^(id obj) {
        [searchBar resignFirstResponder];
        keywordCondition = obj;
        searchBar.text = keywordCondition;
        [self getFirstPage];
    } clearCompletion:^{
        [searchHistoryList removeAllObjects];
    } disappearKeyboard:^{
        [searchBar resignFirstResponder];
    }];
}


- (void)insertRecordWithString:(NSString*)str{
    if (!str || str.length == 0) {
        return;
    }
    if ([searchHistoryList containsObject:str]) {
        [searchHistoryList removeObject:str];
    }
    [searchHistoryList insertObject:str atIndex:0];
    NSArray *arr = nil;
    if (searchHistoryList.count > 10) {
        arr = [searchHistoryList subarrayWithRange:NSMakeRange(0, 10)];
    }else{
        arr = searchHistoryList;
    }
    [[NSUserDefaults standardUserDefaults] setObject:arr forKey:[[CoachTableViewController class] description]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - UISearchBarDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (!canOpenKeyboard) {
        [searchBar resignFirstResponder];
    }
    if (_useControls == NO) {
        return;
    }
    if (_datas.count < 4) { //记录太少无需滚动隐藏
        return;
    }
    int currentPostion = scrollView.contentOffset.y;
    if (currentPostion - _lastPosition > 25) {
        _lastPosition = currentPostion;
        [self toggleViewActionContainer:NO];
    }else if (_lastPosition > 0 && _lastPosition - currentPostion > 25){
        _lastPosition = currentPostion;
        [self toggleViewActionContainer:YES];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    canOpenKeyboard = NO;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    canOpenKeyboard = YES;
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)sb{
    if (sb.text.length > 0) {
        keywordCondition = sb.text;
        [GolfSearchRecordADM hide];
        [self insertRecordWithString:sb.text];
        [sb resignFirstResponder];
        [self getFirstPage];
    }else{
        [SVProgressHUD showInfoWithStatus:@"请输入搜索内容"];
    }
}

- (void)searchBar:(UISearchBar *)sb textDidChange:(NSString *)searchText{
    if (sb.text.length == 0) {
        [self createRecordListView];
    }
}


#pragma mark - 处理过滤条件控制面板显示与影藏

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self toggleViewActionContainer:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self toggleViewActionContainer:YES];
}


- (void)toggleViewActionContainer:(BOOL)flag{
    if (_useControls == NO) {
        return;
    }
    
    [UIView animateWithDuration:.3f animations:^{
        self.viewActionTopConstraint.constant = flag?0.f:-44.f;
        [self.viewActionContainer layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.viewActionContainer.hidden = !flag;
    }];
    self.viewActionTopConstraint.constant = flag?0.f:-44.f;
}

#pragma mark - 过滤条件与排序规则控制方法

- (IBAction)chooseSort:(UIButton *)btn {
    btn.selected = !btn.selected;
    _imgRight.image = btn.selected ? imgPointBlue:imgPointGray;
    [JXChooseTime hideAnimate:NO];
    if (showed) {
        [JXChooseSort hide];
    }else{
        [JXChooseSort show:_sortCondition supView:self.view belowSubview:_viewActionContainer posY:108 controller:self completion:^(id data) {
            [_btnSort setTitle:data[@"title"] forState:(UIControlStateNormal)];
            _sortCondition = [data[@"value"] intValue];
            [self getFirstPage];
        } showed:^{
            showed = YES;
            _imgRight.image = imgPointBlue;
        } hided:^{
            showed = NO;
            btn.selected = NO;
            _imgRight.image = imgPointGray;
        }];
    }
}

- (IBAction)chooseTime:(UIButton *)btn {
    btn.selected = !btn.selected;
    _imgLeft.image = btn.selected ? imgPointBlue:imgPointGray;
    [JXChooseSort hideAnimate:NO];
    if (showed) {
        [JXChooseTime hide];
    }else{
        // 数据上报点
        [[BaiduMobStat defaultStat] logEvent:@"btnFreeTime" eventLabel:@"空闲时间按钮点击"];
        [MobClick event:@"btnFreeTime" label:@"空闲时间按钮点击"];
        [JXChooseTime jxAnimatedDate:dateCondition time:timeCondition supView:self.view belowSubview:_viewActionContainer posY:107 completion:^(NSString *date, NSString *time) {
            if (date != nil && time != nil) {
                dateCondition = date;
                timeCondition = time;
                NSString *btnTitle = [NSString stringWithFormat:@"%@ %@",[date substringFromIndex:5],time];
                NSInteger day = [Utilities numDayWithBeginDate:[Utilities getDateFromString:date] endDate:[Utilities getDateFromString:[Utilities stringwithDate:[NSDate date]]]];
                if (day == 0) {
                    btnTitle = [NSString stringWithFormat:@"今天 %@",time];
                }
                [_btnTime setTitle:btnTitle forState:(UIControlStateNormal)];
                [self getFirstPage];
            }
        } cleanCompletion:^{
            [_btnTime setTitle:@"空闲时间" forState:(UIControlStateNormal)];
            dateCondition = nil;
            timeCondition = nil;
            [JXChooseTime hide];
            [self getFirstPage];
        } showed:^{
            showed = YES;
            _imgLeft.image = imgPointBlue;
        } hided:^{
            showed = NO;
            btn.selected = NO;
            _imgLeft.image = imgPointGray;
        }];
    }
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datas.count + (_datas.count > 0 ? 1:0);
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == _datas.count && hasMore == YES) {
        [self getCoachListByPage];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_datas.count == indexPath.row) {
        return [tableView dequeueReusableCellWithIdentifier:(hasMore ? @"LoadingCell":@"AllLoadedCell") forIndexPath:indexPath];
    }
    TeachingCoachModel *tcm = _datas[indexPath.row];
    CoachTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CoachTableViewCell" forIndexPath:indexPath];
   [cell loadData:tcm];
    return cell;
}

#pragma mark - TableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_datas.count == indexPath.row) {
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self pushWithStoryboard:@"Teach" title:@"教练详情" identifier:@"CoachDetailsViewController" completion:^(BaseNavController *controller) {
        CoachDetailsViewController *vc = (CoachDetailsViewController *)controller;
        TeachingCoachModel *m = _datas[indexPath.row];
        vc.coachId = m.coachId;
    }];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_datas.count == indexPath.row) {
        return 44;
    }
    return 93;
}

@end
