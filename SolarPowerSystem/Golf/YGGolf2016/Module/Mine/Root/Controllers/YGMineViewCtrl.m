//
//  YGMineViewCtrl.m
//  Golf
//
//  Created by zhengxi on 15/12/7.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "YGMineViewCtrl.h"
#import "YGMineCell.h"
#import "TopicHelp.h"
#import "CoachTransitionalPageController.h"
#import "CoachInfoReviewController.h"
#import "YGSettingViewCtrl.h"
#import "YGCashBalanceViewCtrl.h"
#import "YGMoreSettingsViewCtrl.h"

#import "AddFriendsViewController.h"
#import "FriendsMainViewController.h"
#import "IMNotificationDefine.h"
#import "IMCore.h"
#import "YGMyYueduViewCtrl.h"

#import "YGSearchViewCtrl.h"
#import "CustomerServiceViewCtrl.h"

#import "YGMyTeachingArchiveViewCtrl.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "YGCouponListViewCtrl.h"

#import "YGOrderManagerViewCtrl.h"
#import "SharePackage.h"
#import "YGYunbiBalanceViewCtrl.h"

@interface YGMineViewCtrl ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic,strong) const NSArray *rowTitleArrary;
@property (nonatomic,strong) const NSArray *rowIconArrary;
@property (nonatomic,strong) DepositInfoModel *myDepositInfo;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) SharePackage *share;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (nonatomic,assign) int msgCount;
@end

@implementation YGMineViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    [GolfAppDelegate shareAppDelegate].currentController = self;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
    [self noLeftButton];
    [self rightNavButtonImg:@"tel"];
    
    self.rowTitleArrary = @[@[@" ", @" "],@[@" "],@[@"教练管理中心"],@[@"订单管理",@"教学档案",@"我的头条"],@[@"分享给好友",@"设置",@"更多"]];
    self.rowIconArrary = @[@[@" ", @" "],@[@" "],@[@"jiaolian"],@[@"dingdan",@"jiaoxue",@"icon_me_read"],@[@"fanyunbi",@"shezhi",@"gengduo"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearBadge) name:@"LOGOUTED" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userFollowed) name:@"NEWFOOLOWED" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableData) name:IMMessageReceivedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableData) name:IMMessageSendedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableData) name:IMSessionValueChangedNotification object:nil];
    
    
    /**
     换绑成功需要刷新更改本地显示的手机号

     @param notification <#notification description#>

     @return <#return value description#>
     */
    ygweakify(self);
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"ChangeBindingSuccess" object:nil] subscribeNext:^(NSNotification *notification) {
        ygstrongify(self);
        [self.tableView reloadRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
    }];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)doRightNavAction{
    [CustomerServiceViewCtrl show];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];//不要

    if ([LoginManager sharedManager].loginState) {
        [[ServiceManager serviceManagerWithDelegate:self] getDepositInfo:[[LoginManager sharedManager] getSessionId] needCount:1];
    }else{
        [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES blockRetrun:^(id data) {
            [_tableView setContentOffset:CGPointMake(0, 0) animated:NO];
            [[ServiceManager serviceManagerWithDelegate:self] getDepositInfo:[[LoginManager sharedManager] getSessionId] needCount:1];
        } cancelReturn:^(id data) {
            [self.tabBarController setSelectedIndex:0];
        }];
    }
}

-(void)reloadTableData{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.msgCount = [[IMCore shareInstance] allUnreadMessagesCountWithOwnerId:[NSString stringWithFormat:@"%d",[LoginManager sharedManager].session.memberId]];//lq 加 私信条数
        _badgeNum = (int)[self sumOfAllNumber];
        [self refreshBadgeValue];
        [self.tableView reloadData];
    });
}

#pragma mark - ServiceManagerDelegate
- (void)serviceResult:(ServiceManager*)serviceManager Data:(id)data flag:(NSString*)flag{
    NSArray *array = [NSArray arrayWithArray:data];
    if (array && array.count>0) {
        if (Equal(flag, @"deposit_info")) {
            [LoginManager sharedManager].myDepositInfo = [array objectAtIndex:0];
            [LoginManager sharedManager].session.noDeposit = [LoginManager sharedManager].myDepositInfo.no_deposit;
            [LoginManager sharedManager].session.memberLevel = (int)[LoginManager sharedManager].myDepositInfo.memberLevel;
//            self.myDepositInfo = [LoginManager sharedManager].myDepositInfo;
            self.myDepositInfo = [array objectAtIndex:0];
            [self saveOldDepositInfo];
            NSString *sessoinId = ([LoginManager sharedManager].loginState ? [LoginManager sharedManager].session.sessionId:nil);
            [[ServiceManager serviceManagerWithDelegate:self] userFollowList:sessoinId followType:1 longitude:[LoginManager sharedManager].currLongitude latitude:[LoginManager sharedManager].currLatitude pageNo:1 pageSize:20];
            return;
        }
    }
    
    if (Equal(flag, @"user_follow_list")) {
        if (array && array.count > 0) {
            NSDictionary *dic = [array objectAtIndex:0];
            int newFollowedCount = [[dic objectForKey:@"new_followed_count"] intValue];
            [[NSUserDefaults standardUserDefaults] setObject:@(newFollowedCount) forKey:@"NEW_FOLLOWED_COUNT"];
            self.msgCount = [[IMCore shareInstance] allUnreadMessagesCountWithOwnerId:[NSString stringWithFormat:@"%d",[LoginManager sharedManager].session.memberId]];//lq 加 私信条数
            _badgeNum = (int)[self sumOfAllNumber];
            [self refreshBadgeValue];
        }
    }
    dispatch_async( dispatch_get_main_queue(), ^{
        self.tableView.hidden = NO;
        if (self.loadingView) {
            [self.loadingView removeFromSuperview];
        }
        [self.tableView reloadData];
    });
}

#pragma mark - UITableViewDataSource UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _rowTitleArrary.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 2) {
        return _myDepositInfo.coachLevel > -1 ? 1 : 0;
    }
//    if (section == 6) {
//        return _myDepositInfo.coachLevel > -1 ? 0 : 1;
//    }
    NSArray *a = _rowTitleArrary[section];
    return [a count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *string = nil;
    if (indexPath.section == 0 && indexPath.row == 0) {
        string = @"MineInformationTableViewCell";
    } else if (indexPath.row == 1 && indexPath.section == 0) {
        string = @"FriendCell";
    } else if(indexPath.row == 0 && indexPath.section == 1) {
        string = @"MineAccountTableViewCell";
    }else{
        string = @"YGMineCell";
    }
    YGMineCell *cell = [tableView dequeueReusableCellWithIdentifier:string forIndexPath:indexPath];
    if (indexPath.section == 0 && indexPath.row == 1) {
        ygweakify(self);
        cell.blockFriend = ^(NSNumber *tag){
            ygstrongify(self);
            if ([tag intValue] == 0) {
                [self toChatListViewController];
            }else if ([tag intValue] == 1){
                [self pushWithStoryboard:@"Friends" title:@"" identifier:@"FriendsMainViewController" completion:^(BaseNavController *controller) {
                    FriendsMainViewController *vc = (FriendsMainViewController *)controller;
                    vc.segmentIndex = 1;
                }];
            }else{
                [self pushWithStoryboard:@"AddFriends" title:nil identifier:@"AddFriendsViewController" completion:^(BaseNavController *controller) {
                }];
            }
        };
        int msgCount = [[IMCore shareInstance] allUnreadMessagesCountWithOwnerId:[NSString stringWithFormat:@"%d",[LoginManager sharedManager].session.memberId]];//lq 加 私信条数
        cell.msgCount = msgCount;
        [UIApplication sharedApplication].applicationIconBadgeNumber = msgCount;
        cell.redPointAboutFriends = [self judgeFriendHaveRedPoint];
        
    }
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.isFirstCell = YES;
        if (_myDepositInfo.coachLevel > 0) {
            cell.coachLevelButton.hidden = NO;
            [cell.coachLevelButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ic_%lda",(long)_myDepositInfo.coachLevel]] forState:UIControlStateNormal];
        } else {
            cell.coachLevelButton.hidden = YES;
        }
        cell.toUserGuideBlock = ^ {
            [[GolfAppDelegate shareAppDelegate] showInstruction:[NSString stringWithFormat:@"https://m.bookingtee.com/vip.html?%d", [LoginManager sharedManager].session.memberLevel] title:@"用户说明" WithController:self];
        };
        cell.toCoachGuideBlock = ^ {
            [[GolfAppDelegate shareAppDelegate] showInstruction:[NSString stringWithFormat:@"%@common/coachLevel.jsp?coachId=%d",URL_SHARE,[LoginManager sharedManager].session.memberId] title:@"教练等级说明" WithController:self];
        };
    } else {
        cell.coachLevelButton.hidden = YES;
        cell.isFirstCell = NO;
    }
    if ((indexPath.section == 4 && indexPath.row == 0) || (indexPath.row == 1 && indexPath.section == 0) || indexPath.section == 1){
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.section == 3 && indexPath.row == 1 && _myDepositInfo.remainClassCount > 0) {
        cell.badgeLabel.hidden = NO;
        cell.badgeLabel.backgroundColor = [UIColor whiteColor];
        cell.badgeLabel.textColor = [UIColor colorWithHexString:@"#999999"];
        cell.badgeLabel.layer.borderColor = [UIColor colorWithHexString:@"#999999"].CGColor;
        cell.badgeLabel.text = [NSString stringWithFormat:@"%ld  ", (long)_myDepositInfo.remainClassCount];
        cell.badgeLabel.layer.borderWidth = 0.5;
    } else {
        cell.badgeLabel.backgroundColor = [UIColor redColor];
        cell.badgeLabel.textColor = [UIColor whiteColor];
        cell.badgeLabel.layer.borderColor = [UIColor redColor].CGColor;
        cell.badgeLabel.layer.borderWidth = 0;
        if (indexPath.section == 3 && indexPath.row == 0 && [self sumOfOrderNumber] > 0) {
            cell.badgeLabel.hidden = NO;
            cell.badgeLabel.text = [NSString stringWithFormat:@"%d  ", [self sumOfOrderNumber]];
        } else if (indexPath.section == 2 && _myDepositInfo.teachingMsgCount > 0) {
            cell.badgeLabel.hidden = NO;
            cell.badgeLabel.text = [NSString stringWithFormat:@"%ld  ", (long)_myDepositInfo.teachingMsgCount];
        } else {
            cell.badgeLabel.hidden = YES;
        }
    }
    if (indexPath.row == 0 && indexPath.section == 1) {
        cell.accountLabel.text = [NSString stringWithFormat:@"%ld", (long)_myDepositInfo.banlance];
        cell.yunbiLabel.text = [NSString stringWithFormat:@"%ld", (long)_myDepositInfo.yunbiBalance];
        cell.couponLabel.text = [NSString stringWithFormat:@"%ld", (long)_myDepositInfo.couponTotal];
        cell.yunbiBadgeLabel.hidden = ![self judgeYunbiBalanceIncrease];
        cell.accountBadgeLabel.hidden = ![self judgeBanlanceIncrease];
        cell.couponBadgeLabel.hidden = ![self judgeCouponTotalIncrease];
        ygweakify(self);
        cell.toAccountBlock = ^ (NSInteger tag) {
            ygstrongify(self);
            switch (tag) {
                case 1:{
                    YGCashBalanceViewCtrl *myBalanceVC = [YGCashBalanceViewCtrl instanceFromStoryboard];
                    [self pushViewController:myBalanceVC title:@"账户余额" hide:YES];
                    break;}
                case 2:{
                    YGYunbiBalanceViewCtrl *myBalanceVC = [YGYunbiBalanceViewCtrl instanceFromStoryboard];
                    [self pushViewController:myBalanceVC title:@"我的云币" hide:YES];
                    break;}
                case 3:{
                    [[NSUserDefaults standardUserDefaults] setObject:@([LoginManager sharedManager].myDepositInfo.couponTotal) forKey:[NSString stringWithFormat:@"couponTotal-single-%@", [LoginManager sharedManager].session.mobilePhone]];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    YGCouponListViewCtrl *vc = [YGCouponListViewCtrl instanceFromStoryboard];
                    [self.navigationController pushViewController:vc animated:YES];
                    break;}
                default:
                    break;
            }
        };
    }
    cell.iconLabel.text = _rowTitleArrary[indexPath.section][indexPath.row];
    UIImage *img = nil;
    if ([(_rowIconArrary[indexPath.section][indexPath.row]) length] > 0) {
        img = [UIImage imageNamed: _rowIconArrary[indexPath.section][indexPath.row]];
    }
    cell.iconImageView.image = img;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 62;
    }else if(indexPath.section == 0 && indexPath.row == 1){
        return 80;
    }else if (indexPath.section == 1) {
        return 78;
    } else {
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    } else if (section == 2) {
        if (_myDepositInfo.coachLevel > -1 ) {
            return 10;
        } else
            return 0;
    } else{
        return 10;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0) {
                [self toPersonalHomeControllerByMemberId:[LoginManager sharedManager].session.memberId displayName:[LoginManager sharedManager].session.displayName target:self];
            }
            break;
        case 2:
            if (_myDepositInfo.coachLevel > 0) {
                [self pushWithStoryboard:@"Coach" title:@"教练管理中心" identifier:@"CoachManagerCenterController" completion:nil];
            }else{
                [self pushWithStoryboard:@"Coach" title:@"教练认证" identifier:@"CoachAuthenticationController" completion:nil];
            }
            break;
        case 3:
            switch (indexPath.row) {
                case 0:{
                    
                    YGOrderManagerViewCtrl *vc = [YGOrderManagerViewCtrl instanceFromStoryboard];
                    [self.navigationController pushViewController:vc animated:YES];
                    
                }   break;
                case 1:{
//                    [self pushWithStoryboard:@"Teach" title:@"我的教学" identifier:@"MyTeachInfoViewController" completion:nil];
                    YGMyTeachingArchiveViewCtrl *vc = [YGMyTeachingArchiveViewCtrl instanceFromStoryboard];
                    [self pushViewController:vc hide:YES];
                    
                }   break;
                case 2:{
                    
                    //我的头条
                    YGMyYueduViewCtrl *vc = [YGMyYueduViewCtrl instanceFromStoryboard];
                    [self.navigationController pushViewController:vc animated:YES];
                }   break;
                default:
                    break;
            }
            break;
        case 4:
            if (indexPath.row == 0) {
                [self inviteGift];
            } else if (indexPath.row == 1) {
                YGSettingViewCtrl *mineSettingVC = [YGSettingViewCtrl instanceFromStoryboard];
                mineSettingVC.blockLogoutReturn = ^(id data){
                    self.myDepositInfo = nil;
                    
                    UITabBarController *tabbarCtrl = [GolfAppDelegate shareAppDelegate].tabBarController;
                    [tabbarCtrl setSelectedViewController:[tabbarCtrl.viewControllers firstObject]];
                };
                [self pushViewController:mineSettingVC title:@"设置" hide:YES];
            } else {
                YGMoreSettingsViewCtrl *moreVC = [YGMoreSettingsViewCtrl instanceFromStoryboard];
                moreVC.coachLevel = (int)_myDepositInfo.coachLevel;
                [self pushViewController:moreVC title:@"更多" hide:YES];
            }
            break;
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor colorWithHexString:@"#F0EFF5"];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(nonnull UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor colorWithHexString:@"#F0EFF5"];
}

#pragma mark - Set

- (void)clearBadge{
    self.badgeNum = 0;
}

- (void)setBadgeNum:(int)badgeNum{
    _badgeNum = badgeNum;
    [self refreshBadgeValue];
    if ([LoginManager sharedManager].loginState) {
        [[ServiceManager serviceManagerWithDelegate:self] getDepositInfo:[[LoginManager sharedManager] getSessionId] needCount:1];
    }
}

- (int)sumOfOrderNumber {
    int count = 0;
    count += _myDepositInfo.waitPayCount;
    count += _myDepositInfo.waitPayCount2;
    count += _myDepositInfo.waitPayCount3;
    return count;
}

- (NSInteger)sumOfAllNumber {
    return [self sumOfOrderNumber] + _myDepositInfo.teachingMsgCount + self.msgCount + [[[NSUserDefaults standardUserDefaults] objectForKey:@"NEW_FOLLOWED_COUNT"] intValue];
}

-(void)toChatListViewController{
    [self pushWithStoryboard:@"Friends" title:@"" identifier:@"FriendsMainViewController" completion:^(BaseNavController *controller) {
        FriendsMainViewController *vc = (FriendsMainViewController *)controller;
        vc.segmentIndex = 0;
    }];
}

- (void)refreshBadgeValue {
    if (_badgeImage == nil) {
        _badgeImage = [[UIImageView alloc] initWithFrame:CGRectMake(Device_Width - Device_Width / 5 * 0.281 , 4, 9, 9)];
        _badgeImage.backgroundColor = [UIColor redColor];
        [Utilities drawView:_badgeImage radius:4.5 borderColor:[UIColor redColor]];
        [[GolfAppDelegate shareAppDelegate].tabBarController.tabBar addSubview:_badgeImage];
    }
    _badgeImage.hidden = YES;
    if (_badgeNum > 0) {
        self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",_badgeNum];
    }else{
        self.navigationController.tabBarItem.badgeValue = nil;
    }
}

- (BOOL)judgeFriendHaveRedPoint {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"PossibleFriends"] && [[NSUserDefaults standardUserDefaults] boolForKey:@"AddressBookFriends"]) {
        return NO;
    }
    return YES;
}

- (BOOL)judgeBanlanceIncrease {
    NSNumber *banlance = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"banlance-single-%@", [LoginManager sharedManager].session.mobilePhone]];
    if (banlance) {
        if (self.myDepositInfo.banlance > [banlance intValue]) {
            return YES;
        }
    } else {
        if (self.myDepositInfo == nil) {
            return NO;
        }
        [[NSUserDefaults standardUserDefaults] setObject:@(self.myDepositInfo.banlance) forKey:[NSString stringWithFormat:@"banlance-single-%@", [LoginManager sharedManager].session.mobilePhone]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return NO;
}

- (BOOL)judgeYunbiBalanceIncrease {
    NSNumber *yunbiBalance = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"yunbiBalance-single-%@", [LoginManager sharedManager].session.mobilePhone]];
    if (yunbiBalance) {
        if (self.myDepositInfo.yunbiBalance > [yunbiBalance intValue]) {
            return YES;
        }
    } else {
        if (self.myDepositInfo == nil) {
            return NO;
        }
        [[NSUserDefaults standardUserDefaults] setObject:@(self.myDepositInfo.yunbiBalance) forKey:[NSString stringWithFormat:@"yunbiBalance-single-%@", [LoginManager sharedManager].session.mobilePhone]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return NO;
}

- (BOOL)judgeCouponTotalIncrease {
    NSNumber *couponTotal = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"couponTotal-single-%@", [LoginManager sharedManager].session.mobilePhone]];
    if (couponTotal) {
        if (self.myDepositInfo.couponTotal > [couponTotal intValue]) {
            return YES;
        }
    } else {
        if (self.myDepositInfo == nil) {
            return NO;
        }
        [[NSUserDefaults standardUserDefaults] setObject:@(self.myDepositInfo.couponTotal) forKey:[NSString stringWithFormat:@"couponTotal-single-%@", [LoginManager sharedManager].session.mobilePhone]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return NO;
}

- (void)saveOldDepositInfo {
    if (_badgeImage == nil) {
        _badgeImage = [[UIImageView alloc] initWithFrame:CGRectMake(Device_Width - Device_Width / 5 * 0.281 , 4, 9, 9)];
        _badgeImage.backgroundColor = [UIColor redColor];
        [Utilities drawView:_badgeImage radius:4.5 borderColor:[UIColor redColor]];
        [[GolfAppDelegate shareAppDelegate].tabBarController.tabBar addSubview:_badgeImage];
    }
    self.badgeImage.hidden = YES;
    [[NSUserDefaults standardUserDefaults] setObject:@([LoginManager sharedManager].myDepositInfo.banlance) forKey:[NSString stringWithFormat:@"banlance-%@", [LoginManager sharedManager].session.mobilePhone]];
    [[NSUserDefaults standardUserDefaults] setObject:@([LoginManager sharedManager].myDepositInfo.yunbiBalance) forKey:[NSString stringWithFormat:@"yunbiBalance-%@", [LoginManager sharedManager].session.mobilePhone]];
    [[NSUserDefaults standardUserDefaults] setObject:@([LoginManager sharedManager].myDepositInfo.couponTotal) forKey:[NSString stringWithFormat:@"couponTotal-%@", [LoginManager sharedManager].session.mobilePhone]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Invite
- (void)inviteGift {
    if ([LoginManager sharedManager].loginState) {
        if ([self needPerfectMemberData]) {
            return;
        }
    }
    NSString *title = @"我在用云高高尔夫，订场便宜球友很多，你也来试试吧";
    NSString *content = [NSString stringWithFormat:@"注册输入邀请码%d，即可获得50~100现金购物券",[[LoginManager sharedManager] getUserId]];
    
    NSString *url = @"https://m.bookingtee.com/wx/";
    
    if (!_share) {
        _share = [[SharePackage alloc] init];
    }
    _share.isInviteNewUser = YES;
    _share.shareTitle = title;
    _share.shareContent = content;
    _share.circleOfFriendsString = [NSString stringWithFormat:@"我在用云高高尔夫，订场便宜球友多，注册输入邀请码%d领红包",[[LoginManager sharedManager] getUserId]];
    _share.shareImg = [UIImage imageNamed:@"logo"];
    _share.shareUrl = url;
    
    _share.isNeedAddressBook = YES;
    [_share shareInfoForView:self.view];
}

#pragma mark - YGLoginViewCtrlDelegate
- (void)loginButtonPressed:(id)sender {
//    [self viewWillAppear:NO];
    if ([LoginManager sharedManager].loginState) {
        [[ServiceManager serviceManagerWithDelegate:self] getDepositInfo:[LoginManager sharedManager].session.sessionId needCount:1];
    }
}

- (void)userFollowed {
    if ([LoginManager sharedManager].loginState) {
        [[ServiceManager serviceManagerWithDelegate:self] userFollowList:[LoginManager sharedManager].session.sessionId followType:1 longitude:[LoginManager sharedManager].currLongitude latitude:[LoginManager sharedManager].currLatitude pageNo:1 pageSize:20];
    }
}
@end
