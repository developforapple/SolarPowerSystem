//
//  ChooseCoachListController.m
//  Golf
//
//  Created by 黄希望 on 15/5/7.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "ChooseCoachListController.h"
#import "MJRefresh.h"
#import "ChooseCoachCell.h"
#import "ChooseCoachHeadView.h"
#import "JXConfirmOrderController.h"
#import "JXChooseTimeController.h"
#import "CoachDetailsViewController.h"
#import "TeachingCourseType.h"
#import "PublicCourseDetailController.h"
#import "NoResultView.h"
#import "YGMapViewCtrl.h"

@interface ChooseTeachingModel : NSObject

@property (nonatomic,assign) int academyId;             // 学院id
@property (nonatomic,strong) NSString *academyName;     // 学院名
@property (nonatomic,assign) float distance;            // 距离
@property (nonatomic,strong) NSString *address;         // 详细地址
@property (nonatomic,assign) double longitude;
@property (nonatomic,assign) double latitude;
@property (nonatomic,strong) NSMutableArray *coachList; // 教练列表

@end

@implementation ChooseTeachingModel @end

@interface ChooseCoachListController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,assign) int page;
@property (nonatomic,assign) int currentAcademyId; // 当前取到的学院id
@property (nonatomic,assign) BOOL isMore;


@property (nonatomic,strong) TeachProductDetail *teachProductDetail;

@end

@implementation ChooseCoachListController{
    NoResultView *noResultView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getTeachingProduct];
}

- (void)getTeachingProduct{
    [[ServiceManager serviceManagerWithDelegate:self] teachingProductDetail:self.productId];
}

- (void)initization{
    self.dataSource = [NSMutableArray array];
    self.isMore = YES;
    
    __weak ChooseCoachListController *weakSelf = self;
    noResultView = [NoResultView text:@"该地区暂无适配教练" type:NoResultTypeList superView:self.view show:^{
        weakSelf.tableView.hidden = YES;
    } hide:^{
        weakSelf.tableView.hidden = NO;
    }];
    
    self.tableView.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
        weakSelf.page = 1;
        weakSelf.isMore = YES;
        weakSelf.currentAcademyId = 0;
        [weakSelf loadDataPageNo:weakSelf.page];
    }];
    
    self.tableView.mj_footer = [MJRefreshFooter footerWithRefreshingBlock:^{
        weakSelf.page++;
        [weakSelf loadDataPageNo:weakSelf.page];
    }];
    
    [self.tableView.mj_header beginRefreshing];
}

- (void)loadDataPageNo:(int)page{
    if (self.isMore) {
        [[ServiceManager serviceManagerWithDelegate:self] getCoachListByPageNo:page pageSize:100 withLongitude:[LoginManager sharedManager].currLongitude latitude:[LoginManager sharedManager].currLatitude cityId:self.cityId orderBy:0 date:nil time:nil keyword:nil academyId:0 productId:self.productId];
    }else{
        [self.tableView.mj_footer endRefreshing];
    }
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray*)data;
    if (Equal(flag, @"teaching_coach_info")) {
        if (self.page == 1) {
            [self.dataSource removeAllObjects];
        }
        [self handleData:array];
        if (array.count > 0) {
            self.isMore = YES;
            self.tableView.mj_footer.hidden = NO;
        }else{
            self.isMore = NO;
            self.tableView.mj_footer.hidden = YES;
        }
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        [noResultView show:self.dataSource.count == 0];
    }else if (Equal(flag, @"teaching_product_detail")){
        if (array.count > 0) {
            self.teachProductDetail = array[0];
            [self initization];
        }
    }
}

// 处理数据
- (void)handleData:(NSArray*)array{
    if (array.count > 0) {
        for (TeachingCoachModel *model in array) {
            if (model.academyId != self.currentAcademyId) { // 新增
                self.currentAcademyId = model.academyId;
                ChooseTeachingModel *choose = [[ChooseTeachingModel alloc] init];
                choose.academyId = model.academyId;
                choose.academyName = model.academyName;
                choose.distance = model.distance;
                choose.address = model.address;
                choose.longitude = model.longitude;
                choose.latitude = model.latitude;
                choose.coachList = [NSMutableArray arrayWithObject:model];
                [self.dataSource addObject:choose];
            }else{ // 同一页或不同页
                ChooseTeachingModel *choose = [self.dataSource lastObject];
                [choose.coachList addObject:model];
            }
        }
    }
}

#pragma mark - UITableView delegate && dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.dataSource.count > 0) {
        ChooseTeachingModel *teachingModel = self.dataSource[section];
        return [teachingModel.coachList count];
    }else{
        return 0;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChooseCoachCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChooseCoachCell"];
    if (self.dataSource.count > 0) {
        ChooseTeachingModel *teachingModel = self.dataSource[indexPath.section];
        if (teachingModel.coachList.count>0&&indexPath.row<teachingModel.coachList.count) {
            TeachingCoachModel *model = teachingModel.coachList[indexPath.row];
            cell.classType = self.teachProductDetail.classType;
            cell.teachingCoachModel = model;
            cell.blockReturn = ^(id obj){
                int classType = [obj intValue];
                if (classType == TeachingCourseTypeMulti) {
                    [self pushWithStoryboard:@"Jiaoxue" title:@"确认订单" identifier:@"JXConfirmOrderController" completion:^(BaseNavController *controller) {
                        JXConfirmOrderController *confirmOrder = (JXConfirmOrderController *)controller;
                        confirmOrder.teachingCoach = model;
                        confirmOrder.productId = self.productId;
                        confirmOrder.publicClassId = self.publicClassId;
                        confirmOrder.productName = self.teachProductDetail.productName;
                        confirmOrder.sellingPrice = self.teachProductDetail.sellingPrice;
                        confirmOrder.classHour = self.teachProductDetail.classHour;
                        confirmOrder.returnCash = self.teachProductDetail.giveYunbi;
                        confirmOrder.blockReturn = ^(id data){
                            [self.navigationController popToViewController:self animated:YES];
                        };
                    }];
                }else if (classType == TeachingCourseTypePublic){
                    [self pushWithStoryboard:@"Jiaoxue" title:@"公开课详情" identifier:@"PublicCourseDetailController" completion:^(BaseNavController *controller) {
                        PublicCourseDetailController *publicCourseDetail = (PublicCourseDetailController*)controller;
                        publicCourseDetail.productId = self.teachProductDetail.productId;
                    }];
                }else{
                    [self pushWithStoryboard:@"Jiaoxue" title:@"选择预约时间" identifier:@"JXChooseTimeController" completion:^(BaseNavController *controller) {
                        JXChooseTimeController *chooseTime = (JXChooseTimeController *)controller;
                        chooseTime.teachingCoach = model;
                        chooseTime.productId = self.productId;
                        chooseTime.productName = self.teachProductDetail.productName;
                        chooseTime.sellingPrice = self.teachProductDetail.sellingPrice;
                        chooseTime.classHour = self.teachProductDetail.classHour;
                        chooseTime.publicClassId = self.publicClassId;
                        chooseTime.classNo = 1;
                        chooseTime.returnCash = self.teachProductDetail.giveYunbi;
                        chooseTime.classType = classType;
                        chooseTime.blockReturn = ^(id data){
                            [self.navigationController popToViewController:self animated:YES];
                        };
                    }];
                }
            };
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self pushWithStoryboard:@"Teach" title:@"教练主页" identifier:@"CoachDetailsViewController" completion:^(BaseNavController *controller) {
        ChooseTeachingModel *teachingModel = self.dataSource[indexPath.section];
        TeachingCoachModel *model = teachingModel.coachList[indexPath.row];
        CoachDetailsViewController *coachDetails = (CoachDetailsViewController*)controller;
        coachDetails.coachId = model.coachId;
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 87;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 87;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.dataSource.count == 0) {
        return nil;
    }
    
    ChooseTeachingModel *teachingModel = self.dataSource[section];
    ChooseCoachHeadView *headView = [[[NSBundle mainBundle] loadNibNamed:@"ChooseCoachHeadView" owner:self options:nil] lastObject];
    headView.academyNameLabel.text = teachingModel.academyName;
    headView.addressLabel.text = [NSString stringWithFormat:@"%.02fkm %@",teachingModel.distance,teachingModel.address];
    headView.daohang = ^(void){

        ClubModel *club = [[ClubModel alloc] init];
        club.clubName = teachingModel.academyName;
        club.address = teachingModel.address;
        club.latitude = teachingModel.latitude;
        club.longitude = teachingModel.longitude;
        club.trafficGuide = @"";
        
        YGMapViewCtrl *vc = [YGMapViewCtrl instanceFromStoryboard];
        vc.clubList = @[club];
        [self.navigationController pushViewController:vc animated:YES];
    };
    return headView;
}

@end
