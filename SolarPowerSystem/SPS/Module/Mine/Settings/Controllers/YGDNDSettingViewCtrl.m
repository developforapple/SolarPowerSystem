//
//  YGDNDSettingViewCtrl.m
//  Golf
//
//  Created by zhengxi on 15/12/25.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "YGDNDSettingViewCtrl.h"
#import "YGSettingCell.h"
#import <PINCache/PINCache.h>

@interface YGDNDSettingViewCtrl ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) void (^switchButtonBlock) (BOOL);
@property (strong, nonatomic) NSMutableDictionary *paramDic;

@end

@implementation YGDNDSettingViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    [GolfAppDelegate shareAppDelegate].currentController = self;
    [self initializeTableView];
}

- (void)initializeTableView {
    self.paramDic = [[[NSUserDefaults standardUserDefaults] objectForKey:@"MessageNotificateSetting"] mutableCopy];
    if (!self.paramDic) {
        self.paramDic = [NSMutableDictionary dictionaryWithObjects:@[@(1),@(1),@(1),@(1),@(0)] forKeys:@[@"key_0",@"key_1",@"key_2",@"key_3",@"key_4"]];
    }
    [[PINCache sharedCache] objectForKey:IDENTIFIER(@"ISOPEN_YQ_PUSH") block:^(PINCache * _Nonnull cache, NSString * _Nonnull key, id  _Nullable object) {
        int onOff = [object intValue];
        __weak YGDNDSettingViewCtrl *weakSelf = self;
        self.switchButtonBlock = ^ (BOOL isOn) {
            [weakSelf.paramDic setObject:@(isOn) forKey:@"key_4"];
            [[ServiceManager serviceManagerWithDelegate:weakSelf] userEditSwitch:[[LoginManager sharedManager] getSessionId] noDisturbing:[weakSelf.paramDic[@"key_4"] intValue] memberFollow:[weakSelf.paramDic[@"key_2"] intValue] memberMessage:[weakSelf.paramDic[@"key_3"] intValue] topicPraise:[weakSelf.paramDic[@"key_0"] intValue] topicComment:[weakSelf.paramDic[@"key_1"] intValue] yaoBallNotify:onOff];
        };
    }];
}
#pragma mark - UITableViewDataSource, UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 80;
    }
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isOn) {
        return 3;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"noDisturb%ldTableViewCell", (long)indexPath.row] forIndexPath:indexPath];
    if (indexPath.row == 0) {
        ((YGSettingCell *)cell).selectionStyle = UITableViewCellSelectionStyleNone;
        ((YGSettingCell *)cell).leadingLabel.text = @"勿扰模式";
        [((YGSettingCell *)cell).switchButton setOn:_isOn];
        ((YGSettingCell *)cell).switchButtonBlock = _switchButtonBlock;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - ServiceManagerDelegate
- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    if (Equal(flag, @"user_edit_switch")) {
        if (serviceManager.success) {
            self.isOn = [_paramDic[@"key_4"] intValue] == 1 ? YES : NO;
            [[NSUserDefaults standardUserDefaults] setObject:self.paramDic  forKey:@"MessageNotificateSetting"];
            if (_buttonBlock) {
                _buttonBlock([_paramDic[@"key_4"] intValue]);
            }
        }
        [_tableView reloadData];
    }
}

#pragma mark - YGLoginViewCtrlDelegate
- (void)loginButtonPressed:(id)sender {
    [self initializeTableView];
}

@end
