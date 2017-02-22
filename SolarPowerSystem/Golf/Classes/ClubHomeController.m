//
//  ClubHomeController.m
//  Golf
//
//  Created by 黄希望 on 15/10/12.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "ClubHomeController.h"
#import "ClubRushPurchaseCell_Now.h"
#import "ClubRushPurchaseCell_Will.h"
#import "UIView+AutoLayout.h"
#import "SpreeUpdateCell.h"
#import "ClubListViewController.h"
#import "SearchClubViewController.h"
#import "SelectedCitysController.h"
#import "ClubMainViewController.h"
#import "ClubScrollImageCell.h"
#import "SpecialPackageCell.h"
#import "ClubHotCitiesCell.h"
#import "TwoLabelsCell.h"
#import "TabbarChangeView.h"
#import "YGPackageIndexViewCtrl.h"
#import "SpecialOfferListViewController.h"

@interface ClubHomeController ()<UITableViewDelegate,UITableViewDataSource>{
    NSInteger _spreeType; // 抢购类型 1：正在抢购 2: 即将抢购
    NSInteger _pageNo;
    NSInteger _pageSize;
    BOOL _dataLoadOver; // 数据是否加载完毕
}

@property (nonatomic,weak) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *spreeTimeArr;
@property (nonatomic,strong) NSMutableArray *activityArr;
@property (nonatomic,strong) NSMutableArray *hotCityArr;
@property (nonatomic,strong) NSArray *callList;

@property (nonatomic,strong) ConditionModel *cm;
@property (nonatomic,assign) BOOL reload;//标记是否重新加载顶部banner

@end

@implementation ClubHomeController{

    TabbarChangeView *tabbarView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化界面
    [self initNIB];
    
    // 初始化数据
    [self initCM];
    
    // 调用接口
    [self getDataFromServer];
    
    [[API shareInstance] statisticalWithBuriedpoint:3 Success:nil failure:nil];//埋点
}

- (void)initNIB
{
    
    self.tableView.backgroundColor = [UIColor clearColor];
    ygweakify(self);
    [self.tableView setRefreshHeaderEnable:YES footerEnable:NO callback:^(YGRefreshType type) {
        ygstrongify(self);
        [self getFistClubSpreeTimeList];
    }];
    
    tabbarView = [[[NSBundle mainBundle] loadNibNamed:@"TabbarChangeView" owner:self options:nil] lastObject];
    [tabbarView.btn1 setTitle:@"限时抢购" forState:(UIControlStateNormal)];
    [tabbarView.btn1 setTitle:@"限时抢购" forState:(UIControlStateHighlighted)];
    [tabbarView.btn1 setTitle:@"限时抢购" forState:UIControlStateSelected];
    
    [tabbarView.btn2 setTitle:@"即将抢购" forState:(UIControlStateNormal)];
    [tabbarView.btn2 setTitle:@"即将抢购" forState:(UIControlStateHighlighted)];
    [tabbarView.btn2 setTitle:@"即将抢购" forState:UIControlStateSelected];

    tabbarView.clickBlock = ^(id data){
        ygstrongify(self);
        if (!self) return;
        
        NSInteger index = [data integerValue];
        if (self->_spreeType != index) {
            self->_spreeType = index;
            [self getFistClubSpreeTimeList];
        }
    };
}

// 创建共享数据
- (void)initCM{
    // 数据源
    self.spreeTimeArr = [NSMutableArray array];
    self.activityArr = [NSMutableArray array];
    self.hotCityArr = [NSMutableArray array];
    _spreeType = 1;
    _pageNo = 1;
    _pageSize = 20;
    
    _cm = [[ConditionModel alloc] init];
    _cm.price = 0;
    _cm.people = 0;
    _cm.cityId = 0;
    _cm.provinceId = 0;
    _cm.clubName = @"";
    _cm.cityName = @"当前位置";
    
    NSDate *tomorrow = [Utilities getTheDay:[NSDate date] withNumberOfDays:1];
    tomorrow = [Utilities changeDateWithDate:tomorrow];
    [[NSUserDefaults standardUserDefaults] setObject:tomorrow forKey:@"tomorrow"];
    _cm.date = [Utilities stringwithDate:tomorrow];
    
    NSDate *tom = [Utilities changeDateWithDate:[Utilities getTheDay:[NSDate date] withNumberOfDays:1]];
    if ([tomorrow timeIntervalSinceDate:tom] != 0) {
        _cm.date = [Utilities stringwithDate:tom];
    }
    _cm.time = @"07:30";
    
    // 抢购提醒列表
    self.callList = [[NSUserDefaults standardUserDefaults] objectForKey:@"ClubCallSetting"];
}

- (void)getDataFromServer{
    // 获取系统时间
    [self getSystemTime];
    
    // 获取活动列表
    [[ServiceManager serviceManagerWithDelegate:self] getActivityListByLongitude:[LoginManager sharedManager].currLongitude
                                                                        latitude:[LoginManager sharedManager].currLatitude
                                                                         putArea:4
                                                                      resolution:1 needGroup:NO preventError:NO];
    // 获取热门城市
    [self getHotCityList];
    
    // 获取抢购列表
    [self getClubSpreeTimeList];
}

- (void)getSystemTime{
    if ([LoginManager sharedManager].timeInterGab == KDefaultTimeInterGab) {
        [ServerService getServerTimeWithSuccess:^(NSTimeInterval timeInterval) {
            [LoginManager sharedManager].timeInterGab = timeInterval;
        } failure:nil];
    }
}

- (void)getFistClubSpreeTimeList{
    _pageNo = 1;
    [self getClubSpreeTimeList];
}

// 获取抢购列表
- (void)getClubSpreeTimeList{
    [ServerService getClubSpreeListWithSpreeType:_spreeType spreeId:0 pageNo:_pageNo pageSize:_pageSize longitude:[LoginManager sharedManager].currLongitude latitude:[LoginManager sharedManager].currLatitude success:^(NSArray *list) {
        if (_pageNo == 1) {
            [self.spreeTimeArr removeAllObjects];
        }
        for (ClubSpreeModel *csm in list) {
            if ([_callList containsObject:@(csm.spreeId)]) {
                csm.hasSetted = YES;
            }
            [self.spreeTimeArr addObject:csm];
        }
        [self.tableView.mj_header endRefreshing];
        if (list.count < _pageSize) {
            _dataLoadOver = YES;
        }
        self.reload = YES;
        [self.tableView reloadData];
        [self.tableView layoutIfNeeded]; //layoutIfNeeded会强制重绘并等待完成。 http://blog.csdn.net/cuibo1123/article/details/48558213  这个是为了让tableview刷新，然后在self.reload = no
        _pageNo ++;
        self.reload = NO;
    } failure:^(id error) {
        self.reload = NO;
    }];
}

- (void)getHotCityList{
    [ServerService getCityListWithHotCity:1 success:^(NSArray *list) {
        [self.hotCityArr removeAllObjects];
        [self.hotCityArr addObjectsFromArray:list];
        self.reload = YES;
        [self.tableView reloadData];
        [self.tableView layoutIfNeeded];
        self.reload = NO;
    } failure:^(id error) {
    }];
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *arr = (NSArray*)data;
    if (Equal(flag, @"activity_list")) {
        [self.activityArr removeAllObjects];
        [self.activityArr addObjectsFromArray:arr];
        self.reload = YES;
        [self.tableView reloadData];
        [self.tableView layoutIfNeeded];
        self.reload = NO;
    }
}

 

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (tabbarView && scrollView.contentOffset.y >= 384) {
        [tabbarView changeBlur:YES];
    }else{
        [tabbarView changeBlur:NO];
    }
}


#pragma mark - UITableView delegate && datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 7;
    }else{
        return _dataLoadOver == YES ? self.spreeTimeArr.count+2:self.spreeTimeArr.count+1;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            ClubScrollImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClubScrollImageCell" forIndexPath:indexPath];
            [cell setDatas:_activityArr reload:self.reload];
            if (cell.checkNearbyBlock == nil) {
                ygweakify(self);
                cell.checkNearbyBlock = ^(id data){
                    ygstrongify(self);
                    ClubListViewController *vc = [ClubListViewController instanceFromStoryboard];
                    vc.cm = [_cm copy];
                    [self pushViewController:vc title:@"" hide:YES];
                };
            }
            
            return cell;
        }else if (indexPath.row == 2){
            return [tableView dequeueReusableCellWithIdentifier:@"TwoLabelsCell" forIndexPath:indexPath];
        }else if (indexPath.row == 3){
            ClubHotCitiesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClubHotCitiesCell" forIndexPath:indexPath];
            [cell loadHotCities:self.hotCityArr reload:self.reload];
            if (cell.hotCityBlock == nil) {
                ygweakify(self);
                cell.hotCityBlock = ^(SearchCityModel *data){
                    ygstrongify(self);
                    if (data) {
                        int cityId = data.cityId;
                        for (SearchCityModel *scm in _hotCityArr) {
                            if (scm.cityId == cityId) {
                                ClubListViewController *vc = [ClubListViewController instanceFromStoryboard];
                                vc.cm = [_cm copy];
                                vc.cm.cityId = cityId;
                                vc.cm.cityName = scm.cityName;
                                [self pushViewController:vc title:@"" hide:YES];
                                break;
                            }
                        }
                    }
                };
            }
            return cell;
        }else if (indexPath.row == 5){
            SpecialPackageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SpecialPackageCell" forIndexPath:indexPath];
            if (cell.clickBlock == nil) {
                cell.clickBlock = ^(id data){
                    int index = [data intValue];
                    if (index == 1) {
                        // 特价时段
                        SpecialOfferListViewController *specialOfferList = [[SpecialOfferListViewController alloc] init];
                        specialOfferList.myCondition = [_cm copy];
                        [self pushViewController:specialOfferList title:@"特价时段" hide:YES];
                    }else{
                        // 精选套餐
                        YGPackageIndexViewCtrl *vc = [YGPackageIndexViewCtrl instanceFromStoryboard];
                        [self pushViewController:vc title:@"旅行套餐" hide:YES];
                    }
                };
            }
            
            return cell;
        }else{
            return [tableView dequeueReusableCellWithIdentifier:@"ClubHomeGab" forIndexPath:indexPath];
        }
    }else{
        if (_spreeType == 1) {
            if (indexPath.row == self.spreeTimeArr.count+1) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DATA_LOAD_OVER" forIndexPath:indexPath];
                if (self.spreeTimeArr.count == 0) {
                    cell.textLabel.text = @"暂无抢购数据";
                }else{
                    cell.textLabel.text = @"数据已加载完毕";
                }
                return cell;
            }
            if (indexPath.row == 0) {
                SpreeUpdateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SpreeUpdateCell" forIndexPath:indexPath];
                cell.noteLabel.text = [GolfAppDelegate shareAppDelegate].systemParamInfo.spreeNote;
                return cell;
            }
            ClubRushPurchaseCell_Now *cell = [tableView dequeueReusableCellWithIdentifier:@"ClubRushPurchaseCell_Now" forIndexPath:indexPath];
            if (indexPath.row - 1 < self.spreeTimeArr.count) {
                cell.csm = self.spreeTimeArr[indexPath.row-1];
            }
            if (cell.spreeBlock == nil) {
                ygweakify(self);
//                ygweakify(_cm);
                __weak ConditionModel *cm = _cm;
                cell.spreeBlock = ^(id data){
                    ygstrongify(self);
//                    ygstrongify(_cm);
                    ClubSpreeModel *csm = (ClubSpreeModel*)data;
                    ClubMainViewController *vc = [ClubMainViewController instanceFromStoryboard];
                    vc.rush = YES;
                    vc.cm = [cm copy];
                    vc.cm.clubId = csm.clubId;
                    vc.csm = csm;
                    vc.agentId = -1;
                    vc.callRefreshBlock = ^(id data){
                        ygstrongify(self);
                        NSArray *arr = (NSArray*)data;
                        self.callList = [NSArray arrayWithArray:arr];
                        [_tableView reloadData];
                    };
                    [self pushViewController:vc title:@"抢购详情" hide:YES];
                };
            }
           
            return cell;
        }else{
            if (indexPath.row == self.spreeTimeArr.count+1) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DATA_LOAD_OVER" forIndexPath:indexPath];
                if (self.spreeTimeArr.count == 0) {
                    cell.textLabel.text = @"暂无抢购数据";
                }else{
                    cell.textLabel.text = @"数据已加载完毕";
                }
                return cell;
            }
            if (indexPath.row == 0) {
                SpreeUpdateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SpreeUpdateCell" forIndexPath:indexPath];
                cell.noteLabel.text = [GolfAppDelegate shareAppDelegate].systemParamInfo.spreeNote;
                return cell;
            }
            ClubRushPurchaseCell_Will *cell = [tableView dequeueReusableCellWithIdentifier:@"ClubRushPurchaseCell_Will" forIndexPath:indexPath];
            cell.callList = _callList;
            if (indexPath.row-1<self.spreeTimeArr.count) {
                cell.csm = self.spreeTimeArr[indexPath.row-1];
            }
            if (cell.spreeBlock == nil) {
                ygweakify(self);
                cell.spreeBlock = ^(id data){
                    ygstrongify(self);
                    ClubSpreeModel *csm = (ClubSpreeModel*)data;
                    ClubMainViewController *vc = [ClubMainViewController instanceFromStoryboard];
                    vc.rush = YES;
                    vc.cm = [_cm copy];
                    vc.cm.clubId = csm.clubId;
                    vc.csm = csm;
                    vc.agentId = -1;
                    vc.callRefreshBlock = ^(id data){
                        ygstrongify(self);
                        NSArray *arr = (NSArray*)data;
                        self.callList = [NSArray arrayWithArray:arr];
                        [_tableView reloadData];
                    };
                    [self pushViewController:vc title:@"抢购详情" hide:YES];
                };
            }
            if (cell.callBlock == nil) {
                ygweakify(self);
                cell.callBlock = ^(id data){
                    ygstrongify(self);
                    ClubSpreeModel *csm = (ClubSpreeModel*)data;
                    if (csm.hasSetted) {
                        [self addCallNum:csm.spreeId];
                        [self.tableView reloadData];
                        [self createLocalNotification:csm];
                    }else{
                        [self deleteCallNum:csm.spreeId];
                        [self.tableView reloadData];
                        [self cancelLocalNotification:csm];
                    }
                };
            }
            
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 2) {
            SelectedCitysController *vc = [SelectedCitysController instanceFromStoryboard];
            vc.hotCityArr = _hotCityArr;
            vc.cm = [_cm copy];
            [self pushViewController:vc title:@"" hide:YES];
        }
    }else{
        if (indexPath.row-1<self.spreeTimeArr.count) {
            ClubSpreeModel *csm = self.spreeTimeArr[indexPath.row-1];
            ClubMainViewController *vc = [ClubMainViewController instanceFromStoryboard];
            vc.rush = YES;
            vc.cm = [_cm copy];
            vc.cm.clubId = csm.clubId;
            vc.csm = csm;
            vc.agentId = -1;
            vc.callRefreshBlock = ^(id data){
                NSArray *arr = (NSArray*)data;
                self.callList = [NSArray arrayWithArray:arr];
                [_tableView reloadData];
            };
            [self pushViewController:vc title:@"抢购详情" hide:YES];
        }
    }
}

#pragma mark - 本地通知相关
- (void)addCallNum:(int)spreeId{ // 增加设置提醒的个数
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSArray *array = [userDefault objectForKey:@"ClubCallSetting"];
    NSMutableArray *mutArray = nil;
    if (array && array.count > 0) {
        mutArray = [NSMutableArray arrayWithArray:array];
        [mutArray addObject:@(spreeId)];
    }else{
        mutArray = [NSMutableArray arrayWithObject:@(spreeId)];
    }
    self.callList = [NSArray arrayWithArray:mutArray];
    [userDefault setObject:mutArray forKey:@"ClubCallSetting"];
    [SVProgressHUD showSuccessWithStatus:@"设置成功，开抢前10分钟会提醒您"];
}

- (void)deleteCallNum:(int)spreeId{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSArray *array = [userDefault objectForKey:@"ClubCallSetting"];
    
    if ([array containsObject:@(spreeId)]) {
        NSMutableArray *mt = [NSMutableArray arrayWithArray:array];
        [mt removeObject:@(spreeId)];
        self.callList = [NSArray arrayWithArray:mt];
        [userDefault setObject:mt forKey:@"ClubCallSetting"];
    }
    [SVProgressHUD showInfoWithStatus:@"已取消提醒"];
}

- (void)createLocalNotification:(ClubSpreeModel*)csm{
    UILocalNotification *newNotification = [[UILocalNotification alloc] init];
    if (newNotification) {
        newNotification.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        NSDate *fireDate = [[Utilities getDateFromString:csm.spreeTime WithFormatter:@"yyyy-MM-dd HH:mm:ss"]dateByAddingTimeInterval:-600];
        newNotification.fireDate = fireDate;
        newNotification.alertBody = @"您关注的球场即将开抢了，赶紧去抢购吧！";
        newNotification.applicationIconBadgeNumber += 1;
        newNotification.soundName = UILocalNotificationDefaultSoundName;
        newNotification.repeatInterval = 0;
        
        NSDictionary *infoDic = @{@"spree_id":@(csm.spreeId),@"club_id":@(csm.clubId),@"call_type":@"club"};
        newNotification.userInfo = infoDic;
        
        UIApplication *app = [UIApplication sharedApplication];
        [app scheduleLocalNotification:newNotification];
    }
}

- (void)cancelLocalNotification:(ClubSpreeModel*)csm{
    NSArray *narry=[[UIApplication sharedApplication] scheduledLocalNotifications];
    if (narry.count > 0) {
        for (int i=0; i<narry.count; i++) {
            UILocalNotification *localNotification = [narry objectAtIndex:i];
            NSDictionary *userInfo = localNotification.userInfo;
            if (Equal(@"club", userInfo[@"call_type"])) {
                if ([userInfo[@"spree_id"] intValue] == csm.spreeId) {
                    UIApplication *app = [UIApplication sharedApplication];
                    [app cancelLocalNotification:localNotification];
                }
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 190;
        }else if (indexPath.row == 2){
            return 40;
        }else if (indexPath.row == 3){
            return 88;
        }else if (indexPath.row == 5){
            return 80;
        }else{
            return 10;
        }
    }else{
        if (_dataLoadOver && self.spreeTimeArr.count+1 == indexPath.row) {
            return 44;
        }
        if (indexPath.row == 0) {
            CGSize sz = [Utilities getSize:[GolfAppDelegate shareAppDelegate].systemParamInfo.spreeNote withFont:[UIFont systemFontOfSize:12] withWidth:Device_Width];
            return sz.height + 15;
        }
        return 140;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0 ? 0 : 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return nil;
    }
    return tabbarView;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == _spreeTimeArr.count && _dataLoadOver == NO && _spreeTimeArr.count>0) {
        [self getClubSpreeTimeList];
    }
}

// 搜索球场
- (IBAction)searchClubAction:(id)sender{
    SearchClubViewController *vc = [SearchClubViewController instanceFromStoryboard];
    _cm.clubName = @"";
    vc.cm = _cm;
    [self pushViewController:vc title:@"" hide:YES];
}

@end
