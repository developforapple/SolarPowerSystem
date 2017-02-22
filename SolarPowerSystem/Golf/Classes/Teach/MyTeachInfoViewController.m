//
//  MyTeachInfoViewController.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/20.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "MyTeachInfoViewController.h"
#import "MyTeachInfoHeaderCell.h"
#import "MyTeachActionTableViewCell.h"
#import "TeachInfoTableViewCell.h"
#import "TeachInfoDetailTableViewController.h"
#import "MemberReservationModel.h"
#import "RemainderClassTableViewController.h"
#import "MemberClassModel.h"
#import "JXChooseTimeController.h"
#import "TeachingOrderListViewController.h"
#import "TeachInfoCommentTableViewController.h"


@interface MyTeachInfoViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@end

@implementation MyTeachInfoViewController{
    NSMutableArray *datas1,*datas2,*datas;
    
    int size;
    int page;
    BOOL loading;
    BOOL hasMore;
    int remainHour;
    int classCount;
    
    MemberClassModel *classModel;
    NSIndexPath *currentIndexPath;
}


#pragma mark - UI处理

- (void)viewDidLoad {
    [super viewDidLoad];
    ygweakify(self);
    [self.tableView setRefreshHeaderEnable:YES footerEnable:NO callback:^(YGRefreshType type) {
        ygstrongify(self);
         [self getFirstPage];
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全部订单" style:UIBarButtonItemStylePlain target:self action:@selector(showTeachingOrderListViewController)];
    
    datas1 = [[NSMutableArray alloc] init];
    datas2 = [[NSMutableArray alloc] init];
    datas = [[NSMutableArray alloc] init];
    
    
    [self getFirstPage];
}

- (void)showTeachingOrderListViewController{
    TeachingOrderListViewController *vc = [TeachingOrderListViewController instanceFromStoryboard];
    vc.canSlide = YES;
    vc.blockRefresh = ^(id data){
        [self getFirstPage];
    };
    vc.title = @"全部订单";
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 逻辑方法

- (void)chooseTime:(MemberClassModel *)m{
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
        chooseTime.classId = m.classId;
        chooseTime.classNo = m.classHour-m.remainHour+1;
        chooseTime.classType = m.classType;
        ygweakify(self);
        chooseTime.blockReturn = ^(id data){
            ygstrongify(self);
            [self getFirstPage];
            [self.navigationController popToViewController:self animated:YES];
        };
    }];
}

- (void)getTeachingMemberReservationWatiList{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ServiceManager serviceManagerWithDelegate:self] getTeachingMemberByReservationStatus:1 pageNo:0 pageSize:0 sessionId:[[LoginManager sharedManager] getSessionId] coachId:0 memberId:0 keyword:nil];
    });
}

- (void)getTeachingMemberReservationHistoryList{
    loading = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ServiceManager serviceManagerWithDelegate:self] getTeachingMemberByReservationStatus:0 pageNo:page pageSize:size sessionId:[[LoginManager sharedManager] getSessionId] coachId:0 memberId:0 keyword:nil];
    });
}

- (void)getFirstPage{
    page = 0;
    size = 15;
    hasMore = YES;
    [self getTeachingMemberReservationWatiList];
}

- (void)serviceResult:(ServiceManager*)serviceManager Data:(id)data flag:(NSString*)flag{
    [_tableView.mj_header endRefreshing];
    
    NSArray *arr = (NSArray*)data;
   
    if (Equal(flag, @"teaching_member_class_list")) {
        classModel = [arr firstObject];
        return;
    }
    
    if (Equal(flag, @"teaching_member_reservation_list")) {
        MemberReservationModel *mrm = [arr firstObject];
        remainHour = mrm.remainHour;
        classCount = mrm.classCount; //课程数，如果只有一种点击预约教练直接进入预约界面而非课程列表
        
        if (mrm.classCount == 1) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[ServiceManager serviceManagerWithDelegate:self] getTeachingMemberClassList:[[LoginManager sharedManager] getSessionId] coachId:0];
            });
        }
        if (page == 0) {
            [datas1 removeAllObjects];
            [datas2 removeAllObjects];
            if (mrm.dataList && mrm.dataList.count > 0) {
                [_tableView setHidden:NO];
                for (ReservationModel *m in mrm.dataList) {
                    if (m.reservationStatus == 1) {
                        [datas1 addObject:m];
                    }
                }
            }
            
            page++;
            [self getTeachingMemberReservationHistoryList];
        }else{
            if (mrm.dataList && mrm.dataList.count > 0) {
                [_tableView setHidden:NO];
                [datas2 addObjectsFromArray:mrm.dataList];
                page++;
                hasMore = YES;
            }else{
                hasMore = NO;
            }
        }
    }
    [datas removeAllObjects];
    [datas addObject:[MyTeachActionTableViewCell class]];
    if (datas1.count > 0) {
        [datas addObject:@"待上课程"];
        for (int i = 0; i < datas1.count; i++) {
            id obj = datas1[i];
            [datas addObject:obj];
            if (datas1.count > 1 && (i + 1) != datas1.count) {
                [datas addObject:@(0)];
            }
        }
    }else{
        if (remainHour > 0) {
            [datas addObject:@"CellGo"];
        }else{
            [datas addObject:@"CellNone"];
        }
    }
    if (datas2.count > 0) {
        [datas addObject:@"历史课程"];
        for (int i = 0; i < datas2.count; i++) {
            id obj = datas2[i];
            [datas addObject:obj];
            if (datas2.count > 1 && (i + 1) != datas2.count) {
                [datas addObject:@(0)];
            }
        }
    }
    if (_loadingView) {
        [_loadingView stopAnimating];
    }
    self.tableView.hidden = NO;
    [self.tableView reloadData];
    loading = NO;
}

#pragma mark - UITableViewDataSource

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == datas.count && hasMore == YES) {
        [self getTeachingMemberReservationHistoryList];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return datas.count + (datas2.count > 0 ? 1:0);
}

- (void)showRemainderClassTableViewController{
    [self pushWithStoryboard:@"Teach" title:@"剩余课时" identifier:@"RemainderClassTableViewController" completion:^(BaseNavController *controller) {
        RemainderClassTableViewController *vc = (RemainderClassTableViewController *)controller;
        vc.sessionId = [[LoginManager sharedManager] getSessionId];
        vc.blockReturn = ^(id data){
            [self getFirstPage];
        };
    }];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (datas.count == indexPath.row && datas2.count > 0) {
        return [tableView dequeueReusableCellWithIdentifier:(hasMore ? @"LoadingCell":@"AllLoadedCell") forIndexPath:indexPath];
    }
    if (indexPath.row == 0) {
        MyTeachActionTableViewCell *cell = (MyTeachActionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MyTeachActionTableViewCell" forIndexPath:indexPath];
        NSMutableAttributedString *btnTitle = [[NSMutableAttributedString alloc] initWithString:@"剩余" attributes:@{NSForegroundColorAttributeName:MainTintColor,NSFontAttributeName:[UIFont systemFontOfSize:14.0f]}];
        [btnTitle appendAttributedString:[[NSMutableAttributedString alloc]
                                          initWithString:[NSString stringWithFormat:@"%d",remainHour]
                                          attributes:@{NSForegroundColorAttributeName:MainHighlightColor,NSFontAttributeName:[UIFont systemFontOfSize:20]}]
         ];
        [btnTitle appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"课时" attributes:@{NSForegroundColorAttributeName:MainTintColor,NSFontAttributeName:[UIFont systemFontOfSize:14.0f]}]];
        [cell.btnCourseTime setAttributedTitle:btnTitle forState:(UIControlStateNormal)];
        cell.btnYueTeacher.enabled = remainHour > 0;
        
        if (cell.blockCourseTimeReturn == nil) {
            cell.blockCourseTimeReturn = ^(id data){
                [self showRemainderClassTableViewController];
            };
        }
        if (cell.blockYueTeacher == nil) {
            cell.blockYueTeacher = ^(id data){
                if (classCount > 1) {
                    [self showRemainderClassTableViewController];
                }else if(classCount == 1 && classModel != nil){
                    [self chooseTime:classModel];
                }
            };
        }
        
        return cell;
    }
    id data = datas[indexPath.row];

    if ([data isKindOfClass:[NSNumber class]]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellLine" forIndexPath:indexPath];
        return cell;
    }
    if ([data isKindOfClass:[NSString class]]) {
        if ([data isEqualToString:@"CellGo"]) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellGo" forIndexPath:indexPath];
            return cell;
        }else if([data isEqualToString:@"CellNone"]){
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellNone" forIndexPath:indexPath];
            return cell;
        }
        return [self cellForHeaderTitle:data tableView:tableView indexPath:indexPath];
    }
    if ([data isKindOfClass:[ReservationModel class]]) {
        return [self cellForTeachInfo:data tableView:tableView indexPath:indexPath];
    }
    return [[UITableViewCell alloc] init];
}

- (UITableViewCell *)cellForHeaderTitle:(NSString *)title tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    MyTeachInfoHeaderCell *cell = (MyTeachInfoHeaderCell *)[tableView dequeueReusableCellWithIdentifier:@"MyTeachInfoHeaderCell" forIndexPath:indexPath];
    cell.labelHeaderName.text = title;
    return cell;
}

- (UITableViewCell *)cellForTeachInfo:(ReservationModel *)m tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    NSString *identifier = @"TeachInfoTableViewCell";
    
    if (m.reservationStatus == 6) {
        identifier = @"TeachInfoTableViewWaitReplyCell";
    }

    TeachInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    [cell loadData:@{@"data":m,@"row":@(indexPath.row)}];
    if (cell.blockReturn == nil) {
        cell.blockReturn = ^(id nd){
            ReservationModel *rm = (ReservationModel *)nd[@"data"];
            
            [self performSegueWithIdentifier:@"TeachInfoCommentTableViewController" sender:nil withBlock:^(id sender, id destinationVC) {
                TeachInfoCommentTableViewController *vc = (TeachInfoCommentTableViewController *)destinationVC;
                vc.reservationId = rm.reservationId;
                vc.data = [[NSMutableDictionary alloc] initWithDictionary:nd];
                if (_blockReturn) {
                    vc.blockReturn = _blockReturn;
                }else{
                    vc.blockReturn = ^(id data){
                        ReservationModel *rm = (ReservationModel *)data[@"data"];
                        datas[[data[@"row"] intValue]] = rm;
                        [self.tableView reloadData];
                        [self.navigationController popViewControllerAnimated:YES];
                    };
                }
            }];
        };
    }
    
    
    return cell;
}


#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    currentIndexPath = indexPath;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (datas.count == indexPath.row && datas2.count > 0) {
        return;
    }
    id data = datas[indexPath.row];

    if ([data isKindOfClass:[ReservationModel class]]) {
        if (![LoginManager sharedManager].loginState) {
            [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:NO];
            return;
        }
        
        ReservationModel *m = (ReservationModel *)data;
        //进入详情
        [self pushWithStoryboard:@"Teach" title:@"课程详情" identifier:@"TeachInfoDetailTableViewController" completion:^(BaseNavController *controller) {
            TeachInfoDetailTableViewController *vc = (TeachInfoDetailTableViewController *)controller;
            vc.reservationId = m.reservationId;
            vc.blockCanceled = ^(id data){
                [self getFirstPage];
            };
            vc.blockRefresh = ^(id data){
                ReservationModel *rm = (ReservationModel *)data;
                datas[currentIndexPath.row] = rm;
                [self.tableView reloadData];
            };
        }];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (datas.count == indexPath.row && datas2.count > 0) {
        return 44;
    }
    if (indexPath.row == 0) {
        return 60;
    }
    id data = datas[indexPath.row];
    if ([data isKindOfClass:[NSNumber class]]) {
        return 10;
    }
    if ([data isKindOfClass:[NSString class]]) {
        if ([data isEqualToString:@"CellGo"] || [data isEqualToString:@"CellNone"]){
            return 150;
        }
        return 33;
    }
    if ([data isKindOfClass:[ReservationModel class]]) {
        return 130;
    }
    return 0;
}


@end
