//
//  ClubMainViewController.m
//  Golf
//
//  Created by 黄希望 on 15/10/26.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "ClubMainViewController.h"
#import "WeathersViewController.h"
#import "ClubMoreDetailViewController.h"
#import "ClubCommentController.h"
#import "ClubSpecialCell.h"
#import "ClubChooseDTCell.h"
#import "TeetimeListCell.h"
#import "OnlyOneLineCell.h"
#import "TitlePriceCell.h"
#import "TwoLabelsCell.h"
#import "ClubManagerTableViewCell.h"
#import "ChooseDateController.h"
#import "ChooseTimeController.h"
#import "TrendsModel.h"
#import "TopicHelp.h"
#import "TrendsTableViewCell.h"
#import "CCActionSheet.h"
#import "TrendsPraiseListController.h"
#import "ImageBrowser.h"
#import "BaseVideoPlayController.h"
#import "VipValidateViewController.h"
#import "TrendsViewController.h"
#import "ConfirmTeeTimeController.h"
#import "WKDChatViewController.h"
#import "ClubRushPurchaseCell_Will.h"
#import "ThreeLabelsCell.h"
#import "ClubRushTypesCell.h"
#import "CalendarClass.h"
#import "YGMapViewCtrl.h"
#import "IMCore.h"
#import "YGCapabilityHelper.h"
#import "CCAlertView.h"
#import "CityMultiplePackageViewController.h"
#import "JZNavigationExtension.h"
#import "YGPublishViewCtrl.h"
#import "SpecialOfferModel.h"
#import "WeatherModel.h"
#import "SpecialOfferListViewController.h"
#import "SharePackage.h"
#import "YGPackageDetailViewCtrl.h"

@interface ClubMainViewController () <UITableViewDelegate,UITableViewDataSource>{
    IBOutletCollection(UIButton) NSArray *roundBtns;
    UILabel *_specialTimeLabel;
    
    BOOL _isTeetimeAll;
    
    // 判断当前vip
    BOOL _isVip;
    BOOL _isWaitingVip;
    
    // 话题相关变量
    NSString *replyContent;
    NSIndexPath *indexPath_;
    TopicModel *topicModel_;
//    BOOL zaning;
    
    SpecialOfferModel *_sfm;
    
    BOOL _showDarkNaviBarItem;
}

@property (strong, nonatomic) SharePackage *share;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (nonatomic,weak) IBOutlet UIButton *weatherBtn;
@property (nonatomic,weak) IBOutlet UILabel *clubNameLabel;
@property (nonatomic,weak) IBOutlet UIButton *commentBtn;
@property (nonatomic,weak) IBOutlet UIImageView *clubImageView;
@property (nonatomic,weak) UIButton *timeBtn;
@property (nonatomic,weak) UIButton *dateBtn;

@property (nonatomic, strong) ConfirmTeeTimeController *confirmTeetime;

@property (nonatomic) CGFloat imageScalingFactor;
@property (nonatomic,strong) TopicModel *topicModel;

@property (nonatomic,strong) NSMutableArray *teetimeArr;
@property (nonatomic,strong) NSMutableArray *trendArr;
@property (nonatomic,strong) NSMutableArray *clubPictureList;
@property (nonatomic,strong) NSArray *weatherArray;
@property (nonatomic,strong) NSArray *callSettingList;

@property (nonatomic,strong) NSString *teetimeStr;
@property (nonatomic,assign) NSInteger topSize;
@property (nonatomic,strong) NSString *clubPhone;
@property (nonatomic,assign) int timeMinPrice;
@property (nonatomic,strong) NSString *timeStartTime;
@property (nonatomic,strong) NSString *timeEndTime;
@property (nonatomic,strong) NSString *errorInfo;
@property (nonatomic,assign) NSInteger isofficial;
@property (nonatomic,assign) NSInteger specialPriceType;
@property (nonatomic,strong) ClubModel *clubInfo;
@property BOOL isOneDetailList;
@property (nonatomic) int isAttentionOrComment;
@property (nonatomic, strong) ArticleCommentModel *articleCommentModel;

@end

@implementation ClubMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    YGPostBuriedPoint(YGCoursePointCourse);
    
    [TopicHelp registerNibs:self.tableView];
    [self initizationData];
    self.hidesClearText = YES;
    self.dimissHidden = YES;
    self.inputToolbar.hidden = YES;
    
    self.navigationItem.title = nil;//最开始不显示标题
    [self leftNavButtonImg:@"ic_nav_back_light"];
    [self rightButtonActionWithImg:@"ic_share_3px_light" autoSize:YES];
}

-(void)viewDidLayoutSubviews{
    CGRect navigationBarRect = self.navigationController.navigationBar.frame;
    CGFloat top = navigationBarRect.size.height + navigationBarRect.origin.y - 10;
    self.tableView.contentInset = UIEdgeInsetsMake(top, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(top, 0, 0, 0);
}

-(void)dealloc{
    if (!_rush) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshAttentList" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshTopicSignalCell" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshTopicList" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PUBLISH_TOPIC_FAILURED" object:nil];
    }
}

- (void)initizationData{
    if (!_rush) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTopicList) name:@"refreshTopicList" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTopicListWithAttention:) name:@"refreshAttentList" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSignalCell:) name:@"refreshTopicSignalCell" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publishTopicFailured) name:@"PUBLISH_TOPIC_FAILURED" object:nil];
        [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 10, 0)];
    }

    _imageScalingFactor = 80;
    
    if (!_rush) {
        // teetime列表
        self.teetimeArr = [NSMutableArray array];
        // 动态列表
        self.trendArr = [NSMutableArray array];
        _isTeetimeAll = YES;
        
        // 获取teetime列表
        [self getTeetimeList];
        // 获取特价列表
        [self getSpecialPriceList];
        // 获取VIP信息
        [self getVipListWithCompletion:nil];
        // 获取动态列表
        [self getTrendList];
    }else{
        NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:@"ClubCallSetting"];
        self.callSettingList = [NSArray arrayWithArray:arr];
        
        // 获取系统时间
        [self getSystemTime];
        
        if (!_csm || _csm.spreeId == 0) {
            _cm = [[ConditionModel alloc] init];
            _cm.price = 0;
            _cm.people = 0;
            _cm.cityId = 0;
            _cm.provinceId = 0;
            _cm.clubName = @"";
            _cm.cityName = @"当前位置";
            _cm.date = [Utilities stringwithDate:[CalendarClass dateForStandardToday]];
            _cm.time = @"07:30";
            _cm.clubId = _clubId;
            
            ygweakify(self);
            [ServerService getClubSpreeListWithSpreeType:0 spreeId:_spreeId pageNo:1 pageSize:1 longitude:[LoginManager sharedManager].currLongitude latitude:[LoginManager sharedManager].currLatitude success:^(NSArray *list) {
                ygstrongify(self);
                if (list.count>0) {
                    self.csm = [list firstObject];
                    [self.tableView reloadData];
                }
            } failure:^(id error) {
            }];
        }
    }
    
    // 设置头部的三个圆框
    [self setRoundBtn];
    
    // 取球场详情信息
    [self getClubDetail];
    
    // teetime确认弹出层的创建
    [self createChooseTeetimeView];
}

- (void)refreshTopicList{
    [_trendArr removeAllObjects];
    [self getTrendList];
}

- (void)refreshSignalCell:(NSNotification *)nf{
    NSDictionary *dic = [nf object];
    NSString *api = dic[@"api"];
    
    if ([@"topic_share_add" isEqualToString:api] || [@"topic_praise_add" isEqualToString:api]) {
        TopicModel *m = dic[@"topicModel"];
        m.cellHeight = [TopicHelp cellHeightWithData:m topicType:0 hasDetail:YES refresh:YES];
        if (m) {
            for (TopicModel *tm in _trendArr) {
                if ([tm isKindOfClass:[TopicModel class]] && tm.topicId == m.topicId) {
                    NSInteger index = [_trendArr indexOfObject:tm];
                    [_trendArr replaceObjectAtIndex:index withObject:m];
                    [self.tableView reloadData];
                    break;
                }
            }
        }
    }else{
        [self getTrendList];
    }
}

- (void)refreshTopicListWithAttention:(NSNotification *)nf{
    NSDictionary *dic = nf.object;
    UserFollowModel *model = dic[@"data"];
    for (TopicModel *m in _trendArr) {
        if ([m isKindOfClass:[TopicModel class]]) {
            if (m.memberId == model.memberId) {
                m.isFollowed = model.isFollowed;
                if ([dic[@"flag"] intValue] == 3) {
                    m.displayName = model.displayName;
                }
            }
        }
    }
    [self.tableView reloadData];
}

- (void)scrollViewDidScrollWithOffset:(CGFloat)scrollOffset
{
    if (scrollOffset < 0){
        CGFloat f = 1 - (scrollOffset / self.imageScalingFactor);
        self.clubImageView.transform = CGAffineTransformMakeScale(f, f);
    }else{
        self.clubImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }
    
    [self animateNavigationBar:scrollOffset];
}

- (void)animateNavigationBar:(CGFloat)scrollOffset
{
    // 当头部视图底部移动到导航栏处时导航栏完全显示。
    CGFloat alpha = scrollOffset/(CGRectGetHeight(self.tableView.tableHeaderView.bounds)-64.f);
    alpha = MAX(0, MIN(1, alpha));
    BOOL showTitle = alpha >= 0.5f;
    
    self.jz_navigationBarBackgroundAlpha = alpha;
    if (showTitle!=_showDarkNaviBarItem) {
        _showDarkNaviBarItem = showTitle;
        self.navigationItem.title = showTitle?(self.title.length!=0?self.title:self.clubInfo.clubName):@"";
        [self leftNavButtonImg:showTitle?@"ic_nav_back":@"ic_nav_back_light"];
        [self rightButtonActionWithImg:showTitle?@"ic_share_3px":@"ic_share_3px_light" autoSize:YES];
    }
}


#pragma mark ------------------------ 接口相关 ---------------------
// 获取teetime列表信息
- (void)getTeetimeList{
    [[ServiceManager serviceManagerWithDelegate:self] searchNewTeeTime:_cm.clubId agentId:self.agentId date:_cm.date time:_cm.time];
}

// 获取球场信息
- (void)getClubDetail{
    [[ServiceManager serviceManagerWithDelegate:self] getClubInfo:_cm.clubId needPackage:1];
}

// 获取特价列表
- (void)getSpecialPriceList{
    NSInteger _weekDay = [Utilities weekDayByDate:[Utilities getDateFromString:_cm.date]];
    [[ServiceManager serviceManagerWithDelegate:self] getClubSpecialOffList:_cm.clubId weekDay:(int)_weekDay date:_cm.date];
}

// 获取天气预报
- (void)getWeatherInfo{
    [[ServiceManager serviceManagerWithDelegate:self] getWeatherInfoWithCityId:_cm.cityId];
}

// 获取动态列表
- (void)getTrendList{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ServiceManager serviceManagerWithDelegate:self] topicList:nil
                                                              tagId:0
                                                            tagName:nil
                                                           memberId:0
                                                             clubId:_cm.clubId
                                                            topicId:0
                                                          topicType:0 pageNo:1 pageSize:3
                                                          longitude:[LoginManager sharedManager].currLongitude
                                                           latitude:[LoginManager sharedManager].currLatitude];
    });
}

- (void)getSystemTime{
    if ([LoginManager sharedManager].timeInterGab == KDefaultTimeInterGab) {
        [ServerService getServerTimeWithSuccess:^(NSTimeInterval timeInterval) {
            [LoginManager sharedManager].timeInterGab = timeInterval;
        } failure:nil];
    }
}

// 接口返回数据
- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    if (data) {
        NSArray *arr = (NSArray*)data;
        if (Equal(flag, @"search_teetime2")) {
            if (arr.count > 0) {
                NSDictionary *teeTimeDic = [arr objectAtIndex:0];
                self.teetimeStr = [teeTimeDic objectForKey:@"teetime"];
                if(!_teetimeStr || _teetimeStr.length==0) _teetimeStr = @"07:30";
                _errorInfo = [teeTimeDic objectForKey:@"error_info"];
                _topSize = [[teeTimeDic objectForKey:@"top_size"] intValue];
                
                self.clubPhone = [teeTimeDic objectForKey:@"club_phone"];
                self.timeMinPrice = [[teeTimeDic objectForKey:@"time_min_price"] intValue];
                self.timeStartTime = [teeTimeDic objectForKey:@"time_start_time"];
                self.timeEndTime = [teeTimeDic objectForKey:@"time_end_time"];
                NSArray *teetimes = [teeTimeDic objectForKey:@"teetime_list"];
                
                [self.teetimeArr removeAllObjects];
                [self.teetimeArr addObjectsFromArray:teetimes];
                
                
                _specialPriceType = 0;
                _isTeetimeAll = YES;
                self.isofficial = 0;
                if (_topSize > 0) {
                    self.isofficial = 1;
                    if (_teetimeArr.count-_topSize+1>4) {
                        _isTeetimeAll = NO;
                    }
                }else{
                    if (_teetimeArr.count>4) {
                        _isTeetimeAll = NO;
                    }
                }
                
                if (self.timeStartTime.length>0&&self.timeEndTime.length>0&&self.timeMinPrice>0){
                    BOOL sp = [Utilities compareTimeWithCurrentTime:_cm.time beginTime:self.timeStartTime endTime:self.timeEndTime];
                    _specialPriceType = sp ? 2 : 1;
                    
                    _sfm = [[SpecialOfferModel alloc] init];
                    _sfm.clubId = _cm.clubId;
                    _sfm.beginDate = _cm.date;
                    _sfm.beginTime = self.timeStartTime;
                    _sfm.endTime = self.timeEndTime;
                    _sfm.currentPrice = self.timeMinPrice;
                }
                
                [self.tableView reloadData];
                self.tableView.hidden = NO;
                _loadingView.hidden = YES;
                _clubImageView.hidden = NO;
            }
        }else if (Equal(flag, @"club_info")){
            if (arr.count>0) {
                self.clubInfo = (ClubModel*)[arr objectAtIndex:0];
                
                [_clubNameLabel setText:_clubInfo.clubName];
                [[BaiduMobStat defaultStat] pageviewStartWithName:_clubInfo.clubName];
                [MobClick beginLogPageView:_clubInfo.clubName];
                
                _cm.clubId = _clubInfo.clubId;
                _cm.clubName = _clubInfo.clubName;
                _cm.cityId = _clubInfo.cityId;
                _cm.cityName = _clubInfo.cityName;
                [_commentBtn setTitle:[NSString stringWithFormat:@"%d",_clubInfo.totalLevel] forState:UIControlStateNormal];
                
                [_clubImageView sd_setImageWithURL:[NSURL URLWithString:_clubInfo.clubImage] placeholderImage:[UIImage imageNamed:@"cgit_l"]];
                
                if (_cm.cityId>0) {
                    [self getWeatherInfo];
                }else{
                    _weatherBtn.hidden = YES;
                }
                [self.tableView reloadData];
                self.tableView.hidden = NO;
                _loadingView.hidden = YES;
                _clubImageView.hidden = NO;
            }
        }else if (Equal(flag, @"city_weather")){
            if (serviceManager.success) {
                self.weatherArray = arr;
                [self handleWeatherData];
            }else{
                _weatherBtn.hidden = YES;
            }
        }else if (Equal(flag, @"topic_list")){
            TrendsModel *tm = [arr firstObject];
            if (_isOneDetailList) {
                self.isOneDetailList = NO;
                if (tm.topicList.count == 1) {
                    TopicModel *m = [tm.topicList firstObject];
                    topicModel_ = m;
                    [self judgeLoginAndPerfectAndIsFollowed];
                    for (TopicModel *theModel in _trendArr) {
                        if ([theModel isKindOfClass:[TopicModel class]]) {
                            if (theModel.memberId == m.memberId) {
                                theModel.isFollowed = m.isFollowed;
                            }
                        }
                    }
                }
                return;
            }
            if (tm.topicList.count > 0) {
                [_trendArr removeAllObjects];
                for (TopicModel *tp in tm.topicList) {
                    _clubInfo.topicCount = tp.topicCount;
                    tp.cellHeight = [TopicHelp cellHeightWithData:tp topicType:0 hasDetail:YES refresh:YES];
                    [_trendArr addObject:tp];
                }
            }
            [self.tableView reloadData];
            self.tableView.hidden = NO;
            _loadingView.hidden = YES;
            _clubImageView.hidden = NO;
        }else if (Equal(flag, @"club_picture_list")){
            self.clubPictureList = [NSMutableArray array];
            if (_clubInfo.clubImage.length>0) {
                [self.clubPictureList addObject:_clubInfo.clubImage];
            }
            if (arr && arr.count > 0) {
                [self.clubPictureList addObjectsFromArray:arr];
            }
            [ImageBrowser IBWithImages:self.clubPictureList isCollection:NO currentIndex:0 initRt:CGRectMake(0, 0, Device_Width, 160) isEdit:NO highQuality:YES vc:self backRtBlock:^CGRect(NSInteger index) {
                return CGRectMake(0, 0, Device_Width, 160);
            } completion:nil];
        }else if (Equal(flag, @"club_package_list")){
            if (arr && arr.count > 1) {
                [self enterCityMultiplePackageVCWithList:arr];
            }else if (arr && arr.count == 1){
                [self getPackageDetailInfo:arr];
            }else{
                [[GolfAppDelegate shareAppDelegate] alert:nil message:@"获取套餐详情失败！"];
            }
        }else if (Equal(flag, @"package_detail")){
            PackageDetailModel *model = (PackageDetailModel*)[arr objectAtIndex:0];
            if (model.packageId > 0) {
                [self pushVC:model];
            }else{
                [[GolfAppDelegate shareAppDelegate] alert:nil message:@"获取套餐详情失败"];
            }
        }
    }
}

- (NSString*)dateBtnTitle{
    NSString *dateStr = [Utilities getDateStringFromString:_cm.date WithFormatter:@"MM月dd日"];
    NSString *weekStr = [Utilities getWeekDayByDate:[Utilities getDateFromString:_cm.date]];
    return [NSString stringWithFormat:@"%@ %@",dateStr,weekStr];
}


// 天气处理
- (void)handleWeatherData{
    if (_weatherArray.count > 0) {
        _weatherBtn.hidden = NO;
        NSDate *date = [Utilities getDateFromString:_cm.date];
        NSDate *today = [Utilities changeDateWithDate:[NSDate date]];
        int index = [date timeIntervalSinceDate:today]/(24*3600);
        if (index>-1 && index <_weatherArray.count) {
            [self weatherWithData:[_weatherArray objectAtIndex:index] date:_cm.date];
        }else if (_weatherArray.count == 1){
            [self weatherWithData:[_weatherArray objectAtIndex:0] date:_cm.date];
        }else{
            [self weatherWithData:[_weatherArray objectAtIndex:1] date:_cm.date];
        }
    }else{
        _weatherBtn.hidden = YES;
    }
}

- (void)weatherWithData:(WeatherModel*)model date:(NSString*)dateStr{
    NSString *weatherStr = [NSString stringWithFormat:@" %@ ",[self date:model.dateStr]];
    weatherStr = [weatherStr stringByAppendingString:model.temperatureRangeInfo];
    [_weatherBtn setTitle:weatherStr forState:UIControlStateNormal];
    UIImage *weatherImg = [UIImage imageNamed:[NSString stringWithFormat:@"aa_%d",model.picureNo]];
    [_weatherBtn setImage:weatherImg forState:UIControlStateNormal];
}

- (NSString*)date:(NSString*)theDate{
    NSDate *date = [Utilities getDateFromString:theDate];
    NSDate *today = [Utilities changeDateWithDate:[NSDate date]];
    if ([date timeIntervalSinceDate:today] == 0) {
        return @"今天";
    }
    if ([date timeIntervalSinceDate:today] == 24*3600) {
        return @"明天";
    }
    return [Utilities getDateStringFromString:theDate WithFormatter:@"dd日"];
}


- (void)setRoundBtn{
    for (UIButton *btn in roundBtns) {
        [Utilities drawView:btn radius:16 bordLineWidth:1 borderColor:[UIColor whiteColor]];
    }
}

- (void)createChooseTeetimeView{
    _confirmTeetime = [[self storyboard:@"BookTeetime"] instantiateViewControllerWithIdentifier:@"ConfirmTeeTimeController"];
    [self.view addSubview:_confirmTeetime.view];
    [self addChildViewController:_confirmTeetime];
    _confirmTeetime.view.hidden = YES;
}


#pragma mark ------------------------ 按钮相关 ---------------------

// 预定teetime
- (void)popTeetimeListView{
    if (_topSize>0) {
        _confirmTeetime.cm = _cm;
        _confirmTeetime.teetimes = [self.teetimeArr subarrayWithRange:NSMakeRange(0, _topSize)];
        _confirmTeetime.club = _clubInfo;
        _confirmTeetime.isVip = _isVip;
        _confirmTeetime.canBack = YES;
        [_confirmTeetime show:YES index:0 data:nil];
    }
}


- (IBAction)headImageClick:(id)sender{
    if (!self.clubPictureList) {
        [[ServiceManager serviceManagerWithDelegate:self] getClubPictureList:_cm.clubId];
    }else if (self.clubPictureList.count > 0){
        [ImageBrowser IBWithImages:self.clubPictureList isCollection:NO currentIndex:0 initRt:CGRectMake(0, 0, Device_Width, 160) isEdit:NO highQuality:YES vc:self backRtBlock:^CGRect(NSInteger index) {
            return CGRectMake(0, 0, Device_Width, 160);
        } completion:nil];
    }
}

- (void)doRightNavAction
{
    if ([LoginManager sharedManager].loginState) {
        if ([self needPerfectMemberData]) {
            return;
        }
    }
    NSString *title = nil;
    NSString *content = nil;
    NSString *url = nil;

    if (_rush) {
        title = [NSString stringWithFormat:@"【云高抢购】%d抢%@",_csm.currentPrice,_csm.spreeName];
        content = [NSString stringWithFormat:@"原价%d元，现价%d元开抢，数量所剩不多了，马上来抢吧。",_csm.originalPrice,_csm.currentPrice];
        url = [NSString stringWithFormat:@"%@club/club_tee_spree.jsp?spreeId=%d&courseId=%d",URL_SHARE,_csm.spreeId,_cm.clubId];//jsp?spreeId=749&courseId=77
    }else{
        if (self.teetimeArr.count > 0) {
            TTModel *m = [self.teetimeArr objectAtIndex:0];
            int minPrice = m.price ;
            for (TTModel *model in self.teetimeArr) {
                minPrice = MIN(minPrice, model.price);
            }
            title = [NSString stringWithFormat:@"%@",_cm.clubName];
            NSString *date = [Utilities getDateStringFromString:_cm.date WithFormatter:@"yyyy年MM月dd日"];
            content = [NSString stringWithFormat:@"%@,评分%d分,%@,¥%d起.",_clubInfo.courseKind,_clubInfo.totalLevel,date,minPrice];
            url = [NSString stringWithFormat:@"%@club/clubdetail.jsp?courseId=%d&teeDate=%@&teeTime=%@",URL_SHARE,_cm.clubId,_cm.date,_cm.time];
            
        }
    }
    if (!_share) {
        _share = [[SharePackage alloc] initWithTitle:title content:content img:_clubImageView.image url:url];
    }
    [_share shareInfoForView:self.view];
}

// 导航按钮事件
- (IBAction)mapAction:(id)sender{
    
    ClubModel *club = [[ClubModel alloc] init];
    club.clubName = _clubInfo.clubName;
    club.address = _clubInfo.address;
    club.latitude = _clubInfo.latitude;
    club.longitude = _clubInfo.longitude;
    club.trafficGuide = _clubInfo.trafficGuide;
    
    YGMapViewCtrl *vc = [YGMapViewCtrl instanceFromStoryboard];
    vc.clubList = @[club];
    [self.navigationController pushViewController:vc animated:YES];
}

// 球场详情信息
- (IBAction)clubDetailAction:(id)sender{
    ClubMoreDetailViewController *clubMoreDetail = [[ClubMoreDetailViewController alloc] init];
    clubMoreDetail.clubId = _cm.clubId;
    clubMoreDetail.clubInfo = _clubInfo;
    [self pushViewController:clubMoreDetail title:@"球场信息" hide:YES];
}

// 球场评分按钮事件
- (IBAction)clubCommentAction:(id)sender{
    [self pushWithStoryboard:@"BookTeetime" title:@"球场评分" identifier:@"ClubCommentController" completion:^(BaseNavController *controller) {
        ClubCommentController *vc = (ClubCommentController*)controller;
        vc.clubId = _cm.clubId;
        vc.refreshBlock = ^(id data){
            _clubInfo.totalLevel = [data intValue];
            [_commentBtn setTitle:[NSString stringWithFormat:@"%d",_clubInfo.totalLevel] forState:UIControlStateNormal];
        };
    }];
}

- (IBAction)weatherDetailAction:(id)sender{
    [self pushWithStoryboard:@"BookTeetime" title:_cm.cityName identifier:@"WeathersViewController" completion:^(BaseNavController *controller) {
        WeathersViewController *vc = (WeathersViewController*)controller;
        vc.weatherArr = _weatherArray;
    }];
}


#pragma mark - UITableView 相关
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _rush ? (_csm.description_.length>0 ? 2 : 1) : 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_rush) {
        return section == 0 ? 3 : 2;
    }else{
        switch (section) {
            case 0:
                return 1;
            case 1:
                if (_errorInfo.length > 0) {
                    return 1;
                }else{
                    if (_isTeetimeAll) {
                        NSInteger rows = (_topSize > 0 ? self.teetimeArr.count - _topSize + 1 : self.teetimeArr.count);
                        return rows;
                    }else {
                        return 5;
                    }
                }
            case 2:
                return 2;
            case 3:
                return 1;
            case 4:
                return _clubInfo.clubManagerData[@"member_id"] ? 1 : 0;
            case 5:
                if (_clubInfo.topicCount > 3) {
                    return _trendArr.count>=3 ? 5 : _trendArr.count+1;
                }else return _trendArr.count + 1;
            default:
                return 0;
        }
    }
}

- (void)toChatViewController:(id) obj{
    __weak typeof(self) weakSelf = self;
    WKDChatViewController *chatVC = [[WKDChatViewController alloc] init];
    chatVC.hidesBottomBarWhenPushed = YES;
    chatVC.targetImage = obj;
    chatVC.memId = [_clubInfo.clubManagerData[@"member_id"] intValue];
    chatVC.title = _clubInfo.clubManagerData[@"display_name"];
    [weakSelf pushViewController:chatVC title:_clubInfo.clubManagerData[@"display_name"] hide:YES];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ygweakify(self);
    if (_rush) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                ClubRushPurchaseCell_Will *cell = [tableView dequeueReusableCellWithIdentifier:@"ClubRushPurchaseCell_Will" forIndexPath:indexPath];
                cell.csm = _csm;
                return cell;
            }else if (indexPath.row == 1){
                NSString *date = [Utilities getDateStringFromString:_csm.teeDate WithFormatter:@"MM月dd日"];
                if (_csm.stockQuantity-_csm.soldQuantity<=0) {
                    OnlyOneLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OnlyOneLineCell_time" forIndexPath:indexPath];
                    cell.showTextLabel.text = [NSString stringWithFormat:@"%@ %@-%@",date,_csm.startTime,_csm.endTime];
                    return cell;
                }else{
                    ThreeLabelsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ThreeLabelsCell" forIndexPath:indexPath];
                    cell.theFirstLabel.text = [NSString stringWithFormat:@"%@ %@-%@",date,_csm.startTime,_csm.endTime];
                    cell.theSecondLabel.text = [NSString stringWithFormat:@"%d位",_csm.stockQuantity-_csm.soldQuantity];
                    cell.theThirdLabel.hidden = (_csm.stockQuantity-_csm.soldQuantity<=4&& _csm.stockQuantity-_csm.soldQuantity > 0) ? NO : YES;
                    return cell;
                }
            }else{
                NSString *identifier = [self getCellIdentifier];
                ClubRushTypesCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
                
                cell.csm = _csm;
                cell.cm = [_cm copy];
                if (cell.refreshBlock == nil) {
                    cell.refreshBlock = ^(id data){
                        ygstrongify(self);
                        [self.tableView reloadData];
                    };
                }
                
                if (cell.callRefreshBlock == nil) {
                    cell.callRefreshBlock = ^(id data){
                        ygstrongify(self);
                        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                        NSArray *array = [userDefault objectForKey:@"ClubCallSetting"];
                        self.callSettingList = [NSArray arrayWithArray:array];
                        [self.tableView reloadData];
                        
                        if (self.callRefreshBlock) {
                            self.callRefreshBlock (array);
                        }
                    };
                }
                if (cell.bookBlock == nil) {
                    cell.bookBlock = ^(id data){
                        ygstrongify(self);
                        NSArray *teetimes = (NSArray*)data;
                        self.confirmTeetime.cm = self.cm;
                        self.confirmTeetime.teetimes = teetimes;
                        self.confirmTeetime.isSpree = YES;
                        self.confirmTeetime.club = self.clubInfo;
                        self.confirmTeetime.isVip = self->_isVip;
                        self.confirmTeetime.canBack = YES;
                        [self.confirmTeetime show:YES index:0 data:nil];
                    };
                }
                return cell;
            }
        }else{
            if (indexPath.row == 0) {
                OnlyOneLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OnlyOneLineCell_noteTitle" forIndexPath:indexPath];
                cell.showTextLabel.text = @"抢购须知";
                return cell;
            }else{
                TwoLabelsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwoLabelsCell_bookNote" forIndexPath:indexPath];
                cell.oneLabel.attributedText = [self dotAttributedStringWithBookNote:_csm.description_];
                cell.otherLabel.attributedText = [[NSAttributedString alloc] initWithString:_csm.description_ attributes:[self bookNoteAttributes:NO]];
                cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
                return cell;
            }
        }
    }else{
        if (indexPath.section == 0) {
            ClubSpecialCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClubSpecialCell" forIndexPath:indexPath];
            cell.teetimeLabel.text = @"";
            cell.minPriceLabel.text = @"";
            if (_specialPriceType == 1) {
                _specialTimeLabel = cell.teetimeLabel;
                cell.teetimeLabel.text = [NSString stringWithFormat:@"%@~%@",_timeStartTime,_timeEndTime];
                cell.minPriceLabel.text = [NSString stringWithFormat:@"%d",_timeMinPrice];
            }
            return cell;
        }else if (indexPath.section == 1){
            if (_errorInfo.length > 0) {
                OnlyOneLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OnlyOneLineCell_c" forIndexPath:indexPath];
                cell.showTextLabel.textColor = [UIColor colorWithHexString:@"666666"];
                cell.showTextLabel.text = _errorInfo;
                return cell;
            }else{

                if (_topSize>0) {// 有官方球场报价
                    if (indexPath.row == 0) {
                        TeetimeListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TeetimeListCell_o" forIndexPath:indexPath];
                        if (self.teetimeArr.count>0) {
                            TTModel *ttm = self.teetimeArr[0];
                            cell.timeMinPrice = _timeMinPrice;
                            cell.clubSpecialOffType = [self specialTypeWithTeetime:ttm.teetime];
                            cell.ttm = ttm;
                            
                            if (cell.bookBlock == nil) {
                                cell.bookBlock = ^(id data){
                                    ygstrongify(self);
                                    TTModel *ttm = (TTModel*)data;
                                    if (ttm.payType == PayTypeVip && !self->_isVip) {
                                        [[GolfAppDelegate shareAppDelegate] alert:nil message:@"该球场为会员球场，非会员不可预定"];
                                    }else{
                                        if (ttm.agentId<0) {
                                            [self callClub];
                                        }else{
                                            self.confirmTeetime.cm = self.cm;
                                            self.confirmTeetime.teetimes = [self.teetimeArr subarrayWithRange:NSMakeRange(0, self.topSize)];
                                            self.confirmTeetime.club = self.clubInfo;
                                            self.confirmTeetime.isVip = self->_isVip;
                                            self.confirmTeetime.canBack = YES;
                                            [self.confirmTeetime show:YES index:1 data:ttm];
                                        }
                                    }
                                };
                            }
                            
                        }
                        
                        return cell;
                    }else if (!_isTeetimeAll && indexPath.row == 4){
                        OnlyOneLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OnlyOneLineCell_c" forIndexPath:indexPath];
                        cell.showTextLabel.textColor = [UIColor colorWithHexString:@"249df3"];
                        cell.showTextLabel.text = @"查看全部商家";
                        return cell;
                    }else{
                        TeetimeListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TeetimeListCell_a" forIndexPath:indexPath];
                        if (indexPath.row < _teetimeArr.count-_topSize+1) {
                            TTModel *ttm = self.teetimeArr[indexPath.row+_topSize-1];
                            cell.timeMinPrice = _timeMinPrice;
                            cell.clubSpecialOffType = [self specialTypeWithTeetime:ttm.teetime];
                            cell.ttm = ttm;
                        }
                        cell.bookBlock = ^(id data){
                            ygstrongify(self);
                            TTModel *ttm = (TTModel*)data;
                            if (ttm.agentId<0) {
                                [self callClub];
                            }else{
                                self.confirmTeetime.cm = self.cm;
                                self.confirmTeetime.teetimes = [self.teetimeArr subarrayWithRange:NSMakeRange(indexPath.row+self.topSize-1, 1)];
                                self.confirmTeetime.club = self.clubInfo;
                                self.confirmTeetime.isVip = self->_isVip;
                                self.confirmTeetime.canBack = NO;
                                [self.confirmTeetime show:YES index:1 data:ttm];
                            }
                        };
                        cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
                        if (indexPath.row == (self.teetimeArr.count - _topSize + 1) -1 ) {
                            cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
                        }
                        return cell;
                    }
                }else{
                    if (!_isTeetimeAll&&indexPath.row == 4) {
                        OnlyOneLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OnlyOneLineCell_c" forIndexPath:indexPath];
                        cell.showTextLabel.textColor = [UIColor colorWithHexString:@"249df3"];
                        cell.showTextLabel.text = @"查看全部商家";
                        return cell;
                    }else{
                        TeetimeListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TeetimeListCell_a" forIndexPath:indexPath];
                        if (indexPath.row<self.teetimeArr.count) {
                            TTModel *ttm = self.teetimeArr[indexPath.row];
                            cell.timeMinPrice = _timeMinPrice;
                            cell.clubSpecialOffType = [self specialTypeWithTeetime:ttm.teetime];
                            cell.ttm = ttm;
                        }
                        cell.bookBlock = ^(id data){
                            ygstrongify(self);
                            TTModel *ttm = (TTModel*)data;
                            if (ttm.payType == PayTypeVip && !self->_isVip) {
                                [[GolfAppDelegate shareAppDelegate] alert:nil message:@"该球场为会员球场，非会员不可预定"];
                            }else{
                                if (ttm.agentId<0) {
                                    [self callClub];
                                }else{
                                    self.confirmTeetime.cm = self.cm;
                                    self.confirmTeetime.teetimes = [self.teetimeArr subarrayWithRange:NSMakeRange(indexPath.row, 1)];
                                    self.confirmTeetime.club = self.clubInfo;
                                    self.confirmTeetime.isVip = self->_isVip;
                                    self.confirmTeetime.canBack = NO;
                                    [self.confirmTeetime show:YES index:1 data:ttm];
                                }
                            }
                        };
                        cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
                        if (indexPath.row == self.teetimeArr.count - 1) {
                            cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
                        }
                        return cell;
                    }
                }
            }
        }else if (indexPath.section == 2){
            TitlePriceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TitlePriceCell" forIndexPath:indexPath];
            cell.ttLabel.text = @"";
            cell.priceLabel.text = @"";
            cell.bottomLine.hidden = YES;
            if (indexPath.row == 0) {
                if (_clubInfo.minTimePrice>0) {
                    cell.ttLabel.text = @"特惠时段";
                    cell.priceLabel.text = [NSString stringWithFormat:@"%d",_clubInfo.minTimePrice];
                    cell.bottomLine.hidden = NO;
                    if (_clubInfo.minPackagePrice <= 0) {
                        cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
                    }
                }
            }else if (indexPath.row == 1){
                if (_clubInfo.minPackagePrice>0) {
                    cell.ttLabel.text = @"旅行套餐（打球＋酒店）";
                    cell.priceLabel.text = [NSString stringWithFormat:@"%d",_clubInfo.minPackagePrice];
                }
                cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
            }
            return cell;
        }else if (indexPath.section == 3){
            TwoLabelsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwoLabelsCell" forIndexPath:indexPath];
            cell.oneLabel.text = @"";
            cell.otherLabel.text = @"";
            if ([LoginManager sharedManager].loginState && _isofficial == 1) {
                if (_isVip) {
                    cell.oneLabel.text = @"您已通过该球场会员身份验证";
                }else if (_isWaitingVip){
                    cell.oneLabel.text = @"您的会员身份正在审核中";
                }else{
                    cell.oneLabel.text = @"我是该球会会员";
                    cell.otherLabel.text = @"立即验证";
                }
            }
            return cell;
        }else if (indexPath.section == 4){
            ClubManagerTableViewCell *cmc = [tableView dequeueReusableCellWithIdentifier:@"ClubManagerTableViewCell" forIndexPath:indexPath];
            if (_clubInfo.clubManagerData[@"member_id"]) {
                cmc.clubManagerData = _clubInfo.clubManagerData;
                if (cmc.sendMsgBlock == nil) {
                    cmc.sendMsgBlock = ^(id obj){
                        ygstrongify(self);
                        [self toChatViewController:obj];
                    };
                }
            }
            return cmc;
        }else{
            if (indexPath.row == 0) {
                TwoLabelsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwoLabelsCell_t" forIndexPath:indexPath];
                cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
                if (_trendArr.count==0) {
                    cell.oneLabel.text = @"暂无动态";
                    cell.otherLabel.text = @"发布动态";
                }else{
                    cell.oneLabel.text = [NSString stringWithFormat:@"球场动态  (%d)",_clubInfo.topicCount];
                    cell.otherLabel.text = @"";
                }
                return cell;
            }else if (indexPath.row == 4){
                OnlyOneLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OnlyOneLineCell_c" forIndexPath:indexPath];
                cell.showTextLabel.textColor = [UIColor colorWithHexString:@"249df3"];
                cell.showTextLabel.text = @"查看全部";
                return cell;
            }else{
                TopicModel *m = _trendArr[indexPath.row-1];
                TrendsTableViewCell *cell = (TrendsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TopicHelp identifierWithTopicModel:m initIdentifier:@"TrendsTableViewCell7-9"] forIndexPath:indexPath];
                cell.showAllContent = NO;
                [cell loadDatas:m];
                cell.btnAttention.hidden = YES;
                cell.delegate = self;
                
                if (cell.blockHeadImageTaped == nil) {
                    cell.blockHeadImageTaped = ^(id data){
                        ygstrongify(self);
                        TopicModel *m = (TopicModel *)data;
                        [self toPersonalHomeControllerByMemberId:m.memberId displayName:m.displayName target:self];
                    };
                }
                
                if (cell.blockNicknameTaped == nil) {
                    cell.blockNicknameTaped = ^(id data){
                        ygstrongify(self);
                        TopicModel *m = (TopicModel *)data;
                        [self toPersonalHomeControllerByMemberId:m.memberId displayName:m.displayName target:self];
                    };
                }
                
                if (cell.blockVipTaped == nil) {
                    cell.blockVipTaped = ^(id data){
                        ygstrongify(self);
                        TopicModel *m = (TopicModel *)data;
                        [[GolfAppDelegate shareAppDelegate] showInstruction:[NSString stringWithFormat:@"http://m.bookingtee.com/vip.html?%d", m.memberLevel] title:@"用户说明" WithController:self];
                    };
                }
                
                if (cell.blockReplyLabelTaped == nil) {
                    cell.blockReplyLabelTaped = ^(id data){
                        ygstrongify(self);
                        [self hideKeyboard];
                        self.viewAction = [data valueForKeyPath:@"el"];
                        self.articleCommentModel = (ArticleCommentModel *)data[@"artice_comment_model"];
                        TopicModel *model = data[@"topic_model"];
                        topicModel_ = model;
                        self.isAttentionOrComment = 1;
                        [self judgeLoginAndPerfectAndIsFollowed];
                    };
                }
                
                if (cell.blockReplyTaped == nil) {
                    cell.blockReplyTaped = ^(id data){
                        ygstrongify(self);
                        self.viewAction = [data valueForKeyPath:@"el"];
                        TopicModel *m = (TopicModel *)[data valueForKeyPath:@"data"];
                        topicModel_ = m;
                        if (m.commentCount == 0) {
                            self.isAttentionOrComment = 2;
                            [self judgeLoginAndPerfectAndIsFollowed];
                        }else{
                            [self toTrendsDetailsViewController:m indexPath:indexPath];
                        }
                    };
                }
                
                if (cell.blockCoachLevelTaped == nil) {
                    cell.blockCoachLevelTaped = ^(id data){
                        ygstrongify(self);
                        TopicModel *m = (TopicModel *)data;
                        [self toPersonalHomeControllerByMemberId:m.memberId displayName:m.displayName target:self];
                    };
                }
                
                if (cell.blockSeeAllContentTaped == nil) {
                    cell.blockSeeAllContentTaped = ^(id data){
                        ygstrongify(self);
                        [self hideKeyboard];
                        TopicModel *m = (TopicModel *)data;
                        m.showAllContent = !m.showAllContent;
                        [self.tableView reloadData];
                    };
                }
                
                if (cell.blockSellAllReplyTaped == nil) {
                    cell.blockSellAllReplyTaped = ^(id data){
                        ygstrongify(self);
                        [self hideKeyboard];
                        [self toTrendsDetailsViewController:data indexPath:indexPath];
                    };
                }
                
                if (cell.blockMoreZanTaped == nil) {
                    cell.blockMoreZanTaped = ^(id data){
                        ygstrongify(self);
                        TopicModel *m = (TopicModel *)data;
                        [self pushWithStoryboard:@"TrendsPraiseList" title:[NSString stringWithFormat:@"%d人赞过",m.praiseCount] identifier:@"TrendsPraiseListController" completion:^(BaseNavController *controller) {
                            TrendsPraiseListController *vc = (TrendsPraiseListController*)controller;
                            vc.topicId = m.topicId;
                        }];
                    };
                }
                if (cell.blockMoreShareTaped == nil) {
                    cell.blockMoreShareTaped = ^(id data){
                        ygstrongify(self);
                        TopicModel *m = (TopicModel *)data;
                        [self pushWithStoryboard:@"TrendsPraiseList" title:[NSString stringWithFormat:@"%d人分享",m.shareCount] identifier:@"TrendsPraiseListController" completion:^(BaseNavController *controller) {
                            TrendsPraiseListController *vc = (TrendsPraiseListController*)controller;
                            vc.isShareList=YES;
                            vc.topicId = m.topicId;
                        }];
                    };
                }
                
                if (cell.blockImagePreview == nil) {
                    cell.blockImagePreview = ^(id data){
                        ygstrongify(self);
                        NSDictionary *nd = (NSDictionary *)data;
                        TopicModel *m = nd[@"data"];
                        UIButton *btn = nd[@"view"];
                        NSMutableArray *rects = nd[@"rects"];
                        
                        CGRect convertRect = [btn.superview convertRect:btn.frame toView:[GolfAppDelegate shareAppDelegate].window];
                        NSInteger index = btn.tag;
                        if (m.topicPictures.count == 4) {
                            if (index == 4) {
                                index = 3;
                            }
                            if (index == 5) {
                                index = 4;
                            }
                        }
                        if (m.topicPictures.count > 0) {
                            id obj = m.topicPictures[0];
                            if ([obj isKindOfClass:[UIImage class]]) {
                                [ImageBrowser IBWithImages:m.topicPictures isCollection:NO currentIndex:index-1 initRt:convertRect isEdit:NO highQuality:NO vc:self backRtBlock:^CGRect(NSInteger i) {
                                    return [rects[i] CGRectValue];
                                } completion:nil];
                                return ;
                            }
                        }
                        
                        [ImageBrowser IBWithImages:m.topicPictures isCollection:NO currentIndex:index-1 initRt:convertRect isEdit:NO highQuality:YES vc:self backRtBlock:^CGRect(NSInteger i) {
                            return [rects[i] CGRectValue];
                        } completion:nil];
                    };
                }
                if (cell.blockVideoPreview == nil) {
                    cell.blockVideoPreview = ^(id data){
                        NSDictionary *nd = (NSDictionary *)data;
                        TopicModel *m = nd[@"data"];
                        BaseVideoPlayController *basevc = [[BaseVideoPlayController alloc] init];
                        basevc.blockReturn = ^(id obj){
                            BaseNavController *vc = (BaseNavController*)obj;
                            [Player playWithUrl:m.topicVideo rt:CGRectZero supportSlowed:YES supportCircle:YES vc:vc completion:^{
                                [vc.navigationController popViewControllerAnimated:NO];
                            }];
                        };
                        [[GolfAppDelegate shareAppDelegate].currentController pushViewController:basevc title:@"" hide:YES animated:NO];
                    };
                }
                
                if (cell.blockTeachingSiteTaped == nil) {
                    cell.blockTeachingSiteTaped = ^(id data){
                        ygstrongify(self);
                        TopicModel *m = (TopicModel *)data;
                        [self pushWithStoryboard:@"Trends" title:@"球场话题" identifier:@"TrendsViewController" completion:^(BaseNavController *controller) {
                            TrendsViewController *vc = (TrendsViewController *)controller;
                            vc.clubId = m.clubId;
                            vc.clubName = m.clubName;
                        }];
                    };
                }
                
                if (cell.blockZanTaped == nil) {
                    __weak UITableViewCell *weakCell = cell;
                    cell.blockZanTaped = ^(id data, UIButton *btn){
                        ygstrongify(self);
                        [self hideKeyboard];
                        TopicModel *m = (TopicModel *)data;
                        if (![LoginManager sharedManager].loginState) {
                            [[LoginManager sharedManager] loginWithDelegate:nil controller:self animate:YES blockRetrun:^(id data) {
                                [TopicHelp zanActionWithModel:m tableViewCell:weakCell tableView:self.tableView block:^(id d) {
                                    btn.userInteractionEnabled = YES;
                                }];
                            } cancelReturn:^(id data) {
                                btn.userInteractionEnabled = YES;
                            }];
                            return;
                        }
                        [TopicHelp zanActionWithModel:m tableViewCell:weakCell tableView:self.tableView block:^(id d) {
                            btn.userInteractionEnabled = YES;
                        }];
                    };
                }
                
                if (cell.blockShareTaped == nil) {
                    cell.blockShareTaped = ^(id data){
                        ygstrongify(self);
                        [self hideKeyboard];
                        if ([LoginManager sharedManager].loginState) {
                            if ([self needPerfectMemberData]) {
                                return;
                            }
                        }
                        NSDictionary *nd = (NSDictionary *)data;
                        TopicModel *m = nd[@"data"];
                        NSString *title = nil;
                        NSString *content = nil;
                        NSString *url = [NSString stringWithFormat:@"%@topic/topic.html?topicId=%d",URL_SHARE,m.topicId];
                        UIImage *img = nil;
                        if (m.topicContent.length > 0 && m.topicPictures.count > 0) {
                            title = [NSString stringWithFormat:@"分享%@的动态",m.displayName];
                            content = m.topicContent;
                            img = nd[@"img"];
                            if (img == nil) {
                                img = [UIImage imageNamed:@"logo.png"];
                            }
                        }else if (m.topicContent.length > 0){
                            title = [NSString stringWithFormat:@"分享%@的动态",m.displayName];
                            content = m.topicContent;
                            img = [UIImage imageNamed:@"logo.png"];
                        }else if (m.topicPictures.count > 0){
                            title = [NSString stringWithFormat:@"分享%@的动态",m.displayName];
                            content = [NSString stringWithFormat:@"分享了%d张图片",(int)m.topicPictures.count];
                            img = nd[@"img"];
                            if (img == nil) {
                                img = [UIImage imageNamed:@"logo"];
                            }
                        }
                        if (!self.share) {
                            self.share = [[SharePackage alloc] init];
                        }
                        self.share.shareTitle = title;
                        self.share.shareContent = content;
                        self.share.shareUrl = url;
                        self.share.shareImg = img;
                        self.share.topicID = m.topicId;
                        [self.share shareInfoForView:self.view];
                    };
                }
                return cell;
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_rush) {
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        // 特价
        if (_specialPriceType == 1) {
            _specialPriceType = 2;
            [self specialTeetimeHandleData:_sfm];
            __weak typeof(self) ws = self;
            [self addAnimationWithView:self.view completion:^(BOOL finished) {
                [ws.timeBtn setTitle:[NSString stringWithFormat:@"%@",ws.cm.time] forState:UIControlStateNormal];
                [ws getTeetimeList];
            }];
        }
    }else if (indexPath.section == 1){
        if (_topSize > 0) {
            if (indexPath.row == 0) {
                [self popTeetimeListView];
            }else if (!_isTeetimeAll && indexPath.row == 4){
                _isTeetimeAll = YES;
                [self.tableView reloadData];
            }
        }else{
            if (!_isTeetimeAll&&indexPath.row == 4) {
                _isTeetimeAll = YES;
                [self.tableView reloadData];
            }
        }
    }else if (indexPath.section == 2){ // 球场列表
        if (indexPath.row == 0) {
            if (_clubInfo.minTimePrice>0) {
                //特价时段
                SpecialOfferListViewController *specialOfferList = [[SpecialOfferListViewController alloc] init];
                specialOfferList.myCondition = [_cm copy];
                [self pushViewController:specialOfferList title:@"特惠时段" hide:YES];
                
            }
        }else if (indexPath.row == 1){
            if (_clubInfo.minPackagePrice>0) {
                // 套餐
                [self getClubPackageList];
            }
        }
    }else if (indexPath.section == 3){ // 特价/套餐
        if ([LoginManager sharedManager].loginState && _isofficial == 1) {
            // 验证球会会员
            if ([LoginManager sharedManager].loginState) {
                if (![LoginManager sharedManager].vipList) {
                    [self getVipListWithCompletion:^(id obj) {
                        [self validateVip];
                    }];
                }else{
                    [self validateVip];
                }
            }else{
                [[LoginManager sharedManager] loginWithDelegate:nil controller:self animate:YES blockRetrun:^(id data) {
                    [self getVipListWithCompletion:^(id obj) {
                        if (!_isVip) {
                            
                            CCAlertView *alertView = [[CCAlertView alloc] initWithTitle:nil message:@"该球会仅限会员预订，非会员不可预订"];
                            [alertView addButtonWithTitle:@"立即验证" block:^{
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    [self validateVip];
                                });
                            }];
                            [alertView addButtonWithTitle:@"取消" block:nil];
                            [alertView show];
                        }
                    }];
                }];
            }
        }
    }else if (indexPath.section == 4){ // 球场经理
        [self toPersonalHomeControllerByMemberId:[_clubInfo.clubManagerData[@"member_id"] intValue] displayName:_clubInfo.clubManagerData[@"display_name"] target:self];
    }else if (indexPath.section == 5){ // 动态
        if (indexPath.row == 0 || indexPath.row == 4) {
            if (_trendArr.count == 0) {
                if (_cm.clubId > 0) {
                    if (![LoginManager sharedManager].loginState) {
                        ygweakify(self)
                        [[LoginManager sharedManager] loginWithDelegate:nil controller:self animate:YES blockRetrun:^(id data) {
                            ygstrongify(self)
                            [self toYGTeachingArchivePublishViewCtrl];
                        }];
                        return;
                    }
                    [self toYGTeachingArchivePublishViewCtrl];

                }
                return;
            }
            NSArray *subControllers = [GolfAppDelegate shareAppDelegate].naviController.viewControllers;
            for (NSInteger i=subControllers.count-1; i>=0; i--) {
                BaseNavController *bc = subControllers[i];
                if ([bc isKindOfClass:[TrendsViewController class]]) {
                    [bc back];
                    return;
                }
            }
            [self pushWithStoryboard:@"Trends" title:@"球场话题" identifier:@"TrendsViewController" completion:^(BaseNavController *controller) {
                YGPostBuriedPoint(YGFeedPointlist_Course);
                TrendsViewController *vc = (TrendsViewController *)controller;
                vc.clubId = _cm.clubId;
                vc.clubName = _clubInfo.clubName;
            }];
        }else {
            [self toTrendsDetailsViewController:_trendArr[indexPath.row-1] indexPath:indexPath];
        }
    }
}

- (void)toYGTeachingArchivePublishViewCtrl{
    SearchClubModel *clubModel = [SearchClubModel new];
    clubModel.clubId = _cm.clubId;
    clubModel.clubName = _cm.clubName;
    
    YGPublishViewCtrl *vc = [YGPublishViewCtrl instanceFromStoryboard];
    vc.publishType = YGPublishTypeTopic;
    vc.clubModel = clubModel;
    vc.taPublishBlock = ^(NSMutableDictionary *data){
        [self insertPublicTopicFirst:data];
    };
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)toTrendsDetailsViewController:(TopicModel *)m indexPath:(NSIndexPath *)indexPath{
    ygweakify(self)
    [TopicHelp toTrendsDetailsViewController:m indexPath:indexPath target:self blockDelete:^(id data) {
        TopicModel *d = (TopicModel *)data;
        ygstrongify(self)
        for (id obj in self.trendArr) {
            if ([obj isKindOfClass:[TopicModel class]]) {
                TopicModel *mm = (TopicModel *)obj;
                if (mm.topicId == d.topicId) {
                    [self.trendArr removeObject:obj];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationNone)];
                    break;
                }
            }
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_rush) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                CGSize sz = [Utilities getSize:_csm.spreeName withFont:[UIFont systemFontOfSize:16] withWidth:Device_Width-26];
                if (sz.height>30) {
                    return 70-20 + sz.height;
                }
                return 70;
            }else if (indexPath.row == 1){
                return _csm.stockQuantity-_csm.soldQuantity<=0 ? 45 : 68;
            }else{
                if (_csm.stockQuantity-_csm.soldQuantity<=0) {
                    return 94;
                }else{
                    return [ClubRushTypesCell timeIntervalWithCompareResult:_csm.spreeTime timeInterGab:[LoginManager sharedManager].timeInterGab]<0 ? 64 : 94;
                }
            }
        }else{
            if (_csm.description_.length == 0) {
                return 0;
            }else{
                if (indexPath.row == 0) {
                    return 40;
                }else{
                    CGSize sz = [Utilities getSize:_csm.description_ attributes:[self bookNoteAttributes:YES] withWidth:Device_Width-43];
                    return sz.height + 37;
                }
            }
        }
    }else{
        if (indexPath.section == 0) {
            return _specialPriceType == 1 ? 69 : 0;
        }else if (indexPath.section == 1){
            if (_errorInfo.length>0) {
                return [Utilities getSize:_errorInfo withFont:[UIFont systemFontOfSize:14] withWidth:Device_Width-26].height+23;
            }else{
                if (_topSize>0) {
                    if (indexPath.row == 0) {
                        return 85;
                    }else if (!_isTeetimeAll&&indexPath.row == 4){
                        return 40;
                    }else{
                        return 64;
                    }
                }else{
                    return indexPath.row == 4 && !_isTeetimeAll ? 40 : 64;
                }
            }
        }else if (indexPath.section == 2){
            if (indexPath.row == 0) {
                return _clubInfo.minTimePrice>0 ? 40 : 0;
            }else if (indexPath.row == 1){
                return _clubInfo.minPackagePrice>0 ? 40 : 0;
            }
        }else if (indexPath.section == 3){
            return [LoginManager sharedManager].loginState && _isofficial == 1 ? 40 : 0;
        }else if (indexPath.section == 4){
            if (_clubInfo.clubManagerData[@"member_id"]) {
                return 69;
            }
        }else{
            if (indexPath.row == 0) {
                return 40;
            }else if (indexPath.row == 4){
                return 40;
            }else{
                TopicModel *modal = _trendArr[indexPath.row-1];
                return [self  heightWithModel:modal hasDetails:YES indexPath:indexPath];
            }
        }
    }
    return 0;
}

- (CGFloat)heightWithModel:(TopicModel *)model hasDetails:(BOOL)hasDetails indexPath:(NSIndexPath *)indexPath{
    CGFloat imgHeight = 0;
    CGFloat contentWidth = 0;
    CGFloat replyWidth = 0;
    
    if (IS_3_5_INCH_SCREEN){
        imgHeight = 74;
        contentWidth = 240;
        replyWidth = 222;
    }else if( IS_4_0_INCH_SCREEN) {
        imgHeight = 74;
        contentWidth = 240;
        replyWidth = 222;
    }else if(IS_4_7_INCH_SCREEN){
        imgHeight = 92.5;
        contentWidth = 295;//
        replyWidth = 277;//287;
    }else if(IS_5_5_INCH_SCREEN) {
        imgHeight = 105.33333333333334;
        contentWidth = 334;
        replyWidth = 316;
    }
    
    CGFloat height = 55; //头像高度55

    //内容文本高度
    if (model.plainContent && model.plainContent.length > 0) {
        CGSize size = [model.plainContent boundingRectWithSize:CGSizeMake(contentWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName :[UIFont systemFontOfSize:15]} context:nil].size;
        
        int count = size.height / 17.895;
        
        if (model.showAllContent) {
            height += size.height;
            height += 21; //查看全文按钮高度
        }else{
            if (count > 5) {
                height += 17.895 * 5;  //超过5行只显示5行
                height += 21; //查看全文按钮高度
            }else{
                height += size.height;
            }
        }
        
        height += 8;//文字顶部距离
    }
    if ([model.topicType intValue] == 0 || [model.topicType intValue] == 2) {//普通动态
        switch (model.topicPictures.count) { //4.72.5  6.  6p.
            case 1:{
                BOOL hasVideo = (model.topicVideo && model.topicVideo.length > 0);
                
                id obj = model.topicPictures[0];
                CGFloat cellHeight = [TopicHelp heightWithImage:obj hasVideo:hasVideo];
                if (model.cellHeight != cellHeight) {
                    model.cellHeight = cellHeight;
                }
                height += (model.cellHeight == 0 ? 152:model.cellHeight);
            }
                break;
            case 2:
            case 3:
                height += imgHeight;
                break;
            case 4:
            case 5:
            case 6:
                height += (imgHeight * 2 + 4);
                break;
            case 7:
            case 8:
            case 9:
                height += (imgHeight * 3 + (4 * 2));
                break;
            default:
                break;
        }
        
        //公里、地址、高度
        if (model.topicPictures.count > 0) {
            height += 24;
        }else{
            height += 14;
        }
    }else if ([model.topicType intValue] == 1){//悦读分享
        height += 80;
    }
    
    //下场时间等足迹信息的高度
    if (model.teeDate != nil) {
        //        height += 20;
        if (model.cardId == 0 || model.publicMode == 0) {
            height += 20;
        }else{
            height += 70 + 20;
        }
    }else{
        if (model.sourceInfo.length > 0) {
            height += 20;
        }
    }
    
    //三个按钮高度 + 按钮距离上部分空间的高度 + 按钮下部分距离
    height += (24 + 13 + 15);
    
    
    if (hasDetails) {
        //赞、分享、回复评论视图的高度
        if (model.praiseList.count == 0 && model.commentList.count == 0 && model.shareList.count == 0) {
            height += 6; //单元格最底部间距
        }else{
            //赞视图高度
            if (model.praiseList.count > 0) {
                height += 52;
            }else{
                height += 0;
            }
            
            //分享视图高度
            if (model.shareList.count > 0) {
                height += 52;
            }else{
                height += 0;
            }
            
            //回复视图高度
            if (model.commentCount > 0) {
                
                NSMutableArray *list5 = [[NSMutableArray alloc] initWithCapacity:5];
                if (model.commentList.count <= 5) {
                    [list5 addObjectsFromArray:model.commentList];
                }else{
                    [list5 addObjectsFromArray:[model.commentList subarrayWithRange:NSMakeRange(model.commentList.count - 5, 5)]];
                }
                
                for (int i = 1; i <= 5; i++) {
                    if (i <= list5.count) {
                        ArticleCommentModel *nd = list5[i -1];
                        
                        NSString *text = @"";
                        
                        if (nd.toMemberId > 0) {
                            if (nd.toMemberId == model.memberId) {
                                text = [NSString stringWithFormat:@"%@@:%@",nd.displayName,nd.commentContent];
                            }else{
                                text = [NSString stringWithFormat:@"%@ 回复 %@:%@",nd.displayName,nd.toDisplayName,nd.commentContent];
                            }
                        }else{
                            text = [NSString stringWithFormat:@"%@:%@",nd.displayName,nd.commentContent];
                        }
                        
                        CGSize size = [text boundingRectWithSize:CGSizeMake(replyWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
                        
                        if (size.height >= (16.701999999999998 * 2)) {  //如果超过两行则是算两行高度
                            height += (16.701999999999998 * 2);
                        }else{
                            height += size.height;
                        }
                        height += 6; //6是标签之间的高度
                    }
                }
                if (model.commentCount > 5) { //查看全部评论按钮的高度
                    height += 34;
                }else{
                    height += 4;
                }
                height += 13;//容器内容底部的间距
            }else{
                if ((model.praiseList.count > 0 && model.shareList.count == 0) || (model.praiseList.count == 0 && model.shareList.count > 0)) {
                    height += 10;
                }
                if (model.praiseCount > 0 && model.shareCount > 0) {
                    height += 10;
                }
            }
            height += 12;
        }
    }else{
        height += 12;
    }
    
    return height;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_rush) {
        return section == 0 ? 0 : 10;
    }else{
        if (section == 0) {
            return 40;
        }else if (section == 1){
            return 0;
        }else if (section == 2){
            return (_clubInfo.minTimePrice>0 || _clubInfo.minPackagePrice>0) ? 10 : 0;
        }else if (section == 3){
            return [LoginManager sharedManager].loginState && _isofficial == 1 ? 10 : 0;
        }else if (section == 4){
            if (_clubInfo.clubManagerData[@"member_id"]) {
                return 10;
            }
        }else if (section == 5){
            return 10;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        if (_rush) {
            return nil;
        }
        ClubChooseDTCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClubChooseDTCell"];
        _dateBtn = cell.dateBtn;
        _timeBtn = cell.timeBtn;
        [_dateBtn setTitle:[self dateBtnTitle] forState:UIControlStateNormal];
        [_timeBtn setTitle:_cm.time forState:UIControlStateNormal];
        
        cell.blockClick = ^(id data){
            NSInteger index = [data integerValue];
            if (index == 1) {
                [ChooseDateController controllerWithTarget:self date:_cm.date clubId:_cm.clubId completion:^(NSString *selectDate) {
                    if (selectDate) {
                        NSString *dateString = [NSString stringWithFormat:@"%@ %@:00",selectDate,_cm.time];
                        NSDate *date = [Utilities getDateFromString:dateString WithFormatter:@"yyyy-MM-dd HH:mm:ss"];
                        NSDate *currentDate = [CalendarClass dateForStandardTodayAll];
                        if ([date timeIntervalSinceDate:currentDate]<0) {
                            NSString *hour = [Utilities getHourByDate:currentDate];
                            NSString *minute = [Utilities getMinuteByDate:currentDate];
                            NSString *time = [NSString stringWithFormat:@"%@:%@",hour,minute];
                            if ([minute integerValue]>0&&[minute integerValue]<30) {
                                minute = @"30";
                                time = [NSString stringWithFormat:@"%@:%@",hour,minute];
                            }else if ([minute integerValue] > 30){
                                currentDate = [currentDate dateByAddingTimeInterval:1800];//加半个小时
                                hour = [Utilities getHourByDate:currentDate];
                                time = [NSString stringWithFormat:@"%@:00",hour];
                            }
                            NSArray *arr = [time componentsSeparatedByString:@":"];
                            if ([arr[0] integerValue]*60+[arr[1] integerValue]>1230) {
                                [[GolfAppDelegate shareAppDelegate] alert:nil message:@"您选择的开球日期或时间已过，请重新选择时间预订"];
                                return ;
                            }else{
                                _cm.time = time;
                            }
                        }
                        _cm.date = selectDate;
                        [self getTeetimeList];
                    }
                }];
            }else{
                [ChooseTimeController controllerWithTarget:self date:_cm.date time:_cm.time clubId:_cm.clubId completion:^(NSString *selectTime) {
                    if (selectTime) {
                        _cm.time = selectTime;
                        [self getTeetimeList];
                    }
                }];
            }
        };
        return cell;
    }
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, -2, Device_Width, 12)];
    headView.backgroundColor = [UIColor colorWithHexString:@"f1f0f6"];
    return headView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self scrollViewDidScrollWithOffset:scrollView.contentOffset.y];
}

#pragma mark - 键盘聊天控制相关

- (NSInteger)specialTypeWithTeetime:(NSString*)teetime{
    NSInteger type = 0;
    BOOL isSpecialPrice = [Utilities compareTimeWithCurrentTime:teetime beginTime:_timeStartTime endTime:_timeEndTime];
    type = isSpecialPrice ? 2 : 1;
    return type;
}

-(void)hideKeyboard{
    [super hideKeyboard];
    self.memberId = 0;
    self.displayName = nil;
    [self.inputToolbar setPlaceHolder:@"请输入评论内容"];
}



- (void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressRightBarButton:(UIButton *)sender
{
    [self sendContent:toolbar.contentView.textView.text];
}


- (void)sendContent:(NSString*)text{
    [self.inputToolbar.contentView.textView setText:@""];
    if (text && text.length > 0) {
        replyContent = text;
        
        if (![LoginManager sharedManager].loginState) {
            [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES blockRetrun:^(id data) {
                [self _sendContent:text];
            }];
            return;
        }
        [self _sendContent:text];
    }
}

- (void)_sendContent:(NSString *)text{
    if ([Utilities isBlankString:text]) {
        [SVProgressHUD showInfoWithStatus:@"输入的内容无效"];
        return;
    }
    
    if ([self needPerfectMemberData]) {
        return;
    }
    
    if (text.length > 200) {
        [SVProgressHUD showInfoWithStatus:@"您输入的文字过长，不能超过200字符"];
        return;
    }
    
    
    [ServerService topicCommentAdd:[[LoginManager sharedManager] getSessionId] topicId:topicModel_.topicId toMemberId:self.memberId text:text success:^(id data) {
        
        topicModel_.commentCount ++;
        ArticleCommentModel *cm = [[ArticleCommentModel alloc] initWithDic:data];
        if (topicModel_.commentList == nil) {
            topicModel_.commentList = [[NSMutableArray alloc] init];
        }
        [topicModel_.commentList addObject:cm];
        
        NSDictionary *nd = @{@"topicModel":topicModel_,@"articCommentModel":cm,@"api":@"topic_comment_add"};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTopicSignalCell" object:nd];
        
        topicModel_ = nil;
        self.memberId = 0;
        self.displayName = @"";
        [self hideKeyboard];
        
    } failure:^(id error) {
        topicModel_ = nil;
        self.memberId = 0;
        self.displayName = @"";
    }];
}




#pragma mark - 抢购相关

- (NSString*)getCellIdentifier{
    NSString *identifier = nil;
    // 已抢光
    if (_csm.stockQuantity-_csm.soldQuantity<=0) {
        identifier = @"ClubRushTypesCell_over";
    }else{
        NSTimeInterval timeInterval = [ClubRushTypesCell timeIntervalWithCompareResult:_csm.spreeTime timeInterGab:[LoginManager sharedManager].timeInterGab];
        NSDate *spreeDate = [Utilities getDateFromString:_csm.spreeTime WithFormatter:@"yyyy-MM-dd HH:mm:ss"];
        NSInteger dayIndex = [spreeDate timeIntervalSinceDate:[CalendarClass dateForToday]] / (3600*24);
        
        if (timeInterval / (24*3600) < 0) {
            // 正在抢购
            identifier = @"ClubRushTypesCell_rushing";
        }else{
            if (dayIndex < 0) {
                identifier = @"ClubRushTypesCell_rushing";
            }else if (dayIndex == 0){
                if (timeInterval / (24*3600) < 1){// 小于24小时
                    // 小于10分钟
                    if (timeInterval < 10*60) {
                        identifier = @"ClubRushTypesCell_willrush";
                    }else{
                        identifier = _csm.hasSetted ? @"ClubRushTypesCell_setted" : @"ClubRushTypesCell_setting";
                    }
                }else{
                    identifier = _csm.hasSetted  ? @"ClubRushTypesCell_oneday_setted" : @"ClubRushTypesCell_oneday_setting";
                }
            }else{
                identifier = _csm.hasSetted  ? @"ClubRushTypesCell_oneday_setted" : @"ClubRushTypesCell_oneday_setting";
            }
        }
    }
    return identifier;
}

// 点击查看特价，时间处理算法
- (void)specialTeetimeHandleData:(SpecialOfferModel *)model{
    if (model) {
        _cm.clubId = model.clubId;
        _cm.weekDay = model.weekDay;
        
        if (model.weekDay > 0) {
            NSDate *endDate = [Utilities getDateFromString:model.endDate];
            NSDate *today = [Utilities changeDateWithDate:[NSDate date]];
            NSInteger currentIndex = [Utilities weekDayByDate:[NSDate date]];
            NSDate *date = nil;
            if([endDate timeIntervalSinceDate:today] == 0) {
                _cm.date = [Utilities stringwithDate:endDate];
            }else if (model.weekDay == 1) {
                if (currentIndex == 1) {
                    date = [Utilities getTheDay:[NSDate date] withNumberOfDays:7];
                }
                else{
                    date = [Utilities getTheDay:[NSDate date] withNumberOfDays:(8-currentIndex)];
                }
            }else{
                if (model.weekDay > currentIndex) {
                    if (currentIndex == 1) {
                        date = [Utilities getTheDay:[NSDate date] withNumberOfDays:(7-model.weekDay)];
                    }
                    else{
                        date=[Utilities getTheDay:[NSDate date] withNumberOfDays:(model.weekDay-currentIndex)];
                    }
                }else{
                    date=[Utilities getTheDay:[NSDate date] withNumberOfDays:(model.weekDay-currentIndex+7)];
                }
            }
            _cm.date = [Utilities stringwithDate:date];
        }else{
            _cm.date = model.beginDate;
        }
        
        if (model.beginTime.length <= 0 || model.endTime.length <= 0) {
            _cm.time = @"07:30";
        }else{
            _cm.time = [self setMidValue:model];
        }
        _cm.time = [Utilities minTimeWithDate:_cm.date time:_cm.time];
    }
}

- (int)setValueLength:(NSString *)value{
    NSArray *array = [value componentsSeparatedByString:@":"];
    if (array&&array.count==2) {
        int timeInterval = [[array objectAtIndex:0] intValue]*60 + [[array objectAtIndex:1] intValue];
        return timeInterval;
    }
    return 0;
}

- (NSString *)setMidValue:(SpecialOfferModel *)model{
    int timeInterval1 = [self setValueLength:model.beginTime];
    int timeInterval2 = [self setValueLength:model.endTime];
    int timeHour = (timeInterval1 + timeInterval2)/120;
    int timeMin = ((timeInterval1 + timeInterval2) / 2) % 60;
    if (timeMin < 15 || timeMin > 45) {
        timeMin = 0;
        return [NSString stringWithFormat:@"%02d:%02d",timeHour,timeMin];
    }else{
        timeMin = 30;
        return [NSString stringWithFormat:@"%02d:%02d",timeHour,timeMin];
    }
    return nil;
}


- (void)showChat:(ArticleCommentModel *)nd{
    if (![LoginManager sharedManager].loginState) {
        [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES blockRetrun:^(id data) {
            [self showChat_:nd];
        }];
        return;
    }
    [self showChat_:nd];
}

- (void)removeCommentModel:(ArticleCommentModel *)nd{
    [ServerService topicCommentDelete:[[LoginManager sharedManager] getSessionId] commentId:nd.commentId topicId:topicModel_.topicId success:^(id obj) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTopicSignalCell" object:@{@"topicModel":topicModel_,@"articCommentModel":nd,@"api":@"topic_comment_delete"}];
    } failure:nil];
}

- (void)showChat_:(ArticleCommentModel *)nd{
    if (nd.memberId == [LoginManager sharedManager].session.memberId) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self removeCommentModel:nd];
        }];
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [alert addAction:actionCancel];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    self.memberId = nd.memberId;
    self.displayName = nd.displayName;
    [self showChatWithPlaceHolder:[NSString stringWithFormat:@"回复%@:",self.displayName]];
}



- (void)getClubPackageList{
    [[ServiceManager serviceManagerWithDelegate:self] getClubPackageListWithClubId:_cm.clubId];
}

- (void)pushVC:(PackageDetailModel *)packageDetail
{
    YGPackageDetailViewCtrl *vc = [YGPackageDetailViewCtrl instanceFromStoryboard];
    vc.packageId = packageDetail.packageId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)getPackageDetailInfo:(NSArray *)array{
    PackageModel * model = [array objectAtIndex:0];
    [[ServiceManager serviceManagerWithDelegate:self] getPackageDetailListWithPackageId:model.packageId clubId:model.clubId agentId:model.agentId];
}

- (void)enterCityMultiplePackageVCWithList:(NSArray *)array{
    CityMultiplePackageViewController *cityMultiplePackage = [[CityMultiplePackageViewController alloc] init];
    cityMultiplePackage.clubId = _cm.clubId;
    cityMultiplePackage.multipleList = array;
    [self pushViewController:cityMultiplePackage title:_clubInfo.clubName hide:YES];
}


#pragma mark - 验证球会会员相关
- (void)getVipListWithCompletion:(void(^)(id obj))completion{
    _isVip = NO;
    _isWaitingVip = NO;
    
    [[LoginManager sharedManager] loadVipListWithVipStatus:-1 clubId:_cm.clubId statusBlock:^(int vipType) {
        if (vipType == 0) {
            _isVip = YES;
        }else if (vipType == 1){
            _isWaitingVip = YES;
        }
        [self.tableView reloadData];
        if (completion) {
            completion (nil);
        }
    }];
}

// 验证会员身份
- (void)validateVip{
    // 0表示已通过审核
    // 1表示等待审核
    if (_isVip) {
        [[GolfAppDelegate shareAppDelegate] alert:nil message:@"您已是该球会的会员，无需再验证"];
    }else if (_isWaitingVip){
        
        CCAlertView *alert = [[CCAlertView alloc] initWithTitle:@"" message:@"您的验证申请已经发送，等待球会审核。您也可以直接拨打球会电话，要求球会验证会员身份。"];
        [alert addButtonWithTitle:@"取消" block:nil];
        [alert addButtonWithTitle:@"拨打电话" block:^{
            [self callClub];
        }];
        [alert show];
        
    }else{
        VipValidateViewController *vipValidate = [[VipValidateViewController alloc] init];
        vipValidate.clubId = _cm.clubId;
        vipValidate.phoneNum = _clubInfo.phone;
        vipValidate.blockReturn = ^ (id obj){
            [self getVipListWithCompletion:nil];
        };
        [self pushViewController:vipValidate title:_cm.clubName hide:YES];
    }
}


- (void)callClub
{
    if (self.clubInfo.phone.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"该商家未设置客服电话"];
    }else{
        [YGCapabilityHelper call:self.clubInfo.phone needConfirm:NO];
    }
}


- (void)publishTopicFailured{
    for (TopicModel *m in _trendArr) {
        if ([m isKindOfClass:[TopicModel class]]) {
            if ([@"发布中" isEqualToString:m.topicTime]) {
                m.topicTime = @"发布失败";
                [self.tableView reloadData];
                break;
            }
        }
    }
}

-(void)insertPublicTopicFirst:(NSMutableDictionary *)data{
    TopicModel *m = [[TopicModel alloc] init];
    m.memberId = [LoginManager sharedManager].session.memberId;
    m.memberLevel = [LoginManager sharedManager].session.memberLevel;
    m.displayName = [LoginManager sharedManager].session.displayName;
    m.headImage = [LoginManager sharedManager].session.headImage;
    m.topicTime = @"发布中";
    if (data[@"location"]) {
        m.clubName = data[@"location"];
    }
    if (data[@"content"]) {
        m.topicContent = data[@"content"];
        m.plainContent = [Utilities plainTextWithText:m.topicContent];
    }
    if (data[@"video"]) {
        m.topicVideo = data[@"video"];
    }
    if (data[@"images"]) {
        m.topicPictures = data[@"images"];
    }
    m.isTemp = YES;
    if (_trendArr) {
        [_trendArr removeAllObjects];
        m.cellHeight = [TopicHelp heightWithImage:[m.topicPictures firstObject] hasVideo:(m.topicVideo && m.topicVideo.length > 0)];
        [_trendArr addObject:m];
        [self.tableView reloadData];
    }
}


- (NSAttributedString *)dotAttributedStringWithBookNote:(NSString *)bookNote{
    if (!bookNote && bookNote.length == 0) {
        return nil;
    }
    bookNote = [bookNote stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    NSArray *arr = [bookNote componentsSeparatedByString:@"\n"];
    if (arr.count > 0) {
        NSMutableString *dotString = [NSMutableString string];
        for (NSString *str in arr) {
            CGSize sz = [Utilities getSize:str withFont:[UIFont systemFontOfSize:14] withWidth:Device_Width-43];
            if (sz.height > 14) {
                [dotString appendString:@"•\n"];
            }else {
                continue;
            }
            int lineNum = sz.height / 20;
            for (int i=0; i<lineNum; i++) {
                [dotString appendString:@"\n"];
            }
        }
        return [[NSAttributedString alloc] initWithString:dotString attributes:[self bookNoteAttributes:YES]];
    }else{
        return nil;
    }
}

- (NSDictionary*)bookNoteAttributes:(BOOL)isDot{
    NSMutableParagraphStyle *mps = [[NSMutableParagraphStyle alloc] init];
    mps.lineSpacing = 7;
    return @{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor colorWithHexString:isDot?@"999999":@"333333"],NSParagraphStyleAttributeName:mps};
}


- (void)addAnimationWithView:(UIView*)spView completion:(void(^)(BOOL finished))completion{
    CGPoint pts = [_specialTimeLabel.superview convertPoint:_specialTimeLabel.center toView:self.view];
    CGPoint pte = [_timeBtn.superview convertPoint:_timeBtn.center toView:self.view];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 16)];
    label.center = pts;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor colorWithHexString:@"666666"];
    label.text = [NSString stringWithFormat:@"%@",_cm.time];
    [spView addSubview:label];
    
    [Utilities mutablePathMoveAnimationWithStartPoint:CGPointMake(pts.x, pts.y) endPoint:CGPointMake(pte.x, pte.y) controlPoint:CGPointMake(pte.x/2,pte.y-40) view:label duration:0.6 completion:completion];
}

#pragma mark - JudgeLoginAndPerfectAndIsFollowed
- (void)judgeLoginAndPerfectAndIsFollowed {
    if (![LoginManager sharedManager].loginState) {
        [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES blockRetrun:^(id data) {
            self.isOneDetailList = YES;
            [[ServiceManager serviceManagerWithDelegate:self] topicList:[[LoginManager sharedManager] getSessionId] tagId:0 tagName:nil memberId:topicModel_.memberId clubId:0 topicId:topicModel_.topicId topicType:0 pageNo:1 pageSize:20 longitude:[LoginManager sharedManager].currLongitude latitude:[LoginManager sharedManager].currLatitude];
        }];
        return;
    };
    if (topicModel_.isFollowed == -1) {
        self.isOneDetailList = YES;
        [[ServiceManager serviceManagerWithDelegate:self] topicList:[[LoginManager sharedManager] getSessionId] tagId:0 tagName:nil memberId:topicModel_.memberId clubId:0 topicId:topicModel_.topicId topicType:0 pageNo:1 pageSize:20 longitude:[LoginManager sharedManager].currLongitude latitude:[LoginManager sharedManager].currLatitude];
        return;
    }
    if ([self needPerfectMemberData]) {
        return;
    }
    if (_isAttentionOrComment == 1) {
        if (topicModel_.isFollowed == 3 || topicModel_.isFollowed == 6) {
            [SVProgressHUD showInfoWithStatus:@"禁止评论"];
        } else {
            [self showChat:_articleCommentModel];
        }
    } else if (_isAttentionOrComment == 2) {
        if (topicModel_.isFollowed == 3 || topicModel_.isFollowed == 6) {
            [SVProgressHUD showInfoWithStatus:@"禁止评论"];
        } else {
            [self showChatWithPlaceHolder:@"请输入评论内容"];
        }
    }
}
@end


