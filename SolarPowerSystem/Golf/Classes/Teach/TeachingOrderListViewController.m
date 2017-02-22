//
//  TeachingOrderListViewController.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/22.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "TeachingOrderListViewController.h"
#import "TeachingOrderModel.h"
#import "TeachingOrderTableViewCell.h"
#import "TeachingOrderDetailViewController.h"
#import "TeachingOrderStatus.h"
#import "GolfSearchRecordADM.h"
#import "PayOnlineViewController.h"
#import "YGBaseNavigationController.h"

@interface TeachingOrderListViewController ()<UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *viewLine;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *btns;
@property (weak, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@end

@implementation TeachingOrderListViewController{
    NSMutableArray *datas;
    NSMutableArray *searchHistoryList;
    
    int size;
    int page;
    BOOL loading;
    BOOL hasMore;
    int orderState;
    
    NSString *keyword;
    
    UISearchBar *searchBar;
    int index;
    
    BOOL canOpenKeyboard;
    
    NSInteger currentIndex;
    NoResultView *noResultView;
}

#pragma mark - 搜索视图相关

- (IBAction)slideToLeft:(id)sender {
    if (_canSlide) {
        if (index -1 >= 0) {
            [self btnPressed:_btns[index-1]];
        }
    }
}

- (IBAction)slideToRight:(id)sender {
    if (_canSlide) {
        if (index +1 < _btns.count) {
            [self btnPressed:_btns[index+1]];
        }
    }
}

- (void)createRecordListView{
    [GolfSearchRecordADM recordListWithCacheName:[[TeachingOrderListViewController class] description] controller:self completion:^(id obj) {
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
    [[NSUserDefaults standardUserDefaults] setObject:arr forKey:[[TeachingOrderListViewController class] description]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



#pragma mark - UI控制

- (IBAction)btnPressed:(UIButton *)btn {
    for (int i = 0; i < _btns.count; i++) {
        UIButton *b = _btns[i];
        b.selected = NO;
        if (b == btn) {
            index = i;
        }
    }
    btn.selected = YES;
    [self lineOffset:btn];
    
    orderState = [@(btn.tag) intValue];
    [self getFirstPage];
}


- (void)lineOffset:(UIButton *)btn{
    CGFloat x = btn.frame.origin.x;
    for (NSLayoutConstraint *c  in [_viewLine.superview constraints]) {
        if (c.firstAttribute == NSLayoutAttributeLeading && c.firstItem == _viewLine) {
            c.constant = x;
            if ([self.view respondsToSelector:@selector(animateWithDuration:delay:usingSpringWithDamping:initialSpringVelocity:options:animations:completion:)]) {
                [UIView animateWithDuration:.3 delay:0 usingSpringWithDamping:6 initialSpringVelocity:6 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
                    [_viewLine layoutIfNeeded];
                } completion:nil];
            }else{
                [UIView animateWithDuration:.3 animations:^{
                    [_viewLine layoutIfNeeded];
                }];
            }
            
            break;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentIndex = -1;
    
    
    datas = [[NSMutableArray alloc] init];
    
    if (_hasSearchButton) {
        [self rightButtonActionWithImg:@"search"];
    }
    
    if (_isSearchViewController) {
        searchHistoryList = [[NSMutableArray alloc] init];
        [searchHistoryList addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:[[TeachingOrderListViewController class] description]]];
        
        [self createRecordListView];
        
        _viewHeader.hidden = YES;
        [_tableView pinToSuperviewEdges:(JRTViewPinTopEdge) inset:0];
        [self.tableView setContentInset:(UIEdgeInsetsMake(64, 0, 0, 0))];
    }else{
        @weakify(self)
        [self.tableView setRefreshHeaderEnable:YES footerEnable:NO callback:^(YGRefreshType type) {
            @strongify(self)
            [self getFirstPage];
        }];
        [self getFirstPage];
        [self.tableView setContentInset:(UIEdgeInsetsMake(104, 0, 0, 0))];
    }
    
    __weak TeachingOrderListViewController *weakSelf = self;
    
    noResultView = [NoResultView text:@"暂无该状态下的订单" type:NoResultTypeBill superView:self.view show:^{
        weakSelf.tableView.hidden = YES;
    } hide:^{
        weakSelf.tableView.hidden = NO;
    }];
}

- (void)doRightNavAction{
    TeachingOrderListViewController *vc = (TeachingOrderListViewController *)[[UIStoryboard storyboardWithName:@"Teach" bundle:NULL] instantiateViewControllerWithIdentifier:@"TeachingOrderListViewController"];
    vc.isSearchViewController = YES;
    vc.canSlide = NO;
    vc.coachId = [LoginManager sharedManager].session.memberId;
    vc.blockCancel = ^(id data){
        if (datas == nil || datas.count == 0) {
            [noResultView show:YES];
        }
    };
    YGBaseNavigationController *nav = [[YGBaseNavigationController alloc] initWithRootViewController:vc];
    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nav animated:YES completion:nil];
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
        [[BaiduMobStat defaultStat] logEvent:@"btnSearchNavButton" eventLabel:@"导航条搜索按钮点击"];
        [MobClick event:@"btnSearchNavButton" label:@"导航条搜索按钮点击"];
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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelSearchBar)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
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
        
        searchBar.placeholder = @"按课程名字查找";
        [searchBar setTintColor:[Utilities R:246.0 G:244.0 B:236.0]];
        [self.navigationController.navigationBar addSubview:searchBar];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [searchBar becomeFirstResponder];
        });
    }
    searchBar.hidden = NO;
}


#pragma mark - 逻辑方法
- (void)getFirstPage{
    page = 1;
    size = 20;
    hasMore = YES;
    [self getTeachingOrderList];
}

- (void)getTeachingOrderList{
    loading = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ServiceManager serviceManagerWithDelegate:self] teachingOrderList:[[LoginManager sharedManager] getSessionId] coachId:_coachId memberId:0 orderState:orderState pageNo:page pageSize:size keyWord:keyword];
    });
}

- (void)serviceResult:(ServiceManager*)serviceManager Data:(id)data flag:(NSString*)flag{

    [self.tableView.mj_header endRefreshing];
    
    NSArray *arr = (NSArray*)data;

    if (Equal(flag, @"teaching_order_list")) {
        if (page == 1) {
            [datas removeAllObjects];
        }
        if (arr && arr.count > 0) {//6.3之后结构改为字典
            NSDictionary *dic = [arr objectAtIndex:0];
            if ([dic objectForKey:@"data_list"]) {
                NSArray *theArray = [dic objectForKey:@"data_list"];
                
 
                if (theArray && theArray.count > 0) {
                    for (id obj in theArray) {
                        [datas addObject:[[TeachingOrderModel alloc] initWithDic:obj]];
                    }
                    page++;
                    hasMore = YES;
                } else {
                    hasMore = NO;
                }
                [noResultView show:datas.count == 0];
            }
        }
    }
    if (_loadingView) {
        [_loadingView removeFromSuperview];
    }
    [self.tableView reloadData];
    loading = NO;
}


#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == datas.count && hasMore == YES) {
        [self getTeachingOrderList];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (datas.count == indexPath.row) {
        return 44;
    }
    return 95;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (datas.count == indexPath.row) {
        return;
    }
    
    currentIndex = indexPath.row;
    
    TeachingOrderModel *m = datas[indexPath.row];
    
    [self pushWithStoryboard:@"Teach" title:[NSString stringWithFormat:@"订单%d",m.orderId] identifier:@"TeachingOrderDetailViewController" completion:^(BaseNavController *controller) {
        TeachingOrderDetailViewController *vc = (TeachingOrderDetailViewController *)controller;
        vc.orderId = m.orderId;
        vc.isCoach = _coachId > 0;
        vc.blockRefresh = ^(id data){
            if (data) {
                int os = [data intValue];
                
                if (index == 0) {
                    if (currentIndex > -1) {
                        TeachingOrderModel *o = datas[currentIndex];
                        o.orderState = os;
                        datas[currentIndex] = o;
                    }
                }else{
                    if (datas.count > indexPath.row) {
                        [datas removeObjectAtIndex:indexPath.row];
                    }
                }
                
                if (_blockRefresh) {
                    _blockRefresh(data);
                }
                [self.tableView reloadData];
            }
            
        };
        vc.blockReturn = ^(id data){
            [self.navigationController popToViewController:self animated:YES];
        };
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return datas.count + (datas.count > 0 ? 1:0);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (datas.count == indexPath.row) {
        UITableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:@"AllLoadedCell" forIndexPath:indexPath];
        return cell;
    }
    
    TeachingOrderModel *m = datas[indexPath.row];
    NSString *identifier = @"TeachingOrderTableViewCell";
    if (_coachId == 0 && m.orderState == 6) {
        identifier = @"TeachingOrderTableViewCell6";
    }
    
    
    TeachingOrderTableViewCell *cell = (TeachingOrderTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    [cell loadData:m isCoach:_coachId > 0];
    if (m.orderState == 6) {
        if (cell.blockReturn == nil) {
            cell.blockReturn = ^(id data){
                if (![LoginManager sharedManager].loginState) {
                    [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES];
                    return;
                }
                TeachingOrderModel *modal = (TeachingOrderModel *)data;

                if (modal.orderState == TeachingOrderStatusWaitPay){
                    PayOnlineViewController *payOnline = [[PayOnlineViewController alloc] init];
                    payOnline.payTotal = modal.orderTotal;
                    payOnline.orderTotal = modal.orderTotal;
                    payOnline.orderId = modal.orderId;
                    payOnline.waitPayFlag = 3;
                    payOnline.productId = modal.productId;
                    payOnline.academyId = modal.academyId;
                    payOnline.classType = modal.classType;
                    payOnline.classHour = modal.classHour;
                    payOnline.blockReturn = ^(id data){
                        [self getFirstPage];
                        [self.navigationController popToViewController:self animated:YES];
                    };
                    [self pushViewController:payOnline title:@"在线支付" hide:YES];
                }
            };
        }
    }
    
    return cell;
}



@end
