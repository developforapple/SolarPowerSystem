//
//  MyStudentDetailController.m
//  Golf
//
//  Created by 黄希望 on 15/6/5.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "MyStudentDetailController.h"
#import "StudentDetailChangeView.h"
#import "CoachOrderListCell.h"
#import "TeachingRecordCell.h"
#import "MemberReservationModel.h"
#import "TeachingOrderDetailViewController.h"
#import "TeachInfoDetailTableViewController.h"
#import "MyStudentInfoCell.h"
#import "CCAlertView.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface MyStudentDetailController ()<UITableViewDelegate,UITableViewDataSource>{
    UIImageView *bgView;
}

@property (nonatomic,strong) IBOutlet UITableView *tableView;
@property (nonatomic,strong) StudentDetailChangeView *changeView;

@end

@implementation MyStudentDetailController{
    NSMutableArray *teachingRecordList;
    NSMutableArray *teachingOrderList;
    
    BOOL isOrder;

    int pageNo;
    BOOL loading;
    BOOL hasMore;
    int pageNo2;
    BOOL loading2;
    BOOL hasMore2;
    int pageSize;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    pageSize = 20;
    
    if (!self.student && self.memberId > 0 && [LoginManager sharedManager].session.memberId > 0) {
        [[ServiceManager serviceManagerWithDelegate:self] teachingCoachMemberList:[[LoginManager sharedManager] getSessionId] coachId:[LoginManager sharedManager].session.memberId memberId:self.memberId pageNo:1 pageSize:1 keyWord:nil];
    }else if (self.student){
        [self initization];
    }
}

- (void)initization{
    teachingRecordList = [NSMutableArray array];
    teachingOrderList = [NSMutableArray array];
    pageNo = 1;
    hasMore = YES;
    pageNo2 = 1;
    hasMore2 = YES;
    isOrder = NO;
    
    self.changeView = [[[NSBundle mainBundle] loadNibNamed:@"StudentDetailChangeView" owner:self options:nil] lastObject];
    self.changeView.frame = CGRectMake(0, 0, Device_Width, 40);
    
    bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, Device_Width, 180)];
    bgView.image = [UIImage imageNamed:@"line_blue"];
    bgView.hidden = YES;
    [self.view insertSubview:bgView atIndex:0];
    
    
    // 初始化切换按钮部分
    ygweakify(self);
    _changeView.blockReturn = ^(id obj){
        ygstrongify(self);
        NSInteger index = [obj integerValue];
        if (index == 1) {
            isOrder = NO;
        }else{
            isOrder = YES;
        }
        [self.tableView setContentOffset:CGPointZero animated:NO];
        [self getFirstPage];
    };
    [self getFirstPage];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    ygweakify(self);
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"refreshAttentList" object:nil] subscribeNext:^(NSNotification *notification) {
        ygstrongify(self);
        NSDictionary *info = [notification object];
        UserFollowModel *model = info[@"data"];
        self.student.isFollowed = model.isFollowed;
        [self.tableView reloadData];
    }];
}



#pragma mark - 加载数据

- (void)getFirstPage{
    if (isOrder) {
        pageNo = 1;
        hasMore = YES;
        loading = NO;
        [self teachingOrderList];
    }else{
        pageNo2 = 1;
        hasMore2 = YES;
        loading2 = NO;
        [self getTeachingMemberByReservationStatus];
    }
}

- (void)teachingOrderList{
    if (loading2) {
        return;
    }
    loading2 = YES;
    [[ServiceManager serviceManagerWithDelegate:self] teachingOrderList:[[LoginManager sharedManager] getSessionId] coachId:[LoginManager sharedManager].session.memberId memberId:_student.memberId orderState:0 pageNo:pageNo2 pageSize:pageSize keyWord:nil];
}

- (void)getTeachingMemberByReservationStatus{
    if (loading) {
        return;
    }
    loading = YES;
    [[ServiceManager serviceManagerWithDelegate:self] getTeachingMemberByReservationStatus:0 pageNo:pageNo pageSize:pageSize sessionId:[[LoginManager sharedManager] getSessionId] coachId:[LoginManager sharedManager].session.memberId memberId:_student.memberId keyword:nil];
}


#pragma mark - 数据回调
- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray*)data;
    if (Equal(flag, @"teaching_member_reservation_list")) {
        MemberReservationModel *mrm = [array firstObject];
        
        if (pageNo == 1) {
            [teachingRecordList removeAllObjects];
        }
        if (array && array.count > 0) {
            [teachingRecordList addObjectsFromArray:mrm.dataList];
            pageNo++;
            hasMore = array.count == 20;
        }else{
            hasMore = NO;
        }
        loading = NO;
        [_tableView reloadData];
        _tableView.hidden = NO;
    }
    
    if (Equal(flag, @"teaching_order_list")) {
        if (pageNo2 == 1) {
            [teachingOrderList removeAllObjects];
        }
        if (array && array.count > 0) {
            NSDictionary *dic = [array objectAtIndex:0];
            if (dic != nil) {
                NSArray *subArray = [dic objectForKey:@"data_list"];
                if (subArray && subArray.count > 0) {
                    NSArray *theArray = [subArray subarrayWithRange:NSMakeRange(0, MIN(subArray.count,3))];
                    for (id obj in  theArray){
                        [teachingOrderList addObject:[[TeachingOrderModel alloc] initWithDic:obj]];
                    }
                }

            }
            
            pageNo2++;
            hasMore2 = array.count == 20;
        }else{
            hasMore2 = NO;
        }
        loading2 = NO;
        [_tableView reloadData];
         _tableView.hidden = NO;
    }
    if (Equal(flag, @"teaching_coach_member_list")) {
        if (array.count > 0) {
            self.student = array[0];
            [self initization];
        }
        _tableView.hidden = NO;
    }
}

#pragma mark - UITableView delegate && dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }else{
        if (isOrder) {
            return [teachingOrderList count] + 1;
        }else{
            return [teachingRecordList count] + 1;
        }
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        MyStudentInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyStudentInfoCell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"line_blue"]];
        cell.student = _student;
        return cell;
    }
    if (isOrder) {
        if (teachingOrderList.count == indexPath.row) {
            return [tableView dequeueReusableCellWithIdentifier:(hasMore2 ? @"LoadingCell":@"AllLoadedCell") forIndexPath:indexPath];
        }else{
            CoachOrderListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CoachOrderListCell" forIndexPath:indexPath];
            if (indexPath.row < teachingOrderList.count) {
                cell.orderModel = teachingOrderList[indexPath.row];
            }
            return cell;
        }
    }else{
        if (teachingRecordList.count == indexPath.row) {
            return [tableView dequeueReusableCellWithIdentifier:(hasMore ? @"LoadingCell":@"AllLoadedCell") forIndexPath:indexPath];
        }else{
            TeachingRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TeachingRecordCell" forIndexPath:indexPath];
            if (indexPath.row < teachingRecordList.count) {
                ReservationModel *rm = teachingRecordList[indexPath.row];
                cell.rm = rm;
                ygweakify(self);
                ygweakify(rm);
                cell.blockReturn = ^(id obj){
                    
                    CCAlertView *alert = [[CCAlertView alloc] initWithTitle:@"" message:@"确认已完成该教学？"];
                    [alert addButtonWithTitle:@"取消" block:nil];
                    [alert addButtonWithTitle:@"确定完成" block:^{
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [[ServiceManager serviceManagerInstance] teachingMemberReservationComplete:[[LoginManager sharedManager] getSessionId] coachId:[LoginManager sharedManager].session.memberId reservationId:rm.reservationId opteraton:1 periodId:rm.periodId callBack:^(BOOL boolen) {
                                if (boolen) {
                                    ygstrongify(self);
                                    ygstrongify(rm);
                                    [SVProgressHUD showSuccessWithStatus:@"确认成功"];
                                    rm.reservationStatus = 6;
                                    [self.tableView reloadData];
                                }
                            }];
                        });
                    }];
                    [alert show];
                };
            }
            return cell;
        }
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return nil;
    }else{
        return self.changeView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0 ? 0 : 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 184;
    }else{
        if (isOrder && indexPath.row < teachingOrderList.count) {
            return 77;
        }else{
            return 44;
        }
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (isOrder){
        if (indexPath.row == teachingOrderList.count && hasMore2 == YES) {
            [self teachingOrderList];
        }
    }else{
        if (indexPath.row == teachingRecordList.count && hasMore == YES) {
            [self getTeachingMemberByReservationStatus];
        }
    }
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section > 0) {
        if (isOrder) {
            if (indexPath.row < teachingOrderList.count) {
                TeachingOrderModel *tom = teachingOrderList[indexPath.row];
                
                TeachingOrderDetailViewController *vc = [TeachingOrderDetailViewController instanceFromStoryboard];
                vc.orderId = tom.orderId;
                vc.isCoach = YES;
                ygweakify(self);
                ygweakify(tom);
                vc.blockRefresh = ^(id data){
                    ygstrongify(self);
                    ygstrongify(tom);
                    int ID = [data intValue];
                    tom.orderState = ID;
                    [self.tableView reloadData];
                };
                vc.blockReturn = ^(id data){
                    ygstrongify(self);
                    [self.navigationController popToViewController:self animated:YES];
                };
                [self pushViewController:vc title:[NSString stringWithFormat:@"订单%d",tom.orderId] hide:YES];
            }
        }else{
            if (indexPath.row < teachingRecordList.count) {
                ReservationModel *rm = teachingRecordList[indexPath.row];
                
                //进入详情
                TeachInfoDetailTableViewController *vc = [TeachInfoDetailTableViewController instanceFromStoryboard];
                vc.reservationId = rm.reservationId;
                vc.plsBack = YES;//如果查看学员详情就回到当前界面
                vc.coachId = [LoginManager sharedManager].session.memberId;
                ygweakify(self);
                ygweakify(rm);
                vc.blockCanceled = ^(id data){
                    ygstrongify(self);
                    ygstrongify(rm);
                    rm.reservationStatus = [data intValue];
                    [self.tableView reloadData];
                };
                [self pushViewController:vc title:@"预约详情" hide:YES];
                
            }
        }
    }
}

@end
