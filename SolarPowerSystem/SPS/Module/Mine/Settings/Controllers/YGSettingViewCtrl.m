//
//  YGSettingViewCtrl.m
//  Golf
//
//  Created by zhengxi on 15/11/3.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "YGSettingViewCtrl.h"
#import "YGSettingCell.h"
#import "YGBlackListViewCtrl.h"
#import "IMNotificationDefine.h"
#import "CCActionSheet.h"
#import "CCAlertView.h"
#import "YGChangePasswordViewCtrl.h"
#import "YGDNDSettingViewCtrl.h"
#import "YGNotificationSettingViewCtrl.h"
#import <StoreKit/StoreKit.h>
#import "YGAboutViewCtrl.h"
#import "IMCore.h"
#import "YGThriftRequestManager.h"
#import "YYWebImage.h"
#import "IMMessages.h"
#import "IMUserInfo.h"
#import "IMSession.h"
#import "IMCardInfo.h"
#import "YGBindingListViewCtrl.h"
#import "YGMallAddressModel.h"
#import "YGMallAddressListViewCtrl.h"
#import <MagicalRecord/MagicalRecord.h>
#import <PINCache/PINCache.h>

@interface YGSettingViewCtrl ()<UITableViewDataSource, UITableViewDelegate, SKStoreProductViewControllerDelegate>
@property (strong, nonatomic) NSArray *rowTextArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) CGFloat cacheSize;
@property (strong, nonatomic) NSMutableDictionary *paramDic;
@property (weak, nonatomic) IBOutlet UIView *activityView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic,strong) YGMallAddressModel *addressModel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end

@implementation YGSettingViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    [GolfAppDelegate shareAppDelegate].currentController = self;
    [self initializeDictionary];
    [self initializeTableView];
    [self initializeDeliveryAddressList];
    self.bottomConstraint.constant = -49;//1底部的tabbar动画导致view的真实尺寸延迟
}

- (void)initializeTableView {
    self.rowTextArray = @[@[@"新消息通知",@"勿扰模式",@"收货地址",@"绑定设置",@"修改密码",@"可通过手机号搜索到我"],@[@"不看此人动态",@"黑名单管理"],@[@"清除缓存"],@[@"评价云高",@"关于云高"],@[@""]];
}

- (void)initializeDictionary {
    self.paramDic = [[[NSUserDefaults standardUserDefaults] objectForKey:@"MessageNotificateSetting"] mutableCopy];
    if (!self.paramDic) {
        self.paramDic = [NSMutableDictionary dictionaryWithObjects:@[@(1),@(1),@(1),@(1),@(0)] forKeys:@[@"key_0",@"key_1",@"key_2",@"key_3",@"key_4"]];
    }
    if (![LoginManager sharedManager].loginState) {
        [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES blockRetrun:^(id data) {
            [[ServiceManager serviceManagerWithDelegate:self] userSwitchInfo:[[LoginManager sharedManager] getSessionId]];
        }];
        return;
    }
    [[ServiceManager serviceManagerWithDelegate:self] userSwitchInfo:[[LoginManager sharedManager] getSessionId]];
}

- (void)initializeDeliveryAddressList {
    
    ygweakify(self);
    [YGMallAddressModel fetchDefaultAddress:^(YGMallAddressModel *address) {
        ygstrongify(self);
        self.addressModel = address;
        [self.tableView reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshCleanCacheCell];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.bottomConstraint.constant = 0;//2底部的tabbar动画导致view的真实尺寸延迟
}

- (void)refreshCleanCacheCell {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUInteger sdCacheSize = [[SDImageCache sharedImageCache] getSize];
        NSUInteger yyCacheSize = [[[YYImageCache sharedCache] diskCache] totalCost];
        CGFloat cacheSizeMB = (sdCacheSize+yyCacheSize)/1024.f/1024.f;
        self.cacheSize = cacheSizeMB>.1f?cacheSizeMB:0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didGetSize];
        });
    });
}

- (void)didGetSize{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (BOOL)canSearchByMobile
{
    NSNumber *can = [[NSUserDefaults standardUserDefaults] objectForKey:@"CanSearchByMobileKey"];
    if (!can) {
        return YES;
    }
    return [can boolValue];
}

- (void)changeSearchByMobile:(BOOL)isOn
{
    [YGRequest changeMobileSearchStatus:isOn success:^(BOOL suc, id object) {
        if (suc) {
            [[NSUserDefaults standardUserDefaults] setObject:@(isOn) forKey:@"CanSearchByMobileKey"];
        }
        [self.tableView reloadData];
    } failure:^(Error *err) {
        [SVProgressHUD showErrorWithStatus:@"网络不可用"];
        [self.tableView reloadData];
    }];
}

#pragma mark - UITableViewDelegate - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _rowTextArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray *)_rowTextArray[section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath.row == ((NSArray *)_rowTextArray[indexPath.section]).count - 1) && (indexPath.section == _rowTextArray.count - 1)) {
        UITableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:@"YGLogoutCell" forIndexPath:indexPath];
        return cell1;
    }
    YGSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YGSettingCell"];
    cell.leadingLabel.text = _rowTextArray[indexPath.section][indexPath.row];
    if (indexPath.section == 0 && indexPath.row == 5) {
        ygweakify(self);
        cell.trailingLabel.hidden = YES;
        cell.switchButton.hidden = NO;
        cell.switchButton.on = [self canSearchByMobile];
        [cell setSwitchButtonBlock:^(BOOL isOn){
            ygstrongify(self);
            [self changeSearchByMobile:isOn];
        }];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    }else if (indexPath.section == 2) {
        cell.trailingLabel.hidden = NO;
        cell.switchButton.hidden = YES;
        cell.trailingLabel.text = [NSString stringWithFormat:@"%.1fM", _cacheSize];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.row == 1 && indexPath.section == 0) {
        cell.trailingLabel.hidden = NO;
        cell.switchButton.hidden = YES;
        cell.trailingLabel.text = [_paramDic[@"key_4"] boolValue] ? @"开启" : @"关闭";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.row == 2 && indexPath.section == 0) {
        cell.trailingLabel.hidden = NO;
        cell.switchButton.hidden = YES;
        if (_addressModel.post_code.length>0) {
            cell.trailingLabel.text = [NSString stringWithFormat:@"%@%@%@%@ 邮编%@",self.addressModel.province_name,self.addressModel.city_name,self.addressModel.district_name,self.addressModel.address,self.addressModel.post_code];
        }else{
            if (_addressModel) {
                cell.trailingLabel.text = [NSString stringWithFormat:@"%@%@%@%@",self.addressModel.province_name,self.addressModel.city_name,self.addressModel.district_name,self.addressModel.address];
            } else {
                cell.trailingLabel.text = @"暂无地址";
            }
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.trailingLabel.hidden = YES;
        cell.switchButton.hidden = YES;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    return 8;
}

-(void) tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor colorWithHexString:@"#F0EFF5"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0) {
                YGNotificationSettingViewCtrl *viewController = [YGNotificationSettingViewCtrl instanceFromStoryboard];
                viewController.paramDic = _paramDic;
                [self pushViewController:viewController title:_rowTextArray[indexPath.section][indexPath.row] hide:YES];
            }else if (indexPath.row == 1) {
                YGDNDSettingViewCtrl *viewController = [YGDNDSettingViewCtrl instanceFromStoryboard];
                viewController.isOn = [_paramDic[@"key_4"] boolValue];
                viewController.buttonBlock = ^ (BOOL isOn) {
                    self.paramDic[@"key_4"] = @(isOn);
                    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                };
                [self pushViewController:viewController title:_rowTextArray[indexPath.section][indexPath.row] hide:YES];
            }else if(indexPath.row == 2) {
                
                ygweakify(self);
                YGMallAddressListViewCtrl *vc = [YGMallAddressListViewCtrl instanceFromStoryboard];
                vc.isSetDefaultAddress = YES;
                [vc setDidSelectedAddress:^(YGMallAddressModel *address) {
                    ygstrongify(self);
                    self.addressModel = address;
                    [self.tableView reloadData];
                }];
                [self.navigationController pushViewController:vc animated:YES];
                
            }else if (indexPath.row == 3) {//手机绑定
                YGBindingListViewCtrl *vc = [YGBindingListViewCtrl instanceFromStoryboard];
                vc.title = @"绑定设置";
                [self.navigationController pushViewController:vc animated:YES];
            }else if (indexPath.row == 4){
                
                [[LoginManager sharedManager] loginIfNeed:self doSomething:^(id data) {
                    YGChangePasswordViewCtrl *setPassword = [[YGChangePasswordViewCtrl alloc] init];
                    [self pushViewController:setPassword title:_rowTextArray[indexPath.section][indexPath.row] hide:YES];
                }];
            }
            break;
        case 1:
            if (indexPath.row == 0) {
                YGBlackListViewCtrl *viewController = [YGBlackListViewCtrl instanceFromStoryboard];
                viewController.isFollowedParameter = 6;
                [self pushViewController:viewController title:_rowTextArray[indexPath.section][indexPath.row] hide:YES];
            }else if (indexPath.row == 1){
                YGBlackListViewCtrl *viewController = [YGBlackListViewCtrl instanceFromStoryboard];
                viewController.isFollowedParameter = 3;
                [self pushViewController:viewController title:_rowTextArray[indexPath.section][indexPath.row] hide:YES];
            }
            break;
        case 2:
            [self cleanCacheFile];
            break;
        case 3:
            if (indexPath.row == 0) {
                [_activityIndicator startAnimating];
                _activityView.hidden = NO;
                [self evaluate];
            }else if (indexPath.row == 1) {
                [self pushViewController:[YGAboutViewCtrl instanceFromStoryboard] title:@"关于云高高尔夫" hide:YES];
            }
            break;
        case 4:
            [self reLoginAction];
            break;
        default:
            break;
    }
}

#pragma mark - CleanCacheFile
- (void)cleanCacheFile {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"确定清除缓存?" preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self cleanCacheFileAction];
    }];
    [alert addAction:cancelAction];
    [alert addAction:deleteAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)cleanCacheFileAction {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                   , ^{
                       [[SDImageCache sharedImageCache] clearMemory];
                       [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
                           //...
                       }];
                       [[SDImageCache sharedImageCache] cleanDisk];
                       
                       [[[YYImageCache sharedCache] diskCache] removeAllObjects];
                       
                       self.cacheSize = 0;
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self didGetSize];
                       });
                   });
}

#pragma mark - ServiceManagerDelegate
- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    if (Equal(flag, @"user_switch_info")) {
        if (serviceManager.success) {
            NSMutableDictionary *dic = [[[NSUserDefaults standardUserDefaults] objectForKey:@"MessageNotificateSetting"] mutableCopy];
            if (![_paramDic isEqualToDictionary:dic]) {
                [_tableView reloadData];
            }
            return;
        }
    }
}

#pragma mark - ReLogin
- (void)reLoginAction {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"是否退出当前账户?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self loginoutAction];
    }];
    [alert addAction:cancelAction];
    [alert addAction:deleteAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)loginoutAction {
    
    
    [LoginService publicLogout:[[LoginManager sharedManager] getSessionId] success:^(BOOL boolen) {
        if (boolen) {
            [self logoouted];
        }
    } failure:^(Error *error) {
        if (error.code == 100005) {//别删，当对方已经被踢下线时
            [self logoouted];
        }
    }];
}

- (void)logoouted{
    
    // 清除备注
    [LoginManager sharedManager].isloadedUserRemarks = NO;
    
    [[LoginManager sharedManager] setLoginState:NO];
    
    if (_blockLogoutReturn) {
        _blockLogoutReturn(nil);
    }
    
    [[PINCache sharedCache] removeObjectForKey:[NSString stringWithFormat:@"reloadSessions:%d",[LoginManager sharedManager].session.memberId]];
    
    [LoginManager sharedManager].myDepositInfo = nil;
    [LoginManager sharedManager].session = nil;
    [LoginManager sharedManager].vipList = nil;
    
    [[IMCore shareInstance] logoutWithCompletion:^{
        [[PINCache sharedCache] removeObjectForKey:IMUsername];
        [[PINCache sharedCache] removeObjectForKey:IMPassword];
    }];
    
    [IMSession MR_truncateAll];
    [IMMessages MR_truncateAll];
    [IMUserInfo MR_truncateAll];
    [IMCardInfo MR_truncateAll];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGOUTED" object:nil];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KGroupData];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"wechat_user_info"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KGolfUserPassword];
    [self.navigationController popToRootViewControllerAnimated:NO];
}


#pragma mark - SKStoreProductViewControllerDelegate
- (void)evaluate{
    //初始化控制器
    SKStoreProductViewController *storeProductViewContorller = [[SKStoreProductViewController alloc] init];
    //设置代理请求为当前控制器本身
    storeProductViewContorller.delegate = self;
    //加载一个新的视图展示
    [storeProductViewContorller loadProductWithParameters:
     //appId唯一的
     @{SKStoreProductParameterITunesItemIdentifier : kGolfAppStoreIdStr} completionBlock:^(BOOL result, NSError *error) {
         //block回调
         _activityView.hidden = YES;
         [_activityIndicator stopAnimating];
         if(error){
             NSLog(@"error %@ with userInfo %@",error,[error userInfo]);
         }else{
             //模态弹出appstore
             [self presentViewController:storeProductViewContorller animated:YES completion:^{}];
         }
     }];
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - YGLoginViewCtrlDelegate
- (void)loginButtonPressed:(id)sender {
    [self initializeDictionary];
    [self initializeTableView];
    [self initializeDeliveryAddressList];
}

@end
