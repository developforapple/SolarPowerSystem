//
//  IndexViewController.m
//  Golf
//
//  Created by Main on 16/7/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "IndexViewController.h"
#import "YGRefreshComponent.h"
#import "KDCycleBannerViewCell.h"
#import "ThreeActionTableViewCell.h"
#import "LunboTableViewCell.h"
#import "ScrollTeachTableViewCell.h"
#import "GolfHeadlineTableViewCell.h"
#import "YGYueduCell.h"
#import "ClubMainViewController.h"

#import "YGSearchViewCtrl.h"
#import "CustomerServiceViewCtrl.h"
#import "YGWebBrowser.h"
#import "TeachHomeTableViewController.h"
#import "YGYueduMainViewCtrl.h"
#import "ClubMainViewController.h"
#import "ClubListViewController.h"
#import "YGMallHotSellListViewCtrl.h"
#import "AdvertisementView.h"

#import "NewPeopleEnjoyViewController.h"
#import "HomeCoverView.h"
#import "EAIntroView.h"
#import "YGYueduVideoHelper.h"
#import "YGYueduVideoCell.h"
#import "YGGlobalSearchBar.h"

#import "YGMallViewCtrl.h"

#import "IndexViewController+VersionUpdates.h"
#import "IndexViewController+AppEvaluate.h"//app评价弹窗

#import "YGMallFlashSaleCell.h"
#import "YGIndexMallCell.h"
#import "ActivityModel.h"
#import <CoreLocation/CoreLocation.h>
#import "YGIndexCourseListCell.h"
#import "YGPackageIndexViewCtrl.h"
#import "YGThriftRequestManager.h"

static int lockAdvertisement = 1;

@interface IndexViewController ()<UITableViewDelegate,UITableViewDataSource,ServiceManagerDelegate,EAIntroDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UIView *naviTitleView;
@property (weak, nonatomic) IBOutlet YGGlobalSearchBar *titleSearchBar;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSArray *locationSuccessBannerArr;//定位成功的banner数据
@property (nonatomic,strong) NSArray *locationFailurBannerArr;//定位失败的banner数据
@property (nonatomic,strong) HeadLineList *headlineTopList;
@property (nonatomic,strong) HeadLineList *headLineList;
@property (nonatomic,strong) TeachActivityList *teachActivityList;
@property (nonatomic,strong) ThemeCommodityList *themeCommodityList;
@property (nonatomic,strong) HotCourseList *locationFailueHotCourseList;
@property (nonatomic,strong) HotCourseList *locationSuccessHotCourseList;
@property (nonatomic,strong) TravelPackageList *packageList;
@property (nonatomic, strong) ActivityModel *adsData;
@property (nonatomic,assign) BOOL isLoadingCommityList;
@property (nonatomic, strong) AdvertisementView *adsView;
@property (nonatomic, strong) UITapGestureRecognizer *tapG;

@end

@implementation IndexViewController{
    BOOL isLoadingBanner;
    BOOL isLoadingHeadlineTop;
    BOOL isLoadingHeadline;
    BOOL isLoadingTeachActivity;
    BOOL isLoadingThemeCommodity;
    BOOL isLoadingHotCourse;
    BOOL isLoadingPackageList;
    
    /**
     新人专享背景View
     */
    UIView *_bgViewNewPeopleEnjoy;
    HomeCoverView *_homeCoverView;
    
    NSTimeInterval lastQueryTime;
    NoResultView *noResultView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 18;

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *textStr = @"大";
    CGFloat oneLineHeight = [textStr heightWithLabelFont:[UIFont systemFontOfSize:16.0] withLabelWidth:Device_Width - 24];
    
    HeadLineBean *headLineBean = [_headLineList.articleList firstObject];
    CGFloat cellHeight = [headLineBean.linkTitle heightWithLabelFont:[UIFont systemFontOfSize:16.0] withLabelWidth:Device_Width - 24];
    switch (indexPath.row) {
        case 0: //banner
            
            return 140.f/375.f*Device_Width;
            
//            return 140;
            break;
        case 1: //三个按钮
            return 98;
            break;
        case 2: //高俅头条
            return 68;
            break;
        case 3: //section
            return 10;
            break;
            
        case 4: //热门球场
            return 242;
            break;
        case 5: //section
            return 10;
            break;
            
        case 6: //热门套餐
            return 242;
            break;
        case 7: //section
            return 10;
            break;
            
            
        case 8: //商城头部
            return 56.f;
            break;
        case 9: //商城抢购
            return [YGMallFlashSaleCell cellSize].height;
            break;
        case 10: //商城入口
            return 200.f;
            break;
        case 11:
            return 10;
            break;
        case 12:
            return 190;
            break;
        case 13:
            return 10;
            break;
        case 14:
            return 58;
            break;
        case 15:
            if (cellHeight <= oneLineHeight) {
                return 272;
            }else{
                return 272 + oneLineHeight;
            }            
            break;
        case 16:
        case 17:
            return 111;
            break;
        default:
            break;
    }
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 2) {
        [[API shareInstance] statisticalNewWithBuriedpoint:24 objectID:0 Success:nil failure:nil];//埋点
        YGYueduMainViewCtrl *vc = [YGYueduMainViewCtrl instanceFromStoryboard];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 14){
        [[API shareInstance] statisticalNewWithBuriedpoint:32 objectID:0 Success:nil failure:nil];//埋点
        YGYueduMainViewCtrl *vc = [YGYueduMainViewCtrl instanceFromStoryboard];
        vc.columnId = 2;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 8){
        //商城header
        YGMallViewCtrl *vc = [YGMallViewCtrl instanceFromStoryboard];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    switch (indexPath.row) {
        case 0:
        {
            KDCycleBannerViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KDCycleBannerViewCell" forIndexPath:indexPath];
            if ([GolfAppDelegate shareAppDelegate].isLocationSuccess) {
                [cell loadDatas:_locationSuccessBannerArr];
            }else{
                [cell loadDatas:_locationFailurBannerArr];
            }
            if (cell.blockSelected == nil) {
                cell.blockSelected = ^(ActivityModel *model){
                    
                    if (model.dataType.length == 0 && model.activityPage.length > 0) {
                        YGWebBrowser *activityMain = [YGWebBrowser instanceFromStoryboard];
                        activityMain.title = @"活动详情";
                        activityMain.activityModel = model;
                        activityMain.activityId = model.activityId;
                        [weakSelf pushViewController:activityMain title:@"活动详情" hide:YES];
                    }else{
                        NSDictionary *dic = @{@"data_type":model.dataType,
                                              @"data_id":@(model.dataId),
                                              @"sub_type":@(model.subType),
                                              @"data_extra":model.dataExtra
                                              };
                        [[GolfAppDelegate shareAppDelegate] handlePushControllerWithData:dic];
                    }
                };
            }
            return cell;
        }
            break;
        case 1:
        {
            ThreeActionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ThreeActionTableViewCell" forIndexPath:indexPath];
            
            if (cell.btn1Return == nil) {
                cell.btn1Return = ^(id data){
                    [weakSelf pushWithStoryboard:@"BookTeetime" title:@" " identifier:@"ClubHomeController" completion:^(BaseNavController *controller) {}]; //球场预订
                };
            }
            if (cell.btn2Return == nil) {
                cell.btn2Return = ^(id data){
                    YGPackageIndexViewCtrl *vc = [YGPackageIndexViewCtrl instanceFromStoryboard];
                    [weakSelf pushViewController:vc hide:YES];
                };
            }
            if (cell.btn3Return == nil) {
                cell.btn3Return = ^(id data){
                    YGMallViewCtrl *vc = [YGMallViewCtrl instanceFromStoryboard];
                    [weakSelf.navigationController pushViewController:vc animated:YES];//@"精选商城"
                };
            }
            if (cell.btn4Return == nil) {
                cell.btn4Return = ^(id data){
                    [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:@"ic_coach_new"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [weakSelf pushViewController:[TeachHomeTableViewController instanceFromStoryboard] hide:YES];//@"教学预约"
                    
                };
            }
            return cell;
        }
            break;
        case 2:
        {
            LunboTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LunboTableViewCell" forIndexPath:indexPath];
            if (cell.tempArr == nil || _headLineList.articleList != cell.tempArr) {
                [cell loadDatas:_headlineTopList.articleList];
            }
            return cell;
        }
            break;
        case 3:
            return [tableView dequeueReusableCellWithIdentifier:@"sectionCell" forIndexPath:indexPath];
            break;
            
        case 4:
        {
            YGIndexCourseListCell *cell = [tableView dequeueReusableCellWithIdentifier:kYGIndexCourseListCell forIndexPath:indexPath];
            if ([GolfAppDelegate shareAppDelegate].isLocationSuccess) {
                [cell configureWithCourses:_locationSuccessHotCourseList.hotCourseBeanList];
            }else{
                [cell configureWithCourses:_locationFailueHotCourseList.hotCourseBeanList];
            }
            cell.loading = !isLoadingHotCourse;
            return cell;
        }
            break;
        case 5:
            return [tableView dequeueReusableCellWithIdentifier:@"sectionCell" forIndexPath:indexPath];
            break;
        case 6:
        {
            YGIndexCourseListCell *cell = [tableView dequeueReusableCellWithIdentifier:kYGIndexCourseListCell forIndexPath:indexPath];
            [cell configureWithPackages:self.packageList.packageList];
            cell.loading = !isLoadingPackageList;
            return cell;
        }
            break;
        case 7:
            return [tableView dequeueReusableCellWithIdentifier:@"sectionCell" forIndexPath:indexPath];
            break;
            
            
            
        case 8:{ //商城头部
            return [tableView dequeueReusableCellWithIdentifier:@"YGIndexHeaderCell" forIndexPath:indexPath];
        }   break;
        case 9:{
            // 商城抢拍
            YGMallFlashSaleCell *cell = [tableView dequeueReusableCellWithIdentifier:kYGMallFlashSaleCell forIndexPath:indexPath];
            if (!cell.flashSale) {
                cell.flashSale = [[YGMallFlashSaleLogic alloc] initWithScene:YGMallFlashSaleSceneIndex];
            }
            cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
            cell.layoutMargins = UIEdgeInsetsMake(0, 1000, 0, 0);
            return cell;
            
        }   break;
            
        case 10:{
            YGIndexMallCell *cell = [tableView dequeueReusableCellWithIdentifier:kYGIndexMallCell forIndexPath:indexPath];
            cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
            cell.layoutMargins = UIEdgeInsetsMake(0, 1000, 0, 0);
            [cell configureWithData:_themeCommodityList];
            return cell;
        }
            break;
        case 11:
            return [tableView dequeueReusableCellWithIdentifier:@"sectionCell" forIndexPath:indexPath];
            break;
        case 12:
        {
            ScrollTeachTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScrollTeachTableViewCell" forIndexPath:indexPath];
            if (cell.datas == nil || cell.datas != self.teachActivityList.teachActivityList) {
                [cell loadDatas:self.teachActivityList.teachActivityList];
            }
            
            if (cell.blockMore == nil) {
                cell.blockMore = ^(id data){
                    [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:@"ic_coach_new"];
                    [self pushViewController:[TeachHomeTableViewController instanceFromStoryboard] hide:YES];//@"教学预约"
                };
            }
            return cell;
        }
            break;
        case 13:
            return [tableView dequeueReusableCellWithIdentifier:@"sectionCell" forIndexPath:indexPath];
            break;
        case 14:
            return [tableView dequeueReusableCellWithIdentifier:@"GolfHeadCell" forIndexPath:indexPath];
            break;
        case 15:
        {
            GolfHeadlineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GolfHeadlineTableViewCell" forIndexPath:indexPath];
            cell.headLineBean = [_headLineList.articleList firstObject];
            
            if (cell.blockVideoPlay == nil) {
                cell.blockVideoPlay = ^(id data){
                    [SVProgressHUD show];
                    HeadLineBean *headLineBean = (HeadLineBean *)data;
                    __block BOOL isWebURL;
                    if (headLineBean.videoUsePlayer == 2) {
                        isWebURL = YES;
                    }else{
                        isWebURL = NO;
                    }
                    [YGYueduVideoHelper playVideo:headLineBean.videoUrl isWebURL:isWebURL fromViewController:weakSelf completion:^(BOOL suc, NSString *msg) {
                        if (suc) {
                            [SVProgressHUD dismiss];
                        }else{
                            [SVProgressHUD showErrorWithStatus:@"当前网络连接失败"];
                        }
                    }];
                    
                };
            }
            return cell;
        }
            break;
        case 16:
        {
            YGYueduVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YGYueduVideoCell" forIndexPath:indexPath];
            HeadLineBean *headLineBean = _headLineList.articleList[1];
            [self fillHeadLineBean:headLineBean toCell:cell];
            cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
            if (cell.blockPlay == nil) {
                cell.blockPlay = ^(id data){
                    [SVProgressHUD show];
                    HeadLineBean *headLineBean = (HeadLineBean *)data;
                    __block BOOL isWebURL;
                    if (headLineBean.videoUsePlayer == 2) {
                        isWebURL = YES;
                    }else{
                        isWebURL = NO;
                    }
                    [YGYueduVideoHelper playVideo:headLineBean.videoUrl isWebURL:isWebURL fromViewController:weakSelf completion:^(BOOL suc, NSString *msg) {
                        if (suc) {
                            [SVProgressHUD dismiss];
                        }else{
                            [SVProgressHUD showErrorWithStatus:@"当前网络连接失败"];
                        }
                    }];
                };
            }
            return cell;
        }
            break;
        case 17:
        {
            YGYueduVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YGYueduVideoCell" forIndexPath:indexPath];
            HeadLineBean *headLineBean = _headLineList.articleList.lastObject;
            [self fillHeadLineBean:headLineBean toCell:cell];
            cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
            if (cell.blockPlay == nil) {
                cell.blockPlay = ^(id data){
                    [SVProgressHUD show];
                    HeadLineBean *headLineBean = (HeadLineBean *)data;
                    __block BOOL isWebURL;
                    if (headLineBean.videoUsePlayer == 2) {
                        isWebURL = YES;
                    }else{
                        isWebURL = NO;
                    }
                    [YGYueduVideoHelper playVideo:headLineBean.videoUrl isWebURL:isWebURL fromViewController:weakSelf completion:^(BOOL suc, NSString *msg) {
                        if (suc) {
                            [SVProgressHUD dismiss];
                        }else{
                            [SVProgressHUD showErrorWithStatus:@"当前网络连接失败"];
                        }
                    }];
                };
            }
            return cell;
        }
            break;

        default:
            break;
    }

    return [[UITableViewCell alloc] init];
}

- (void)fillHeadLineBean:(HeadLineBean *)headLineBean toCell:(YGYueduVideoCell *)cell{
    [Utilities loadImageWithURL:[NSURL URLWithString:headLineBean.picUrl] inImageView:cell.articleImageViews placeholderImage:self.defaultImage];
    cell.articleTitleLabel.text = headLineBean.linkTitle;
    cell.articleDateLabel.text = headLineBean.createdAt;
    cell.articleSourceLabel.text = headLineBean.accountName;
    cell.headLineBean = headLineBean;
    cell.articleVideoLengthLabel.text = headLineBean.categoryName;
}

#pragma mark - 视图控制
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (![[GolfAppDelegate shareAppDelegate] isFirstEnterApp]) {
        [self loadAdvertisement];//加载广告页
    }
    
    [self noLeftButton];
    
    self.defaultImage = [UIImage imageNamed:@"default_"];
    
    self.tableView.contentInset = UIEdgeInsetsMake(64.f, 0, 49.f, 0);
    
    lastQueryTime = -1;

    // 获取所有的球场信息由服务器 在特定的页面已经返回
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        // time-consuming task
//        [[ServiceManager serviceManagerWithDelegate:self] getAllClubs];
//    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reservePushNotification:) name:@"systemNewsCount" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getActivityData) name:@"LoadHomeBanner" object:nil];//接收到appDelegate的通知加载banner
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNearbyHotCourseData) name:@"didUpdatgeLocations" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newPeopleEnjoy:) name:@"NewPeopleEnjoy" object:nil];//新人专享接受通知
    
    [YGMallFlashSaleCell registerIn:self.tableView];
    ygweakify(self);
    [self.tableView setRefreshHeaderEnable:YES footerEnable:NO callback:^(YGRefreshType type) {
        ygstrongify(self);
        [self getFirstPageDatas];
    }];
    [self getFirstPageDatas];
 
    [[API shareInstance] statisticalWithBuriedpoint:1 Success:nil failure:nil];//埋点

    __weak IndexViewController *weakSelf = self;
    noResultView = [NoResultView text:@"点击屏幕，重新加载" type:(NoResultTypeWifi) superView:self.view btnTaped:^{
        [weakSelf detectionNetworking];
        [weakSelf getFirstPageDatas];
    } show:^{
        weakSelf.tableView.hidden = YES;
    } hide:^{
        weakSelf.tableView.hidden = NO;
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self detectionNetworking];
    });
    
    BOOL isFirstGetLastVersion = [[NSUserDefaults standardUserDefaults] boolForKey:IDENTIFIER(@"isFirstGetLastVersion")];
    if (!isFirstGetLastVersion) {
        [self getLastVersion];//版本更新
    }
    
    [self openPosition];//打开定位
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.navigationItem.leftBarButtonItem = nil;
    
    CGRect frame = self.naviTitleView.frame;
    // 解决初始化时导航栏宽度不正确、回到首页时右侧发生明显变化的两个问题
    // 不同iOS版本和iOS设备上上导航栏左右边缘宽度不一样。但一般是小于20的。
    // 当大于20时表示导航栏为了在左侧给返回按钮留出空间，自动缩小了titleView的宽度。所以需要手动调整宽度。
    // Device_Width 超过了titleView允许的最大宽度，所以系统会根据边距进行自动调整。
    if (CGRectGetMinX(frame) > 20.f) {
        frame.size.width = Device_Width;
        self.naviTitleView.frame = frame;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([NSDate timeIntervalSinceReferenceDate] - lastQueryTime > 300 && [CLLocationManager locationServicesEnabled]) {
        lastQueryTime = [NSDate timeIntervalSinceReferenceDate];
        [[GolfAppDelegate shareAppDelegate] startUpdateLocation];
    }
    [[API shareInstance] statisticalWithBuriedpoint:2 Success:nil failure:nil];//埋点
    
    [self viewWillMethod];//APP评价弹窗
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.view.subviews containsObject:_adsView]) {//lyf 加 推送进入app,若已经退出，也要加启屏页
        [self endAdvertisement];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self viewDisappearMethod];
}

#pragma mark 检测是否有网络
- (void)detectionNetworking{
    if (![[GolfAppDelegate shareAppDelegate] networkReachability]) {
        [noResultView show:YES];
    }else{
        [noResultView show:NO];
    }
}

- (void)dealloc
{
    self.tableView.delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didUpdatgeLocations" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didFailLocations" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"systemNewsCount" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoadHomeBanner" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NewPeopleEnjoy" object:nil];//lq 加 接收到APPDelegate的通知
}

#pragma mark - Actions
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [[YGSearchViewCtrl instanceFromStoryboard] displayFromViewController:self.navigationController keywords:[self.titleSearchBar currentKeywords]];
    [[API shareInstance] statisticalNewWithBuriedpoint:23 objectID:0 Success:nil failure:nil];//埋点
    return NO;
}

- (IBAction)customerService:(id)sender
{
    [CustomerServiceViewCtrl show];
}

#pragma mark  getNetworkingDatas
- (void)getFirstPageDatas{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getNetwordingDatas];
        [self getNearbyHotCourseData];
    });
}

- (void)getActivityData{
    /**
     banner
     */
    if ([GolfAppDelegate shareAppDelegate].isLocationSuccess) {
        ygweakify(self);
        [ServerService getActivityListByLongitude:[LoginManager sharedManager].currLongitude latitude:[LoginManager sharedManager].currLatitude putArea:0 esolution:0 needGroup:NO success:^(id data) {
            ygstrongify(self);
            self.locationSuccessBannerArr = (NSArray *)data;
            [self.tableView reloadRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        } failure:nil];
    }else{
        ygweakify(self);
        [ServerService getActivityListByLongitude:-1.0 latitude:-1.0 putArea:0 esolution:0 needGroup:NO success:^(id data) {
            ygstrongify(self);
            self.locationFailurBannerArr = (NSArray *)data;
            [self.tableView reloadRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationNone];

        } failure:nil];
    }
}

- (void)getNearbyHotCourseData{
    /**
     附近热门球场
     */
    Location *location = [Location new];;
    if ([GolfAppDelegate shareAppDelegate].isLocationSuccess) {
        location.longitude = [NSString stringWithFormat:@"%f",[LoginManager sharedManager].currLongitude];
        location.latitude = [NSString stringWithFormat:@"%f",[LoginManager sharedManager].currLatitude];
        ygweakify(self);
        [[API shareInstance] hotCourseListWithLocation:location success:^(HotCourseList *ab) {
            ygstrongify(self);
            self.locationSuccessHotCourseList = ab;
            isLoadingHotCourse = YES;
            [self.tableView reloadRow:4 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        } failure:^(Error *error) {
            isLoadingHotCourse = YES;
        }];
    }else{
        ygweakify(self);
        [[API shareInstance] hotCourseListWithLocation:location success:^(HotCourseList *ab) {
            ygstrongify(self);
            self.locationFailueHotCourseList = ab;
            isLoadingHotCourse = YES;
            [self.tableView reloadRow:4 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        } failure:^(Error *error) {
            isLoadingHotCourse = YES;
        }];
    }
    
    // 旅行套餐
    [YGRequest getIndexTravelPackageList:location success:^(BOOL suc, TravelPackageList *object) {
        isLoadingPackageList = YES;
        if (suc) {
            self.packageList = object;
            [self.tableView reloadRow:6 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        }
    } failure:^(Error *err) {
        isLoadingPackageList = YES;
    }];
    

    /**
     banner数据
     */
    if ([GolfAppDelegate shareAppDelegate].isLocationSuccess) {
        ygweakify(self);
        [ServerService getActivityListByLongitude:[LoginManager sharedManager].currLongitude latitude:[LoginManager sharedManager].currLatitude putArea:0 esolution:0 needGroup:NO success:^(id data) {
            ygstrongify(self);
            self.locationSuccessBannerArr = (NSArray *)data;
            [self.tableView reloadRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
            isLoadingBanner = YES;
        } failure:^(id error) {
            isLoadingBanner = YES;
        }];
    }else{
        ygweakify(self);
        [ServerService getActivityListByLongitude:-1.0 latitude:-1.0 putArea:0 esolution:0 needGroup:NO success:^(id data) {
            ygstrongify(self);
            self.locationFailurBannerArr = (NSArray *)data;
            [self.tableView reloadRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
            isLoadingBanner = YES;
        } failure:^(id error) {
            isLoadingBanner = YES;
        }];
    }
    
    if (isLoadingHotCourse && isLoadingBanner && isLoadingPackageList) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView.mj_header endRefreshing];
        });
    }
}

- (void)getNetwordingDatas{
    /**
     高球头条
     */
    ygweakify(self);
    [[API shareInstance] headLineTopListSuccess:^(HeadLineList *ab) {
        ygstrongify(self);
        self.headlineTopList = ab;
        isLoadingHeadlineTop = YES;
        [self.tableView reloadRow:2 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
    } failure:^(Error *error) {
        isLoadingHeadlineTop = YES;
    }];
    /**
     golf头条
     */
    [[API shareInstance] headLineListSuccess:^(HeadLineList *ab) {
        ygstrongify(self);
        self.headLineList = ab;
        isLoadingHeadline = YES;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:10 inSection:0],[NSIndexPath indexPathForRow:11 inSection:0],[NSIndexPath indexPathForRow:12 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    } failure:^(Error *error) {
        isLoadingHeadline = YES;
    }];
    
    /**
     教学课程
     */
    [[API shareInstance] teachActivityListSuccess:^(TeachActivityList *ab) {
        ygstrongify(self);
        self.teachActivityList = ab;
        isLoadingTeachActivity = YES;
        [self.tableView reloadRow:10 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
    } failure:^(Error *error) {
        isLoadingTeachActivity = YES;
    }];
    
    /**
     精选商品
     */
    [[API shareInstance] themeCommodityListSuccess:^(ThemeCommodityList *ab) {
        ygstrongify(self);
        self.themeCommodityList = ab;
        self.isLoadingCommityList = YES;
        [self.tableView reloadRow:8 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
    } failure:^(Error *error) {
        ygstrongify(self);
        self.isLoadingCommityList = YES;
    }];
    
    if (isLoadingThemeCommodity && isLoadingTeachActivity && isLoadingHeadline && isLoadingHeadlineTop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ygstrongify(self);
            [self.tableView.mj_header endRefreshing];
        });
    }
    
}

- (void)willEndAdvertisement {
    if (lockAdvertisement == 1) {
        [self endAdvertisement];
    }
}

- (void)endAdvertisement {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    if (_adsView) {
        [_adsView removeFromSuperview];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {//若允许则定位，若第一次或者不允许，则等home页处理
            CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
            if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {//golfdelegate里已经定过,但是没显示YaoBallHints
                [GolfAppDelegate shareAppDelegate].isFirstLocationShowYaoBallHints = NO;
            }
        }
//        [[GolfAppDelegate shareAppDelegate] beginNotificationAndLocation];
//        [[GolfAppDelegate shareAppDelegate] startUpdateLocation];
    }
}

#pragma mark ----新人专享
-(void)newPeopleEnjoy:(NSNotification *)noti{
    NSDictionary *dict = [noti userInfo];
    if (![dict[@"err"] isKindOfClass:[NSNull class]]) {
        return;
    }
    [GolfAppDelegate shareAppDelegate].isShowAlert = YES;
    
    __weak typeof(self) weakSelf = self;
    _bgViewNewPeopleEnjoy = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _bgViewNewPeopleEnjoy.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeNewPeopleBgView:)];
    [_bgViewNewPeopleEnjoy addGestureRecognizer:tap];
    
    _homeCoverView = [HomeCoverView loadXibView];
    _homeCoverView.imageViewIcon.userInteractionEnabled = YES;
    
    if (![dict[@"showPic"] isKindOfClass:[NSNull class]]) {
        [_homeCoverView.imageViewIcon sd_setImageWithURL:[NSURL URLWithString:dict[@"showPic"]] placeholderImage:[UIImage imageNamed:@""]];
    }
    _homeCoverView.center = _bgViewNewPeopleEnjoy.center;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.adsView != nil){
            NSInteger adsViewIndex = [[[GolfAppDelegate shareAppDelegate].window subviews] indexOfObject:self.adsView];
            [[GolfAppDelegate shareAppDelegate].window insertSubview:_bgViewNewPeopleEnjoy atIndex:adsViewIndex];
            [[GolfAppDelegate shareAppDelegate].window insertSubview:_homeCoverView aboveSubview:_bgViewNewPeopleEnjoy];
        }else{
            [[GolfAppDelegate shareAppDelegate].window bringSubviewToFront:_bgViewNewPeopleEnjoy];
            [[GolfAppDelegate shareAppDelegate].window insertSubview:_homeCoverView aboveSubview:_bgViewNewPeopleEnjoy];
        }
        
    });
    
    _homeCoverView.cancelBtnActionBlock = ^(){
        //取消按钮
        [weakSelf cancelNewPeopleEnjoy];
    };
    /**
     1点击跳url页面 2点击调app指定位置
     */
    if ([dict[@"jumpType"] intValue] == 1) {
        _homeCoverView.reciverSoonBtnActionBlock = ^(){
            //立即领取按钮
            if (![dict[@"webUrl"] isKindOfClass:[NSNull class]]) {
                NewPeopleEnjoyViewController *newPeopleEnjoyVC = [[NewPeopleEnjoyViewController alloc] init];
                newPeopleEnjoyVC.skipUrl = dict[@"webUrl"];
                [weakSelf pushViewController:newPeopleEnjoyVC title:@"新人专享" hide:YES];
                [weakSelf cancelNewPeopleEnjoy];
            }
        };
    }else{
        //跳转到其他页面，后续再约定。。。。。。
        
    }
}
-(void)cancelNewPeopleEnjoy{
    [GolfAppDelegate shareAppDelegate].isShowAlert = NO;
    [_bgViewNewPeopleEnjoy removeFromSuperview];
    [_homeCoverView removeFromSuperview];
}

-(void)removeNewPeopleBgView:(UITapGestureRecognizer *)tap{
    [self cancelNewPeopleEnjoy];
}

#pragma mark others
- (void)locationToTeetimeMainVc:(NSString *)urlStr{
    NSDictionary *dic = [Utilities webInterfaceToDic:[NSURL URLWithString:urlStr] prefix:SCHEMA_GOLF];
    if (dic) {
        ConditionModel *myCondition = [[ConditionModel alloc] init];
        myCondition.clubId = [[dic objectForKey:@"club_id"] intValue];
        if ([dic objectForKey:@"date"])
            myCondition.date = [dic objectForKey:@"date"];
        if ([dic objectForKey:@"time"])
            myCondition.time = [dic objectForKey:@"time"];
        if (myCondition.clubId > 0 ) {
            [self pushWithStoryboard:@"BookTeetime" title:@"" identifier:@"ClubMainViewController" completion:^(BaseNavController *controller) {
                ClubMainViewController *vc = (ClubMainViewController*)controller;
                vc.cm = myCondition;
                vc.agentId = -1;
            }];
            
        }
    }
}

- (void)updateSearchKeywords:(NSString *)keywords
{
    NSArray *array = [keywords componentsSeparatedByString:@" "];
    if (array.count > 0) {
        self.titleSearchBar.possibleKeywords = array;
    }
}

- (void)getAdditionInfo {
    if([NSDate timeIntervalSinceReferenceDate] - lastQueryTime > 180 && [CLLocationManager locationServicesEnabled]) {
        lastQueryTime = [NSDate timeIntervalSinceReferenceDate];
        [self getActivityData];
    }
}

- (void)reservePushNotification:(NSNotification *)notificate{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ServiceManager serviceManagerWithDelegate:self] systemParamInfo:[[NSUserDefaults standardUserDefaults] objectForKey:KGolfSessionPhone] sessionID:[LoginManager sharedManager].session.sessionId];
    });
}

#pragma mark - Advertisement
- (void)loadAdvertisement {
    [self startAdvertisement];
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(willEndAdvertisement) userInfo:nil repeats:NO];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        double longitude;
        double latitude;
        if([LoginManager sharedManager].positionIsValid) {
            longitude = [LoginManager sharedManager].currLongitude;
            latitude = [LoginManager sharedManager].currLatitude;
        } else {
            longitude = 0;
            latitude = 0;
        }
        [ServerService getActivityListByLongitude:longitude latitude:latitude putArea:5 esolution:0 needGroup:NO success:^(id data) {
            NSArray *array = (NSArray *)data;
            if (array.count > 0) {
                self.adsData = array[0];
            }
            [self showAdvertisementView];
        } failure:^(id error) {
        }];
        [self getActivityData];
    });
}

- (void)showAdvertisementView {
    _adsView.adsImageView.hidden = NO;
    _adsView.skipButton1.hidden = NO;
    [_adsView.adsImageView sd_setImageWithURL:[NSURL URLWithString:_adsData.activityPicture] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            lockAdvertisement = 0;
            [self endAdvertisement];
            return;
        }
        lockAdvertisement = 0;
        [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(endAdvertisement) userInfo:nil repeats:NO];
    }];
    [[API shareInstance] statisticalWithBuriedpoint:1 Success:nil failure:nil];//埋点
}

- (void)startAdvertisement {
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.adsView = [[[NSBundle mainBundle] loadNibNamed:@"AdvertisementView" owner:self options:nil] firstObject];
    ygweakify(self);
    self.adsView.skipAdsBlock = ^ {
        ygstrongify(self);
        [self endAdvertisement];
    };
    _tapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toAdvertisementDetailView)];
    [_adsView.adsImageView addGestureRecognizer:_tapG];
    _adsView.frame = [[UIScreen mainScreen] bounds];
    _adsView.skipButton.hidden = NO;
    [[GolfAppDelegate shareAppDelegate].window addSubview:_adsView];
}

- (void)toAdvertisementDetailView {
    [_adsView.adsImageView removeGestureRecognizer:_tapG];
    if (_adsData.dataType.length == 0 && _adsData.activityPage.length > 0) {
        [_adsView removeFromSuperview];
        YGWebBrowser *activityMain = [YGWebBrowser instanceFromStoryboard];
//        ActivityMainViewController *activityMain = [[ActivityMainViewController alloc] initWithNibName:@"ActivityMainViewController" bundle:nil];
        activityMain.title = @"活动详情";
        activityMain.activityModel = _adsData;
        activityMain.activityId = _adsData.activityId;
        [self pushViewController:activityMain title:@"活动详情" hide:YES];
    }else{
        NSDictionary *dic = @{@"data_type":_adsData.dataType,
                              @"data_id":@(_adsData.dataId),
                              @"sub_type":@(_adsData.subType),
                              @"data_extra":_adsData.dataExtra
                              };
        [[GolfAppDelegate shareAppDelegate] handlePushControllerWithData:dic];
    }
    
}

@end
