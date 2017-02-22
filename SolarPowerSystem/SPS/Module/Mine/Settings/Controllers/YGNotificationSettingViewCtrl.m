//
//  YGNotificationSettingViewCtrl.m
//  Golf
//
//  Created by zhengxi on 15/12/25.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "YGNotificationSettingViewCtrl.h"
#import "YGSettingCell.h"
#import <PINCache/PINCache.h>

@interface YGNotificationSettingViewCtrl ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) void (^switchButtonBlock) (BOOL, NSIndexPath *);
@property (strong, nonatomic) NSArray *titleArray;
@property (nonatomic) BOOL isOn;
@property (strong, nonatomic) NSMutableDictionary *temParamDic;

@end

@implementation YGNotificationSettingViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [GolfAppDelegate shareAppDelegate].currentController = self;
    [self initializeTableView];
}

- (void)initializeTableView {
    self.titleArray = @[@[@"接收新消息通知"], @[@"有人赞了我", @"有人评论我", @"有人关注我",@"有新的约球"]];
    if (!self.paramDic) {
        self.paramDic = [[[NSUserDefaults standardUserDefaults] objectForKey:@"MessageNotificateSetting"] mutableCopy];
        if (!self.paramDic) {
            self.paramDic = [NSMutableDictionary dictionaryWithObjects:@[@(1),@(1),@(1),@(1)] forKeys:@[@"key_0",@"key_1",@"key_2",@"key_3"]];
        }
    }
    
    [[PINCache sharedCache] objectForKey:IDENTIFIER(@"ISOPEN_YQ_PUSH") block:^(PINCache * _Nonnull cache, NSString * _Nonnull key, id  _Nullable object) {
        _paramDic[@"key_3"] = object;
        if ([_paramDic[@"key_0"] intValue] == 1 || [_paramDic[@"key_1"] intValue] == 1 || [_paramDic[@"key_2"] intValue] == 1 || [_paramDic[@"key_3"] intValue] == 1) {
            _isOn = YES;//不能用self.isOn = YES;
        } else {
            _isOn = NO;
        }
    }];
}

- (void)changeSwitchButton:(BOOL)isOn indexPath:(NSIndexPath *)indexPath  cell:(YGSettingCell *)cell{
    self.temParamDic = _paramDic;
    int a = isOn ? 1 : 0;
    int onOff = 0;
    if (indexPath.section == 0) {
        self.isOn = isOn;
        [_tableView reloadData];
    } else if(indexPath.section == 1 && indexPath.row <= 2){
        [_paramDic setObject:@(a) forKey:[NSString stringWithFormat:@"key_%ld", (long)indexPath.row]];
        
        [_tableView reloadData];
    }else{
        if (a==1) {
            onOff = 1;
        }else{
            onOff = 0;
        }
        _paramDic[@"key_3"] = @(onOff);
        [[PINCache sharedCache] setObject:@(a) forKey:IDENTIFIER(@"ISOPEN_YQ_PUSH")];
    }
    
    NSArray *arr = [_paramDic allValues];
    BOOL flag = NO;
    for (int i = 0; i < arr.count; i++) {
        if ([arr[i] intValue] == 1) {
            flag = YES;
            break;
        }
    }
    _isOn = flag;
    [_tableView reloadData];

    [[ServiceManager serviceManagerWithDelegate:self] userEditSwitch:[[LoginManager sharedManager] getSessionId] noDisturbing:0 memberFollow:[self.paramDic[@"key_2"] intValue] memberMessage:[self.paramDic[@"key_3"] intValue] topicPraise:[self.paramDic[@"key_0"] intValue] topicComment:[self.paramDic[@"key_1"] intValue] yaoBallNotify:onOff];
}

- (void)setIsOn:(BOOL)isOn {
    _isOn = isOn;
    int a = isOn ? 1 : 0;
    _paramDic[@"key_0"] = @(a);
    _paramDic[@"key_1"] = @(a);
    _paramDic[@"key_2"] = @(a);
    _paramDic[@"key_3"] = @(a);
    [[PINCache sharedCache] setObject:@(a) forKey:IDENTIFIER(@"ISOPEN_YQ_PUSH")];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _titleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_titleArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    YGSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationTableViewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.leadingLabel.text = _titleArray[indexPath.section][indexPath.row];
    if (indexPath.section == 0) {
        [cell.switchButton setOn:_isOn];
    } else if(indexPath.section == 1 && indexPath.row <= 2){
        [cell.switchButton setOn:[[_paramDic valueForKey:[NSString stringWithFormat:@"key_%ld", (long)indexPath.row]] boolValue]];
    }else{
        [[PINCache sharedCache] objectForKey:IDENTIFIER(@"ISOPEN_YQ_PUSH") block:^(PINCache * _Nonnull cache, NSString * _Nonnull key, id  _Nullable object) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell.switchButton setOn:[object boolValue]];
            });
        }];
    }
    __weak YGSettingCell *weakCell = cell;
    cell.switchButtonBlock = ^ (BOOL isOn) {
        [weakSelf changeSwitchButton:isOn indexPath:indexPath cell:weakCell];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    return 8;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor colorWithHexString:@"#F0EFF5"];
}
#pragma mark - ServiceManagerDelegate
- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    if (Equal(flag, @"user_edit_switch")) {
        if (serviceManager.success) {
            [[NSUserDefaults standardUserDefaults] setObject:self.paramDic  forKey:@"MessageNotificateSetting"];
        } else {
            self.paramDic = _temParamDic;
            [_tableView reloadData];
        }
    }
}

#pragma mark - YGLoginViewCtrlDelegate
- (void)loginButtonPressed:(id)sender {
    [self initializeTableView];
}

@end
