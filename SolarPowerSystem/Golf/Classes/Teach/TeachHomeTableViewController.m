//
//  TeachHomeTableViewController.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/6.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "TeachHomeTableViewController.h"
#import "CityTitleView.h"
#import "SudokuTableViewCell.h"
#import "ThreeEntranceTableViewCell.h"
#import "ADBannerTableViewCell.h"
#import "CoachTableViewCell.h"
#import "LinqToObjectiveC.h"
#import "CourseDetailController.h"
#import "CoachTableViewController.h"
#import "PublicCourseHomeController.h"
#import "CityTableViewController.h"
#import "CCAlertView.h"
#import "ChooseCoachListController.h"
#import "CoachDetailsViewController.h"
#import "CourseSchoolTableViewController.h"
#import "UIView+AutoLayout.h"
#import "MyTeachInfoViewController.h"
#import "YGMyTeachingArchiveViewCtrl.h"

@interface TeachHomeTableViewController ()

@property (strong, nonatomic) CityTitleView *viewTitle; //导航标题控件
@property (strong, nonatomic) SearchCityModel *selectedCityModel; //城市列表中选中的城市modal
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnMyTeach;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

@end

@implementation TeachHomeTableViewController{
    NSMutableArray *arrSudoku;      //4个方格广告
    NSMutableArray *arrBanners;     //banner广告集合
    NSMutableArray *arrCoaches;     //教练列表
    int page;
    NSMutableArray *arrCities;
    int sortCondition;
}

- (void)toMyTeachInfoViewController{
    YGMyTeachingArchiveViewCtrl *vc = [YGMyTeachingArchiveViewCtrl instanceFromStoryboard];
    [self.navigationController pushViewController:vc animated:YES];
    
}


- (IBAction)showMyTeachViewController:(id)sender{
    
    [[BaiduMobStat defaultStat] logEvent:@"btnTeachingMyClass" eventLabel:@"我的教学按钮点击"];
    [MobClick event:@"btnTeachingMyClass" label:@"我的教学按钮点击"];
    
    if (![LoginManager sharedManager].loginState) {
        [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES blockRetrun:^(id da) {
            [self toMyTeachInfoViewController];
        }];
        return;
    }
    
    [self toMyTeachInfoViewController];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.defaultImage = [UIImage imageNamed:@"cgit_l"];
    
    [_tableView setContentInset:UIEdgeInsetsMake(-137, 0, 15, 0)];
    arrSudoku = [[NSMutableArray alloc] init];
    arrBanners = [[NSMutableArray alloc] init];
    arrCoaches = [[NSMutableArray alloc] init];
    
    page = 1;
    sortCondition = 0;
    
    ygweakify(self)
    //加载开通教学的城市列表数据
    arrCities = [NSMutableArray new];
    [CityTableViewController loadCitiesToArray:arrCities bySupportType:SupportCoachType success:^(id data) {
        ygstrongify(self)
        [self loadCityModel];   //加载之前定位的服务城市
        [self initTitleView];   //初始化教学标题栏
        [self changeCity];      //检测用户是否需要选择城市或者切换为当前城市
        [self getCoachListByPage];
    }];
    [self getActivityList]; //加载广告数据
    [[API shareInstance] statisticalWithBuriedpoint:5 Success:nil failure:nil];//埋点
}


//初始化标题视图
- (void)initTitleView{
    _viewTitle = [CityTitleView nibWithName:@"CityTitleView"];
    __weak CityTitleView *viewTitle = _viewTitle;
    __weak TeachHomeTableViewController *controller = self;
    
    //设定标题栏点击弹出城市列表
    _viewTitle.blockReturn = ^(id data){

        [controller performSegueWithIdentifier:@"CityTableViewController" sender:nil withBlock:^(id sender, id destinationVC) {
            CityTableViewController *vc = (CityTableViewController *)[destinationVC topViewController];
            vc.supportType = SupportCoachType;
            if (_selectedCityModel != nil) {
                vc.cityName = controller.selectedCityModel.cityName;
                [GolfAppDelegate shareAppDelegate].searchCityModel = controller.selectedCityModel;
            }
            //城市列表点击cell返回数据
            vc.blockReturn = ^(id data){
                page = 1;
                sortCondition = 0;
                if (data) {
                    _selectedCityModel = data;
                    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:K_SELECTED_CITY_MODEL];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    SearchCityModel *m = (SearchCityModel *)data;
                    [GolfAppDelegate shareAppDelegate].searchCityModel = m;
                    viewTitle.labelTitle.text = m.cityName; //返回城市modal后把title替换
                }else{
                    SearchCityModel *mm = [[SearchCityModel alloc] init];
                    mm.latitude = [LoginManager sharedManager].currLatitude;
                    mm.longitude = [LoginManager sharedManager].currLongitude;
                    mm.cityName = @"当前位置";
                    _selectedCityModel = mm;
                    [GolfAppDelegate shareAppDelegate].searchCityModel = controller.selectedCityModel;
                    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:mm] forKey:K_SELECTED_CITY_MODEL];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    viewTitle.labelTitle.text = @"当前位置";
                }
                [controller getCoachListByPage];
                [destinationVC dismissViewControllerAnimated:YES completion:^{
                    [controller.tableView setContentOffset:CGPointMake(0, -controller.tableView.contentInset.top) animated:YES];
                }];
            };
        }];
    };
    if (_selectedCityModel) {
        _viewTitle.labelTitle.text = _selectedCityModel.cityName;
    }
    _viewTitle.hidden = YES;
    
    self.navigationItem.titleView = _viewTitle;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _viewTitle.hidden = NO;
        [_viewTitle show];
    });
}


//检查是否需要提示用户切换城市，如果当前定位失败或者现在定位和之前城市不一样就提示用户，如果用户取消切换一天以后进入再次提示用户更换城市
- (void)changeCity{
    if (_selectedCityModel == nil) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_viewTitle showCityList:nil];
        });
        [GolfAppDelegate shareAppDelegate].searchCityModel = nil;
    }else if(_selectedCityModel != nil && _selectedCityModel.cityId != 0) { //如果是当前位置就不提示切换
        [GolfAppDelegate shareAppDelegate].searchCityModel = _selectedCityModel;
        NSDate *date = [NSDate date];
        NSDate *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:K_LAST_CANCEL_DATE];
        NSInteger count = 0;
        BOOL show = NO;
        if (lastDate) {
            count = [Utilities numDayWithBeginDate:lastDate endDate:date]; //如果上一次取消的时间距离现在已经超过一天了就重新提示用户切换
            show = count >= 1;
        }else{
            show = YES;
        }
        
        SearchCityModel *scm = [self inCityList];
        
        if (scm != nil && _selectedCityModel.cityId != scm.cityId && show == YES) {
            CCAlertView *alert = [[CCAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"是否将城市切换到你当前所在的城市：%@",scm.cityName]];
            [alert addButtonWithTitle:@"取消" block:^{
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:K_LAST_CANCEL_DATE];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }];
            [alert addButtonWithTitle:@"切换" block:^{
                _selectedCityModel = scm;
                [GolfAppDelegate shareAppDelegate].searchCityModel = _selectedCityModel;
                [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:scm] forKey:K_SELECTED_CITY_MODEL];
                [[NSUserDefaults standardUserDefaults] synchronize];
                _viewTitle.labelTitle.text = scm.cityName; //返回城市modal后把title替换
                page = 1;
                [self getCoachListByPage];
            }];
            [alert show];
        }
    }
}


#pragma mark - 业务逻辑

//检测当前用户所在地经纬度的城市是否涵盖在开通城市列表中
- (SearchCityModel *)inCityList{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (SearchCityModel *m in arrCities) {
        NSCoor c1 = NSCoorMake([LoginManager sharedManager].currLatitude, [LoginManager sharedManager].currLongitude);
        NSCoor c2 = NSCoorMake(m.latitude, m.longitude);
        double distance = distanceBetween(c1, c2)/1000.f;
        if (distance <= 150) {
            [arr addObject:@{[NSString stringWithFormat:@"%f",distance]:m}];
        }
    }
    if (arr.count > 0) {
        NSArray *sort = [arr linq_sort:^id(id item) {
            NSArray *kyes = [item allKeys];
            return [kyes firstObject];
        }];
        return [[[sort lastObject] allValues] firstObject];
    }
    return nil;
}

//加载存储在磁盘的城市数据，如果没有加载成功则根据当前经纬度计算城市是否包含在开通服务的城市列表中
- (void)loadCityModel{
    NSData *storeCityModel = [[NSUserDefaults standardUserDefaults] valueForKey:K_SELECTED_CITY_MODEL];
    if (storeCityModel) {
        _selectedCityModel = [NSKeyedUnarchiver unarchiveObjectWithData:storeCityModel];
        [GolfAppDelegate shareAppDelegate].searchCityModel = _selectedCityModel;
    }else{
        _selectedCityModel = [self inCityList];
        [GolfAppDelegate shareAppDelegate].searchCityModel = _selectedCityModel;
        if (_selectedCityModel) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_selectedCityModel] forKey:K_SELECTED_CITY_MODEL];
        }
    }
}


//加载教练分页数据
- (void)getCoachListByPage{
    [[ServiceManager serviceManagerWithDelegate:self] getCoachListByPageNo:page
                                                                  pageSize:15
                                                             withLongitude:[LoginManager sharedManager].currLongitude
                                                                  latitude:[LoginManager sharedManager].currLatitude
                                                                    cityId:(_selectedCityModel == nil ? 0:_selectedCityModel.cityId)
                                                                   orderBy:sortCondition
                                                                      date:nil
                                                                      time:nil
                                                                   keyword:nil
                                                                 academyId:0 productId:0];
}

//加载活动广告数据
- (void)getActivityList{
    [[ServiceManager serviceManagerWithDelegate:self] getActivityListByLongitude:[LoginManager sharedManager].currLongitude
                                                                            latitude:[LoginManager sharedManager].currLatitude
                                                                             putArea:2
                                                                          resolution:1 needGroup:NO preventError:NO];
}

- (void)serviceResult:(ServiceManager*)serviceManager Data:(id)data flag:(NSString*)flag{
    NSArray *arr = (NSArray*)data;
        
    if (Equal(flag, @"teaching_coach_info")) {
        if (page == 1) {
            [arrCoaches removeAllObjects];
        }
        if (arr && arr.count > 0) {
            [arrCoaches addObjectsFromArray:arr];
        }
    }else if (Equal(flag, @"activity_list")) {
        arrSudoku = [[NSMutableArray alloc] initWithArray:[arr linq_where:^BOOL(id item) {
            ActivityModel *m = (ActivityModel *)item;
            return m.areaShape == 2;
        }]];
        arrBanners = [[NSMutableArray alloc] initWithArray:[arr linq_where:^BOOL(id item) {
            ActivityModel *m = (ActivityModel *)item;
            return m.areaShape == 1;
        }]];
    }
    [self.tableView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_loadingView) {
            [_loadingView removeFromSuperview];
        }
        self.tableView.hidden = NO;
    });
}


#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            ThreeEntranceTableViewCell *cell = (ThreeEntranceTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ThreeEntranceTableViewCell" forIndexPath:indexPath];
            if (cell.blockReturn == nil) {
                cell.blockReturn = ^(id data){
                    NSInteger index = [data integerValue];
                    switch (index) {
                        case 0:
                        {
                            [[BaiduMobStat defaultStat] logEvent:@"btnTeachingCoach" eventLabel:@"教练按钮点击"];
                            [MobClick event:@"btnTeachingCoach" label:@"教练按钮点击"];
                            [self pushWithStoryboard:@"Teach" title:@"教练列表" identifier:@"CoachTableViewController" completion:^(BaseNavController *controller) {
                                CoachTableViewController *vc = (CoachTableViewController*)controller;
                                vc.datas = [[NSMutableArray alloc] initWithArray:arrCoaches];
                                vc.useControls = YES;
                                vc.hasSearchButton = YES;
                                vc.selectedCityModel = _selectedCityModel;
                            }];
                        }
                            break;
                        case 1:
                        {
                            [self pushWithStoryboard:@"Teach" title:@"学院" identifier:@"CourseSchoolTableViewController" completion:^(BaseNavController *controller) {
                                CourseSchoolTableViewController *vc = (CourseSchoolTableViewController*)controller;
                                vc.cityId = (_selectedCityModel == nil ? 0:_selectedCityModel.cityId);
                                vc.hasSearchButton = YES;
                            }];
                        }
                            break;
                        case 2:
                        {
                            [self pushWithStoryboard:@"Jiaoxue" title:@"公开课" identifier:@"PublicCourseHomeController" completion:^(BaseNavController *controller) {
                                PublicCourseHomeController *course = (PublicCourseHomeController*)controller;
                                course.cityId = (_selectedCityModel == nil ? 0:_selectedCityModel.cityId);
                            }];
                        }
                            break;
                            
                        default:
                            break;
                    }
                    
                };
            }
            
            return cell;
        }
            break;
        case 1:
        {
            SudokuTableViewCell *cell = (SudokuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:(arrSudoku.count >= 3 ? @"SudokuTableViewCell4":@"SudokuTableViewCell2") forIndexPath:indexPath];
            [cell loadDatas:arrSudoku];
            if (cell.blockReturn == nil) {
                cell.blockReturn = ^(id data){
                    NSInteger index = [data integerValue];
                    ActivityModel *m = arrSudoku[index];
                    YGPostBuriedPoint(YGTeachPointH5Lessons);
                    // 数据上报点
                    NSString *ID = [NSString stringWithFormat:@"btnTeachingBanner%tu",index];
                    [[BaiduMobStat defaultStat] logEvent:ID eventLabel:@"教学banner按钮"];
                    [MobClick event:ID label:@"教学banner按钮"];
                    NSDictionary *dic = @{@"data_type":m.dataType,
                                          @"data_id":@(m.dataId),
                                          @"data_model":m,
                                          @"sub_type":@(m.subType),
                                          @"data_extra":m.activityPage
                                          };
                    [[GolfAppDelegate shareAppDelegate] handlePushControllerWithData:dic];
                };
            }
            
            return cell;
        }
            break;
            
        case 2:
        {
            NSString *identifier = @"ADBannerTableViewCellFirst";
            
            switch (arrBanners.count) {
                case 1:
                    identifier = @"ADBannerTableViewCellMiddle";
                    break;
                case 2:
                {
                    switch (indexPath.row) {
                        case 0:
                            identifier = @"ADBannerTableViewCellFirst";
                            break;
                        case 1:
                            identifier = @"ADBannerTableViewCellMiddle";
                            break;
                        default:
                            break;
                    }
                }
                    break;
                default:
                {
                    if (indexPath.row == 0) {
                        identifier = @"ADBannerTableViewCellFirst";
                    }else if (indexPath.row == arrBanners.count -1) {
                         identifier = @"ADBannerTableViewCellLast";
                    }else{
                        identifier = @"ADBannerTableViewCellMiddle";
                    }
                }
                    break;
            }
            ActivityModel *m = arrBanners[indexPath.row];
            ADBannerTableViewCell *cell = (ADBannerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
            [Utilities loadImageWithURL:[NSURL URLWithString:m.activityPicture] inImageView:cell.imgBanner placeholderImage:self.defaultImage];
            cell.activityModel = m;
            if (cell.blockReturn == nil) {
                cell.blockReturn = ^(id data){
                    ActivityModel *m = (ActivityModel *)data;
                    
                    // 数据上报点
                    YGPostBuriedPoint(YGTeachPointH5Lessons);
                    NSString *ID = [NSString stringWithFormat:@"btnTeachingBanner%tu",indexPath.row+4];
                    [[BaiduMobStat defaultStat] logEvent:ID eventLabel:@"教学banner按钮"];
                    [MobClick event:ID label:@"教学banner按钮"];
                    NSDictionary *dic = @{@"data_type":m.dataType,
                                          @"data_id":@(m.dataId),
                                          @"data_model":m,
                                          @"sub_type":@(m.subType),
                                          @"data_extra":m.dataExtra
                                          };
                    [[GolfAppDelegate shareAppDelegate] handlePushControllerWithData:dic];
                };
            }
            return cell;
        }
            break;
            
        case 3:
        {
            if (arrCoaches.count > 0) {
                if (indexPath.row == 0) {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecommendCell" forIndexPath:indexPath];
                    [cell setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
                    return cell;
                }
                
                if (indexPath.row <= arrCoaches.count) {
                    TeachingCoachModel *tcm = arrCoaches[indexPath.row -1];
                    CoachTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CoachTableViewCell" forIndexPath:indexPath];
                    [cell loadData:tcm];
                    return cell;
                }else{
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MoreCell" forIndexPath:indexPath];
                    return cell;
                }
            }
        }
            break;
            
        default:
            break;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self sectionCount];
}

//计算section数量
- (NSInteger)sectionCount{
    return 4;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return arrSudoku.count > 0 ? 1:0;
            break;
        case 2:
            return arrBanners.count;
            break;
        case 3:
            return arrCoaches.count + (arrCoaches.count > 0 ? 2:0);
            break;
        default:
            break;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = [UIColor colorWithHexString:@"#f1f0f6"];
    return v;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 0;
            break;
        case 1:
            return arrSudoku.count > 0 ? 10:0;
            break;
        case 2:
            return arrBanners.count > 0 ? 10:0;
            break;
        case 3:
            return arrCoaches.count > 0 ? 10:0;
            break;
        default:
            return 0;
            break;
    }
    return 0;
}


#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //教练有数据并且属于，最后一个section，并且当前是加载的第一页
    if (arrCoaches.count > 0 && indexPath.section == ([self sectionCount] -1) && page == 1) {
        page = 2;
        [self getCoachListByPage];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (arrCoaches.count > 0 && indexPath.section == ([self sectionCount] - 1)) { //当前属于教练列表中
        if (indexPath.row == 0 || indexPath.row == arrCoaches.count + 1) { //推荐教练这一行cell or 加载更多这一行cell
            [self pushWithStoryboard:@"Teach" title:@"教练列表" identifier:@"CoachTableViewController" completion:^(BaseNavController *controller) {
                CoachTableViewController *vc = (CoachTableViewController*)controller;
                vc.selectedCityModel = _selectedCityModel;
                vc.useControls = YES;
                vc.hasSearchButton = YES;
                vc.datas = [[NSMutableArray alloc] initWithArray:arrCoaches];
            }];
        }else{
            [self pushWithStoryboard:@"Teach" title:@"教练详情" identifier:@"CoachDetailsViewController" completion:^(BaseNavController *controller) {
                CoachDetailsViewController *vc = (CoachDetailsViewController *)controller;
                TeachingCoachModel *m = arrCoaches[indexPath.row - 1];
                vc.coachId = m.coachId;
            }];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            return 144;
            break;
        case 1:
            if (arrSudoku.count > 4) {
                return Device_Width;
            }
            switch (arrSudoku.count) {
                case 0:
                    return 0; //没有广告就不显示
                    break;
                case 1:
                case 2:
                    return Device_Width / 2;  //2个以内显示一行
                    break;
                case 3:
                case 4:
                    return Device_Width;  // 3个以上显示两行
                    break;
                default:
                    break;
            }
            break;
        case 2:
        {
            
            switch (arrBanners.count) {
                case 1:
                    return 191;
                    break;
                case 2:
                {
                    switch (indexPath.row) {
                        case 0:
                            return 176;
                            break;
                        case 1:
                            return 191;
                            break;
                        default:
                            break;
                    }
                }
                    break;
                default:
                {
                    if (indexPath.row == 0) {
                        return 176;
                    }else if (indexPath.row == arrBanners.count - 1) {
                        return 176;
                    }else{
                        return 191;
                    }

                }
                    break;
            }
            return 176;
            
        }
            break;
        case 3:
        {
            if (indexPath.row == 0 || indexPath.row == arrCoaches.count + 1) {
                return 40;
            }
            return 93;
        }
            break;
        default:
            break;
    }
    return 0;
}

@end
