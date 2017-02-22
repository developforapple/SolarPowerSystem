//
//  PublicCourseHomeController.m
//  Golf
//
//  Created by 黄希望 on 15/5/8.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "PublicCourseHomeController.h"
#import "PublicCourseDetailController.h"
#import "PublicCourseSearchController.h"
#import "JXChooseTimeController.h"
#import "NoMoreTableViewCell.h"
#import "YGBaseNavigationController.h"

@interface PublicCourseHomeController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation PublicCourseHomeController{
    NoResultView *noResultView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout=UIRectEdgeNone;
    [self rightButtonActionWithImg:@"search"];
    
    self.dataSource = [NSMutableArray array];
    self.tableView.hidden = YES;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PublicCourseCell" bundle:nil] forCellReuseIdentifier:@"PublicCourseCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"NoMoreTableViewCell" bundle:nil] forCellReuseIdentifier:@"NoMoreTableViewCell"];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
    footerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footerView;
    
    [self initization];

}

- (void)initization{
//    self.tableView.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
//        ws.page = 1;
//        ws.isMore = YES;
//        ws.tableView.mj_footer.hidden = NO;
//        [ws loadDataPageNo:ws.page];
//    }];
//    
//    self.tableView.mj_footer = [MJRefreshFooter footerWithRefreshingBlock:^{
//        ws.page ++;
//        [ws loadDataPageNo:ws.page];
//    }];
    ygweakify(self);
    [self.tableView setRefreshHeaderEnable:YES footerEnable:YES callback:^(YGRefreshType type) {
        ygstrongify(self);
        if (type == YGRefreshTypeHeader) {
            self.page = 1;
            self.isMore = YES;
            self.tableView.mj_footer.hidden = NO;
            [self loadDataPageNo:self.page];
        }else if (type == YGRefreshTypeFooter){
            self.page ++;
            [self loadDataPageNo:self.page];
        }
    }];
    
    self.page = 1;
    self.isMore = YES;
    if (!_isSearch) {
        [self loadDataPageNo:self.page];
    }
    
    NSString *text = _isSearch ? @"筛选不到满足条件的公开课" : @"该地区暂无公开课";
    noResultView = [NoResultView text:text type:NoResultTypeList superView:self.view show:^{
        ygstrongify(self);
        self.tableView.hidden = YES;
    } hide:^{
        ygstrongify(self);
        self.tableView.hidden = NO;
    }];
}

- (void)observerRefresh{
    self.page = 1;
    self.isMore = YES;
    self.tableView.mj_footer.hidden = NO;
    [self loadDataPageNo:self.page];
}

- (void)loadDataPageNo:(int)page{
    if (self.isMore) {
        [[ServiceManager serviceManagerWithDelegate:self] getPublicListWithLo:[LoginManager sharedManager].currLongitude la:[LoginManager sharedManager].currLatitude keyWord:nil cityId:self.cityId pageNo:page pageSize:20];
    }else{
        [self.tableView.mj_footer endRefreshing];
    }
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray *)data;
    if (Equal(flag, @"teaching_public_class_info")) {
        self.tableView.hidden = NO;
        
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
    return !self.isMore && self.dataSource.count > 0 ? [self.dataSource count]+1 : [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!self.isMore && self.dataSource.count > 0 && indexPath.row == self.dataSource.count) {
        NoMoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoMoreTableViewCell" forIndexPath:indexPath];
        return cell;
    }else{
        PublicCourseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PublicCourseCell" forIndexPath:indexPath];
        cell.publicCourse = self.dataSource[indexPath.row];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!self.isMore && self.dataSource.count > 0 && indexPath.row == self.dataSource.count) return 44;
    return 234;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (!self.isMore && self.dataSource.count > 0 && indexPath.row == self.dataSource.count) return;
    [self pushWithStoryboard:@"Jiaoxue" title:@"公开课详情" identifier:@"PublicCourseDetailController" completion:^(BaseNavController *controller) {
        PublicCourseModel *model = self.dataSource[indexPath.row];
        PublicCourseDetailController *publicCourseDetail = (PublicCourseDetailController*)controller;
        publicCourseDetail.publicClassId = model.publicClassId;
    }];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (![self.navigationController.viewControllers containsObject:self]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PUBLIC_COURSE_OBSERVER_REFRESH" object:nil];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observerRefresh) name:@"PUBLIC_COURSE_OBSERVER_REFRESH" object:nil];
}

- (void)doRightNavAction{
    PublicCourseSearchController *vc = [PublicCourseSearchController instanceFromStoryboard];
    vc.isSearch = YES;
    vc.cityId = self.cityId;
    YGBaseNavigationController *nav = [[YGBaseNavigationController alloc] initWithRootViewController:vc];
    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nav animated:YES completion:nil];
}

@end
