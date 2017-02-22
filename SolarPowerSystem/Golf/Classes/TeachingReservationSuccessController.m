//
//  TeachingReservationSuccessController.m
//  Golf
//
//  Created by 黄希望 on 15/5/13.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "TeachingReservationSuccessController.h"
#import "CouponNumCell.h"
#import "VoucherTableViewCell.h"
#import "SuccessTopCell.h"
#import "ReserveSuccessInfoCell.h"
#import "ReserveSuccessAddressCell.h"
#import "AwardView.h"
#import "BaseCoverView.h"
#import "YGCouponDetailViewCtrl.h"
#import "YGMapViewCtrl.h"
#import "CouponModel.h"
#import "SharePackage.h"
#import "YGOrderHandler.h"

@interface TeachingReservationSuccessController()<AwardViewDelegate,UITableViewDelegate,UITableViewDataSource>{
    SharePackage *_share;
}

@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *couponList;
@property (nonatomic,assign) int totalCouponAmount;
@property (nonatomic,assign) BOOL isConsumeAward;
@property (nonatomic,strong) AwardModel *awardModel;

@end

@implementation TeachingReservationSuccessController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.couponList = [NSMutableArray array];
    self.tableView.tableFooterView = [[UIView alloc] init];

    if (self.orderId > 0) {
        [self getOrderInfo];
    }else if (self.teachingCoachModel){
        _tableView.hidden = NO;
        [_tableView reloadData];
    }
}

- (void)getOrderInfo{
    [[ServiceManager serviceManagerWithDelegate:self] teachingOrderDetail:[[LoginManager sharedManager] getSessionId] orderId:self.orderId coachId:0];
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray*)data;
    if (array > 0) {
        if (Equal(flag, @"teaching_order_detail")) {
            _tableView.hidden = NO;
            
            TeachingOrderDetailModel *orderDetail = array[0];
            if (orderDetail) {
                
                [[YGOrderHandler handlerWithOrder:orderDetail] postOrderDidChangedNotification];
                
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"OperatedAllKindsOrder" object:@{@"data":orderDetail,@"orderType":@3,@"operate":@2}];//lyf 加 orderType:1球场，2商品，3教学 operate:1是删除，2是其他
            }

            self.teachingCoachModel = [[TeachingCoachModel alloc] init];
            _teachingCoachModel.nickName = orderDetail.nickName;
            _teachingCoachModel.address = orderDetail.address;
            _teachingCoachModel.teachingSite = orderDetail.teachingSite;
            _teachingCoachModel.distance = orderDetail.distance;
            _teachingCoachModel.longitude = orderDetail.longitude;
            _teachingCoachModel.latitude = orderDetail.latitude;
            self.date = orderDetail.teachingDate;
            self.time = orderDetail.teachingTime;
            [_tableView reloadData];
            
            if (!_isConsumeAward && self.orderId) {
                [[ServiceManager serviceManagerWithDelegate:self] consumeAward:[[LoginManager sharedManager] getSessionId] orderId:self.orderId orderType:@"teaching"];
            }
        }
        if (Equal(flag, @"consume_award")) {
            _isConsumeAward = YES;
            if (array.count>0){
                NSDictionary *dic = array[0];
                id obj1 = dic[@"red_packet"];
                if (obj1) {
                    self.awardModel = [[AwardModel alloc] initWithDic:obj1];
                }
                if (self.awardModel) {
                    [self rightButtonActionWithImg:@"ic_hongbao"];
                    AwardView *awardView = [AwardView viewWithFrame:CGRectMake(0, 0, Device_Width-26, 343) model:self.awardModel delegate:self];
                    [BaseCoverView viewWithFrame:[GolfAppDelegate shareAppDelegate].window.bounds color:[UIColor blackColor] alpha:0.7 sbFrame:awardView.frame sbView:awardView spView:[GolfAppDelegate shareAppDelegate].naviController.view];
                }else{
                    self.navigationItem.rightBarButtonItem = nil;
                }
                
                NSArray *resultArr = dic[@"coupon_list"];
                if (resultArr && resultArr.count > 0) {
                    _totalCouponAmount = 0;
                    for (NSDictionary *obj in resultArr) {
                        _totalCouponAmount += [obj[@"coupon_amount"] intValue]/100;
                        CouponModel *cm = [[CouponModel alloc] initWithDic:obj];
                        [_couponList addObject:cm];
                    }
                    
                    [_tableView reloadData];
                }
            }
        }
    }
}

- (NSString*)dateWeekStr{
    NSString *dt = self.date;
    NSString *week = [Utilities getWeekDayByDate:[Utilities getDateFromString:self.date]];
    if (dt.length>0&&week.length>0) {
        return [NSString stringWithFormat:@"%@ %@",dt,week];
    }else if (dt.length>0){
        return [NSString stringWithFormat:@"%@",dt];
    }else if (week.length>0){
        return [NSString stringWithFormat:@"%@",week];
    }
    return @"";
}


#pragma mark - UITableView delegate && dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.couponList.count > 0) {
        return 4+self.couponList.count;
    }
    return 3;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        SuccessTopCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SuccessTopCell" forIndexPath:indexPath];
        return cell;
    }else if (indexPath.row == 1){
        ReserveSuccessInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReserveSuccessInfoCell" forIndexPath:indexPath];
        cell.coachNameLabel.text = _teachingCoachModel.nickName.length>0 ? _teachingCoachModel.nickName : @" ";
        cell.dateLabel.text = [self dateWeekStr];
        cell.timeLabel.text = [self timeAreaWithTime:self.time];
        return cell;
    }else if (indexPath.row == 2){
        ReserveSuccessAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReserveSuccessAddressCell" forIndexPath:indexPath];
        cell.teachingSiteLabel.text = _teachingCoachModel.teachingSite.length>0 ? _teachingCoachModel.teachingSite : @" ";
        cell.addressLabel.text = [NSString stringWithFormat:@"%.02fkm %@",_teachingCoachModel.distance,_teachingCoachModel.address];
        return cell;
    }else if (indexPath.row == 3){
        CouponNumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CouponNumCell" forIndexPath:indexPath];
        cell.couponNumLabel.text = [NSString stringWithFormat:@"恭喜您获得%d元现金券",_totalCouponAmount];
        return cell;
    }else{
        VoucherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VoucherTableViewCell" forIndexPath:indexPath];
        cell.viewType = VoucherTableViewTypeMore;
        if (_couponList.count > 0 && indexPath.row < _couponList.count+4) {
            CouponModel *cm = _couponList[indexPath.row-4];
            [cell setPrice:[@(cm.couponAmount) description]];
            [cell setTitle:cm.couponName];
            [cell setOther:[NSString stringWithFormat:@"有效期至 %@\n%@",cm.expireTime,cm.couponDescription == nil ? @"":cm.couponDescription]];
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 80;
    }else if (indexPath.row == 1){
        return 97;
    }else if (indexPath.row == 2){
        NSString *address = [NSString stringWithFormat:@"%.02fkm %@",_teachingCoachModel.distance,_teachingCoachModel.address];
        CGSize sz = [Utilities getSize:address withFont:[UIFont systemFontOfSize:12] withWidth:Device_Width-155];
        return 68+sz.height;
    }else if (indexPath.row == 3){
        return 59;
    }else{
        return 101;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 2) {
        ClubModel *club = [[ClubModel alloc] init];
        club.clubName = _teachingCoachModel.teachingSite;
        club.address = _teachingCoachModel.address;
        club.latitude = _teachingCoachModel.latitude;
        club.longitude = _teachingCoachModel.longitude;
        club.trafficGuide = @"";
        
        YGMapViewCtrl *vc = [YGMapViewCtrl instanceFromStoryboard];
        vc.clubList = @[club];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if (indexPath.row > 3){
        if (_couponList.count > 0 && indexPath.row < _couponList.count+4) {
            CouponModel *cm = _couponList[indexPath.row-4];
            YGCouponDetailViewCtrl *vc = [YGCouponDetailViewCtrl instanceFromStoryboard];
            vc.title = @"现金券详情";
            vc.couponModel = cm;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (NSString*)timeAreaWithTime:(NSString*)time{
    if (!time || time.length == 0) {
        return @"";
    }
    int t = [[[time componentsSeparatedByString:@":"] firstObject] intValue];
    return [NSString stringWithFormat:@"%02d:00~%02d:00",t,t+1];
}

- (void)doRightNavAction{
    AwardView *awardView = [AwardView viewWithFrame:CGRectMake(0, 0, Device_Width-26, 343) model:self.awardModel delegate:self];
    [BaseCoverView viewWithFrame:[GolfAppDelegate shareAppDelegate].window.bounds color:[UIColor blackColor] alpha:0.7 sbFrame:awardView.frame sbView:awardView spView:[GolfAppDelegate shareAppDelegate].naviController.view];
}

- (void)awardViewCallBackWithData:(AwardModel*)model{
    if ([LoginManager sharedManager].loginState) {
        if ([self needPerfectMemberData]) {
            return;
        }
    }
    if (_share) {
        _share = nil;
    }
    _share = [[SharePackage alloc] initWithTitle:model.awardTitle content:model.awardContent img:[UIImage imageNamed:@"award.png"] url:model.awardUrl];
    [_share shareInfoForView:[GolfAppDelegate shareAppDelegate].currentController.view];
}

- (void)doLeftNavAction{
    if (!_blockReturn) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    //lyf 加 没读懂 为了解决点左键没法后退和进入下一页乱后退， 1
    else {
        _blockReturn(nil);
    }
}

//-(void)viewDidDisappear:(BOOL)animated{//lyf 屏蔽 没读懂 为了解决点左键没法后退和进入下一页乱后退， 2
//    [super viewDidDisappear:animated];
//    if (_blockReturn) {
//        _blockReturn(nil);
//    }
//}

@end
