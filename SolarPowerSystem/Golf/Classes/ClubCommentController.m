//
//  ClubCommentController.m
//  Golf
//
//  Created by 黄希望 on 15/10/23.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "ClubCommentController.h"
#import "ClubCommentCell.h"
#import "CmtStars.h"
#import "DayViewHeadCell.h"
#import "AddCommentViewController.h"
#import "TopicHelp.h"
#import "CommentModel.h"

@interface ClubCommentController ()<UITableViewDelegate,UITableViewDataSource,AddCommentDelegate>{
    NoResultView *_noResultView;
}

@property (nonatomic,strong) TotalCommentModel *totalCM;

@property (nonatomic,weak) IBOutlet UITableView *tableView;

@property (nonatomic,weak) IBOutlet UILabel *totalCmtNumLabel;
@property (nonatomic,weak) IBOutlet UILabel *cmtNum1;
@property (nonatomic,weak) IBOutlet UILabel *cmtNum2;
@property (nonatomic,weak) IBOutlet UILabel *cmtNum3;
@property (nonatomic,weak) IBOutlet UILabel *cmtNum4;

@property (nonatomic,strong) IBOutletCollection(UIImageView) NSArray *totalStars;
@property (nonatomic,strong) IBOutletCollection(UIImageView) NSArray *stars1;
@property (nonatomic,strong) IBOutletCollection(UIImageView) NSArray *stars2;
@property (nonatomic,strong) IBOutletCollection(UIImageView) NSArray *stars3;
@property (nonatomic,strong) IBOutletCollection(UIImageView) NSArray *stars4;

@property (nonatomic,strong) NSMutableArray *commentArr;
@property (nonatomic,assign) int pageSize;
@property (nonatomic,assign) int pageNo;
@property (nonatomic,assign) BOOL isOver; // 数据是否已加载完毕

@end

@implementation ClubCommentController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self rightButtonAction:@"添加评分"];
    [self initizationnData];
}

- (void)initizationnData{
    
    self.commentArr = [NSMutableArray array];
    _pageNo = 0;
    _pageSize = 20;
    
    @weakify(self)
    [self.tableView setRefreshHeaderEnable:YES footerEnable:NO callback:^(YGRefreshType type) {
        @strongify(self)
        [self getFistPage];
    }];
    self.tableView.contentInset = UIEdgeInsetsMake(64.f, 0, 0, 0);
    
    __weak typeof(self) ws = self;
    _noResultView = [NoResultView text:@"点击右上角“添加点评”给球场评分" type:NoResultTypeList superView:self.view show:^{
        ws.tableView.hidden = YES;
    } hide:^{
        ws.tableView.hidden = NO;
    }];
    
    [self getFistPage];
}

// 刷新评论列表
- (void)getFistPage{
    _pageNo = 0;
    _isOver = NO;
    [self getCommentList];
}

- (void)getCommentList{
    _pageNo ++;
    [[ServiceManager serviceManagerWithDelegate:self] getClubCommentList:self.clubId pageNo:_pageNo];
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray*)data;
    if (Equal(flag, @"club_comment_list")) {
        self.totalCM = [array objectAtIndex:0];
        if (_pageNo == 1) {
            if (_refreshBlock) {
                _refreshBlock (@(_totalCM.totalLevel));
            }
            [self.commentArr removeAllObjects];
        }
        [self.commentArr addObjectsFromArray:self.totalCM.commentList];
        [self.tableView.mj_header endRefreshing];
        
        if (self.totalCM.commentList.count < _pageSize) {
            _isOver = YES;
        }
        
        [_tableView reloadData];
        [self handleData];
        
        if (_noResultView) {
            [_noResultView show:_commentArr.count>0?NO:YES];
        }
    }
}

- (void)handleData{
    [_totalCmtNumLabel setText:[NSString stringWithFormat:@"总评  %d分",_totalCM.totalLevel]];
    [_cmtNum1 setText:[NSString stringWithFormat:@"%d分",_totalCM.difficultyLevel]];
    [_cmtNum2 setText:[NSString stringWithFormat:@"%d分",_totalCM.grassLevel]];
    [_cmtNum3 setText:[NSString stringWithFormat:@"%d分",_totalCM.sceneryLevel]];
    [_cmtNum4 setText:[NSString stringWithFormat:@"%d分",_totalCM.serviceLevel]];
    
    [CmtStars setStars:_totalStars cmtLevel:_totalCM.totalLevel large:YES];
    [CmtStars setStars:_stars1 cmtLevel:_totalCM.difficultyLevel large:NO];
    [CmtStars setStars:_stars2 cmtLevel:_totalCM.grassLevel large:NO];
    [CmtStars setStars:_stars3 cmtLevel:_totalCM.sceneryLevel large:NO];
    [CmtStars setStars:_stars4 cmtLevel:_totalCM.serviceLevel large:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _commentArr.count+1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == _commentArr.count) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_isOver? @"DataLoadOver" : @"LoadingCell" forIndexPath:indexPath];
        return cell;
    }
    ClubCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClubCommentCell" forIndexPath:indexPath];
    if (indexPath.row < _commentArr.count) {
        cell.cm = _commentArr[indexPath.row];
        cell.blockReturn = ^(id data){
            CommentModel *cm = (CommentModel*)data;
            [self toPersonalHomeControllerByMemberId:cm.memberId displayName:cm.displayName target:self];
            
        };
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == _commentArr.count) {
        return 40;
    }
    CommentModel *cm = _commentArr[indexPath.row];
    if (cm.commentContent.length == 0) {
        return 90;
    }
    
    CGSize sz = [Utilities getSize:cm.commentContent withFont:[UIFont systemFontOfSize:14] withWidth:Device_Width-81];
    return sz.height + 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    DayViewHeadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DayViewHeadCell"];
    cell.dateLabel.text = [NSString stringWithFormat:@"    %d条评论",_totalCM.commentCount];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == _commentArr.count && !_isOver) {
        [self getCommentList];
    }
}

- (void)doRightNavAction{
    [GolfAppDelegate shareAppDelegate].currentController = self;
    [self addComment];
}

- (void)addComment{
    UserCommentModel *model = [[UserCommentModel alloc] init];
    model.clubId = _clubId;
    model.orderId = 0;
    
    AddCommentViewController *addComment = [[AddCommentViewController alloc] initWithNibName:@"AddCommentViewController" bundle:nil];
    addComment.delegate = self;
    addComment.userComment = model;
    [self pushViewController:addComment title:@"添加点评" hide:YES];
}

- (void)AddCommentSuccessRefreshData{
    [self getFistPage];
}

@end
