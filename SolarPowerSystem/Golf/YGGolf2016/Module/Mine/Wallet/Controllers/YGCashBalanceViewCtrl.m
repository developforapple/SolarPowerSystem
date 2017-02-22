//
//  YGCashBalanceViewCtrl.m
//  Golf
//
//  Created by zhengxi on 15/12/11.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "YGCashBalanceViewCtrl.h"
#import "YGBalanceDetailsViewCtrl.h"
#import "YGWalletTopUpViewCtrl.h"
#import "YGWalletWithdrawViewCtrl.h"
#import "YGWalletTransferViewCtrl.h"
#import "WKDChatViewController.h"
#import "CCAlertView.h"
#import "IMCore.h"
#import "ReactiveCocoa.h"

@interface YGCashBalanceViewCtrl ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *rowTitleArrary;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *freezeTotalLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@end

@implementation YGCashBalanceViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self rightButtonAction:@"收支明细"];
    [GolfAppDelegate shareAppDelegate].currentController = self;
    self.rowTitleArrary = @[@"",@[@"充值", @"提现", @"转账给好友"]];
    self.balanceLabel.text = [NSString stringWithFormat:@"%ld",(long)[LoginManager sharedManager].myDepositInfo.banlance];
    self.freezeTotalLabel.text = [NSString stringWithFormat:@"%ld元",(long)[LoginManager sharedManager].myDepositInfo.freezeTotal];
    NSInteger h = _tableView.tableHeaderView.frame.size.height;
    UIView *theView = [[UIView alloc] initWithFrame:CGRectMake(0, -h*3, [UIScreen mainScreen].bounds.size.width, h*4)];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];  // 设置渐变效果
    gradientLayer.bounds = theView.bounds;
    gradientLayer.borderWidth = 0;
    gradientLayer.frame = theView.bounds;
    gradientLayer.colors = @[(id)[[UIColor colorWithHexString:@"#069cd8"] CGColor],(id)[[UIColor colorWithHexString:@"#04b6fe"] CGColor]];
    gradientLayer.startPoint = CGPointMake(1, 0.75);
    gradientLayer.endPoint = CGPointMake(1, 1);
    [theView.layer insertSublayer:gradientLayer atIndex:0];
    [self.tableView addSubview:theView];
    [self.tableView sendSubviewToBack:theView];
    
    ygweakify(self);
    [[[NSNotificationCenter defaultCenter]
       rac_addObserverForName:@"ConfirmedTransfer" object:nil]
       subscribeNext:^(id x) {
           ygstrongify(self);
           [self ConfirmedTransfer:x];
       }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([LoginManager sharedManager].loginState) {
        [[ServiceManager serviceManagerWithDelegate:self] getDepositInfo:[[LoginManager sharedManager] getSessionId] needCount:1];
    }else{
        [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES blockRetrun:^(id data) {
            [[ServiceManager serviceManagerWithDelegate:self] getDepositInfo:[[LoginManager sharedManager] getSessionId] needCount:1];
        } cancelReturn:^(id data) {
            [self.tabBarController setSelectedIndex:0];
        }];
    }
}

- (void)doRightNavAction {
    YGBalanceDetailsViewCtrl *balanceListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"YGBalanceDetailsViewCtrl"];
    balanceListVC.accountType = 2;
    [self pushViewController:balanceListVC title:@"收支明细" hide:YES];

}

#pragma mark - ServiceManagerDelegate
- (void)serviceResult:(ServiceManager*)serviceManager Data:(id)data flag:(NSString*)flag{
    NSArray *array = [NSArray arrayWithArray:data];
    if (array && array.count>0) {
        if (Equal(flag, @"deposit_info")) {
            [LoginManager sharedManager].myDepositInfo = [array objectAtIndex:0];
            [LoginManager sharedManager].session.noDeposit = [LoginManager sharedManager].myDepositInfo.no_deposit;
            [LoginManager sharedManager].session.memberLevel = (int)[LoginManager sharedManager].myDepositInfo.memberLevel;
            self.balanceLabel.text = [NSString stringWithFormat:@"%ld",(long)[LoginManager sharedManager].myDepositInfo.banlance];
            self.freezeTotalLabel.text = [NSString stringWithFormat:@"%ld元",(long)[LoginManager sharedManager].myDepositInfo.freezeTotal];
            [[NSUserDefaults standardUserDefaults] setObject:@([LoginManager sharedManager].myDepositInfo.banlance) forKey:[NSString stringWithFormat:@"banlance-single-%@", [LoginManager sharedManager].session.mobilePhone]];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    [_tableView reloadData];
    _tableView.hidden = NO;
}

#pragma mark - ConfirmedTransfer
- (void)ConfirmedTransfer:(NSNotification *)notification {
    NSDictionary *info = [notification object];
    if (info) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"转账成功" message:@"款项已成功转入对方账户" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSArray * ctrlArray = self.navigationController.viewControllers;
            [self.navigationController popToViewController:ctrlArray[1] animated:YES];
        }];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"发私信" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self sendMessage:(NSDictionary *)info];
        }];
        [alert addAction:action];
        [alert addAction:action1];
        [self presentViewController:alert animated:YES completion:nil];
    }
    [[ServiceManager serviceManagerWithDelegate:self] getDepositInfo:[[LoginManager sharedManager] getSessionId] needCount:1];
}

- (void)sendMessage:(NSDictionary *)info {
    if ([self needPerfectMemberData]) {
        return;
    }
//    if ([[IMCore shareInstance] isLogin]) {
        [self toChatViewController:info];
//    }
}

- (void)toChatViewController:(NSDictionary *)info{
    UserFollowModel *model = info[@"data"];
    __weak typeof(self) weakSelf = self;
    WKDChatViewController *chatVC = [[WKDChatViewController alloc] init];
    chatVC.hidesBottomBarWhenPushed = YES;
    chatVC.targetImage = info[@"image"];
    chatVC.memId = model.memberId;
    chatVC.title = model.displayName;
    chatVC.isFollow = model.isFollowed;
    [weakSelf pushViewController:chatVC title:model.displayName  hide:YES];
}

#pragma mark - UITableViewDataSource,UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _rowTitleArrary.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return [_rowTitleArrary[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.textLabel.text = _rowTitleArrary[indexPath.section][indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 44;
    }
    return 8;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(nonnull UIView *)view forSection:(NSInteger)section {
    if (section == 1) {
        view.tintColor = [UIColor colorWithHexString:@"#F0EFF5"];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        self.freezeTotalLabel.text = [NSString stringWithFormat:@"%ld元",(long)[LoginManager sharedManager].myDepositInfo.freezeTotal];
        return _headerView;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 0) {
        return;
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            if ([LoginManager sharedManager].myDepositInfo.banlance >= 100000) {
                [SVProgressHUD showInfoWithStatus:@"余额已达到保证金总额上限，无法充值"];
            } else {
                YGWalletTopUpViewCtrl *vc = [YGWalletTopUpViewCtrl instanceFromStoryboard];
                vc.blockReturn = ^(id data){
                    [self.navigationController popToViewController:self animated:YES];
                };
                [self pushViewController:vc hide:YES];
            }
        }else if (indexPath.row == 1){
            if ([LoginManager sharedManager].myDepositInfo.banlance >= 50) {
                YGWalletWithdrawViewCtrl *balanceBack = [[YGWalletWithdrawViewCtrl alloc] init];
                balanceBack.depositInfoModel = [LoginManager sharedManager].myDepositInfo;
                [self pushViewController:balanceBack title:@"余额提现" hide:YES];
            } else {
                [SVProgressHUD showInfoWithStatus:@"帐户可用余额大于或等于50元方可进行提现操作"];
            }
        }else if (indexPath.row == 2){
            if ([LoginManager sharedManager].myDepositInfo.banlance > 0) {
                YGWalletTransferViewCtrl *transferToFriendsVC = [YGWalletTransferViewCtrl instanceFromStoryboard];
                [self pushViewController:transferToFriendsVC title:@"转帐给好友" hide:YES];
            } else {
                [SVProgressHUD showInfoWithStatus:@"余额不足，无法转账"];
            }
        }
    }
}

#pragma mark - YGLoginViewCtrlDelegate
- (void)loginButtonPressed:(id)sender {
    [[ServiceManager serviceManagerWithDelegate:self] getDepositInfo:[[LoginManager sharedManager] getSessionId] needCount:1];
}

@end
