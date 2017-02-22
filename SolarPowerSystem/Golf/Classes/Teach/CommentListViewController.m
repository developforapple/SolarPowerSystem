//
//  CommentListViewController.m
//  Golf 教练评价列表
//
//  Created by 廖瀚卿 on 15/5/19.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CommentListViewController.h"
#import "CommentTableViewCell.h"
#import "HeaderTableViewCell.h"
#import "StarTableViewCell.h"
#import "TopicHelp.h"
#import "MyStudentDetailController.h"
#import "TeachInfoDetailTableViewController.h"
#import "YGMyStudentDetailViewCtrl.h"

#define IPhone_PortraitKeyBordHeight 216

@interface CommentListViewController ()

//@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *datas;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@end

@implementation CommentListViewController{
    int size;
    int page;
    BOOL loading;
    BOOL hasMore;
    
    CoachDetailCommentModel *cdm;
    NSString *replyContent;
    NSInteger currentRow;
    
    CGFloat labelContentWidth;
    NoResultView *noResultView;
}

#pragma mark - UI处理

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (IS_3_5_INCH_SCREEN || IS_4_0_INCH_SCREEN) {
        labelContentWidth = 242;
    }else if (IS_4_7_INCH_SCREEN){
        labelContentWidth = 297;
    }else if (IS_5_5_INCH_SCREEN){
        labelContentWidth = 336;
    }
    
    if (_canReply) {
        self.hidesClearText = YES;
        self.dimissHidden = YES;
        self.inputToolbar.hidden = YES;
        
    }else{
        self.inputToolbar.hidden = YES;
    }
    
    self.tableView.contentInset = UIEdgeInsetsMake(64.f, 0, 0, 0);
    
    [self getFirstPage];
    
    __weak CommentListViewController *weakSelf = self;
    noResultView = [NoResultView text:(_canReply ? @"还没有人给你评论哦":@"还没有人给教练评论哦") type:NoResultTypeList superView:self.view show:^{
        weakSelf.tableView.hidden = YES;
    } hide:^{
        weakSelf.tableView.hidden = NO;
    }];

}


- (void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressRightBarButton:(UIButton *)sender
{
    [self sendContent:self.inputToolbar.contentView.textView.text];
}

- (void)sendContent:(NSString*)text{
    [self.inputToolbar.contentView.textView setText:@""];
    if (text && text.length > 0) {
        replyContent = text;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[ServiceManager serviceManagerWithDelegate:self] teachingCommentReplyContent:text commentId:cdm.commentId sessionId:[[LoginManager sharedManager] getSessionId]];
        });
    }
}


#pragma mark - 逻辑方法
- (void)getCommentList{
    loading = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ServiceManager serviceManagerWithDelegate:self] getCommentListByPage:page pageSize:size coachId:_coachId productId:_productId];
    });
}


- (void)serviceResult:(ServiceManager*)serviceManager Data:(id)data flag:(NSString*)flag{
    NSArray *arr = (NSArray*)data;
    if (Equal(flag, @"teaching_comment_list")) {
        if (page == 1) {
            _datas = [[NSMutableArray alloc] init];
        }
        if (arr && arr.count > 0) {
            [_datas addObjectsFromArray:arr];
            page++;
            hasMore = YES;
        }else{
            hasMore = NO;
        }
        [noResultView show:_datas.count == 0];
    }
    if (Equal(flag, @"teaching_comment_reply")) {
        BOOL result = [[arr firstObject] boolValue];
        if (result) {
            if (currentRow > -1) {
                CoachDetailCommentModel *cdc = _datas[currentRow];
                cdc.replyContent = replyContent;
                _datas[currentRow] = cdc;
                replyContent = nil;
                currentRow = -1;
            }
            [self hideKeyboard];
        }
    }
    if (_loadingView) {
        [_loadingView removeFromSuperview];
    }
    [self.tableView reloadData];
    loading = NO;
}

- (void)getFirstPage{
    page = 1;
    size = 15;
    hasMore = YES;
    [self getCommentList];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    NSInteger count = _datas.count + (_datas.count > 0 ? 1:0) + 1;
    return count;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1 && indexPath.row == _datas.count + 1 && hasMore == YES) {
        [self getCommentList];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        StarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StarTableViewCell" forIndexPath:indexPath];
        [cell starLevel:_starLevel];
        return cell;
    }else{
        if (_datas.count + 1 == indexPath.row) {
            return [tableView dequeueReusableCellWithIdentifier:(hasMore ? @"LoadingCell":@"AllLoadedCell") forIndexPath:indexPath];
        }
        
        if (indexPath.row == 0) {
            HeaderTableViewCell *cell = (HeaderTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"HeaderTableViewCell" forIndexPath:indexPath];
            cell.labelHeaderTitle.text = [NSString stringWithFormat:@"%d条评价",_commentCount];
            return cell;
        }
        
        CoachDetailCommentModel *ccm = _datas[indexPath.row - 1];
        NSString *identifier = (ccm.replyContent.length > 0 ? @"CommentTableViewCell2":@"CommentTableViewCell");
        if (_canReply) { //教练的cell
            identifier = (ccm.replyContent.length > 0 ? @"CommentCoachTableViewCell":@"CommentCoachTableViewCell2");
        }
        CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        if ([ccm.reservationTime containsString:@"~"]) {
             ccm.reservationTime = [ccm.reservationTime substringToIndex:[ccm.reservationTime rangeOfString:@"~"].location];
        }
        if (indexPath.row == _datas.count) {
            if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                [cell setSeparatorInset:UIEdgeInsetsMake(0, 1000, 0, 0)];
            }
        }else{
            if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                [cell setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 0)];
            }
        }
        [cell loadData:ccm];
        cell.cellRow = indexPath.row - 1;
        
        _datas[indexPath.row - 1] = ccm;
        
        if (cell.blockReturn == nil) {
            cell.blockReturn = ^(id data){
                CoachDetailCommentModel *m = (CoachDetailCommentModel *)data;
                if (_canReply) {
                    
//                    [self pushWithStoryboard:@"Coach" title:@"学员详情" identifier:@"MyStudentDetailController" completion:^(BaseNavController *controller) {
//                        MyStudentDetailController *msd = (MyStudentDetailController*)controller;
//                        msd.memberId = m.memberId;
//                    }];
                    
                    YGMyStudentDetailViewCtrl *vc = [YGMyStudentDetailViewCtrl instanceFromStoryboard];
                    vc.memberId = m.memberId;
                    [self.navigationController pushViewController:vc animated:YES];
                    
                }else{
                    [self toPersonalHomeControllerByMemberId:m.memberId displayName:m.displayName target:self];
                }
                
            };
        }
        if (cell.blockReplyPressed == nil && _canReply == YES) {
            cell.blockReplyPressed = ^(id data){
                
                self.viewAction = [data valueForKeyPath:@"el"];
                cdm = (CoachDetailCommentModel *)[data valueForKeyPath:@"data"];
                
                currentRow = cell.cellRow;
                CGRect rectInTableView = [tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRow+1 inSection:1]];
                CGRect rectInSuperview = [tableView convertRect:rectInTableView toView:[tableView superview]];
                
                CGFloat y = self.view.frame.size.height - IPhone_PortraitKeyBordHeight;
                CGFloat cy = rectInSuperview.size.height + rectInSuperview.origin.y;
                if (cy > y) {
                    CGPoint point = [tableView contentOffset];
                    CGFloat yy = cy - y;
                    [tableView setContentOffset:CGPointMake(0, point.y + yy*2)];
                }
                [self showChatWithPlaceHolder:nil];
            };
        }
        
        if (cell.blockFromPressed == nil) {
            cell.blockFromPressed = ^(id data){
                CoachDetailCommentModel *m = (CoachDetailCommentModel *)data;
                [self pushWithStoryboard:@"Teach" title:@"预约详情" identifier:@"TeachInfoDetailTableViewController" completion:^(BaseNavController *controller) {
                    TeachInfoDetailTableViewController *vc = (TeachInfoDetailTableViewController *)controller;
                    vc.reservationId = m.reservationId;
                    if (_canReply) {
                        vc.coachId = [LoginManager sharedManager].session.memberId;
                    }
                }];
            };
        }
        return cell;
    }
    
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = [UIColor clearColor];
    return v;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 113;
    }
    if (indexPath.row == 0) {
        return 40;
    }
    if (_datas.count + 1 == indexPath.row) {
        return 44;
    }
    CoachDetailCommentModel *dcm = _datas[indexPath.row - 1];
    return [dcm contentSize:CGSizeMake(labelContentWidth, MAXFLOAT) addReply:dcm.replyContent.length > 0 isCoach:_canReply];
}





@end
