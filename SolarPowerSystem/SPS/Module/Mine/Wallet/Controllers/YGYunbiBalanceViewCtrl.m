//
//  YGYunbiBalanceViewCtrl.m
//  Golf
//
//  Created by zhengxi on 15/12/13.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "YGYunbiBalanceViewCtrl.h"
#import "YGBalanceDetailsCell.h"
#import "YGBalanceDetailsViewCtrl.h"
#import "YGMallOrderViewCtrl.h"
#import "ClubOrderViewController.h"
#import "TeachingOrderDetailViewController.h"
#import "YGYunbiIntroViewCtrl.h"
#import "ManagementOrderTableViewCell.h"
#import "YGThriftRequestManager.h"
#import "YGTeachBookingOrderViewCtrl.h"
#import "YGPackageOrderDetailViewCtr.h"

@interface YGYunbiBalanceViewCtrl ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *yunbiLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *yunbiList;
@property (weak, nonatomic) IBOutlet UIButton *noRecordFooterView;
@property (weak, nonatomic) IBOutlet UIView *theTableFooterView;

@end

@implementation YGYunbiBalanceViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout=UIRectEdgeNone;
    [GolfAppDelegate shareAppDelegate].currentController = self;
    [self rightButtonAction:@"云币说明"];
    [self initializeTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.yunbiLabel.text = [NSString stringWithFormat:@"%ld",(long)[LoginManager sharedManager].myDepositInfo.yunbiBalance];
    [[NSUserDefaults standardUserDefaults] setObject:@([LoginManager sharedManager].myDepositInfo.yunbiBalance) forKey:[NSString stringWithFormat:@"yunbiBalance-single-%@", [LoginManager sharedManager].session.mobilePhone]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)initializeTableView {
    self.yunbiLabel.text = [NSString stringWithFormat:@"%ld",(long)[LoginManager sharedManager].myDepositInfo.yunbiBalance];
    self.yunbiList = [NSMutableArray array];
    
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
    
    [self getFirstPage];
}

- (void)getFirstPage {
    [[ServiceManager serviceManagerWithDelegate:self] accountConsumeList:[[LoginManager sharedManager] getSessionId] consumeType:1 pageNo:1];
}

#pragma mark -UITableViewDataSource,UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 40;
    } else {
        return 61;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_yunbiList.count > 0) {
        return _yunbiList.count >= 4 ? 5 : _yunbiList.count + 1;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FirstCellInYGYunbiBalanceViewCtrl" forIndexPath:indexPath];
        if (_yunbiList.count > 4) {
            cell.userInteractionEnabled = YES;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            ((ManagementOrderTableViewCell *)cell).trailingLabel.hidden = NO;
        } else {
            ((ManagementOrderTableViewCell *)cell).trailingLabel.hidden = YES;
            cell.userInteractionEnabled = NO;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    } else {
        YGBalanceDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YGBalanceDetailsCell" forIndexPath:indexPath];
        ConsumeModel *model = [self.yunbiList objectAtIndex:indexPath.row - 1];
        cell.model = model;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(nonnull UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor colorWithHexString:@"#F0EFF5"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row == 0) {
        YGBalanceDetailsViewCtrl *balanceListVC = [YGBalanceDetailsViewCtrl instanceFromStoryboard];
        balanceListVC.accountType = 1;
        [self pushViewController:balanceListVC title:@"收支明细" hide:YES];
    } else {
        ConsumeModel *model = [self.yunbiList objectAtIndex:indexPath.row - 1];

        if (model.relativeType == 1) { // 商品订单
            YGMallOrderViewCtrl *vc = [YGMallOrderViewCtrl instanceFromStoryboard];
            vc.orderId = model.relativeId;
            [self.navigationController pushViewController:vc animated:YES];
        }else if (model.relativeType == 2){ // 球场订单
            NSString *title = [NSString stringWithFormat:@"订单%d",model.relativeId];
            ClubOrderViewController *clubOrder = [[ClubOrderViewController alloc] init];
            clubOrder.orderId = model.relativeId;
            clubOrder.isBackUp = YES;
            [self pushViewController:clubOrder title:title hide:YES];
        }else if (model.relativeType == 3){ // 教学订单
            [self pushWithStoryboard:@"Teach" title:[NSString stringWithFormat:@"订单%d",model.relativeId] identifier:@"TeachingOrderDetailViewController" completion:^(BaseNavController *controller) {
                TeachingOrderDetailViewController *vc = (TeachingOrderDetailViewController *)controller;
                vc.orderId = model.relativeId;
                vc.blockReturn = ^(id data){
                    [self.navigationController popToViewController:self animated:YES];
                };
            }];
        }else if(model.relativeType == 4){// 练习场订单
            [SVProgressHUD show];
            [YGRequest fetchTeachingOrderDetail:@(model.relativeId)
                                        success:^(BOOL suc, id object) {
                                            VirtualCourseOrderDetail *detail = object;
                                            if (suc) {
                                                [SVProgressHUD dismiss];
                                                YGTeachBookingOrderViewCtrl *vc = [YGTeachBookingOrderViewCtrl instanceFromStoryboard];
                                                vc.order = detail.order;
                                                [self.navigationController pushViewController:vc animated:YES];
                                            }else{
                                                [SVProgressHUD showErrorWithStatus:detail.err.errorMsg];
                                            }
                                        }
                                        failure:^(Error *err) {
                                            [SVProgressHUD showErrorWithStatus:@"当前网络不可用"];
                                        }];
        }else if (model.relativeType == 5){ //旅行套餐
            YGPackageOrderDetailViewCtr *vc = [YGPackageOrderDetailViewCtr instanceFromStoryboard];
            vc.orderId = model.relativeId;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark - ServiceManagerDelegate
- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray*)data;
    if (array&&array.count>0) {
        [self.yunbiList addObjectsFromArray:array];
    }
    if (_yunbiList.count == 0) {
        _theTableFooterView.hidden = NO;
        [self.tableView setTableFooterView:_theTableFooterView];
    } else {
        _theTableFooterView.hidden = YES;
        [self.tableView setTableFooterView:nil];
    }
    [_tableView reloadData];
}

- (void)doRightNavAction {
    YGYunbiIntroViewCtrl *vc = [YGYunbiIntroViewCtrl instanceFromStoryboard];
    [vc show];
}
- (IBAction)toMall:(id)sender {
    [[GolfAppDelegate shareAppDelegate] pushToCommodityWithType:2 dataId:0 extro:@"" controller:self];
}

#pragma mark - YGLoginViewCtrlDelegate
- (void)loginButtonPressed:(id)sender {
    [self initializeTableView];
}

@end
