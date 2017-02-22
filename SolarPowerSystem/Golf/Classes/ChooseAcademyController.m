//
//  ChooseAcademyController.m
//  Golf
//
//  Created by 黄希望 on 15/6/16.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "ChooseAcademyController.h"
#import "MJRefresh.h"
#import "NoResultView.h"
#import "ChooseAcademyCell.h"
#import "YGCapabilityHelper.h"

@interface ChooseAcademyController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>

@property (nonatomic,strong) IBOutlet UITableView *tableView;
@property (nonatomic,weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,assign) int page;
@property (nonatomic,assign) BOOL isMore;
@property (nonatomic,strong) NSString *keyword;

@end

@implementation ChooseAcademyController{
    NoResultView *noResultView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initization];
}

#pragma 初始化
- (void)initization{
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.dataSource = [NSMutableArray array];
    self.page = 1;
    self.isMore = YES;
    self.tableView.mj_footer.hidden = NO;
    
    __weak ChooseAcademyController *weakSelf = self;
    noResultView = [NoResultView text:@"暂无您想要的学院" type:NoResultTypeList superView:self.view show:^{
        weakSelf.tableView.hidden = YES;
    } hide:^{
        weakSelf.tableView.hidden = NO;
    }];
    
    self.tableView.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
        weakSelf.page = 1;
        weakSelf.isMore = YES;
        weakSelf.tableView.mj_footer.hidden = NO;
        [weakSelf loadDataPageNo:weakSelf.page];
    }];
    
    self.tableView.mj_footer = [MJRefreshFooter footerWithRefreshingBlock:^{
        weakSelf.page ++;
        [weakSelf loadDataPageNo:weakSelf.page];
    }];
    
    [self loadDataPageNo:self.page];
}

#pragma 获取数据
- (void)loadDataPageNo:(int)page{
    if (self.isMore) {
        [[ServiceManager serviceManagerWithDelegate:self] getTeachingAcademyList:[LoginManager sharedManager].currLongitude latitude:[LoginManager sharedManager].currLatitude cityId:0 keyword:self.keyword pageNo:page pageSize:20];
    }else{
        [self.tableView.mj_footer endRefreshing];
    }
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray*)data;
    if (Equal(flag, @"teaching_academy_info")) {
        if (self.page == 1) {
            [self.dataSource removeAllObjects];
        }
        [self.dataSource addObjectsFromArray:array];
        if (array.count > 0) {
            self.isMore = YES;
            self.tableView.mj_footer.hidden = NO;
        }else{
            self.isMore = NO;
            self.tableView.mj_footer.hidden = YES;
        }
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        [noResultView show:self.dataSource.count == 0];
    }
}

#pragma mark - UITableView delegate && dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.isMore ? [self.dataSource count] : [self.dataSource count] + 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.dataSource.count ) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FinishLoadCell" forIndexPath:indexPath];
        return cell;
    }else{
        ChooseAcademyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChooseAcademyCell" forIndexPath:indexPath];
        AcademyModel *academy = self.dataSource[indexPath.row];
        cell.naemLabel.text = academy.academyName;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.dataSource.count) {
        AcademyModel *academy = self.dataSource[indexPath.row];
        if (_blockReturn) {
            _blockReturn (academy);
            [self back];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

#pragma mark - UITextfield delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    self.keyword = searchText;
    if (self.keyword.length == 0) {
        [searchBar resignFirstResponder];
        [self.tableView.mj_header beginRefreshing];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    if (searchBar.text.length>0) {
        self.isMore = YES;
        self.page = 1;
        self.keyword = searchBar.text;
        [self loadDataPageNo:self.page];
    }else{
        [SVProgressHUD showInfoWithStatus:@"请输入学院名字"];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_searchBar resignFirstResponder];
}

- (IBAction)phoneClick:(id)sender
{
    [YGCapabilityHelper call:[Utilities getGolfServicePhone] needConfirm:YES];
}

@end
