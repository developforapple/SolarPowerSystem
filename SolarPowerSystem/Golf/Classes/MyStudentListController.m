//
//  MyStudentListController.m
//  Golf
//
//  Created by 黄希望 on 15/6/5.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "MyStudentListController.h"
#import "MJRefresh.h"
#import "NoResultView.h"
#import "MyStudentCell.h"
#import "MyStudentDetailController.h"
#import "YGMyStudentDetailViewCtrl.h"

@interface MyStudentListController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>{
    BOOL canOpenKeyBoard;
    NoResultView *noResultView;
}

@property (nonatomic,strong) IBOutlet UITableView *tableView;
@property (nonatomic,weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,assign) int page;
@property (nonatomic,assign) BOOL isMore;
@property (nonatomic,strong) NSString *term;

@end

@implementation MyStudentListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self initization];
}

#pragma mark - 初始化
- (void)initization{
    self.dataSource = [NSMutableArray array];
    self.page = 1;
    self.isMore = YES;
    
    __weak MyStudentListController *weakSelf = self;
    noResultView = [NoResultView text:@"暂无学员" type:NoResultTypeList superView:self.view show:^{
        weakSelf.tableView.hidden = YES;
    } hide:^{
        weakSelf.tableView.hidden = NO;
    }];
    ygweakify(self);
    [self.tableView setRefreshHeaderEnable:YES footerEnable:NO callback:^(YGRefreshType type) {
        ygstrongify(self);
        self.page = 1;
        self.isMore = YES;
        self.term = nil;
        self.searchBar.text = @"";
        self.searchBar.showsCancelButton = NO;
        [self.searchBar resignFirstResponder];
        [self loadDataPageNo:self.page];
    }];
//    self.tableView.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
//        weakSelf.page = 1;
//        weakSelf.isMore = YES;
//        weakSelf.term = nil;
//        weakSelf.searchBar.text = @"";
//        weakSelf.searchBar.showsCancelButton = NO;
//        [weakSelf.searchBar resignFirstResponder];
//        weakSelf.tableView.mj_footer.hidden = NO;
//        [weakSelf loadDataPageNo:weakSelf.page];
//    }];
    
//    self.tableView.mj_footer = [MJRefreshFooter footerWithRefreshingBlock:^{
//        weakSelf.page ++;
//        [weakSelf loadDataPageNo:weakSelf.page];
//    }];

    [self loadDataPageNo:self.page];
}

#pragma 获取数据
- (void)loadDataPageNo:(int)page
{
    if (self.isMore) {
        [[ServiceManager serviceManagerWithDelegate:self] teachingCoachMemberList:[[LoginManager sharedManager] getSessionId] coachId:[LoginManager sharedManager].session.memberId memberId:0 pageNo:page pageSize:20 keyWord:self.term];
    }
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray*)data;
    if (Equal(flag, @"teaching_coach_member_list")) {
        if (self.page == 1) {
            [self.dataSource removeAllObjects];
        }
        [self.dataSource addObjectsFromArray:array];
        if (array.count < 20) {
            self.isMore = NO;
        }else{
            self.isMore = YES;
        }
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        
        [noResultView show:self.dataSource.count == 0];
    }
}

#pragma mark - UITableView delegate && dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataSource count] + 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.dataSource.count ) {
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FinishLoadCell" forIndexPath:indexPath];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:(self.isMore ? @"LoadingCell":@"AllLoadedCell") forIndexPath:indexPath];
        return cell;
    }else{
        MyStudentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyStudentCell" forIndexPath:indexPath];
        cell.student = self.dataSource[indexPath.row];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.dataSource.count) {
        
        StudentModel *model = self.dataSource[indexPath.row];
        YGMyStudentDetailViewCtrl *vc = [YGMyStudentDetailViewCtrl instanceFromStoryboard];
        vc.memberId = model.memberId;
        // 修改了刷新
        ygweakify(self)
        vc.myStudentDetailRefreshBllock = ^(){
            ygstrongify(self)
            self.page = 1;
            self.isMore = YES;
            [self loadDataPageNo:self.page];
        };
        
        // 修改备注刷新
        vc.myStudentDetailRemarkNameBlock = ^(StudentModel *studentModel) {
            ygstrongify(self)
            if (studentModel && model.memberId == studentModel.memberId) {
                model.displayName = studentModel.displayName;
                model.isFollowed = studentModel.isFollowed;
            }
            [self.tableView reloadData];
        };
        
        [self.navigationController pushViewController:vc animated:YES];
        
//        [self pushWithStoryboard:@"Coach" title:@"学员详情" identifier:@"MyStudentDetailController" completion:^(BaseNavController *controller) {
//            MyStudentDetailController *msd = (MyStudentDetailController*)controller;
//            msd.student = model;
//        }];
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.dataSource.count) {
        return 44;
    }else{
        return 80;
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isMore && indexPath.row == self.dataSource.count) {
        self.page ++;
        [self loadDataPageNo:self.page];
    }
}

#pragma mark - UISearchBar delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    searchBar.showsCancelButton = YES;
    canOpenKeyBoard = YES;
    return YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    canOpenKeyBoard = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        canOpenKeyBoard = NO;
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    self.term = searchText;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [[BaiduMobStat defaultStat] logEvent:@"btnSearchBarButton" eventLabel:@"搜索条搜索按钮点击"];
    [MobClick event:@"btnSearchBarButton" label:@"搜索条搜索按钮点击"];
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
    if (searchBar.text.length>0) {
        self.isMore = YES;
        self.page = 1;
        self.term = searchBar.text;
        [self loadDataPageNo:self.page];
    }else{
        [SVProgressHUD showInfoWithStatus:@"请输入学员名字"];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    searchBar.showsCancelButton = NO;
    searchBar.text = @"";
    self.page = 1;
    self.isMore = YES;
    self.term = nil;
    [self loadDataPageNo:self.page];
    [searchBar resignFirstResponder];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (!canOpenKeyBoard) {
        [_searchBar resignFirstResponder];
        _searchBar.showsCancelButton = NO;
    }
}

@end
