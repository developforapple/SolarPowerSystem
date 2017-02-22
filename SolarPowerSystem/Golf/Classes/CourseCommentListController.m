//
//  CourseCommentListController.m
//  Golf
//
//  Created by 黄希望 on 15/5/11.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CourseCommentListController.h"
#import "MJRefresh.h"
#import "CourseCommentCell.h"
#import "NoMoreTableViewCell.h"

@interface CourseCommentListController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) NSMutableArray *cellHeightArray;
@property (nonatomic,assign) int page;
@property (nonatomic,assign) BOOL isMore;

@end

@implementation CourseCommentListController{
    NoResultView *noResultView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [NSMutableArray array];
    self.cellHeightArray = [NSMutableArray array];

    self.isMore = YES;
    [self.tableView registerNib:[UINib nibWithNibName:@"NoMoreTableViewCell" bundle:nil] forCellReuseIdentifier:@"NoMoreTableViewCell"];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self initization];
}

- (void)initization{
    //添加上下拉
    __weak CourseCommentListController *weakSelf = self;
    
    noResultView = [NoResultView text:@"暂无评价" type:NoResultTypeList superView:self.view show:^{
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
        weakSelf.page++;
        [weakSelf loadDataPageNo:weakSelf.page];
    }];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(64.f, 0, 0, 0)];
    
    self.page = 1;
    self.isMore = YES;
    self.tableView.mj_footer.hidden = NO;
    [self loadDataPageNo:self.page];    
}

- (void)getCellHeight{
    if (self.dataSource.count > 0) {
        [self.cellHeightArray removeAllObjects];
        CGSize sz;
        CGFloat height;
        for (CoachDetailCommentModel *model in self.dataSource) {
            if (model.commentContent.length>0) {
                sz = [Utilities getSize:model.commentContent withFont:[UIFont systemFontOfSize:14.0] withWidth:Device_Width - 67];
                height = sz.height+79;
            }else{
                height = 70;
            }
            [self.cellHeightArray addObject:@(height)];
        }
    }
}

- (void)loadDataPageNo:(int)page{
    if (self.isMore) {
        [[ServiceManager serviceManagerWithDelegate:self] getCommentListByPage:page pageSize:20 coachId:0 productId:_productId];
    }else{
        [self.tableView.mj_footer endRefreshing];
    }
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray*)data;
    if (Equal(flag, @"teaching_comment_list")) {
        if (self.page == 1) {
            [self.dataSource removeAllObjects];
        }
        if (array.count > 0) {
            self.isMore = YES;
            self.tableView.mj_footer.hidden = NO;
        }else{
            self.isMore = NO;
            self.tableView.mj_footer.hidden = YES;
        }
        [self.dataSource addObjectsFromArray:array];
        [self getCellHeight];
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        [noResultView show:self.dataSource.count == 0];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return !self.isMore && self.dataSource.count > 0 ? [self.dataSource count]+1 : [self.dataSource count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!self.isMore && self.dataSource.count > 0 && indexPath.row == self.dataSource.count) {
        NoMoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoMoreTableViewCell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor whiteColor];
        return cell;
    }else{
        CourseCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CourseCommentCell"];
        if (indexPath.row < self.dataSource.count) {
            cell.commentModel = self.dataSource[indexPath.row];
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!self.isMore && self.dataSource.count > 0 && indexPath.row == self.dataSource.count) return 44;
    return (self.cellHeightArray.count>0 && indexPath.row < self.cellHeightArray.count) ? [self.cellHeightArray[indexPath.row] floatValue] : 0;
}

@end
