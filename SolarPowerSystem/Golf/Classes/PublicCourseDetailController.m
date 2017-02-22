//
//  PublicCourseDetailController.m
//  Golf
//
//  Created by 黄希望 on 15/5/8.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "PublicCourseDetailController.h"
#import "SharePackage.h"
#import "CourseCommentCell.h"
#import "PublicCourseJoinView.h"
#import "TeachingJoinSuccessController.h"
#import "TeachingOrderStatus.h"
#import "TopicHelp.h"
#import "JXJoinView.h"
#import "CoachDetailsViewController.h"
#import "CourseCommentListController.h"
#import "YGMapViewCtrl.h"
#import "PublicCourseImageCell.h"
#import "PCHeadView.h"
#import "TrendsPraiseListController.h"
#import "PayOnlineViewController.h"

@interface PublicCourseDetailController ()<UITableViewDelegate,UITableViewDataSource,UIWebViewDelegate>{
    PCHeadView *headView;
}

@property (nonatomic,strong) IBOutlet UITableView *tableView;

@property (nonatomic,strong) SharePackage *share;
@property (nonatomic,strong) PublicCourseDetail *courseDetail;

@property (nonatomic,assign) CGFloat webviewHeight;
@property int isLoadOver;//lyf 加

@end

@implementation PublicCourseDetailController{
    BOOL updated;//记录当前界面数据是否有报名 来觉得blockRefresh是否执行，返回的时候。
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self rightButtonAction:@"分享"];
    
    self.tableView.hidden = YES;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self getPublicCourseDetail];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(-137, 0, 0, 0)];
}

- (void)doLeftNavAction{
    [super doLeftNavAction];
    if (_blockRefresh && updated == YES) {
        _blockRefresh(nil);
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:@"PUBLIC_COURSE_JOIN_REFRESH" object:nil];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (![self.navigationController.viewControllers containsObject:self]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PUBLIC_COURSE_JOIN_REFRESH" object:nil];
    }
}

- (void)refreshData:(NSNotification *)notificate{
    [self getPublicCourseDetail];
}

- (void)getPublicCourseDetail{
    if (self.publicClassId > 0 || self.productId > 0) {
        [[ServiceManager serviceManagerWithDelegate:self] getPublicDetailWithCourseId:self.publicClassId productId:self.productId longitude:[LoginManager sharedManager].currLongitude latitude:[LoginManager sharedManager].currLatitude];
    }
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray *)data;
    if (array.count > 0) {
        if (Equal(flag, @"teaching_public_class_detail")) {
            self.tableView.hidden = NO;
            self.courseDetail = array[0];
            [self.tableView reloadData];
        }
        if (Equal(flag, @"teaching_order_submit")) {
            updated = YES;
            TeachingSubmitInfo *submitInfo = array[0];
            if (submitInfo.orderState == TeachingOrderStatusTeaching) {
                if (_blockRefresh) {
                    _blockRefresh(nil);
                }
                [self pushWithStoryboard:@"Jiaoxue" title:@"报名成功" identifier:@"TeachingJoinSuccessController" completion:^(BaseNavController *controller) {
                    TeachingJoinSuccessController *teachingJoinSucess = (TeachingJoinSuccessController*)controller;
                    teachingJoinSucess.shareTitle = self.courseDetail.shareTitle;
                    teachingJoinSucess.shareContent = self.courseDetail.shareContent;
                    teachingJoinSucess.shareImage = self.courseDetail.shareImage;
                    teachingJoinSucess.shareUrl = self.courseDetail.shareUrl;
                }];
            }else if (submitInfo.orderState == TeachingOrderStatusWaitPay){
                PayOnlineViewController *payOnline = [[PayOnlineViewController alloc] init];
                payOnline.payTotal = submitInfo.orderTotal;
                payOnline.orderTotal = submitInfo.orderTotal;
                payOnline.orderId = submitInfo.orderId;
                payOnline.waitPayFlag = 4;
                payOnline.productId = submitInfo.productId;
                payOnline.academyId = submitInfo.academyId;
                payOnline.classType = submitInfo.classType;
                payOnline.blockReturn = ^(id data){
                    [self.navigationController popToViewController:self animated:YES];
                };
                [self pushViewController:payOnline title:@"在线支付" hide:YES];
            }
        }
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
        if (_courseDetail.productIntro.length>0 && _courseDetail.productDetail.length>0) {
            return 8+_courseDetail.commentList.count+4;
        }else if (_courseDetail.productIntro.length>0){
            return 8+_courseDetail.commentList.count+3;
        }else if (_courseDetail.productDetail.length>0){
            return 8+_courseDetail.commentList.count+4;
        }else{
            return 8+_courseDetail.commentList.count;
        }
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {// 顶部大图
        PublicCourseImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PublicCourseImageCell" forIndexPath:indexPath];
        [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:_courseDetail.productImage] placeholderImage:[UIImage imageNamed:@"pic_zhanwei"]];
        cell.productNameLabel.text = _courseDetail.productName.length>0?_courseDetail.productName : @"";
        return cell;
    }else{
        if (indexPath.row == 0) {// 报名人员列表
            PublicCourseImageListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PublicCourseImageListCell" forIndexPath:indexPath];
            cell.joinList = _courseDetail.joinList;
            if (cell.blockReturn == nil) {
                cell.blockReturn = ^(id obj){
                    NSInteger index = [obj integerValue];
                    
                    if (index == [self maxImageCount]-1) {
                        // 查看更多
                        if (index < _courseDetail.joinList.count) {
//                            TopicPraiseListController *topicPraiseList = [[TopicPraiseListController alloc] init];
//                            topicPraiseList.publicClassId = self.courseDetail.publicClassId;
//                            [self pushViewController:topicPraiseList title:[NSString stringWithFormat:@"%lu人报名",(unsigned long)_courseDetail.joinList.count] hide:YES];
                            
                            [self pushWithStoryboard:@"TrendsPraiseList" title:[NSString stringWithFormat:@"%lu人报名",(unsigned long)_courseDetail.joinList.count] identifier:@"TrendsPraiseListController" completion:^(BaseNavController *controller) {
                                TrendsPraiseListController *vc = (TrendsPraiseListController *)controller;
                                vc.publicClassId = self.courseDetail.publicClassId;
                            }];
                        }
                    }else{
                        // 查看单个
                        if (_courseDetail.joinList.count>index) {
                            JoinModel *join = _courseDetail.joinList[index];
                            [self toPersonalHomeControllerByMemberId:join.memberId displayName:@"个人主页" target:self];
                        }
                    }
                };
            }
            return cell;
        }else if (indexPath.row == 1){// 空行
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PublicCourseGabCell" forIndexPath:indexPath];
            return cell;
        }else if (indexPath.row == 2){// 教练信息标题
            PublicCourseTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PublicCourseTitleCell" forIndexPath:indexPath];
            cell.topLineView.hidden = YES;
            cell.botLineView.hidden = NO;
            cell.cusTitleLabel.text = @"活动信息";
            return cell;
        }else if (indexPath.row == 3){// 教练信息
            PublicCourseCoachInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PublicCourseCoachInfoCell" forIndexPath:indexPath];
            [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:_courseDetail.headImage] placeholderImage:[UIImage imageNamed:@"pic_zhanwei"]];
            cell.coachNameLabel.text = _courseDetail.nickName.length>0?_courseDetail.nickName:@"";
            cell.starLevel = _courseDetail.starLevel;
            cell.coachLevelImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_%da",_courseDetail.coachLevel]];
            return cell;
        }else if (indexPath.row == 4){// 日期时间
            PublicCourseDateTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PublicCourseDateTimeCell" forIndexPath:indexPath];
            if (_courseDetail.openDate.length>0&&_courseDetail.openTime.length>0) {
                cell.dateTimeLabel.text = [NSString stringWithFormat:@"%@ %@",_courseDetail.openDate,_courseDetail.openTime];
            }else if (_courseDetail.openDate.length>0){
                cell.dateTimeLabel.text = _courseDetail.openDate;
            }else if (_courseDetail.openTime.length>0){
                cell.dateTimeLabel.text = _courseDetail.openTime;
            }else{
                cell.dateTimeLabel.text = @"";
            }
            return cell;
        }else if (indexPath.row == 5){// 教学地点，地址
            PublicCourseAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PublicCourseAddressCell" forIndexPath:indexPath];
            cell.teachingSiteLabel.text = _courseDetail.teachingSite.length>0?_courseDetail.teachingSite:@"";
            if (_courseDetail.address.length>0) {
                cell.addressLabel.text = [NSString stringWithFormat:@"%.01fkm %@",_courseDetail.distance,_courseDetail.address];
            }else{
                cell.addressLabel.text = [NSString stringWithFormat:@"%.01fkm",_courseDetail.distance];
            }
            return cell;
        }else if (indexPath.row == 6){// 空行
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PublicCourseGabCell" forIndexPath:indexPath];
            return cell;
        }else if (indexPath.row == 7){// 评论总数
            PublicCourseCommentTotalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PublicCourseCommentTotalCell" forIndexPath:indexPath];
            cell.totalLabel.text = [NSString stringWithFormat:@"客户评价 (%d)",_courseDetail.commentCount];
            return cell;
        }else if (indexPath.row == 8+_courseDetail.commentList.count){// 空行
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PublicCourseGabCell" forIndexPath:indexPath];
            return cell;
        }else if (indexPath.row == 9+_courseDetail.commentList.count){// 标题
            PublicCourseTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PublicCourseTitleCell" forIndexPath:indexPath];
            cell.topLineView.hidden = YES;
            cell.botLineView.hidden = YES;
            cell.cusTitleLabel.text = _courseDetail.productDetail.length>0 || _courseDetail.productIntro.length>0 ? @"课程内容" : @"";
            return cell;
        }else if (indexPath.row == 10+_courseDetail.commentList.count){// 课程简介
            PublicCourseTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PublicCourseTitleCell" forIndexPath:indexPath];
            cell.topLineView.hidden = NO;
            cell.botLineView.hidden = YES;
            cell.cusTitleLabel.text = _courseDetail.productIntro.length>0 ? _courseDetail.productIntro : @"";
            cell.cusTitleLabel.textColor = [UIColor colorWithHexString:@"999999"];
            return cell;
        }else if (indexPath.row == 11+_courseDetail.commentList.count){// 网页
            PublicCourseWebCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PublicCourseWebCell" forIndexPath:indexPath];
            if (_courseDetail.productDetail.length>0) {
                [cell.bweb webviewJavaScriptImplement:self];
                cell.bweb.delegate = self;
                cell.bweb.backgroundColor = [UIColor clearColor];
                cell.bweb.scrollView.scrollEnabled = NO;
                cell.bweb.scalesPageToFit = YES;
                cell.bweb.opaque = NO;
                if (!_isLoadOver) {//lyf 加判断 原先会引起无限：访问数据-刷新tableview-（引发）访问数据-刷新tableview。。。。。。
                    [cell.bweb loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.courseDetail.productDetail]]];
                }
                
                if (self.webviewHeight > 0) {
                    [cell.waitingView stopAnimating];
                    cell.waitingView.hidden = YES;
                }
            }
            return cell;
        }else{// 评论
            CourseCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CourseCommentCell"];
            CoachDetailCommentModel *commentModel = _courseDetail.commentList[indexPath.row-8];
            cell.commentModel = commentModel;
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section > 0) {
        if (indexPath.row == 3) {
            [self pushWithStoryboard:@"Teach" title:@"教练主页" identifier:@"CoachDetailsViewController" completion:^(BaseNavController *controller) {
                CoachDetailsViewController *coachDetails = (CoachDetailsViewController*)controller;
                coachDetails.coachId = _courseDetail.coachId;
            }];
        }else if (indexPath.row == 5){
            ClubModel *club = [[ClubModel alloc] init];
            club.clubName = self.courseDetail.teachingSite;
            club.address = self.courseDetail.address;
            club.latitude = self.courseDetail.latitude;
            club.longitude = self.courseDetail.longitude;
            club.trafficGuide = @"";
            
            YGMapViewCtrl *vc = [YGMapViewCtrl instanceFromStoryboard];
            vc.clubList = @[club];
            [self.navigationController pushViewController:vc animated:YES];
            
        }else if (indexPath.row >= 7 && indexPath.row < _courseDetail.commentList.count+8){
            [self pushWithStoryboard:@"Jiaoxue" title:@"客户评价" identifier:@"CourseCommentListController" completion:^(BaseNavController *controller) {
                CourseCommentListController *commentList = (CourseCommentListController*)controller;
                commentList.productId = _courseDetail.productId;
            }];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 175;
    }else{
        if (indexPath.row == 0) {
            return _courseDetail.joinList.count>0 ? 45 : 0;
        }else if (indexPath.row == 1){
            return 10;
        }else if (indexPath.row == 2){
            return 40;
        }else if (indexPath.row == 3){
            return 70;
        }else if (indexPath.row == 4){
            return 40;
        }else if (indexPath.row == 5){
            NSString *address = @"";
            if (_courseDetail.address.length>0) {
                address = [NSString stringWithFormat:@"%.01fkm %@",_courseDetail.distance,_courseDetail.address];
            }else{
                address = [NSString stringWithFormat:@"%.01fkm",_courseDetail.distance];
            }
            CGSize size = [Utilities getSize:address withFont:[UIFont systemFontOfSize:14.0] withWidth:Device_Width - 81];
            return size.height+50;
        }else if (indexPath.row == 6){
            return 10;
        }else if (indexPath.row == 7){
            return 40;
        }else if (indexPath.row == _courseDetail.commentList.count+8){
            return 10;
        }else if (indexPath.row == _courseDetail.commentList.count+9){
            return _courseDetail.productDetail.length>0 || _courseDetail.productIntro.length>0 ? 40 : 0;
        }else if (indexPath.row == _courseDetail.commentList.count+10){
            if (_courseDetail.productIntro.length > 0) {
                CGSize size = [Utilities getSize:_courseDetail.productIntro withFont:[UIFont systemFontOfSize:14.0] withWidth:Device_Width - 26];
                return size.height+23;
            }
            return 0;
        }else if (indexPath.row == _courseDetail.commentList.count+11){
            return _webviewHeight > 0 ? _webviewHeight : 44 ;
        }else{
            CoachDetailCommentModel *commentModel = _courseDetail.commentList[indexPath.row-8];
            if (commentModel.commentContent.length>0) {
                CGSize size = [Utilities getSize:commentModel.commentContent withFont:[UIFont systemFontOfSize:14.0] withWidth:Device_Width - 67];
                return size.height+79;
            }else{
                return 70;
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0 ? 0 : 66;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return nil;
    }
    
    headView = [[[NSBundle mainBundle] loadNibNamed:@"PCHeadView" owner:self options:nil] lastObject];
    headView.frame = CGRectMake(0, 0, Device_Width, 66);
    headView.lineView.hidden = YES;
    
    headView.joinLabel.text = [NSString stringWithFormat:@"%d",_courseDetail.personJoin];
    headView.totalLabel.text = [NSString stringWithFormat:@"/%d人",_courseDetail.personLimit];
    headView.descriptionLabel.text = _courseDetail.blockTime.length>0 ? _courseDetail.blockTime : @"";
    
    __block PublicCourseDetailController *pcdc = self;
    headView.resp = ^(id obj){
        [pcdc jbresp];
    };
    
    [headView.joinBtn setBackgroundColor:[UIColor colorWithHexString:@"#C8C8C8"]];
    if (_courseDetail.classStatus == 0) {
        if (_courseDetail.personJoin<_courseDetail.personLimit) { // 报名中
            headView.joinBtn.enabled = YES;
            [headView.joinBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            if (_courseDetail.sellingPrice>0) {
                [headView.joinBtn setTitle:[NSString stringWithFormat:@"¥%d 报名",_courseDetail.sellingPrice] forState:UIControlStateNormal];
            }else{
                [headView.joinBtn setTitle:@"免费报名" forState:UIControlStateNormal];
            }
            [headView.joinBtn setBackgroundColor:[UIColor colorWithHexString:@"#FF6D00"]];
        }
    }else if (_courseDetail.classStatus == 1){
        headView.joinBtn.enabled = NO;
        [headView.joinBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [headView.joinBtn setTitle:@"报名结束" forState:UIControlStateNormal];
    }else if (_courseDetail.classStatus == 2){
        headView.joinBtn.enabled = NO;
        [headView.joinBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [headView.joinBtn setTitle:@"报名已满" forState:UIControlStateNormal];
    }else if (_courseDetail.classStatus == 3){
        headView.joinBtn.enabled = NO;
        [headView.joinBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [headView.joinBtn setTitle:@"课程结束" forState:UIControlStateNormal];
    }
    
    return headView;
}


- (NSInteger)maxImageCount{
    if (Device_Width == 320) {
        return 7;
    }else if (Device_Width == 375){
        return 8;
    }else {
        return 9;
    }
}

- (void)jbresp{
    [PublicCourseJoinView popWithSupView:self.navigationController.view price:self.courseDetail.sellingPrice completion:^(NSString *phoneNum, NSInteger actionTag) {
        if (actionTag == 1) { // 报名
            [[ServiceManager serviceManagerWithDelegate:self] teachingSubmitOrder:[[LoginManager sharedManager] getSessionId] publicClassId:self.courseDetail.publicClassId productId:0 coachId:0 date:@"" time:@"" phoneNum:phoneNum];
        }else if (actionTag == 2){ // 分享
            [self doRightNavAction];
        }
    }];
}

#pragma mark - UIScrollView delegate 
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y > 176) {
        if (headView.lineView.hidden) {
            headView.lineView.hidden = NO;
        }
    }else{
        if (!headView.lineView.hidden) {
            headView.lineView.hidden = YES;
        }
    }
}
 
#pragma mark - UIWebView delegate 

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSUInteger factHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] intValue];
    webView.height = factHeight;
    self.webviewHeight = factHeight;
    _isLoadOver = YES;//lyf 加 原先会无限刷新
    [self.tableView reloadData];
}

- (void)doRightNavAction{
    if ([LoginManager sharedManager].loginState) {
        if ([self needPerfectMemberData]) {
            return;
        }
    }
    [GolfAppDelegate shareAppDelegate].currentController = self;
    
    if(self.courseDetail) {
        if (!self.share) {
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.courseDetail.shareImage]]];
            image = [Utilities scaleToSize:image size:CGSizeMake(100, 100)];
            self.share = [[SharePackage alloc] initWithTitle:self.courseDetail.shareTitle content:self.courseDetail.shareContent img:image url:self.courseDetail.shareUrl];
        }
        self.share.type = 1;
        [self.share shareInfoForView:self.view];
    }
}

@end
