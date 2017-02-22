//
//  TeachingOrderDetailViewController.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/22.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "TeachingOrderDetailViewController.h"
#import "TitleValueTableViewCell.h"
#import "RemainderClassTableViewCell.h"
#import "ActionTableViewCell.h"
#import "TeachInfoCommentTableViewController.h"
#import "JXChooseTimeController.h"
#import "CoachDetailsViewController.h"
#import "TeachInfoDetailTableViewController.h"
#import "CCAlertView.h"
#import "TeachingOrderStatus.h"
#import "MemberClassModel.h"
#import "CourseDelayController.h"
#import "MyStudentDetailController.h"
#import "YGMyStudentDetailViewCtrl.h"
#import "YGTeachingArchiveLessonDetailViewCtrl.h"
#import "YGTeachingArchiveCourseDetailViewCtrl.h"
#import "YGTeachingArchiveDelayViewCtrl.h"
#import "PayOnlineViewController.h"
#import "YGOrderHandler.h"

static int tempOrderState; //lyf 加

@interface TeachingOrderDetailViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

@end

@implementation TeachingOrderDetailViewController{
    MemberClassModel *mcm;
    TeachingOrderDetailModel *todm;
    UIView *clearView;
}

- (void)back{
    if (_blockReturn) {
        _blockReturn(nil);
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    clearView = [[UIView alloc] init];
    clearView.backgroundColor = [UIColor clearColor];
    
    _toolbar.hidden = (_classId == 0 || _isCoach ) ? YES : NO;
    if (!_isCoach) {
        [self.tableView setContentInset:(UIEdgeInsetsMake(0, 0, 60, 0))];
    }
    
    if (![LoginManager sharedManager].loginState) {
        [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES blockRetrun:^(id obj) {
            [self loadData];
        }];
    }else{
        [self loadData];
    }
}

- (void)loadData{
    if (_orderId > 0) {
        [self getOrderInfo];
    }else if(_classId > 0){
        [self getClassInfo:_classId];
    }
}


- (IBAction)callCoach:(id)sender {
    if (_classId > 0 || todm.classId > 0) {
        // 数据上报采集点
        [[BaiduMobStat defaultStat] logEvent:@"btnContactCoach" eventLabel:@"联系教练点击"];
        [MobClick event:@"btnContactCoach" label:@"联系教练点击"];
        CCAlertView *alert = [[CCAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"呼叫 %@",mcm.mobilePhone]];
        [alert addButtonWithTitle:@"取消" block:nil];
        [alert addButtonWithTitle:@"呼叫" block:^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",mcm.mobilePhone]]];
        }];
        [alert show];
    }
}

//获取订单详情
- (void)getOrderInfo{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ServiceManager serviceManagerWithDelegate:self] teachingOrderDetail:[[LoginManager sharedManager] getSessionId] orderId:_orderId coachId:_isCoach?[LoginManager sharedManager].session.memberId : 0];
    });
}

//获取课程详情
- (void)getClassInfo:(int)classId{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ServiceManager serviceManagerWithDelegate:self] getTeachingMemberClassDetailByClassId:classId orderId:_orderId sessionId:[[LoginManager sharedManager] getSessionId]];
    });
}

- (void)serviceResult:(ServiceManager*)serviceManager Data:(id)data flag:(NSString*)flag{
    NSArray *arr = (NSArray *)data;
    if (Equal(flag, @"teaching_order_detail")) {
        todm = [arr firstObject];
        tempOrderState = todm.orderState;//lyf 加
        if (todm.classId > 0) {
            [self getClassInfo:todm.classId];
            if (!_isCoach) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"OperatedAllKindsOrder" object:@{@"data":todm,@"orderType":@3,@"operate":@2}];//lyf 加 orderType:1球场，2商品，3教学 operate:1是删除，2是其他//lyf屏蔽

                _toolbar.hidden = NO;
            }
            self.tableView.hidden = YES;
        }else{
            _toolbar.hidden = YES;
            self.tableView.hidden = NO;
        }
    }
    if (Equal(flag, @"teaching_order_cancel")) {
        if (todm) {
            todm.orderState = 4;//lyf 加
            
            [[YGOrderHandler handlerWithOrder:todm] postOrderDidChangedNotification];
            
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"OperatedAllKindsOrder" object:@{@"data":todm,@"orderType":@3,@"operate":@2}];//lyf 加 orderType:1球场，2商品，3教学 operate:1是删除，2是其他
        }
        
        [self loadData];
        if (_blockRefresh) {
            _blockRefresh(@(4));
        }
    }
    if (Equal(flag, @"teaching_member_class_detail")) {
        mcm = [arr firstObject];
        tempOrderState = mcm.orderState;//lyf 加
        if (todm == nil) {
            todm = [[TeachingOrderDetailModel alloc] init];
            todm.classId = mcm.classId;
            todm.price = mcm.price;
            todm.coachId = mcm.coachId;
            todm.publicClassId = mcm.publicClassId;
            todm.teachingSite = mcm.teachingSite;
            todm.orderTime = mcm.orderTime;
            todm.nickName = mcm.nickName;
            todm.classType = mcm.classType;
            todm.headImage = mcm.headImage;
            todm.productId = mcm.productId;
            todm.productName = mcm.productName;
            
        }
        todm.remainHour = mcm.remainHour;
        todm.classHour = mcm.classHour;
        todm.orderState = mcm.orderState;
        self.tableView.hidden = NO;
    }
    if (_loadingView) {
        [_loadingView removeFromSuperview];
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    return 10;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    switch (todm.orderState) {
        case 6:
            return 1;
            break;
        case 1:
            return 1 + (mcm.reservationList.count > 0 ? 1:0);
            break;
        case 2:
            return 1 + (mcm.reservationList.count > 0 ? 1:0);
            break;
        case 3:
            return 1 + (mcm.reservationList.count > 0 ? 1:0);
            break;
        case 4:
            return 1;
            break;
        default:
            break;
    }
    return 1;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (todm.orderState) {
        case 6:
            return _isCoach ? 4 : 6;
            break;
        case 1:
            switch (section) {
                case 0:
                    return (_isCoach || (!_isCoach && todm.remainHour == 0)) ? 5 : 6;
                    break;
                case 1:
                    return mcm.reservationList.count + (mcm.reservationList.count > 0 ? 1:0);
                    break;
                default:
                    break;
            }
            break;
        case 2:
            switch (section) {
                case 0:
                    return _isCoach ? 6 : 5;
                    break;
                case 1:
                    return mcm.reservationList.count + (mcm.reservationList.count > 0 ? 1:0);
                    break;
                default:
                    break;
            }
            break;
        case 3:
            switch (section) {
                case 0:
                    return 5 + (_isCoach ? 1:0);
                    break;
                case 1:
                    return mcm.reservationList.count + (mcm.reservationList.count > 0 ? 1:0);
                    break;
                default:
                    break;
            }
            break;
        case 4:
            return 4;
            break;
        default:
            break;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (todm.orderState) {
        case 6:
            switch (indexPath.row) {
                case 0:
                    return 40;
                    break;
                case 1:
                    return 86;
                    break;
                case 2:
                case 3:
                    return 44;
                    break;
                default:
                    return 64;
                    break;
            }
            break;
        case 1:
            switch (indexPath.section) {
                case 0:
                {
                    switch (indexPath.row) {
                        case 0:
                            return 40;
                            break;
                        case 1:
                            return 86;
                            break;
                        case 2:
                        case 3:
                        case 4:
                            return 44;
                            break;
                        case 5:
                            return 64;
                            break;
                        default:
                            break;
                    }
                    
                }
                    break;
                case 1:
                {
                    if (indexPath.row == 0) {
                        return 40;
                    }
                    return 44;
                }
                    break;
                default:
                    break;
            }
            break;
        case 2:
            switch (indexPath.section) {
                case 0:
                {
                    switch (indexPath.row) {
                        case 0:
                            return 40;
                            break;
                        case 1:
                            return 86;
                            break;
                        case 2:
                        case 3:
                        case 4:
                            return 44;
                            break;
                        default:
                            break;
                    }
                }
                    break;
                case 1:
                {
                    if (indexPath.row == 0) {
                        return 40;
                    }
                    return 44;
                }
                    break;
                default:
                    break;
            }
            break;
        case 3:
            switch (indexPath.section) {
                case 0:
                {
                    switch (indexPath.row) {
                        case 0:
                            return 40;
                            break;
                        case 1:
                            return 86;
                            break;
                        case 2:
                        case 3:
                        case 4:
                            return 44;
                            break;
                        case 5:
                            return 64;
                            break;
                        default:
                            break;
                    }
                    
                }
                    break;
                case 1:
                {
                    if (indexPath.row == 0) {
                        return 40;
                    }
                    return 44;
                }
                    break;
                default:
                    break;
            }
            break;
        case 4:
            switch (indexPath.row) {
                case 0:
                    return 40;
                    break;
                case 1:
                    return 86;
                    break;
                default:
                    return 44;
                    break;
            }
            break;
        default:
            break;
    }
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        [[BaiduMobStat defaultStat] logEvent:@"btnOrderDetailHeadImage" eventLabel:@"订单详情头像点击"];
        [MobClick event:@"btnOrderDetailHeadImage" label:@"订单详情头像点击"];
        
        // 跳转到课程详情
        [self _gotoYGTeachingArchiveCourseDetailViewCtrl];
        
    }
    if (indexPath.section == 1 && indexPath.row > 0) {
        
        ReservationModel *m = mcm.reservationList[indexPath.row -1];
        
        YGTeachingArchiveLessonDetailViewCtrl *vc = [YGTeachingArchiveLessonDetailViewCtrl instanceFromStoryboard];
        vc.periodId = m.periodId;
        vc.isCoach = self.isCoach;
        [self.navigationController pushViewController:vc animated:YES];
        
        ygweakify(self)
        vc.taLessonDetailViewCtrlBlock = ^(){
            ygstrongify(self)
            [self loadData];
            if (self.blockRefresh) {
                self.blockRefresh (nil);
            }
        };
        
        //进入详情
//        [self pushWithStoryboard:@"Teach" title:@"课程详情" identifier:@"TeachInfoDetailTableViewController" completion:^(BaseNavController *controller) {
//            TeachInfoDetailTableViewController *vc = (TeachInfoDetailTableViewController *)controller;
//            ReservationModel *m = mcm.reservationList[indexPath.row -1];
//            vc.reservationId = m.reservationId;
//            if (_isCoach) {
//                vc.coachId = [LoginManager sharedManager].session.memberId;
//            }
//            vc.blockRefresh = ^(id data){
//                [self loadData];
//                if (_blockRefresh) {
//                    _blockRefresh (nil);
//                }
//            };
//            vc.blockCanceled = ^(id data){
//                [self loadData];
//                if (_blockRefresh) {
//                    _blockRefresh(nil);
//                }
//            };
//        }];
    }
    
}

- (void)chooseTime:(TeachingOrderDetailModel *)m{
    TeachingCoachModel *tc = [[TeachingCoachModel alloc] init];
    tc.coachId = m.coachId;
    tc.nickName = m.nickName;
    tc.headImage = m.headImage;
    tc.teachingSite = m.teachingSite;
    
    [self pushWithStoryboard:@"Jiaoxue" title:@"选择预约时间" identifier:@"JXChooseTimeController" completion:^(BaseNavController *controller) {
        JXChooseTimeController *chooseTime = (JXChooseTimeController*)controller;
        chooseTime.teachingCoach = tc;
        chooseTime.productId = m.productId;
        chooseTime.productName = m.productName;
        chooseTime.classHour = m.classHour;
        chooseTime.remainHour = m.remainHour;
        chooseTime.classNo = m.classHour-m.remainHour+1;
        chooseTime.classId = m.classId;
        chooseTime.classType = m.classType;
        chooseTime.returnCash = m.giveYunbi;
        chooseTime.blockReturn = ^(id data){
            [self loadData];
            if (_blockRefresh) {
                _blockRefresh(@(1));
            }
            [self.navigationController popToViewController:self animated:YES];
        };

    }];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return clearView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (todm.orderState) {
        case 1: //教学中
        {
            switch (indexPath.section) {
                case 0:
                {
                    switch (indexPath.row) {
                        case 0:
                        {
                            NSString *str = mcm.orderTime;
                            str = str == nil ? @"":str;
                            return [self cellForTitle:@"教学中"
                                                value:[NSString stringWithFormat:@"%@下单",str]
                                               value2:@""
                                    reservationStatus:0
                                            tableView:tableView indexPath:indexPath identifier:@"OrderStatusTableViewCell"];
                        }
                            break;
                        case 1:
                            return [self cellForRemainderClass:tableView indexPath:indexPath];
                            break;
                        case 2:
                            if (_isCoach) {
                                return [self cellForTitle:@"已付金额" value:[NSString stringWithFormat:@"¥%d",todm.orderTotal] value2:@"" reservationStatus:0 tableView:tableView indexPath:indexPath identifier:@"TeachingOrderDetailTypeOne"];
                            }else{
                                return [self cellForTitle:@"已付金额" value:[NSString stringWithFormat:@"¥%d",todm.orderTotal] value2:(todm.giveYunbi > 0 ? [NSString stringWithFormat:@"(返%d云币)",todm.giveYunbi]:@"") reservationStatus:0 tableView:tableView indexPath:indexPath identifier:@"TeachingOrderDetailTypeOne"];
                            }
                            break;
                        case 3:
                            return [self cellForTitle:@"剩余课时" value:[NSString stringWithFormat:@"%d课时",todm.remainHour] value2:[NSString stringWithFormat:@"( 共%d课时 )",todm.classHour] reservationStatus:0 tableView:tableView indexPath:indexPath identifier:@"TeachingOrderDetailTypeThree"];
                            break;
                        case 4:
                            return [self cellForTitle:@"过期时间" value:[NSString stringWithFormat:@"%@",(mcm.expireDate == nil ? @"":mcm.expireDate)] value2:@"" reservationStatus:0 tableView:tableView indexPath:indexPath identifier:@"TeachingOrderDetailTypeOne"];
                            break;
                        case 5:
                        {
                            if (todm.remainHour > 0) {
                                ActionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActionCell3" forIndexPath:indexPath];
                                [cell.btnAction setTitle:@"预约" forState:(UIControlStateNormal)];
                                if (cell.blockReturn == nil) {
                                    cell.blockReturn = ^(id data){
                                        [self chooseTime:todm];
                                    };
                                }
                                return cell;
                            }else{
                                ActionTableViewCell *cell = (ActionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ActionCell2" forIndexPath:indexPath];
                                [cell.btnAction setTitle:@"预约" forState:(UIControlStateNormal)];
                                return cell;
                            }
                        }
                            break;
                            
                        default:
                            break;
                    }
                }
                    break;
                case 1:
                    return [self cellForTeachingListWithTableView:tableView indexPath:indexPath];
                    break;
                default:
                    break;
            }
            
        }
            break;
        case 2: //已完成
        {
            switch (indexPath.section) {
                case 0:
                {
                    switch (indexPath.row) {
                        case 0:
                        {
                            return [self cellForTitle:@"已完成"
                                                value:(mcm.orderTime == nil ? @"":[NSString stringWithFormat:@"%@下单",mcm.orderTime])
                                               value2:@""
                                    reservationStatus:0
                                            tableView:tableView indexPath:indexPath identifier:@"OrderStatusTableViewCell"];
                        }
                            break;
                        case 1:
                            return [self cellForRemainderClass:tableView indexPath:indexPath];
                            break;
                        case 2:
                            if (_isCoach) {
                                return [self cellForTitle:@"已付金额" value:[NSString stringWithFormat:@"¥%d",todm.orderTotal] value2:@"" reservationStatus:0 tableView:tableView indexPath:indexPath identifier:@"TeachingOrderDetailTypeOne"];
                            }else{
                                return [self cellForTitle:@"已付金额" value:[NSString stringWithFormat:@"¥%d",todm.orderTotal] value2:(todm.giveYunbi > 0 ? [NSString stringWithFormat:@"(返%d云币)",todm.giveYunbi]:@"") reservationStatus:0 tableView:tableView indexPath:indexPath identifier:@"TeachingOrderDetailTypeOne"];
                                
                            }
                            
                            break;
                        case 3:
                            return [self cellForTitle:@"剩余课时" value:[NSString stringWithFormat:@"%d课时",todm.remainHour] value2:[NSString stringWithFormat:@"( 共%d课时 )",todm.classHour] reservationStatus:0 tableView:tableView indexPath:indexPath identifier:@"TeachingOrderDetailTypeThree"];
                            break;
                        case 4:
                            return [self cellForTitle:@"过期时间" value:[NSString stringWithFormat:@"%@",(mcm.expireDate == nil ? @"":mcm.expireDate)] value2:@"" reservationStatus:0 tableView:tableView indexPath:indexPath identifier:@"TeachingOrderDetailTypeOne"];
                            break;
                        default:
                            break;
                    }
                }
                    break;
                case 1:
                    return [self cellForTeachingListWithTableView:tableView indexPath:indexPath];
                    break;
                default:
                    break;
            }
            
        }
            break;
        case 3: //已过期
        {
            switch (indexPath.section) {
                case 0:
                {
                    switch (indexPath.row) {
                        case 0:
                            return [self cellForTitle:@"已过期" value:[NSString stringWithFormat:@"%@下单",todm.orderTime] value2:@"" reservationStatus:0 tableView:tableView indexPath:indexPath identifier:@"OrderStatusTableViewCell"];
                            break;
                        case 1:
                            return [self cellForRemainderClass:tableView indexPath:indexPath];
                            break;
                        case 2:
                            if (_isCoach) {
                                return [self cellForTitle:@"已付金额" value:[NSString stringWithFormat:@"¥%d",todm.orderTotal] value2:@"" reservationStatus:0 tableView:tableView indexPath:indexPath identifier:@"TeachingOrderDetailTypeOne"];
                            }else{
                                return [self cellForTitle:@"已付金额" value:[NSString stringWithFormat:@"¥%d",todm.orderTotal] value2:(todm.giveYunbi > 0 ? [NSString stringWithFormat:@"(返%d云币)",todm.giveYunbi]:@"")  reservationStatus:0 tableView:tableView indexPath:indexPath identifier:@"TeachingOrderDetailTypeOne"];
                            }
                            
                            break;
                        case 3:
                            return [self cellForTitle:@"剩余课时" value:[NSString stringWithFormat:@"%d课时",todm.remainHour] value2:[NSString stringWithFormat:@"( 共%d课时 )",todm.classHour] reservationStatus:0 tableView:tableView indexPath:indexPath identifier:@"TeachingOrderDetailTypeTwo"];
                            break;
                        case 4:
                            return [self cellForTitle:@"过期时间" value:[NSString stringWithFormat:@"%@ 已过期",(mcm.expireDate == nil ? @"":mcm.expireDate)] value2:@"" reservationStatus:0 tableView:tableView indexPath:indexPath identifier:@"TeachingOrderDetailTypeFour2"];
                            break;
                        case 5:
                        {
                            ActionTableViewCell *cell = (ActionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ActionCell" forIndexPath:indexPath];
                            [cell.btnAction setTitle:@"延期课程" forState:UIControlStateNormal];
                            cell.blockReturn = ^(id obj){
                                // 跳转到延期课程
                                [self _gotoYGTeachingArchiveDelayViewCtrl];
                                
//                                [self pushWithStoryboard:@"Teach" title:@"延期课程" identifier:@"CourseDelayController" completion:^(BaseNavController *controller) {
//                                    CourseDelayController *vc = (CourseDelayController *)controller;
//                                    vc.classId = mcm.classId;
//                                    vc.expiredDate = mcm.expireDate;
//                                    vc.title = @"延期课程";
//                                    vc.blockReturn = ^(id data){
//                                        [self loadData];
//                                        if (_blockRefresh) {
//                                            _blockRefresh(@(1));
//                                        }
//                                        [self.navigationController popToViewController:self animated:YES];
//                                    };
//                                }];
                                
                            };
                            return cell;
                        }
                            break;
                        default:
                            break;
                    }
                }
                    break;
                case 1:
                    return [self cellForTeachingListWithTableView:tableView indexPath:indexPath];
                    break;
                default:
                    break;
            }
            
        }
            break;
        case 4: //已取消
        {
            switch (indexPath.row) {
                case 0:
                    return [self cellForTitle:@"已取消"
                                        value:[NSString stringWithFormat:@"%@下单",todm.orderTime]
                                       value2:@""
                            reservationStatus:0
                                    tableView:tableView indexPath:indexPath identifier:@"OrderStatusTableViewCell"];
                    break;
                case 1:
                    return [self cellForRemainderClass:tableView indexPath:indexPath];
                    break;
                case 2:
                {
                    if (_isCoach) {
                        return [self cellForTitle:@"待付金额" value:[NSString stringWithFormat:@"¥%d",todm.orderTotal] value2:@"" reservationStatus:0 tableView:tableView indexPath:indexPath identifier:@"TeachingOrderDetailTypeOne"];
                    }else{
                        return [self cellForTitle:@"待付金额" value:[NSString stringWithFormat:@"¥%d",todm.orderTotal] value2:(todm.giveYunbi > 0 ? [NSString stringWithFormat:@"(返%d云币)",todm.giveYunbi]:@"") reservationStatus:0 tableView:tableView indexPath:indexPath identifier:@"TeachingOrderDetailTypeOne"];
                    }
                    
                    
                }
                    break;
                case 3:
                {
                    UITableViewCell *cell = [self cellForTitle:@"购买课时" value:[NSString stringWithFormat:@"%d课时",todm.classHour] value2:@"" reservationStatus:0 tableView:tableView indexPath:indexPath identifier:@"TeachingOrderDetailTypeOne"];
                    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                        cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
                    }
                    return cell;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 6:  //待付款
        {
            switch (indexPath.row) {
                case 0:{
                    NSString *str = todm.orderTime;
                    str = str == nil ? @"":str;
                    return [self cellForTitle:@"待付款"
                                        value:[NSString stringWithFormat:@"%@下单",str]
                                       value2:@"" reservationStatus:0
                                    tableView:tableView indexPath:indexPath identifier:@"OrderStatusTableViewCell"];
                }
                    
                    break;
                case 1:
                    return [self cellForRemainderClass:tableView indexPath:indexPath];
                    break;
                case 2:
                {
                    if (todm.giveYunbi > 0) {
                        return [self cellForTitle:@"待付金额" value:[NSString stringWithFormat:@"¥%d",todm.orderTotal] value2:[NSString stringWithFormat:@"(返%d云币)",todm.giveYunbi] reservationStatus:0 tableView:tableView indexPath:indexPath identifier:(_isCoach ? @"TeachingOrderDetailTypeOne" : @"TeachingOrderDetailTypeFour3")];
                    }else{
                        return [self cellForTitle:@"待付金额" value:[NSString stringWithFormat:@"¥%d",todm.orderTotal] value2:@"" reservationStatus:0 tableView:tableView indexPath:indexPath identifier:(_isCoach ? @"TeachingOrderDetailTypeOne" : @"TeachingOrderDetailTypeFour")];
                    }
                }
                    
                    break;
                case 3:
                {
                    UITableViewCell *cell = [self cellForTitle:@"购买课时" value:[NSString stringWithFormat:@"%d课时",todm.classHour] value2:@"" reservationStatus:0 tableView:tableView indexPath:indexPath identifier:@"TeachingOrderDetailTypeOne"];
                    if (_isCoach) {
                        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                            cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
                        }
                    }
                    return cell;
                    break;
                }
                case 4:
                {
                    ActionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActionCell3" forIndexPath:indexPath];
                    [cell.btnAction setTitle:@"确认支付" forState:(UIControlStateNormal)];
                    if (cell.blockReturn == nil) {
                        cell.blockReturn = ^(id data){
                            
                            if (todm.orderState == TeachingOrderStatusWaitPay){
                                PayOnlineViewController *payOnline = [[PayOnlineViewController alloc] init];
                                payOnline.payTotal = todm.price;
                                payOnline.orderTotal = todm.price;
                                payOnline.orderId = _orderId;
                                payOnline.waitPayFlag = 3;
                                payOnline.productId = todm.productId;
                                payOnline.academyId = todm.academyId;
                                payOnline.classType = todm.classType;
                                payOnline.classHour = todm.classHour;
                                payOnline.blockReturn = ^(id data){
                                    [self loadData];
                                    if (_blockRefresh) {
                                        _blockRefresh (@(1));
                                    }
                                    [self.navigationController popToViewController:self animated:YES];
                                };
                                [self pushViewController:payOnline title:@"在线支付" hide:YES];
                            }
                        };
                    }
                    return cell;
                }
                    break;
                case 5:
                {
                    ActionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CancelOrderCell" forIndexPath:indexPath];
                    if (cell.blockReturn == nil) {
                        cell.blockReturn = ^(id data){
                            if ([LoginManager sharedManager].loginState) {
                                CCAlertView *alert = [[CCAlertView alloc] initWithTitle:@"" message:@"确认取消当前订单吗？"];
                                [alert addButtonWithTitle:@"再想想" block:nil];
                                [alert addButtonWithTitle:@"确定取消" block:^{
                                    [[ServiceManager serviceManagerWithDelegate:self] teachingOrderCancelByOrderId:_orderId sessionId:[[LoginManager sharedManager] getSessionId]];
                                }];
                                [alert show];
                                
                            }
                        };
                    }
                    return cell;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    return [[UITableViewCell alloc] init];
}

- (UITableViewCell *)cellForTeachingListWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return [self cellForTitle:@"教学记录" value:@"" value2:@"" reservationStatus:0 tableView:tableView indexPath:indexPath identifier:@"HeaderTableViewCell"];
    }
    
    ReservationModel *rm = mcm.reservationList[indexPath.row -1];
    NSString *value = @"";
    switch (rm.reservationStatus) {
        case 1:
            value = @"待上课";
            break;
        case 2:
            value = @"已完成";
            break;
        case 3:
            value = @"未到场";
            break;
        case 4:
            value = @"已取消";
            break;
        case 5:
            value = @"已完成";
            if (_isCoach) {
                value = @"待确认";
            }
            break;
        case 6:
//            value = @"待评价";
            value = @"已完成";
            break;
        default:
            break;
    }
    UITableViewCell *cell = nil;
    
    if (rm.reservationStatus == 5 && _isCoach == YES) {
        cell = [self cellForComfirm:rm value:value tableView:tableView indexPath:indexPath];
    }
//    else if (rm.reservationStatus == 6 && _isCoach == NO) {
//        cell = [self cellForComment:rm value:value tableView:tableView indexPath:indexPath];
//    }
    else{
        cell = [self cellForTitle:[NSString stringWithFormat:@"%@ %@",rm.reservationDate,rm.reservationTime] value:value value2:@"" reservationStatus:rm.reservationStatus tableView:tableView indexPath:indexPath identifier:@"DatatimeStatusCell"];
    }
    if (indexPath.row == mcm.reservationList.count) {
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
        }
    }
    return cell;
}

- (UITableViewCell *)cellForComfirm:(ReservationModel *)rm value:(NSString *)value tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    TitleValueTableViewCell *cell = (TitleValueTableViewCell *) [self cellForTitle:[NSString stringWithFormat:@"%@ %@",rm.reservationDate,rm.reservationTime]
                                                                             value:value
                                                                            value2:@""
                                                                 reservationStatus:rm.reservationStatus
                                                                         tableView:tableView
                                                                         indexPath:indexPath
                                                                        identifier:@"DatetimeComfirmButtonCell"];
    cell.rm = rm;
    if (cell.blockReturn == nil) {
        cell.blockReturn = ^(id data){
            CCAlertView *alert = [[CCAlertView alloc] initWithTitle:nil message:@"已完成该学员的教学？"];
            [alert addButtonWithTitle:@"取消" block:nil];
            [alert addButtonWithTitle:@"已完成" block:^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    ReservationModel *m = (ReservationModel *)data;
                    // status-> 1:已教学 2：未到场
                    [[ServiceManager serviceManagerInstance] teachingMemberReservationComplete:[[LoginManager sharedManager] getSessionId] coachId:[LoginManager sharedManager].session.memberId reservationId:m.reservationId opteraton:1 periodId:rm.periodId callBack:^(BOOL boolen) {
                        if (boolen) {
                            [SVProgressHUD showSuccessWithStatus:@"确认成功"];
                            [self loadData];
                            if (_blockRefresh) {
                                _blockRefresh(@(6));
                            }
                        }
                    }];
                });
                
            }];
            [alert show];
            
        };
    }
    return cell;
}

- (UITableViewCell *)cellForComment:(ReservationModel *)rm value:(NSString *)value tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    TitleValueTableViewCell *cell = (TitleValueTableViewCell *) [self cellForTitle:[NSString stringWithFormat:@"%@ %@",rm.reservationDate,rm.reservationTime]
                                                                             value:value
                                                                            value2:@""
                                                                 reservationStatus:rm.reservationStatus
                                                                         tableView:tableView
                                                                         indexPath:indexPath
                                                                        identifier:@"DatetimeButtonCell"];
    cell.rm = rm;
    if (cell.blockReturn == nil) {
        cell.blockReturn = ^(id data){
            ReservationModel *m = (ReservationModel *)data;
            if (m.reservationStatus == 6) {
                TeachInfoCommentTableViewController *vc = [[UIStoryboard storyboardWithName:@"Teach" bundle:NULL] instantiateViewControllerWithIdentifier:@"TeachInfoCommentTableViewController"];
//                [self performSegueWithIdentifier:@"TeachInfoCommentTableViewController" sender:nil withBlock:^(id sender, id destinationVC) {
//                    TeachInfoCommentTableViewController *vc = (TeachInfoCommentTableViewController *)destinationVC;
                    vc.reservationId = m.reservationId;
                    vc.blockReturn = ^(id data){
                        [self loadData];
                        [self.navigationController popToViewController:self animated:YES];
                    };
//                }];
            }
        };
    }
    return cell;
}

- (UITableViewCell *)cellForRemainderClass:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    RemainderClassTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RemainderClassTableViewCell" forIndexPath:indexPath];
    [cell loadData:todm];
    ygweakify(self)
    cell.headBtnHeadTapBlock = ^(id m) {
        ygstrongify(self)
        if (self->todm) {
            [self _gotoUserHeadTapAction];
        }
    };
    return cell;
}

- (UITableViewCell *)cellForTitle:(NSString *)title value:(NSString *)value value2:(NSString *)value2 reservationStatus:(int)reservationStatus tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath identifier:(NSString *)identifier{
    TitleValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.labelTitle.text = title;
    cell.labelValue.text = value;
    cell.labelValue2.text = value2;
    if (reservationStatus > 0) {
        if (reservationStatus == 1) {
            cell.labelValue.textColor = MainHighlightColor;
        }else{
            cell.labelValue.textColor = [UIColor colorWithHexString:@"#999999"];
        }
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 0)];
    }

    return cell;
}

#pragma mark - DoLeftNavAction
- (void)doLeftNavAction {//lyf 加，下单之后又取消的情况
    [super doLeftNavAction];
}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    int status = _orderId > 0 ? todm.orderState : todm.orderState;
    if (status != tempOrderState) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"systemNewsCount" object:nil];
    }
}


- (void)loginButtonPressed:(id)sender{//lyf 加
    [self loadData];
}

/**
 * 点击头像【跳转到学员详情 或者 教练详情】
 */
-(void) _gotoUserHeadTapAction
{
    if (_isCoach) {
        // 新的学员详情
        YGMyStudentDetailViewCtrl *vc = [YGMyStudentDetailViewCtrl instanceFromStoryboard];
        vc.memberId = todm.memberId;
        ygweakify(self)
        vc.myStudentDetailRefreshBllock = ^(){
            ygstrongify(self)
            // 刷新数据
            [self loadData];
            if (self.blockRefresh) {
                self.blockRefresh (nil);
            }
        };
        [self.navigationController pushViewController:vc animated:YES];
        
    } else {
        [self performSegueWithIdentifier:@"CoachDetailsViewController" sender:nil withBlock:^(id sender, id destinationVC) {
            CoachDetailsViewController *vc = (CoachDetailsViewController *)destinationVC;
            vc.coachId = mcm.coachId > 0 ? mcm.coachId:todm.coachId;
            vc.title = @"教练详情";
        }];
    }
}

/**
 * 跳转到课程详情
 */
-(void) _gotoYGTeachingArchiveCourseDetailViewCtrl
{
    YGTeachingArchiveCourseDetailViewCtrl *vc = [YGTeachingArchiveCourseDetailViewCtrl instanceFromStoryboard];
    vc.classId = todm.classId;
    vc.isCoach = self.isCoach;
    ygweakify(self)
    vc.taCourseDetailBlock = ^(){
        ygstrongify(self)
        // 刷新数据
        [self loadData];
        if (self.blockRefresh) {
            self.blockRefresh (nil);
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 * 跳转到延期课程
 */
-(void) _gotoYGTeachingArchiveDelayViewCtrl
{
    YGTeachingArchiveDelayViewCtrl *vc = [YGTeachingArchiveDelayViewCtrl instanceFromStoryboard];
    vc.expiredDate = mcm.expireDate;
    vc.classId = mcm.classId;
    ygweakify(self)
    vc.taDelayClassBlock = ^(){
        ygstrongify(self)
        [self loadData];
        if (self.blockRefresh) {
            self.blockRefresh(@(1));
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

@end
