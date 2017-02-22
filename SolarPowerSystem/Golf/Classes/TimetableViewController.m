//
//  TimetableViewController.m
//  Golf
//
//  Created by 廖瀚卿 on 15/6/8.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "TimetableViewController.h"
#import "MDSpreadViewClasses.h"
#import "MyHeaderViewCell.h"
#import "MyImageViewCell.h"
#import "UIImageView+WebCache.h"
#import "CMPopTipView.h"
#import "MyGrayViewCell.h"
#import "UIView+Shake.h"
#import "MyStrViewCell.h"
#import "MyPop.h"
#import "CoachTimetable.h"
#import "SubscribeTimeTableViewController.h"
#import "ChooseStudentTableViewController.h"
#import "CCAlertView.h"
#import "TeachInfoDetailTableViewController.h"
#import "TrendsPraiseListController.h"
#import "YGTAStudentTimeAlertView.h"
#import "JCAlertView.h"
#import "YGTeachingArchiveLessonDetailViewCtrl.h"

#define kWidth 47

typedef NS_ENUM(NSInteger, CellType) {
    CellTypeButton = 0,
    CellTypeText,
    CellTypeList,
    CellTypeOpenSubscribe,
};

typedef NS_ENUM(NSInteger, SubscribeType){
    SubscribeTypeEnabled = 0,  //允许预约
    SubscribeTypeDisabled = -2 //禁止预约
};


@interface TimetableViewController ()<MDSpreadViewDataSource, MDSpreadViewDelegate,ServiceManagerDelegate>
@property (nonatomic, strong) IBOutlet MDSpreadView *spreadView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnRight;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

@end

@implementation TimetableViewController{
    NSMutableArray *datas;
    NSMutableArray *time;
    MDIndexPath *currentRowPath;
    MDIndexPath *currentColumnPath;
    BOOL reshowPop;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.spreadView setSeparatorColor:[UIColor colorWithHexString:@"#f1f0f6"]];
    [self loadData];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (_blockReturn) {
        _blockReturn(nil);
    }
}

- (IBAction)showSubscribeTimeTableViewController:(id)sender {
    [[BaiduMobStat defaultStat] logEvent:@"btnTimetableTimeSet" eventLabel:@"设置教学时间按钮点击"];
    [MobClick event:@"btnTimetableTimeSet" label:@"设置教学时间按钮点击"];
    [self performSegueWithIdentifier:@"SubscribeTimeTableViewController" sender:nil withBlock:^(id sender, id destinationVC) {
        SubscribeTimeTableViewController *vc = (SubscribeTimeTableViewController *)destinationVC;
        vc.coachId = [LoginManager sharedManager].session.memberId;
        vc.blockReturn = ^(id data){
            [self.navigationController popToViewController:self animated:YES];
            [self loadData];
        };
    }];
}

- (void)loadData{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ServiceManager serviceManagerWithDelegate:self] teachingCoachTimetableByCoachId:_coachId sessionId:[[LoginManager sharedManager] getSessionId]];
    });
}


- (void)updateTimetableWithStatus:(SubscribeType)status date:(NSString *)date time:(NSString *)t{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ServiceManager serviceManagerWithDelegate:self] teachingUpdateTimetableByCoachId:_coachId date:date time:t operation:status sessionId:[[LoginManager sharedManager] getSessionId]];
    });
}

- (void)serviceResult:(ServiceManager*)serviceManager Data:(id)data flag:(NSString*)flag{
    NSArray *arr = (NSArray *)data;
    if (Equal(flag, @"teaching_coach_timetable")) {
        datas = [[NSMutableArray alloc] initWithArray:arr];
        if (reshowPop) {
            reshowPop = NO;
            [self spreadView:self.spreadView didSelectCellForRowAtIndexPath:currentRowPath forColumnAtIndexPath:currentColumnPath];
        }
    }
    if (Equal(flag, @"teaching_coach_update_timetable")) {
        int flag = [[arr firstObject] intValue];
        if (flag == 1) {
            [self loadData];
        }
    }
    if (Equal(flag, @"teaching_coach_update_timetable")) {
        [[MyPop sharedInstance] dismiss];
    }
    if (_loadingView) {
        [_loadingView stopAnimating];
    }
    self.spreadView.hidden = NO;
    [self.spreadView reloadData];
}


//左边Section
- (id)spreadView:(MDSpreadView *)aSpreadView titleForHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(MDIndexPath *)rowPath{
    if (time == nil) {
        time = ((CoachTimetable *)[datas firstObject]).timeList;
    }
    TimeList *nd = time[rowPath.row];
    return nd.time;
}


//顶部section
- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(MDIndexPath *)columnPath{
    CoachTimetable *nd = datas[columnPath.row];
    
    MyHeaderViewCell *cell = (MyHeaderViewCell *)[aSpreadView dequeueReusableCellWithIdentifier:@"MyHeaderViewCell"];
    if (cell == nil) {
        cell = [[MyHeaderViewCell alloc] initWithReuseIdentifier:@"MyHeaderViewCell"];
    }
    if (cell.blockReturn == nil) {
        __weak MyHeaderViewCell *weakCell = cell;
        cell.blockReturn = ^(id data){
            NSLog(@"a");
            CoachTimetable *ct = (CoachTimetable *)data;
            
            TimeList *nd = [ct.timeList firstObject];
            
            NSString *nextTime = ((TimeList *)[ct.timeList lastObject]).time;
            nextTime = [NSString stringWithFormat:@" ~ %@",nextTime];
            NSString *date = ct.date;
            if (date.length > 5) {
                date = [date substringFromIndex:5];
            }
            [[MyPop sharedInstance] showWithType:PopTypeTodayOpenOrClose fromTarget:weakCell inView:self.view
                                        withData:@{@"title":[NSString stringWithFormat:@"%@   %@%@",date,nd.time,nextTime],@"data":@{@"modal":nd,@"date":ct.date,@"time":nd.time}}
                                           block:^(id data) {
                                               if ([data[@"type"] isEqualToString:@"close"]) { //不开放预约
                                                   [self updateTimetableWithStatus:SubscribeTypeDisabled date:data[@"date"] time:nil];
                                               }else if([data[@"type"] isEqualToString:@"subscribe"]){ //预约该时段
                                                   [[MyPop sharedInstance] dismiss];
                                                   [self updateTimetableWithStatus:SubscribeTypeEnabled date:data[@"date"] time:nil];
                                               }
                                           } show:^(id data){
                                           } hide:^(id data){

                                           }];

        };
    }
    cell.data = nd;
    cell.labelWeek.text = [self getWeekDayByDate:nd.date];
    cell.labelDay.text = (section == 0 && columnPath.row == 0) ? @"今天":[self getDayByDate:nd.date];
    cell.labelCount.textColor = nd.classCount > 0 ? MainHighlightColor:[UIColor colorWithHexString:@"#e6e6e6"];
    cell.labelCount.text = [NSString stringWithFormat:@"%d",nd.classCount];
//    [cell layoutSubviews];
    return cell;
}

- (MyStrViewCell *)getCellByCourseType:(CourseType)courseType personCount:(int)personCount spreadView:(MDSpreadView *)aSpreadView{
    MyStrViewCell *cell = (MyStrViewCell *)[aSpreadView dequeueReusableCellWithIdentifier:@"MyStrViewCell"];
    if (cell == nil) {
        cell = [[MyStrViewCell alloc] initWithReuseIdentifier:@"MyStrViewCell"];
    }
    [cell setCourseType:courseType];
    cell.labelCount.text = [NSString stringWithFormat:@"%d",personCount];
    return cell;
}


//cells
- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath{
    CoachTimetable *ct = (CoachTimetable *)datas[columnPath.row];
    TimeList *nd = ct.timeList[rowPath.row];
    
    if (nd.personCount < 0 || nd.classType == 0) {
        MyGrayViewCell *cell = (MyGrayViewCell *)[aSpreadView dequeueReusableCellWithIdentifier:@"MyGrayViewCell"];
        if (cell == nil) {
            cell = [[MyGrayViewCell alloc] initWithReuseIdentifier:@"MyGrayViewCell"];
        }
        [cell setColorType:(nd.personCount == -3 ? ColorTypeBlack:ColorTypeGray)];
        return cell;
    }
    
    switch (nd.classType) {
        case 1: //单节课
        {
            MyImageViewCell *cell = (MyImageViewCell *)[aSpreadView dequeueReusableCellWithIdentifier:@"MyImageViewCell"];
            if (cell == nil) {
                cell = [[MyImageViewCell alloc] initWithReuseIdentifier:@"MyImageViewCell"];
            }
            cell.clipsToBounds = YES;
            ReservationModel *reservation = [nd.reservationList firstObject];
            if (reservation != nil) {
                [cell.imageHead sd_setImageWithURL:[NSURL URLWithString:reservation.headImage] placeholderImage:[UIImage imageNamed:@"head_member"]];
            }else{
                [cell.imageHead setImage:[UIImage imageNamed:@""]];
            }
            return cell;
        }
            break;
        case 2: // 团课
            return [self getCellByCourseType:(CourseTypeGroup) personCount:nd.personCount spreadView:aSpreadView];
            break;
            
        case 3: //公开课
            return [self getCellByCourseType:(CourseTypePublic) personCount:nd.personCount spreadView:aSpreadView];
            break;
            
        default:
            break;
    }
    
    return nil;
}

//- (void)showTeachInfoDetailTableViewControllerByReservationId:(int)reservationId reshow:(BOOL)reshow
//{
//    [self performSegueWithIdentifier:@"TeachInfoDetailTableViewController" sender:nil withBlock:^(id sender, id destinationVC) {
//        TeachInfoDetailTableViewController *vc = (TeachInfoDetailTableViewController *)destinationVC;
//        vc.reservationId = reservationId;
//        vc.title = @"课程详情";
//        vc.coachId = [LoginManager sharedManager].session.memberId;
//        vc.blockReturn = ^(id data){
//            reshowPop = reshow;
//            [[MyPop sharedInstance] dismiss];
//            [self loadData];
//        };
//    }];
//}

/**
 * 跳转到课时详情
 */
-(void) _gotoYGTeachingArchiveLessonDetailViewCtrl:(ReservationModel *) rm reshow:(BOOL)reshow
{
    if (rm) {
        YGTeachingArchiveLessonDetailViewCtrl *vc = [YGTeachingArchiveLessonDetailViewCtrl instanceFromStoryboard];
        vc.periodId = rm.periodId;
        vc.isCoach = (rm.coachId == [LoginManager sharedManager].session.memberId);
        [[MyPop sharedInstance] dismiss];
        ygweakify(self)
        vc.taLessonDetailViewCtrlBlock = ^(){
            ygstrongify(self)
            reshowPop = reshow;
            [[MyPop sharedInstance] dismiss];
            [self loadData];
        };
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)cellActionByData:(id)data reshow:(BOOL)reshow{
    ReservationModel *rm = (ReservationModel *)data[@"data"];
    NSString *type = data[@"type"];
    if ([@"cell" isEqualToString:type]) {
        //去查看课时详情
        [self _gotoYGTeachingArchiveLessonDetailViewCtrl:rm reshow:reshow];
        
    }else if([@"right" isEqualToString:type]){
        //点击以教学按钮打开确认弹出框
        CCAlertView *alert = [[CCAlertView alloc] initWithTitle:nil message:@"已完成该学员的教学？"];
        [alert addButtonWithTitle:@"取消" block:nil];
        [alert addButtonWithTitle:@"已完成" block:^{
            //已完成教学任务
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[BaiduMobStat defaultStat] logEvent:@"btnTimetableComplete" eventLabel:@"我的时间表已教学按钮点击"];
                [MobClick event:@"btnTimetableComplete" label:@"我的时间表已教学按钮点击"];
                [[ServiceManager serviceManagerWithDelegate:self] teachingMemberReservationComplete:[[LoginManager sharedManager] getSessionId] coachId:[LoginManager sharedManager].session.memberId reservationId:rm.reservationId opteraton:1 periodId:rm.periodId callBack:^(BOOL boolen) {
                    if (boolen) {
                        reshowPop = YES;
                        [[MyPop sharedInstance] dismiss];
                        [SVProgressHUD showSuccessWithStatus:@"确认成功"];
                        [self loadData];
                    }
                }];//1:已教学 2：未到场
            });
        }];
        [alert show];
    }

}

- (void)spreadView:(MDSpreadView *)aSpreadView didSelectCellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath{
    currentColumnPath = columnPath;
    currentRowPath = rowPath; 
    
    [[MyPop sharedInstance] dismiss];
    
    CoachTimetable *ct = (CoachTimetable *)datas[columnPath.row];
    TimeList *nd = ct.timeList[rowPath.row];
    NSString *nextTime = [self getNextTime:ct rowAtIndexPath:rowPath];
    
    MDSpreadViewCell *cell = [aSpreadView cellForRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath];
    
    NSString *date = ct.date;
    if (date.length > 5) {
        date = [date substringFromIndex:5];
    }
    
    if (nd.personCount < 0 || nd.classType == 0) {
        if (nd.personCount == -3) { //不能操作的cell
            [cell shake];
        }else{
            //弹出开放预约
            [[MyPop sharedInstance] showWithType:PopTypeSubscribeReOpen fromTarget:cell inView:self.view
                                        withData:@{@"title":[NSString stringWithFormat:@"%@   %@%@",date,nd.time,nextTime],@"data":@{@"modal":nd,@"date":ct.date,@"time":nd.time}}
                                           block:^(id data) {
                                               [self updateTimetableWithStatus:SubscribeTypeEnabled date:data[@"date"] time:data[@"time"]];
            } show:^(id data){
            } hide:^(id data){
                [aSpreadView deselectCellForRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath animated:YES];
            }];
        }
        return;
    }
    
    switch (nd.classType) {
        case 1: //单节课
        {
            ReservationModel *reservation = [nd.reservationList firstObject];
            if (reservation) { //有预约数据则显示
                [[MyPop sharedInstance] showWithType:(reservation.reservationStatus == 5 ? PopTypeTeachingFinished:PopTypeTeachingWait) fromTarget:cell
                                              inView:self.view
                                            withData:@{@"title":[NSString stringWithFormat:@"%@   %@%@",date,nd.time,nextTime],@"data":reservation}
                                               block:^(id data){
                                                   [self cellActionByData:data reshow:NO];
                                               } show:^(id data){
                                                   NSLog(@"showed");
                                               } hide:^(id data){
                                                   NSLog(@"hided");
                                                   [aSpreadView deselectCellForRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath animated:YES];
                                               }];
            } else {
                
                if (self.classInfoBean || self.periodBean) { // 教练 从课程详情 或者 课时详情
                    [self _handleAppointmentedReservation:ct nd:nd rowPath:rowPath];
                    return;
                }
                
                [[MyPop sharedInstance] showWithType:PopTypeSubscribeOrClose fromTarget:cell
                                              inView:self.view
                                            withData:@{@"title":[NSString stringWithFormat:@"%@   %@%@",date,nd.time,nextTime],@"data":@{@"modal":nd,@"date":ct.date,@"time":nd.time}}
                                               block:^(id data) {
                                                   if ([data[@"type"] isEqualToString:@"close"]) { //不开放预约
                                                       [self updateTimetableWithStatus:SubscribeTypeDisabled date:data[@"date"] time:data[@"time"]];
                                                       
                                                   } else if([data[@"type"] isEqualToString:@"subscribe"]){ //预约该时段
                                                       [[MyPop sharedInstance] dismiss];
                                                       ChooseStudentTableViewController *vc = [[UIStoryboard storyboardWithName:@"Teach" bundle:NULL] instantiateViewControllerWithIdentifier:@"ChooseStudentTableViewController"];
                                                       
                                                       vc.coachId = [LoginManager sharedManager].session.memberId;
                                                       vc.sessionId = [[LoginManager sharedManager] getSessionId];
                                                       vc.title = @"选择学员";
                                                       vc.nextTime = [self getNextTime:ct rowAtIndexPath:rowPath];
                                                       vc.date = ct.date;
                                                       vc.time = nd.time;
                                                       
                                                       ygweakify(self)
                                                       vc.blockReturn = ^(id data){
                                                           ygstrongify(self)
                                                           //教练选择学员预约完成
                                                           [self.navigationController popToViewController:self animated:YES];
                                                           [[MyPop sharedInstance] dismiss];
                                                           [self loadData];
                                                       };
                                                       [self.navigationController pushViewController:vc animated:YES];
                                                   }
                                                   
                                               } show:^(id data){
                                               } hide:^(id data){
                                                   [aSpreadView deselectCellForRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath animated:YES];
                                               }];
            }
            return;
            
        }
            break;
        case 2: // 团课
        {
            if (nd.personCount > 0) {
                CoachTimetable *ct = (CoachTimetable *)datas[columnPath.row];
                TimeList *nd = ct.timeList[rowPath.row];
                if (nd.personCount > 0) {
                    [[MyPop sharedInstance] showWithType:(PopTypeTeachingList) fromTarget:cell inView:self.view
                                                withData:@{@"title":[NSString stringWithFormat:@"%@   %@%@",date,nd.time,nextTime],@"data":@{@"modal":nd,@"date":ct.date,@"time":nd.time}}
                                                   block:^(id data){
                                                       [self cellActionByData:data reshow:YES];
                                                   } show:^(id data){
                                                       NSLog(@"showed");
                                                   } hide:^(id data){
                                                       NSLog(@"hided");
                                                       [self.spreadView deselectCellForRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath animated:YES];
                                                   }];
                }
            }else{
                [[MyPop sharedInstance] showWithType:PopTypeTeachingNone fromTarget:cell inView:self.navigationController.view
                                            withData:@{@"title":[NSString stringWithFormat:@"%@   %@%@",date,nd.time,nextTime]}
                                               block:^(id data) {
                                               } show:^(id data){
                                               } hide:^(id data){
                                                   [aSpreadView deselectCellForRowAtIndexPath:rowPath forColumnAtIndexPath:columnPath animated:YES];
                                               }];
            }
            
            return;
        }
            break;
        case 3: //公开课
        {

            TrendsPraiseListController *vc = [[UIStoryboard storyboardWithName:@"TrendsPraiseList" bundle:NULL] instantiateViewControllerWithIdentifier:@"TrendsPraiseListController"];
            vc.publicClassId = nd.publicClassId;
            vc.title = @"报名列表";
            [self.navigationController pushViewController:vc animated:YES];
            
        }
            break;
        default:
            break;
    }
}

- (NSString *)getNextTime:(CoachTimetable *)ct rowAtIndexPath:(MDIndexPath *)rowPath{
    NSString *nextTime = @"";
    if (rowPath.row +1 < ct.timeList.count) {
        TimeList *nd2 = ct.timeList[rowPath.row + 1];
        nextTime = nd2.time;
        nextTime = [NSString stringWithFormat:@" ~ %@",nextTime];
    }
    return nextTime;
}


- (NSInteger)spreadView:(MDSpreadView *)aSpreadView numberOfColumnsInSection:(NSInteger)section{
    return datas.count;
}

- (NSInteger)spreadView:(MDSpreadView *)aSpreadView numberOfRowsInSection:(NSInteger)section{
    if (datas && datas.count > 0) {
        CoachTimetable *ct = (CoachTimetable *)[datas firstObject];
        return ct.timeList.count;
    }
    return 0;
}

- (CGFloat)spreadView:(MDSpreadView *)aSpreadView heightForRowAtIndexPath:(MDIndexPath *)indexPath{
    return kWidth;
}

- (CGFloat)spreadView:(MDSpreadView *)aSpreadView heightForRowHeaderInSection:(NSInteger)rowSection
{
    return 76;
}

- (CGFloat)spreadView:(MDSpreadView *)aSpreadView widthForColumnAtIndexPath:(MDIndexPath *)indexPath{
    return kWidth;
}

- (CGFloat)spreadView:(MDSpreadView *)aSpreadView widthForColumnHeaderInSection:(NSInteger)columnSection{
    return kWidth + 15;
}

- (NSString *)getWeekDayByDate:(NSString *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *d = [Utilities getDateFromString:date];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSDateComponents *weekComp = [calendar components:NSWeekdayCalendarUnit fromDate:d];
#pragma clang diagnostic pop
    NSInteger weekDayEnum = [weekComp weekday];
    NSString *weekDays = nil;
    switch (weekDayEnum) {
        case 1:
            weekDays = @"日";
            break;
        case 2:
            weekDays = @"一";
            break;
        case 3:
            weekDays = @"二";
            break;
        case 4:
            weekDays = @"三";
            break;
        case 5:
            weekDays = @"四";
            break;
        case 6:
            weekDays = @"五";
            break;
        case 7:
            weekDays = @"六";
            break;
        default:
            break;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSDateComponents *dateComp = [calendar components:NSDayCalendarUnit fromDate:d];
#pragma clang diagnostic pop
    NSInteger day = [dateComp day];
    if (day == 1) {
        weekDays = [[Utilities getMonth1ByDate:d] stringByAppendingString:@"月"];
    }
    
    return weekDays;
}

- (NSString *)getDayByDate:(NSString *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComp = [calendar components:NSDayCalendarUnit fromDate:[Utilities getDateFromString:date]];
    return [NSString stringWithFormat:@"%01ld",(long)[dateComp day]];
}

/**
 * 处理单节课预约该时段
 */
-(void) _handleAppointmentedReservation:(CoachTimetable *) ct nd:(TimeList *) nd rowPath:(MDIndexPath *)rowPath
{
    if (self.classInfoBean || self.periodBean) { // 教练 从课程详情 或者 课时详情
        
        MemberClassModel *pMemberClassModel = [MemberClassModel new];
        if (self.classInfoBean) { // 课程详情过来
            pMemberClassModel.classId = self.classInfoBean.classId;
            
        } else if (self.periodBean) { // 课时详情过来
            pMemberClassModel.classId = self.periodBean.classInfo.classId;
            pMemberClassModel.periodId = self.periodBean.periodId;
            self.classInfoBean = self.periodBean.classInfo;
        }
        pMemberClassModel.headImage = self.classInfoBean.memberHeadImage;
        pMemberClassModel.nickName = self.classInfoBean.memberNickName;
        pMemberClassModel.productName = self.classInfoBean.productName;
        
        NSString *nextTimeSring = [self getNextTime:ct rowAtIndexPath:rowPath];
        pMemberClassModel.orderTime = [NSString stringWithFormat:@"%@ %@%@",ct.date,nd.time,nextTimeSring];
        
        [self _showYGTAStudentTimeAlertView:pMemberClassModel date:ct.date time:nd.time];
    }
}

/**
 * 弹窗确认预约
 */
-(void) _showYGTAStudentTimeAlertView:(MemberClassModel *) memberClassModel date:(NSString *) dateString time:(NSString *) timeString
{
    YGTAStudentTimeAlertView *alerView = [YGTAStudentTimeAlertView instance];
    alerView.width = Device_Width - 50.f;
    [alerView configureWithEntity:memberClassModel date:dateString time:timeString];
    
    JCAlertView *alert = [[JCAlertView alloc] initWithCustomView:alerView dismissWhenTouchedBackground:NO];
    [alert show];
    
    ygweakify(self)
    alerView.studentTimeOptBlock = ^(MemberClassModel *memberClassModel,YGTAStudentTimeAlertOptType optType){
        ygstrongify(self)
        switch (optType) {
            case YGTAStudentTimeAlertOptTypeCancel:
            case YGTAStudentTimeAlertOptTypeConfirm:
                [alert dismissWithCompletion:NULL];
                break;
            case YGTAStudentTimeAlertOptTypeAppointmented:{ // 预约成功返回
                if (self.blockReturn) {
                    self.blockReturn(nil);
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
                break;
            default:
                break;
        }
    };
}




@end
