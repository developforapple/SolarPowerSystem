//
//  CourseSchoolTableViewController.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/15.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CourseSchoolTableViewController.h"
#import "CourseSchoolTableViewCell.h"
#import "CourseSchoolDetailsViewController.h"
#import "UIView+AutoLayout.h"
#import "GolfSearchRecordADM.h"
#import "YGBaseNavigationController.h"

@interface CourseSchoolTableViewController ()<UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

@end

@implementation CourseSchoolTableViewController{
    NSMutableArray *datas;
    
    int size;
    int page;
    BOOL loading;
    BOOL hasMore;
    
    NSString *keyword;
    UISearchBar *searchBar;
    BOOL canOpenKeyboard;
    NSMutableArray *searchHistoryList;
    NoResultView *noResultView;
}

#pragma mark = 搜索视图相关

- (void)createRecordListView{
    if (self.loadingView) {
        [self.loadingView removeFromSuperview];
    }
    [GolfSearchRecordADM recordListWithCacheName:[[CourseSchoolTableViewController class] description] controller:self completion:^(id obj) {
        [searchBar resignFirstResponder];
        keyword = obj;
        searchBar.text = keyword;
        [self getFirstPage];
    } clearCompletion:^{
        [searchHistoryList removeAllObjects];
    } disappearKeyboard:^{
        [searchBar resignFirstResponder];
    }];
}

- (void)getRecordData{
    [searchHistoryList removeAllObjects];
    NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:[[CourseSchoolTableViewController class] description]];
    [searchHistoryList addObjectsFromArray:arr];
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
    [[NSUserDefaults standardUserDefaults] setObject:arr forKey:[[CourseSchoolTableViewController class] description]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - UI相关

- (void)viewDidLoad {
    [super viewDidLoad];
    YGPostBuriedPoint(YGTeachPointSchoolList);
    datas = [[NSMutableArray alloc] init];
    
    if (_hasSearchButton) {
        [self rightButtonActionWithImg:@"search"];
    }
    
    if (_isSearchViewController) {
        searchHistoryList = [[NSMutableArray alloc] init];
        
        [self getRecordData];
        [self createRecordListView];
    }else{
        ygweakify(self);
        [self.tableView setRefreshHeaderEnable:YES footerEnable:NO callback:^(YGRefreshType type) {
            ygstrongify(self);
            [self getFirstPage];
        }];
        [self getFirstPage];
    }
    self.tableView.contentInset = UIEdgeInsetsMake(64.f, 0, 0, 0);
    
    __weak CourseSchoolTableViewController *weakSelf = self;
    noResultView = [NoResultView text:@"暂无数据" type:NoResultTypeList superView:self.view show:^{
        weakSelf.tableView.hidden = YES;
    } hide:^{
        weakSelf.tableView.hidden = NO;
    }];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (_isSearchViewController) {
        searchBar.hidden = YES;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_isSearchViewController) {
        [self showSearchBar];
    }
}

- (void)doRightNavAction{
    CourseSchoolTableViewController *vc = (CourseSchoolTableViewController *)[[UIStoryboard storyboardWithName:@"Teach" bundle:NULL] instantiateViewControllerWithIdentifier:@"CourseSchoolTableViewController"];
    vc.isSearchViewController = YES;
    vc.cityId = _cityId;
    vc.blockCancel = ^(id data){
        if (datas == nil || datas.count == 0) {
            [noResultView show:YES];
        }
    };
    YGBaseNavigationController *nav = [[YGBaseNavigationController alloc] initWithRootViewController:vc];
    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nav animated:YES completion:nil];
}



#pragma mark - UISearchBarDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (!canOpenKeyboard) {
        [searchBar resignFirstResponder];
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
        keyword = sb.text;
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


- (void)showSearchBar{
    [self addCancelButton];
    if (!searchBar){
        searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(8, 0, Device_Width-70, 44)];
        searchBar.delegate = self;
        searchBar.showsCancelButton = NO;
        if ([searchBar respondsToSelector:@selector(setReturnKeyType:)]) {
            searchBar.returnKeyType = UIReturnKeySearch;
        }
        
        searchBar.placeholder = @"按学院名字查找";
        [searchBar setTintColor:[Utilities R:246.0 G:244.0 B:236.0]];
        [self.navigationController.navigationBar addSubview:searchBar];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [searchBar becomeFirstResponder];
        });
    }
    searchBar.hidden = NO;
}


#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return datas.count + (datas.count > 0 ? 1:0);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (datas.count == indexPath.row) {
        return [tableView dequeueReusableCellWithIdentifier:(hasMore ? @"LoadingCell":@"AllLoadedCell") forIndexPath:indexPath];
    }

    CourseSchoolTableViewCell *cell = (CourseSchoolTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CourseSchoolTableViewCell" forIndexPath:indexPath];
    AcademyModel *m = datas[indexPath.row];
    
    if (cell.data == nil || cell.data != m) {
        [Utilities loadImageWithURL:[NSURL URLWithString:m.headImage] inImageView:cell.imgLogo placeholderImage:self.defaultImage changeContentMode:NO];
        [cell.labelName setText:m.academyName];
        [cell.labelLocation setText:[NSString stringWithFormat:@"%.2fkm %@",m.distance,m.shortAddress.length > 0 ? m.shortAddress:@""]];
        [cell.labelTeacherCount setText:[NSString stringWithFormat:@"%d名教练",m.coachCount]];
    }
    cell.data = m;
    
    return cell;
}


#pragma mark - TableViewDelegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == datas.count && hasMore == YES) {
        [self getTeachingAcademyList];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (datas.count == indexPath.row) {
        return 44;
    }
    return 106;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (datas.count == indexPath.row) {
        return;
    }
    [self pushWithStoryboard:@"Teach" title:@"学院详情" identifier:@"CourseSchoolDetailsViewController" completion:^(BaseNavController *controller) {
        CourseSchoolDetailsViewController *vc = (CourseSchoolDetailsViewController *)controller;
        AcademyModel *m = datas[indexPath.row];
        vc.academyId = m.academyId;
        vc.academyModel = m;
        vc.cityId = _cityId;
    }];
}

#pragma mark - 业务逻辑

- (void)getFirstPage{
    page = 1;
    size = 20;
    hasMore = YES;
    [self getTeachingAcademyList];
}

//加载分页数据
- (void)getTeachingAcademyList{
    loading = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ServiceManager serviceManagerWithDelegate:self] getTeachingAcademyList:[LoginManager sharedManager].currLongitude latitude:[LoginManager sharedManager].currLatitude cityId:_cityId keyword:keyword pageNo:page pageSize:size];
    });
}

- (void)serviceResult:(ServiceManager*)serviceManager Data:(id)data flag:(NSString*)flag{
    [self.tableView.mj_header endRefreshing];
    
    NSArray *arr = (NSArray*)data;
    if (Equal(flag, @"teaching_academy_info")) {
        if (page == 1) {
            [datas removeAllObjects];
        }
        if (arr && arr.count > 0) {
            [datas addObjectsFromArray:arr];
            page++;
            hasMore = YES;
        }else{
            hasMore = NO;
        }
        [noResultView show:datas.count == 0];
    }
    if (self.loadingView) {
        [self.loadingView removeFromSuperview];
    }
    [self.tableView reloadData];
    loading = NO;
}


@end
