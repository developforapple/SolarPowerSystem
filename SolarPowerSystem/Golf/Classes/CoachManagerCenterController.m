//
//  CoachManagerCenterController.m
//  Golf
//
//  Created by 黄希望 on 15/6/2.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CoachManagerCenterController.h"
#import "CoachThreeViewCell.h"
#import "CoachSixViewCell.h"
#import "MyScheduleTableViewController.h"
#import "TimetableViewController.h"
#import "CoachNoticeController.h"
#import "YGTeachingArchiveService.h"
#import "YGMyTeachingArchiveTitleViewCell.h"
#import "YGMyTeachingArchiveCourseViewCell.h"
#import "YGMyTANoneDefaultViewCell.h"
#import "YGCoachNoticeViewCtrl.h"

@interface CoachManagerCenterController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,weak) IBOutlet UITableView *tableView;

// 获取今日课时
@property (strong, nonatomic) YGTeachingArchiveService *taTodayLessonService;

// 今日订单集合
@property (strong, nonatomic) NSMutableArray *taTodayModelList;

// YES 正在加载今日课程信息
@property (assign, nonatomic) BOOL isTodayLesssonLoading;

@end

@implementation CoachManagerCenterController
{
    BOOL btnAdded;
    UIButton *bgBtn;
    UIButton *button;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self refreshNum];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    ygweakify(self);
    [self.tableView setRefreshHeaderEnable:YES footerEnable:NO callback:^(YGRefreshType type) {
        ygstrongify(self);
        [self initData];
    }];
    
    self.navigationController.navigationItem.leftBarButtonItem.title = @"";
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = @"教练管理中心";
    [self initData];
}

- (void)refreshNum
{
    [self navButtonImage2:[UIImage imageNamed:@"ic_inform"] IconNum:(int)[LoginManager sharedManager].myDepositInfo.teachingMsgCount isRight:YES];
}

- (void)navButtonImage2:(UIImage *)image IconNum:(int)iconNum isRight:(BOOL)isRight
{
    CGSize sz = image.size;
    if (bgBtn == nil) {
        bgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        bgBtn.frame = CGRectMake(0, 0, sz.width, sz.height);
        [bgBtn setBackgroundImage:image forState:UIControlStateNormal];
        if (isRight) {
            [bgBtn addTarget:self action:@selector(doRightNavAction) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [bgBtn addTarget:self action:@selector(doLeftNavAction) forControlEvents:UIControlEventTouchUpInside];
        }
    }

    if (iconNum>0) {
        if (button == nil) {
            button = [UIButton buttonWithType:UIButtonTypeCustom];
            if (isRight) {
                button.frame = CGRectMake(sz.width-9, 0, 18, 18);
            }else{
                button.frame = CGRectMake(-9, 0, 18, 18);
            }
            
            button.backgroundColor = [UIColor redColor];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont systemFontOfSize:11]];
            button.enabled = NO;
            [Utilities drawView:button radius:CGRectGetHeight(button.bounds)/2 bordLineWidth:0 borderColor:nil];
            [bgBtn addSubview:button];
        }
        NSString *title = iconNum>99?@"99+":[@(iconNum) stringValue];
        CGRect frame = button.frame;
        if (title.length >= 3) {
            frame.size.width = 24.f;
        }else{
            frame.size.width = 18.f;
        }
        button.frame = frame;
        [button setTitle:title forState:UIControlStateNormal];
        
    }else{
        [button removeFromSuperview];
        button = nil;
    }
    
    if (btnAdded == NO) {
        [self rightButtonsView:bgBtn];
        btnAdded = YES;
    }
}

#pragma mark -
#pragma mark - 初始化数据

-(void) initData
{
    // 获取相关数据信息
    [self getData];
    
    // 获取今日课程信息
    [self initTodayLessonsData];
    
}

- (void)getData
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ServiceManager serviceManagerWithDelegate:self] getDepositInfo:[[LoginManager sharedManager] getSessionId] needCount:1];
    });
}

- (void)serviceResult:(ServiceManager*)serviceManager Data:(id)data flag:(NSString*)flag
{
    NSArray *array = [NSArray arrayWithArray:data];
    if (array && array.count>0) {
        if (Equal(flag, @"deposit_info")) {
            [LoginManager sharedManager].myDepositInfo = [array objectAtIndex:0];
            [LoginManager sharedManager].session.noDeposit = [LoginManager sharedManager].myDepositInfo.no_deposit;
            [LoginManager sharedManager].session.memberLevel = (int)[LoginManager sharedManager].myDepositInfo.memberLevel;
            [self refreshNum];
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
        }
    }
}

#pragma mark - 
#pragma mark - 获取今日课程信息数据

/**
 * 获取今日课程信息数据
 */
-(void) initTodayLessonsData
{
    if (self.isTodayLesssonLoading) {
        return;
    }
    
    self.isTodayLesssonLoading = YES;
    
    if (!self.taTodayModelList) {
        self.taTodayModelList = [NSMutableArray array];
    }
    
    if (!self.taTodayLessonService) {
        self.taTodayLessonService = [[YGTeachingArchiveService alloc] init];
    }

    ygweakify(self)
    [self.taTodayLessonService fetchTeachingCoachTodayPeriodList:^(YGTAResultModel *resultModel) {
        ygstrongify(self)
        self.isTodayLesssonLoading = NO;
        
        if (self.taTodayModelList && [self.taTodayModelList count] > 0) {
            [self.taTodayModelList removeAllObjects];
        }
        
        if (resultModel && resultModel.isSuccess) {

            NSMutableArray *teachingMemberClassList = resultModel.resultObj;
            if (teachingMemberClassList && [teachingMemberClassList isKindOfClass:[NSArray class]] && [teachingMemberClassList count] > 0) {
                [self.taTodayModelList addObjectsFromArray:teachingMemberClassList];
            }
            
        } else {
            [SVProgressHUD showErrorWithStatus:@"请求数据失败"];
        }
        
        [self.tableView reloadData];
        
    } failure:^(Error *error) {
        ygstrongify(self)
        self.isTodayLesssonLoading = NO;
        [SVProgressHUD showErrorWithStatus:@"请求数据失败"];

    }];
}

#pragma - mark  UITableView delegate && dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (self.taTodayModelList.count + 1);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 208.f;
        
    } else {
        
        YGMyTeachingArchiveViewModel *model = nil;
        if (self.taTodayModelList && self.taTodayModelList.count > 0 && self.taTodayModelList.count > (indexPath.row - 1)) {
            model = [self.taTodayModelList objectAtIndex:(indexPath.row - 1)];
        }
        
        return [model containerHeight];
        
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) { // 九宫格cell
        CoachSixViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CoachSixViewCell" forIndexPath:indexPath];
        if (cell.blockReturn == nil) {
            ygweakify(self)
            cell.blockReturn = ^(id data){
                ygstrongify(self)
                [self showMyScheduleTableViewController];
            };
        }
        return cell;
        
    } else {
        
        id model = nil;
        
        if (self.taTodayModelList && self.taTodayModelList.count > 0 && self.taTodayModelList.count > (indexPath.row - 1)) {
            model = [self.taTodayModelList objectAtIndex:(indexPath.row - 1)];
        }
        
        if ([model isKindOfClass:[YGMyTATitleViewModel class]]) { // 标题文字cell
            
            NSString *CustomCellIdentifier = [YGMyTeachingArchiveTitleViewCell getTableViewCellIdentifier];
            YGMyTeachingArchiveTitleViewCell *cell = (YGMyTeachingArchiveTitleViewCell *)[tableView dequeueReusableCellWithIdentifier: CustomCellIdentifier];
            if (cell == nil) {
                cell = [YGMyTeachingArchiveTitleViewCell shareViewCellWithOwner:self];
            }
            
            [cell configureWithEntity:model];
            
            return cell;
            
        } else if([model isKindOfClass:[YGMyTACourseViewModel class]]) { // 课时cell
            
            NSString *CustomCellIdentifier = [YGMyTeachingArchiveCourseViewCell getTableViewCellIdentifier];
            YGMyTeachingArchiveCourseViewCell *cell = (YGMyTeachingArchiveCourseViewCell *)[tableView dequeueReusableCellWithIdentifier: CustomCellIdentifier];
            if (cell == nil) {
                cell = [YGMyTeachingArchiveCourseViewCell shareViewCellWithOwner:self];
            }
            
            cell.viewCtrl = self;
            ygweakify(self)
            // 处理回调
            cell.taCourseCellOptBlock = ^(YGMyTACourseViewModel *viewModel) {
                ygstrongify(self)
                if (viewModel.optType == YGMyTACourseViewOptTypeConfirm) { // 确认操作
                    // 里面显示操作后的状态
                    [viewModel create:viewModel.isCoach];
                    [self.tableView reloadData];
                    // 处理加载数据
                    [self initData];
                }
            };
            
            // 刷新数据
            cell.taCourseCellRefreshBlock = ^(){
                ygstrongify(self)
                // 处理加载数据
                [self initData];
            };
            
            [cell configureWithEntity:model];
            
            return cell;
            
        } else if([model isKindOfClass:[YGMyTANoneDefaultViewModel class]]) { // 默认文字
            
            NSString *CustomCellIdentifier = [YGMyTANoneDefaultViewCell getTableViewCellIdentifier];
            YGMyTANoneDefaultViewCell *cell = (YGMyTANoneDefaultViewCell *)[tableView dequeueReusableCellWithIdentifier: CustomCellIdentifier];
            if (cell == nil) {
                cell = [YGMyTANoneDefaultViewCell shareViewCellWithOwner:self];
            }
            
            [cell configureWithEntity:model];
            
            return cell;
            
        } else { // 默认的cell信息
            
            NSString *CustomCellIdentifier = @"UITableViewCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CustomCellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CustomCellIdentifier];
            }
            return cell;
        }
    }
}

- (void)showMyScheduleTableViewController
{
    NSArray *timeSet = [LoginManager sharedManager].myDepositInfo.timeSet;
    
    int coachId = [LoginManager sharedManager].session.memberId;
    if (coachId > 0) {
        self.title = @"";
        if ((timeSet && timeSet.count > 0)) {
            [self pushWithStoryboard:@"Teach" title:@"时间表" identifier:@"TimetableViewController" hideBackButton:NO completion:^(BaseNavController *controller) {
                TimetableViewController *vc = (TimetableViewController *)controller;
                vc.coachId = coachId;
            }];
        }else{
            [self pushWithStoryboard:@"Teach" title:@"未设置预约时间" identifier:@"MyScheduleTableViewController" hideBackButton:NO completion:^(BaseNavController *controller) {
                MyScheduleTableViewController *vc = (MyScheduleTableViewController *)controller;
                vc.blockReturn = ^(id data){
                    [self.navigationController popToViewController:self animated:YES];
                };
                vc.timeSet = @[@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@1];
                vc.coachId = coachId;
            }];
        }
    }
}

- (void)doRightNavAction
{
//    [self pushWithStoryboard:@"Coach" title:@"通知" identifier:@"CoachNoticeController"];
    
    YGCoachNoticeViewCtrl *vc = [YGCoachNoticeViewCtrl instanceFromStoryboard];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)dealloc
{
    self.taTodayLessonService = nil;
    self.tableView = nil;
    self.taTodayModelList = nil;
    
}

@end
