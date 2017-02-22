//
//  SubscribeTimeTableViewController.m
//  Golf
//
//  Created by 廖瀚卿 on 15/6/4.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "SubscribeTimeTableViewController.h"
#import "TimetableViewController.h"

@interface SubscribeTimeTableViewController ()<ServiceManagerDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewWhite;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *btns;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnSave;

@end

@implementation SubscribeTimeTableViewController{
    NSMutableArray *arr;
}

- (void)getDepositAction{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ServiceManager serviceManagerWithDelegate:self] getDepositInfo:[[LoginManager sharedManager] getSessionId] needCount:1];
    });
}

- (void)serviceResult:(ServiceManager*)serviceManager Data:(id)data flag:(NSString*)flag{
    NSArray *array = [NSArray arrayWithArray:data];
    if (array && array.count>0) {
        if (Equal(flag, @"deposit_info")) {
            [LoginManager sharedManager].myDepositInfo = [array objectAtIndex:0];
            [LoginManager sharedManager].session.noDeposit = [LoginManager sharedManager].myDepositInfo.no_deposit;
            [LoginManager sharedManager].session.memberLevel = (int)[LoginManager sharedManager].myDepositInfo.memberLevel;
            arr = [[NSMutableArray alloc] initWithArray:[LoginManager sharedManager].myDepositInfo.timeSet];
            if (arr == nil || arr.count == 0) {
                arr = [[NSMutableArray alloc]initWithArray:@[@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1]];
            }
            [self loadData];
        }
    }
    if (Equal(flag, @"teaching_coach_update_timeset")) {
        _btnSave.enabled = YES;
        int flag = [[array firstObject] intValue];
        if (flag == 1) {
            if (_timeSet && _timeSet.count > 0) {
                ygweakify(self);
                [self performSegueWithIdentifier:@"TimetableViewController" sender:nil withBlock:^(id sender, id destinationVC) {
                    ygstrongify(self);
                    TimetableViewController *vc = (TimetableViewController *)destinationVC;
                    vc.coachId = [LoginManager sharedManager].session.memberId;
                    vc.blockReturn = self.blockReturnRoot;
                }];
            }else{
                if (_blockReturn) {
                    _blockReturn(nil);
                }
            }
        }
    }
}

- (void)doLeftNavAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    arr = [[NSMutableArray alloc] initWithArray:_timeSet];

    _viewWhite.layer.borderColor = [UIColor colorWithHexString:@"#c8c8c8"].CGColor;
    _viewWhite.layer.borderWidth = 1;
    
    self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    
    if (_timeSet && _timeSet.count > 0) {
        [self loadData];
    }else{
        [self getDepositAction];
    }
    UIButton *navLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    navLeftButton.frame = CGRectMake(0, 0, 50, 30);
    UIImage *img = [UIImage imageNamed:@"back_icon.png"];
    [navLeftButton setBackgroundImage:img forState:UIControlStateNormal];
    [navLeftButton setBackgroundImage:img forState:UIControlStateHighlighted];
    [navLeftButton addTarget:self action:@selector(doLeftNavAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navLeftButton];
}

- (void)loadData{
    if (arr && arr.count > 0) {
        for (int i = 0; i < _btns.count; i++) {
            UIButton *btn = _btns[i];
            btn.selected = ([arr[i] intValue] == 0);
        }
    }
}

- (IBAction)btnPressed:(UIButton *)btn {
    if (arr && arr.count > 0) {
        btn.selected = !btn.selected;
        NSInteger index = btn.tag - 7;
        arr[index] = btn.selected ? @0:@1;
    }
}

- (IBAction)btnSave:(id)sender {
    _btnSave.enabled = NO;
    NSMutableString *str = [[NSMutableString alloc] init];
    for (int i = 0; i < arr.count; i++) {
        NSNumber *n = arr[i];
        [str appendFormat:@"%d",[n intValue]];
        if (i < arr.count - 1) {
            [str appendString:@","];
        }
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ServiceManager serviceManagerWithDelegate:self] teachingUpdateTimeSetByCoachId:_coachId timeSet:str sessionId:[[LoginManager sharedManager] getSessionId]];
    });
}


@end
