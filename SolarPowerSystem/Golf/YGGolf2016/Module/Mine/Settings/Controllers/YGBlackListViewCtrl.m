//
//  YGBlackListViewCtrl.m
//  Golf
//
//  Created by zhengxi on 15/11/3.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "YGBlackListViewCtrl.h"
#import "UserFollowModel.h"
#import "YGBlackListCell.h"
#import "CCActionSheet.h"
#import "YGProfileViewCtrl.h"
#import "YGUserRemarkCacheHelper.h"

@interface YGBlackListViewCtrl () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *defriendListArray;
@property (nonatomic) int follewedMemberID;
@property int willOperation;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) int page;
@property BOOL hasMore;
@property (weak, nonatomic) IBOutlet UILabel *noListLabel;
@end

@implementation YGBlackListViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [GolfAppDelegate shareAppDelegate].currentController = self;
    [self initializeData];
    [self initializeTableView];
}

- (void)initializeData {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAttentList:) name:@"refreshAttentList" object:nil];
    self.hasMore = YES;
    self.page = 0;
    self.refreshControl = [[UIRefreshControl alloc]init];
    [_refreshControl addTarget:self action:@selector(getFirstPage) forControlEvents:(UIControlEventValueChanged)];
    [self.tableView addSubview:_refreshControl];
    self.defriendListArray = [NSMutableArray array];
    if (_isFollowedParameter == 3) {
        self.willOperation = 7;
        self.noListLabel.text = @"黑名单为空";
    } else if (_isFollowedParameter == 6) {
        self.noListLabel.text = @"没有屏蔽任何人";
        self.willOperation = 6;
    }
    
}

- (void)getFirstPage {
    _page = 1;
    [[ServiceManager serviceManagerWithDelegate:self] userFollowList:[[LoginManager sharedManager] getSessionId] followType:_isFollowedParameter longitude:[LoginManager sharedManager].currLongitude latitude:[LoginManager sharedManager].currLatitude pageNo:_page pageSize:20];
}

- (void)getfollewedList {
    _page++;
    [[ServiceManager serviceManagerWithDelegate:self] userFollowList:[[LoginManager sharedManager] getSessionId] followType:_isFollowedParameter longitude:[LoginManager sharedManager].currLongitude latitude:[LoginManager sharedManager].currLatitude pageNo:_page pageSize:20];
}

- (void)initializeTableView {
    [self getFirstPage];
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)doLeftNavAction {
    [super doLeftNavAction];
   
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshAttentList" object:nil];
}

#pragma mark - UITableViewDelegate - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _defriendListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YGBlackListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YGBlackListCell" forIndexPath:indexPath];
    cell.willOperation = _willOperation;
    __weak YGBlackListCell *cell1= cell;
    if (_defriendListArray.count > 0) {
        cell.model = _defriendListArray[indexPath.row];
    }
    cell.removeBackBlock = ^{
        self.follewedMemberID = cell1.model.memberId;
        [self removeDefriend];
    };
    if (_defriendListArray.count == indexPath.row + 1) {
        cell.separatorInset = UIEdgeInsetsMake(0, self.view.frame.size.width/2, 0, self.view.frame.size.width/2);
    }else{
        cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 62;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_hasMore && (indexPath.row == _defriendListArray.count)) {
        [self getfollewedList];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UserFollowModel *m = _defriendListArray[indexPath.row];    
    if (m.memberId != [LoginManager sharedManager].session.memberId) {
        if ([self needPerfectMemberData]) {
            return;
        }
    }
    
    YGProfileViewCtrl *vc = [YGProfileViewCtrl instanceFromStoryboard];
    vc.memberId = m.memberId;
    vc.blockFollow = ^(id data){
        [self getFirstPage];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - ServiceManagerDelegate
- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray*)data;
    [_refreshControl endRefreshing];
    if (Equal(flag, @"user_follow_list")) {
        if (array && array.count > 0) {
            NSDictionary *dic = [array objectAtIndex:0];
            NSArray *array1 = dic[@"follow_list"];
            if (_page == 1) {
                [self.defriendListArray removeAllObjects];
            }
            
            if (array1 && array1.count>0) {
                for (id obj in array1) {
                    UserFollowModel *model = [[UserFollowModel alloc] initWithDic:obj];
                    NSString *remarkName = [[YGUserRemarkCacheHelper shared] getUserRemarkName:model.memberId];
                    if ([remarkName isNotBlank]) {
                        model.displayName = remarkName;
                    }
                    [self.defriendListArray addObject:model];
                }

                _hasMore = YES;
            }else{
                _hasMore = NO;
            }
            
            if (_defriendListArray.count>0) {
                self.noListLabel.hidden = YES;
                self.tableView.hidden = NO;
            }else{
                self.noListLabel.hidden = NO;
                self.tableView.hidden = YES;
            }
            
            [_tableView reloadData];
        }
    }
    
    if (Equal(flag, @"user_follow_add")) {
        if (array && array.count > 0) {
            NSDictionary *dic = [array objectAtIndex:0];
            UserFollowModel *model = [[UserFollowModel alloc] init];
            model.isFollowed = [dic[@"is_followed"] intValue];
            model.memberId = _follewedMemberID;
            BOOL have = NO;
            NSString *string = nil;
            switch ([dic[@"operation"] intValue]) {
                case 6:
                    string = @"已移出";
                    have = YES;
                    break;
                case 7:
                    string = @"已移出";
                    have = YES;
                    break;
                default:
                    break;
            }
            if (have) {
                [SVProgressHUD showSuccessWithStatus:string];
            }else{
                [SVProgressHUD showInfoWithStatus:string];
            }
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:@[dic[@"operation"],model] forKeys:@[@"flag",@"data"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshAttentList" object:dictionary];
        }
    }
}

- (void)removeDefriend {
    NSString *string = nil;
    if (_willOperation == 6) {
        string = @"确定重新接受此人动态吗？";
    } else {
        string = @"确定将对方移出黑名单吗？TA将可以给你发送私信和评论";
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:string preferredStyle: UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self userFollowAddAction];
    }];
    [alert addAction:cancelAction];
    [alert addAction:deleteAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)userFollowAddAction {
    [[ServiceManager serviceManagerWithDelegate:self] userFollowAdd:[[LoginManager sharedManager] getSessionId] toMemberId:_follewedMemberID nameRemark:nil operation:_willOperation];
}

- (void)refreshAttentList:(NSNotification *)notification {
    NSDictionary *info = [notification object];
    UserFollowModel *model = info[@"data"];
    if ([info[@"flag"] intValue] == 3) {
        for (UserFollowModel *m in _defriendListArray) {
            if (m.memberId == model.memberId) {
                m.displayName = model.displayName;
            }
        }
        [_tableView reloadData];
        return;
    }
    if (model.isFollowed != _isFollowedParameter && model.isFollowed != 6) {
        int i = 0;
        NSMutableArray *array = [NSMutableArray array];
        NSMutableIndexSet *set=[NSMutableIndexSet indexSet];

        for (UserFollowModel *person in _defriendListArray) {
            if (person.memberId == model.memberId) {
                [array addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                [set addIndex:i];
            }
            i++;
        }

        [self.defriendListArray removeObjectsAtIndexes:set];
        [self.tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationFade];
        if (_defriendListArray.count>0) {
            self.noListLabel.hidden = YES;
        }else{
            self.noListLabel.hidden = NO;
        }
    }
}

#pragma mark - YGLoginViewCtrlDelegate
- (void)loginButtonPressed:(id)sender {
    [self initializeData];
    [self initializeTableView];
}

@end
