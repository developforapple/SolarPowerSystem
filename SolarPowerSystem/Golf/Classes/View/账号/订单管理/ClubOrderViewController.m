//
//  ClubOrderViewController.m
//  Golf
//
//  Created by 黄希望 on 14-8-14.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "ClubOrderViewController.h"
#import "UIButton+Custom.h"
#import "SharePackage.h"
#import "ClubMainViewController.h"
#import "YGMapViewCtrl.h"
#import "BottomButtonView.h"
#import "CCActionSheet.h"
#import "CCAlertView.h"
#import "CustomerServiceViewCtrl.h"
#import "YGCapabilityHelper.h"
#import "YGPackageDetailViewCtrl.h"
#import "OrderService.h"
#import "PayOnlineViewController.h"
#import "YGOrderHandlerCourse.h"

static int tempOrderStatus; //lyf 加

@interface ClubOrderViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>{
    UITableView *_tableview;
    UIScrollView *_scrollView;
    SharePackage *_share;
}

@property (nonatomic,strong) NSArray *titleArray;
@property (strong, nonatomic) BottomButtonView *bottomView;
@property (nonatomic) int operation;
@property (strong, nonatomic) YGOrderHandlerCourse *handler;
@end

@implementation ClubOrderViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self rightButtonActionWithImg:@"option.png"];
    
    self.titleArray = @[@"订单状态",@"下单时间",@"订单总价",@"付款方式",@"已付金额",@"",@"可返云币",@"",@"开球时间",@"打球人数",@"   打球人",@"联系电话",@"价格包含",@"",@"",@"提供商家",@"预订说明",@"我的备注",@""];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
    
    _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, Device_Width, 0) style:UITableViewStylePlain];
    _tableview.delegate = self;
    _tableview.dataSource = self;
    _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableview.scrollEnabled = NO;
    [self setExtraCellLineHidden:_tableview];
    [_scrollView addSubview:_tableview];
    
    if (!self.orderDetail) {
        if (![LoginManager sharedManager].loginState) {
            [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES blockRetrun:^(id obj) {
                [[ServiceManager serviceManagerWithDelegate:self] getOrderDetail:[[LoginManager sharedManager] getSessionId] withOrderId:self.orderId flag:@"order_detail"];
            }];
        }else{
            [[ServiceManager serviceManagerWithDelegate:self] getOrderDetail:[[LoginManager sharedManager] getSessionId] withOrderId:self.orderId flag:@"order_detail"];
        }
    }else{
        tempOrderStatus = _orderDetail.orderStatus;
        [_tableview reloadData];
        CGRect rt = _tableview.frame;
        rt.size.height = _tableview.contentSize.height;
        _tableview.frame = rt;
        [_scrollView setContentSize:CGSizeMake(Device_Width, _tableview.contentSize.height+10)];
    }
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(addBottomButton) userInfo:nil repeats:NO];//lyf 加
}
- (void)addBottomButton {
    self.bottomView = [[[NSBundle mainBundle] loadNibNamed:@"BottomButtonView" owner:self options:nil] firstObject];
    CGRect rect = CGRectMake(0, self.view.frame.size.height - 49, Device_Width, 49);
    _bottomView.frame = rect;
    BOOL canCancel = YES;
    if (self.orderDetail.orderStatus == 3 || self.orderDetail.orderStatus == 8) {
        canCancel = NO;
    }
    _bottomView.cancelOrderButton.enabled = canCancel;
    __weak ClubOrderViewController *weakSelf = self;
    _bottomView.cancelButtonBlock = ^ {
        [weakSelf cancelOrder:nil];
    };
    _bottomView.customerButtonBlock = ^ {
        [CustomerServiceViewCtrl show];
    };
    [self.view addSubview:_bottomView];
    [self.view bringSubviewToFront:_bottomView];
    [self refreshBottomView];
}

- (void)refreshBottomView {
    /*
     @"完成预订",
                @"完成消费",2
                @"未到场",
                @"已取消",
     @"等待确认",5
     @"等待支付",6
                @"申请撤销",
                @"已经撤销",*/
    if (self.orderDetail) {
        if (self.orderDetail.packageId <= 0 && self.orderDetail.agentId <= 0) {
            if (self.orderDetail.orderStatus == 4){ // 已取消
                _bottomView.cancelOrderButton.enabled = YES;
                [_bottomView.cancelOrderButton setTitle:[NSString stringWithFormat:@"重新预订"] forState:UIControlStateNormal];
            }else if (self.orderDetail.orderStatus == 2){ // 完成消费
                _bottomView.cancelOrderButton.enabled = YES;
                [_bottomView.cancelOrderButton setTitle:[NSString stringWithFormat:@"再次预订"] forState:UIControlStateNormal];
            } else {
                _bottomView.cancelOrderButton.enabled = YES;
                [_bottomView.cancelOrderButton setTitle:[NSString stringWithFormat:@"取消订单"] forState:UIControlStateNormal];
            }
        } else {
            if (self.orderDetail.orderStatus == 1 || _orderDetail.orderStatus == 5 || _orderDetail.orderStatus == 6) { // 完成预订 待确认 待支付
                _bottomView.cancelOrderButton.enabled = YES;
                [_bottomView.cancelOrderButton setTitle:[NSString stringWithFormat:@"取消订单"] forState:UIControlStateNormal];
            }else if (self.orderDetail.orderStatus == 4){ // 已取消
                _bottomView.cancelOrderButton.enabled = YES;
                [_bottomView.cancelOrderButton setTitle:[NSString stringWithFormat:@"重新预订"] forState:UIControlStateNormal];
            }else if (self.orderDetail.orderStatus == 2){ // 完成消费
                _bottomView.cancelOrderButton.enabled = YES;
                [_bottomView.cancelOrderButton setTitle:[NSString stringWithFormat:@"再次预订"] forState:UIControlStateNormal];
            }else if (self.orderDetail.orderStatus == 7){ // 已申请取消订单
                _bottomView.cancelOrderButton.enabled = YES;
                [_bottomView.cancelOrderButton setTitle:[NSString stringWithFormat:@"取消申请撤销"] forState:UIControlStateNormal];
            }else{
                NSArray *array = @[@"", @"", @"未到场", @"", @"", @"", @"", @"", @"已经退款"];
                [self.bottomView.cancelOrderButton setTitle:array[_orderDetail.orderStatus] forState:UIControlStateDisabled];
                self.bottomView.cancelOrderButton.enabled = NO;
            }
        }
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [GolfAppDelegate shareAppDelegate].currentController = self;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (!self.isBackUp || (_orderDetail.orderStatus != tempOrderStatus)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"systemNewsCount" object:nil]; //lyf 加，下单之后又取消的情况
    }
}

- (YGOrderHandlerCourse *)handler
{
    _handler = [YGOrderHandlerCourse handlerWithOrder:self.orderDetail];
    _handler.viewCtrl = self;
    return _handler;
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    if (Equal(flag, @"order_delete")) {
        if (serviceManager.success) {
            
            
            [self.handler postOrderDidDeletedNotification];
            
            
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"OperatedAllKindsOrder" object:@{@"data":_orderDetail,@"orderType":@1,@"operate":@1}];//lyf 加 orderType:1球场，2商品，3教学 operate:1是删除，2是其他
            [self back];
            return;
        }
    }
    
    if (Equal(flag, @"order_detail")) {
        if (serviceManager.success) {
            NSArray *array = (NSArray*)data;
            if (array && array.count > 0) {
                self.orderDetail = [array objectAtIndex:0];
                tempOrderStatus = _orderDetail.orderStatus;//lyf 加
                
                [self.handler postOrderDidChangedNotification];
                
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"OperatedAllKindsOrder" object:@{@"data":_orderDetail,@"orderType":@1,@"operate":@2}];//lyf 加 orderType:1球场，2商品，3教学 operate:1是删除，2是其他 //lyf屏蔽
                [_tableview reloadData];
                [self refreshBottomView];
                CGRect rt = _tableview.frame;
                rt.size.height = _tableview.contentSize.height;
                _tableview.frame = rt;
                [_scrollView setContentSize:CGSizeMake(Device_Width, _tableview.contentSize.height+10)];
            }
            self.navigationItem.rightBarButtonItem.enabled = YES;
            _bottomView.cancelOrderButton.enabled = YES;
        }else{
            self.navigationItem.rightBarButtonItem.enabled = NO;
            _bottomView.cancelOrderButton.enabled = NO;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 7;
    }else if (section == 1){
        return 8;
    }else {
        return 3;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.textLabel.textColor = [Utilities R:138 G:138 B:138];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.textColor = [Utilities R:6 G:156 B:216];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (indexPath.row == 0) {
        [Utilities lineviewWithFrame:CGRectMake(0, 0, Device_Width, 1) forView:cell.contentView];
    }else if ((indexPath.section == 0&&indexPath.row == 6&&self.orderDetail.yunbi>0) || (indexPath.section == 1&&indexPath.row == 7)){
        [Utilities lineviewWithFrame:CGRectMake(0, 43, Device_Width, 1) forView:cell.contentView];
    }else if (indexPath.section == 2 && indexPath.row == 3){
        [Utilities lineviewWithFrame:CGRectMake(0, 49, Device_Width, 1) forView:cell.contentView];
    }
    if (indexPath.row == 6 || (indexPath.section == 1 && (indexPath.row == 1 || indexPath.row == 7))){
        [Utilities lineviewWithFrame:CGRectMake(15, 0, Device_Width-15, 1) forView:cell.contentView];
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = [self.titleArray objectAtIndex:indexPath.row];
        UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, indexPath.row%2==0?15:1, 230, 16)];
        rightLabel.backgroundColor = [UIColor clearColor];
        rightLabel.font = [UIFont systemFontOfSize:15];
        [cell.contentView addSubview:rightLabel];
        if (indexPath.row == 0) {
            rightLabel.font = [UIFont boldSystemFontOfSize:16];
            rightLabel.text = OrderStatus[self.orderDetail.orderStatus-1];
        }else if (indexPath.row == 1){
            rightLabel.text = [Utilities getDateStringFromString:self.orderDetail.orderCreateTime WithAllFormatter:@"yyyy-MM-dd HH:mm"];
        }else if (indexPath.row == 2){
            rightLabel.textColor = [Utilities R:255 G:109 B:0];
            rightLabel.font = [UIFont boldSystemFontOfSize:16];
            rightLabel.text = [NSString stringWithFormat:@"¥%d",self.orderDetail.orderTotal];
        }else if (indexPath.row == 3){
            rightLabel.font = [UIFont systemFontOfSize:15];
            if (self.orderDetail.payType == PayTypeDeposit) {
                if (self.orderDetail.orderStatus == OrderStatusCancel) {
                    rightLabel.text = @"球场现付";
                }else{
                    rightLabel.text = self.orderDetail.payTotal>0 ? [NSString stringWithFormat:@"球场现付¥%d，预付押金¥%d",self.orderDetail.orderTotal,self.orderDetail.payTotal] : [NSString stringWithFormat:@"球场现付¥%d",self.orderDetail.orderTotal];
                }
            }else if (self.orderDetail.payType == PayTypeOnline){
                rightLabel.text = [NSString stringWithFormat:@"全额预付¥%d",self.orderDetail.orderTotal];
            }else if (self.orderDetail.payType == PayTypeOnlinePart){
                rightLabel.text = self.orderDetail.payTotal>0 ? [NSString stringWithFormat:@"球场现付¥%d，在线支付¥%d",self.orderDetail.orderTotal-self.orderDetail.payTotal,self.orderDetail.payTotal] : @"部分预付";
            }else if (self.orderDetail.payType == PayTypeVip){
                rightLabel.textColor = [Utilities R:255 G:109 B:0];
                rightLabel.text = @"实付金额以球会前台确认为准";
            }
        }else if (indexPath.row == 4){
            if (self.orderDetail.orderStatus == OrderStatusWaitEnsure||self.orderDetail.orderStatus == OrderStatusWaitPay) {
                cell.textLabel.text = self.orderDetail.payType == PayTypeDeposit && self.orderDetail.payTotal > 0 ? @"待付押金" : @"待付金额";
            }else{
                cell.textLabel.text = self.orderDetail.payType == PayTypeDeposit && self.orderDetail.payTotal > 0 ? @"已付押金" : @"已付金额";
            }
            rightLabel.text = [NSString stringWithFormat:@"¥%d",self.orderDetail.payTotal];
        }else if (indexPath.row == 5){
            if (self.orderDetail.orderStatus == OrderStatusWaitPay) {
                UIButton *btn = [UIButton myButton:self Frame:CGRectMake(15, 0, Device_Width-30, 44) NormalImage:@"yellowbtn.png" SelectImage:nil Title:@"立即支付" TitleColor:[UIColor whiteColor] Font:18 Action:@selector(payBtnAction:)];
                [cell.contentView addSubview:btn];
                
                rightLabel.font = [UIFont systemFontOfSize:12];
                rightLabel.frame = CGRectMake(15, 54, Device_Width-30, 12);
                rightLabel.textAlignment = NSTextAlignmentCenter;
                rightLabel.textColor = [Utilities R:255 G:109 B:0];
                rightLabel.text = self.orderDetail.agentId > 0 ? @"请在30分钟内付款，逾期订单将自动取消" : @"请在45分钟内付款，逾期订单将自动取消";
            }
        }else if (indexPath.row == 6){
            if (self.orderDetail.yunbi>0) {
                UIButton *infoBtn = [UIButton myButton:self Frame:CGRectMake(0, 0, 17, 17) NormalImage:@"sb_22.png" SelectImage:nil Title:nil TitleColor:nil Font:0 Action:@selector(yunbiDescription)];
                cell.accessoryView = infoBtn;
                if (self.orderDetail.yunbi==0) {
                    cell.textLabel.text = @"   返云币";
                    rightLabel.text = [NSString stringWithFormat:@"%d",self.orderDetail.yunbi];
                }else if (self.orderDetail.orderStatus == OrderStatusNew) {
                    rightLabel.text = [NSString stringWithFormat:@"%d (待返)",self.orderDetail.yunbi];
                }else if (self.orderDetail.orderStatus == OrderStatusSuccess){
                    rightLabel.text = [NSString stringWithFormat:@"%d (已返)",self.orderDetail.yunbi];
                }else{
                    rightLabel.text = [NSString stringWithFormat:@"%d",self.orderDetail.yunbi];
                }
            }else{
                cell.textLabel.text = @"";
            }
        }
    }else if (indexPath.section == 1){
        cell.textLabel.text = [self.titleArray objectAtIndex:indexPath.row + 7];
        UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, indexPath.row%2==0?0:14, Device_Width-90, 16)];
        rightLabel.backgroundColor = [UIColor clearColor];
        rightLabel.font = [UIFont systemFontOfSize:15];
        [cell.contentView addSubview:rightLabel];
        if (indexPath.row < 6 && indexPath.row >0) {
            if (indexPath.row == 1){
                if (self.orderDetail.packageId > 0) {
                    cell.textLabel.text = @"到达时间";
                }
                rightLabel.text = [NSString stringWithFormat:@"%@ %@",self.orderDetail.teetimeDate,self.orderDetail.teetimeTime];
                
            }else if (indexPath.row == 2){
                rightLabel.text = [NSString stringWithFormat:@"%d人",self.orderDetail.memberNum];
            }else if (indexPath.row == 3){
                rightLabel.text = self.orderDetail.memberName;
            }else if (indexPath.row == 4){
                rightLabel.text = self.orderDetail.mobilePhone;
            }else if (indexPath.row == 5){
                rightLabel.text = self.orderDetail.priceContent;
            }
        }else{
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            rightLabel.frame = CGRectMake(15, 14, Device_Width-100, 15);
            rightLabel.font = [UIFont systemFontOfSize:15];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            if (indexPath.row == 0) {
                rightLabel.text = self.orderDetail.packageId>0 ? self.orderDetail.packageName : self.orderDetail.clubName;
            }else if (indexPath.row == 6){
                rightLabel.font = [UIFont systemFontOfSize:14];
                rightLabel.numberOfLines = 0;
                rightLabel.frame = CGRectMake(15, 0, Device_Width-100, 50);
                rightLabel.text = self.orderDetail.address;
                cell.detailTextLabel.text = @"导航";
            }else if (indexPath.row == 7){
                rightLabel.text = self.orderDetail.linkPhone;
                cell.detailTextLabel.text = @"联系球场";
            }
        }
    }else{
        cell.textLabel.text = [self.titleArray objectAtIndex:indexPath.row + 15];
        UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, indexPath.row%2==0?14:0, Device_Width-30, 16)];
        rightLabel.backgroundColor = [UIColor clearColor];
        rightLabel.font = [UIFont systemFontOfSize:15];
        [cell.contentView addSubview:rightLabel];
        if (indexPath.row == 0) {
            rightLabel.text = self.orderDetail.agentId>0 ? self.orderDetail.agentName : @"球会官方直销";
        }else if (indexPath.row == 1){
            NSString *description = self.orderDetail.description.length>0 ? self.orderDetail.description : @"暂无预订说明";
            CGSize sz = [Utilities getSize:description withFont:[UIFont systemFontOfSize:15] withWidth:Device_Width-90];
            if (sz.height < 20) {
                sz.height = 16;
            }
            rightLabel.numberOfLines = 0;
            rightLabel.lineBreakMode = NSLineBreakByWordWrapping;
            rightLabel.frame = CGRectMake(85, 0, Device_Width-90, sz.height);
            rightLabel.text = description;
        }else if (indexPath.row == 2){
            NSString *description = self.orderDetail.userMemo.length>0 ? self.orderDetail.userMemo : @"暂无";
            CGSize sz = [Utilities getSize:description withFont:[UIFont systemFontOfSize:15] withWidth:Device_Width-30];
            if (sz.height < 20) {
                sz.height = 16;
            }
            rightLabel.numberOfLines = 0;
            rightLabel.lineBreakMode = NSLineBreakByWordWrapping;
            rightLabel.frame = CGRectMake(85, 14, Device_Width-90, sz.height);
            rightLabel.text = description;
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 5) {
            return self.orderDetail.orderStatus == OrderStatusWaitPay ? 80 : 0;
        }else if (indexPath.row == 6){
            return self.orderDetail.yunbi > 0 ? 44 : 0;
        }else {
            if (indexPath.row%2==0) {
                return 44;
            }
            return 16;
        }
    }else if (indexPath.section == 1){
        if (indexPath.row > 0 && indexPath.row < 6) {
            if (indexPath.row%2==0) {
                return 16;
            }
            return 44;
        }else if (indexPath.row == 6){
            return 50;
        }else{
            return 44;
        }
    }else{
        if (indexPath.row == 0) {
            return 44;
        }else if (indexPath.row == 1){
            NSString *description = self.orderDetail.description.length>0 ? self.orderDetail.description : @"暂无预订说明";
            CGSize sz = [Utilities getSize:description withFont:[UIFont systemFontOfSize:15] withWidth:230];
            if (sz.height < 20) {
                sz.height = 16;
            }
            return sz.height;
        }else if (indexPath.row == 2){
            NSString *description = self.orderDetail.userMemo.length>0 ? self.orderDetail.userMemo : @"暂无";
            CGSize sz = [Utilities getSize:description withFont:[UIFont systemFontOfSize:15] withWidth:230];
            if (sz.height < 20) {
                return 44;
            }
            return sz.height + 28;
        }else{
            return 50;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            if (self.orderDetail.packageId==0) {
                ConditionModel *myCondition = [[ConditionModel alloc] init];
                myCondition.date = self.orderDetail.teetimeDate;
                myCondition.time = self.orderDetail.teetimeTime;
                myCondition.clubId = self.orderDetail.clubId;
                
                [self pushWithStoryboard:@"BookTeetime" title:@"" identifier:@"ClubMainViewController" completion:^(BaseNavController *controller) {
                    ClubMainViewController *vc = (ClubMainViewController*)controller;
                    vc.cm = myCondition;
                    vc.agentId = -1;
                }];
            }else{
                YGPackageDetailViewCtrl *vc = [YGPackageDetailViewCtrl instanceFromStoryboard];
                vc.packageId = self.orderDetail.packageId;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }else if (indexPath.row == 6){
            [self pressedMap];
        }else if (indexPath.row == 7){
            [YGCapabilityHelper call:self.orderDetail.linkPhone needConfirm:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 17;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Device_Width, 17)];
    view.backgroundColor = [Utilities R:241 G:240 B:246];
    return view;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{//lyf 加
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [Utilities R:241 G:240 B:246];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 2) {//lyf 加
        return 49;
    }
    return 0.1;
}

- (void)cancelOrder:(UIButton*)button{
    NSString *titleString = nil;
    NSString *cancelString = nil;
    NSString *otherString = nil;
    if (self.orderDetail == nil) {//订单已经删除
        return;
    }
    __block void (^buttonBlock) (void);
    if (self.orderDetail.packageId <= 0) {
        if (self.orderDetail.agentId <= 0) {
            //球会
            if (self.orderDetail.isAllowCancel == 1) {
                self.operation = 0;
                titleString = @"确定取消订单？";
                cancelString = @"再想想";
                otherString = @"取消订单";
                buttonBlock = ^{
                    [self cancelOrderInBackground:_operation];
                };
            }else {
                if (self.orderDetail.orderStatus == 4 || self.orderDetail.orderStatus == 2){ // 重新预订 // 再次预订
                    if (self.orderDetail.packageId==0) {
                        ConditionModel *myCondition = [[ConditionModel alloc] init];
                        myCondition.date = self.orderDetail.teetimeDate;
                        myCondition.time = self.orderDetail.teetimeTime;
                        myCondition.clubId = self.orderDetail.clubId;
                        
                        [self pushWithStoryboard:@"BookTeetime" title:@"" identifier:@"ClubMainViewController" completion:^(BaseNavController *controller) {
                            ClubMainViewController *vc = (ClubMainViewController*)controller;
                            vc.cm = myCondition;
                            vc.agentId = -1;
                        }];
                    }else{
                        
                        YGPackageDetailViewCtrl *vc = [YGPackageDetailViewCtrl instanceFromStoryboard];
                        vc.packageId = self.orderDetail.packageId;
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                    return;
                } else {
                    titleString = @"现已过最晚可取消订单时间，如需取消订单需与商家沟通协商，立即拨通商家电话";
                    cancelString = @"关闭";
                    otherString = @"拨通电话";
                    buttonBlock = ^{
                        [YGCapabilityHelper call:self.orderDetail.linkPhone needConfirm:YES];
                    };
                }
            }
        }else {                                      //中介
            if (self.orderDetail.orderStatus == 1 || self.orderDetail.orderStatus == 5 || self.orderDetail.orderStatus == 6) {
                self.operation = 0;
                titleString = @"确定取消订单？";
                cancelString = @"再想想";
                otherString = @"取消订单";
                buttonBlock = ^{
                    [self cancelOrderInBackground:_operation];
                };
            }else if (self.orderDetail.orderStatus == 4 || self.orderDetail.orderStatus == 2){ // 重新预订 // 再次预订
                if (self.orderDetail.packageId==0) {
                    ConditionModel *myCondition = [[ConditionModel alloc] init];
                    myCondition.date = self.orderDetail.teetimeDate;
                    myCondition.time = self.orderDetail.teetimeTime;
                    myCondition.clubId = self.orderDetail.clubId;
                    
                    [self pushWithStoryboard:@"BookTeetime" title:@"" identifier:@"ClubMainViewController" completion:^(BaseNavController *controller) {
                        ClubMainViewController *vc = (ClubMainViewController*)controller;
                        vc.cm = myCondition;
                        vc.agentId = -1;
                    }];
                }else{
                    
                    YGPackageDetailViewCtrl *vc = [YGPackageDetailViewCtrl instanceFromStoryboard];
                    vc.packageId = self.orderDetail.packageId;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                return;
            } else if (self.orderDetail.orderStatus == 7) {
                self.operation = 1;
                titleString = @"确定取消申请？";
                cancelString = @"再想想";
                otherString = @"取消申请";
                buttonBlock = ^{
                    [self cancelOrderInBackground:_operation];
                };
            } else {
                titleString = @"当前状态不能取消订单";
                cancelString = @"关闭";
                otherString = nil;
                buttonBlock = ^{
                };
            }
        }
    }
    else{
        if (self.orderDetail.orderStatus == 1 || self.orderDetail.orderStatus == 5 || self.orderDetail.orderStatus == 6) {
            self.operation = 0;
            titleString = @"确定取消订单？";
            cancelString = @"再想想";
            otherString = @"取消订单";
            buttonBlock = ^{
                [self cancelOrderInBackground:_operation];
            };
        }else if (self.orderDetail.orderStatus == 4 || self.orderDetail.orderStatus == 2){ // 重新预订 // 再次预订
            if (self.orderDetail.packageId==0) {
                ConditionModel *myCondition = [[ConditionModel alloc] init];
                myCondition.date = self.orderDetail.teetimeDate;
                myCondition.time = self.orderDetail.teetimeTime;
                myCondition.clubId = self.orderDetail.clubId;
                
                [self pushWithStoryboard:@"BookTeetime" title:@"" identifier:@"ClubMainViewController" completion:^(BaseNavController *controller) {
                    ClubMainViewController *vc = (ClubMainViewController*)controller;
                    vc.cm = myCondition;
                    vc.agentId = -1;
                }];
            }else{
                YGPackageDetailViewCtrl *vc = [YGPackageDetailViewCtrl instanceFromStoryboard];
                vc.packageId = self.orderDetail.packageId;
                [self.navigationController pushViewController:vc animated:YES];
            }
            return;
        } else if (self.orderDetail.orderStatus == 7) {
            self.operation = 1;
            titleString = @"确定取消申请？";
            cancelString = @"再想想";
            otherString = @"取消申请";
            buttonBlock = ^{
                [self cancelOrderInBackground:_operation];
            };
        } else {
            titleString = @"当前状态不能取消订单";
            cancelString = @"关闭";
            otherString = nil;
            buttonBlock = ^{
            };
        }
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:titleString preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelString style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *action;
    if (otherString.length > 0) {
        action = [UIAlertAction actionWithTitle:otherString style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            buttonBlock();
        }];
    }
    
    [alert addAction:cancelAction];
    if (otherString.length > 0) {
        [alert addAction:action];
    }
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)cancelOrderInBackground:(int)operation  //取消订单
{
    [OrderService orderCancel:[[LoginManager sharedManager] getSessionId] withOrderId:self.orderDetail.orderId operation:(int)operation success:^(BOOL boolen) {
        if (boolen) {
            NSString *msg = nil;
            if(self.orderDetail.agentId > 0 || self.orderDetail.packageId > 0) {
                if(self.orderDetail.orderStatus == 5 || self.orderDetail.orderStatus == 6) {
                    msg = @"订单取消成功";
                } else if(self.orderDetail.orderStatus == 1){
                    msg = @"您的取消订单申请已提交，请等待审核结果";
                }
            } else {
                if(self.orderDetail.payTotal > 0 && self.orderDetail.orderStatus == OrderStatusNew) {
                    msg = @"订单取消成功，订单使用银行卡支付的金额将在7个工作日内返还至您的银行卡账户，使用云高账户余额支付的金额已返还至您的云高帐户";
                }else{
                    msg = @"订单取消成功";
                }
            }
            if (_operation == 1) {
                msg = @"撤销申请成功";
            }
            [self cancelOrderResult:msg];
            
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"OperatedAllKindsOrder" object:@{@"data":_orderDetail,@"orderType":@1,@"operate":@2}];//lyf 加 orderType:1球场，2商品，3教学 operate:1是删除，2是其他
        }
    } failure:^(id error) {
        
    }];
}

- (void)cancelOrderResult:(NSString *)sender //取消结果
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:sender preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[ServiceManager serviceManagerWithDelegate:self] getOrderDetail:[[LoginManager sharedManager] getSessionId] withOrderId:self.orderDetail.orderId flag:@"order_detail"];
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)payBtnAction:(id)sender{
    if (self.orderDetail.payTotal <= 0) {
        OrderSubmitParamsModel *model = [[OrderSubmitParamsModel alloc] init];
        // TeeTime 开球日期
        model.orderId = self.orderDetail.orderId;
        model.sessionId = [[LoginManager sharedManager] getSessionId];
        model.useAccount = 0;
        
        [OrderService orderPayUnionpay:model success:^(OrderSubmitModel *osm) {
            if (osm) {
                [self pushSuccessOrder:osm];
            }
        } failure:^(id error) {
            
        }];
        return;
    }
    
    PayOnlineViewController *payOnline = [[PayOnlineViewController alloc] init];
    payOnline.orderId = self.orderDetail.orderId;
    payOnline.clubId = self.orderDetail.clubId;
    payOnline.payTotal = self.orderDetail.payTotal;
    payOnline.orderTotal = self.orderDetail.orderTotal;
    payOnline.waitPayFlag = 1;
    payOnline.isOffical = self.orderDetail.agentId == 0 ? YES : NO;
    if (_isInMineVC) {//lyf 加，在"我的"进入付款，要跳会球场订单详情，而不是root
        payOnline.blockReturn = ^(id data){
            [self.navigationController popToViewController:self animated:YES];
            [[ServiceManager serviceManagerWithDelegate:self] getOrderDetail:[[LoginManager sharedManager] getSessionId] withOrderId:self.orderId flag:@"order_detail"];
        };
    }
    [[GolfAppDelegate shareAppDelegate] pushViewController:[GolfAppDelegate shareAppDelegate].currentController WithController:payOnline title:@"支付确认" hide:YES];
}

- (void)pushSuccessOrder:(OrderSubmitModel *)model{
    [self pushWithStoryboard:@"Coach" title:@"订单成功" identifier:@"OrderSuccessViewController" completion:^(BaseNavController *controller) {
        OrderSuccessViewController *orderSuccess = (OrderSuccessViewController*)controller;
        orderSuccess.orderId = _orderDetail.orderId;
    }];
}

- (void)drawView:(UIView*)view radius:(CGFloat)radius borderColor:(UIColor*)color borderWidth:(CGFloat)width{
    CALayer *layer = [view layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:radius];
    [layer setBorderWidth:width];
    [layer setBorderColor:[[color colorWithAlphaComponent:0.9] CGColor]];
    
    view.layer.shadowColor = [[UIColor redColor] CGColor];
    view.layer.shadowOffset = CGSizeMake(0,0);
    view.layer.shadowRadius = MAX(1, radius-2);
}

- (void)doLeftNavAction {
    [super doLeftNavAction];
}

- (void)doRightNavAction{//lyf 改
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"分享" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self shareAction];
    }];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if (_orderDetail.orderStatus == 5 || _orderDetail.orderStatus == 6 || _orderDetail.orderStatus == 1 || _orderDetail.orderStatus == 7) {
            [SVProgressHUD showInfoWithStatus:@"无法删除未完成订单"];
            return;
        }
        [[ServiceManager serviceManagerWithDelegate:self] orderDelete:[[LoginManager sharedManager] getSessionId] orderId:_orderDetail.orderId];
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:action];
    [alert addAction:deleteAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)pressedMap
{
    ClubModel *club = [[ClubModel alloc] init];
    club.clubName = self.orderDetail.clubName;
    club.address = self.orderDetail.address;
    club.latitude = self.orderDetail.latitude;
    club.longitude = self.orderDetail.longitude;
    club.trafficGuide = self.orderDetail.trafficGuid;
    
    YGMapViewCtrl *vc = [YGMapViewCtrl instanceFromStoryboard];
    vc.clubList = @[club];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)yunbiDescription{
    NSString *msg = [NSString stringWithFormat:@"打球后将在1-2个工作日内返%d云币至账户，1云币价值1元现金",self.orderDetail.yunbi];
    [[GolfAppDelegate shareAppDelegate] alert:nil message:msg];
}

- (void)shareAction{
    if ([LoginManager sharedManager].loginState) {
        if ([self needPerfectMemberData]) {
            return;
        }
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *theDate = [formatter dateFromString:self.orderDetail.teetimeDate];
    [formatter setDateFormat:@"MM月dd日"];
    NSString * date = [formatter stringFromDate:theDate];
    
    NSString *info = nil;
    
    if (self.orderDetail.packageId <= 0) {
        info = [NSString stringWithFormat:@"我预订了%@的%@%d人，%@开球。用云高订场挺方便的，您也试试看。",date,self.orderDetail.clubName,self.orderDetail.memberNum,self.orderDetail.teetimeTime];
    }
    else{
        info = [NSString stringWithFormat:@"我预订了%@的套餐%d人，到达日期为%@。用云高订场挺方便的，您也试试看。",self.orderDetail.packageName,self.orderDetail.memberNum,date];
    }
    
    if (!_share) {
        _share = [[SharePackage alloc] initWithTitle:@"订单信息" content:info img:nil url:@"http://m.bookingtee.com/wx/"];
    }
    [_share shareInfoForView:self.view];
}

- (void)loginButtonPressed:(id)sender{//lyf 加
    if (!self.orderDetail) {
        [[ServiceManager serviceManagerWithDelegate:self] getOrderDetail:[[LoginManager sharedManager] getSessionId] withOrderId:self.orderId flag:@"order_detail"];
    }else{
        tempOrderStatus = _orderDetail.orderStatus;
        [_tableview reloadData];
        CGRect rt = _tableview.frame;
        rt.size.height = _tableview.contentSize.height;
        _tableview.frame = rt;
        [_scrollView setContentSize:CGSizeMake(Device_Width, _tableview.contentSize.height+10)];
    }
}
@end
