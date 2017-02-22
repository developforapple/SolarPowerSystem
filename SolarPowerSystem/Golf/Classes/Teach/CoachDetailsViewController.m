 //
//  CoachDetailsViewController.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/12.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CoachDetailsViewController.h"
#import "TeachingCoachModel.h"
#import "CoachTableViewCell.h"
#import "ActionBarTableViewCell.h"
#import "HeaderTableViewCell.h"
#import "LocationTableViewCell.h"
#import "CoachProductTableViewCell.h"
#import "CommentTableViewCell.h"
#import "TitleValueTableViewCell.h"
#import "PublicCourseCell.h"
#import "WKDChatViewController.h"
#import "CourseSchoolDetailsViewController.h"
#import "CourseBuyView.h"
#import "CommentListViewController.h"
#import "PublicCourseDetailController.h"
#import "JXChooseTimeController.h"
#import "JXConfirmOrderController.h"
#import "RemainderClassTableViewController.h"
#import "TeachingCourseType.h"
#import "MemberClassModel.h"
#import "YGMapViewCtrl.h"
#import "TopicHelp.h"
#import "IMCore.h"
#import "JCAlertView.h"

@interface CoachDetailsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *viewSubscribeCoach;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UILabel *labelRemainHour;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@end

@implementation CoachDetailsViewController{
    TeachingCoachModel *tcm;
    BOOL showAll;//标记是否显示所有简介，成就，教学成果数据
    NSMutableArray *arrOthers;//存储成就简介成果
    
    CGFloat labelContentWidth;
    
    UIImage *imageCoach;
}

#pragma mark - 界面交互相关

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshAttentList" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    YGPostBuriedPoint(YGTeachPointCoachDetail);
    self.defaultImage = [UIImage imageNamed:@"head_image"];

    if (IS_3_5_INCH_SCREEN || IS_4_0_INCH_SCREEN) {
        labelContentWidth = 242;
    }else if(IS_4_7_INCH_SCREEN){
        labelContentWidth = 297;
    }else if (IS_5_5_INCH_SCREEN){
        labelContentWidth = 336;
    }
    
    if (IS_5_5_INCH_SCREEN) { //解决在plus下右边按钮靠右边有空隙，妈蛋
        for (NSLayoutConstraint *nc in [_toolbar.superview constraints]) {
            if (nc.firstAttribute == NSLayoutAttributeTrailing && nc.secondItem == _toolbar) {
                nc.constant = -20;
                [_toolbar layoutIfNeeded];
                break;
            }
        }
    }
    
    for (UIView *subView in [self.toolbar subviews]) {
        if ([subView isKindOfClass:[UIImageView class]]) {
            // Hide the hairline border
            subView.hidden = YES;
        }
    }
    
    [self.tableView setContentInset:UIEdgeInsetsMake(-137, 0, 15, 0)];
    
    [self getCoachDetails];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAttentList:) name:@"refreshAttentList" object:nil];
}

- (void)refreshAttentList:(NSNotification *)notification {
    NSDictionary *info = [notification object];
    UserFollowModel *model = info[@"data"];
    tcm.isFollowed = model.isFollowed;
    if ([info[@"flag"] intValue] == 3) {
        tcm.displayName = model.displayName;
    }
    
    [_tableView reloadData];
}

#pragma mark - 业务逻辑
//预约教练
- (IBAction)subscribeCoach:(id)sender {
    [self pushWithStoryboard:@"Teach" title:@"剩余课时" identifier:@"RemainderClassTableViewController" completion:^(BaseNavController *controller) {
        RemainderClassTableViewController *vc = (RemainderClassTableViewController *)controller;
        vc.sessionId = [[LoginManager sharedManager] getSessionId];
        vc.blockReturn = ^(id data){
            [self getCoachDetails];
        };
    }];
}

- (void)getCoachDetails{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ServiceManager serviceManagerWithDelegate:self] getCoachDetailByCoachId:_coachId longitude:[LoginManager sharedManager].currLongitude latitude:[LoginManager sharedManager].currLatitude sessionId:([LoginManager sharedManager].loginState ? [[LoginManager sharedManager] getSessionId]:nil)];
    });
}

- (void)serviceResult:(ServiceManager*)serviceManager Data:(id)data flag:(NSString*)flag{
    NSArray *arr = (NSArray *)data;
    
    if (Equal(flag, @"teaching_coach_detail")) {
        tcm = [arr firstObject];
        NSArray *classList = tcm.classList;
        int classCount = 0;
        for (MemberClassModel *obj in classList) {
            classCount += obj.remainHour;
        }
        
        if (classCount > 0) {
            _labelRemainHour.text = [NSString stringWithFormat:@"%d",classCount];
            [self.tableView setContentInset:UIEdgeInsetsMake(self.tableView.contentInset.top, 0, 60, 0)];
            _viewSubscribeCoach.hidden = NO;
        }else{
            _viewSubscribeCoach.hidden = YES;
            
        }
        arrOthers = [[NSMutableArray alloc] initWithCapacity:3];
        if (tcm.introduction && tcm.introduction.length > 0) {
            [arrOthers addObject:@{@"title":@"个人简介",@"value":tcm.introduction}];
        }
        if (tcm.careerAchievement && tcm.careerAchievement.length > 0) {
            [arrOthers addObject:@{@"title":@"所获成就",@"value":tcm.careerAchievement}];
        }
        if (tcm.teachingAchievement && tcm.teachingAchievement.length > 0) {
            [arrOthers addObject:@{@"title":@"教学成果",@"value":tcm.teachingAchievement}];
        }
    }
    if (_loadingView) {
        [_loadingView removeFromSuperview];
    }
    self.tableView.hidden = NO;
    [self.tableView reloadData];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tcm) {
        int sections = 4;
        if (tcm.productList.count > 0) {
            sections ++;
        }
        if (tcm.publicClassList.count > 0) {
            sections ++;
        }
        return sections;
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tcm) {
        if (section == 0 || section == 1) {
            return 2;
        }

        if (section == 2) {
            if (tcm.productList.count > 0) {
                return tcm.productList.count + 1;
            }
            return tcm.commentList.count + 1; //最多显示两条评论,由服务器数据接口控制
        }
        if (section == 3) {
            if (tcm.productList.count > 0){
                return tcm.commentList.count + 1; //最多显示两条评论,由服务器数据接口控制
            }
            return [self numberOfIntro];
        }
        if (section == 4) {
            if (tcm.productList.count > 0){
                return [self numberOfIntro];
                
            }
            if (tcm.publicClassList.count > 0) {
                return [self numberOfPublicClassList];
            }
        }
        if (section == 5) {
            if (tcm.publicClassList.count > 0) {
                return [self numberOfPublicClassList];
            }
        }
    }
    return 0;
}

- (NSInteger)numberOfPublicClassList{
    return tcm.publicClassList.count + 1;
}

//计算详细介绍的section中有多少行
- (NSInteger)numberOfIntro{
    if (showAll) {
        return 3 + arrOthers.count;
    }else{
        int count = 0;
        if (arrOthers.count == 1) {
            count = 1;
        }
        if (arrOthers.count > 1) {
            count = 2;
        }
        return 3 + count;
    }
}


- (void)_toChatViewController{
    __weak typeof(self) weakSelf = self;
    NSString *name = tcm.displayName.length == 0 ? tcm.nickName:tcm.displayName;
    WKDChatViewController *chatVC = [[WKDChatViewController alloc] init];
    chatVC.hidesBottomBarWhenPushed = YES;
    chatVC.targetImage = imageCoach;
    chatVC.memId = tcm.coachId;
    chatVC.title =tcm.displayName;
    chatVC.isFollow = tcm.isFollowed;
    [weakSelf pushViewController:chatVC title:name hide:YES];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                CoachTableViewCell *cell = (CoachTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CoachTableViewCell" forIndexPath:indexPath];
                cell.isHeaderView = YES;
                [cell loadData:tcm];
                if (cell.imgHeader.image) {
                    imageCoach = cell.imgHeader.image;
                }
                if (cell.blockAuthenticationPressed == nil) {
                    cell.blockAuthenticationPressed = ^(id data){
                        NSString *url = [NSString stringWithFormat:@"%@common/coachLevel.jsp?coachId=%d",URL_SHARE,tcm.coachId];
                        [[GolfAppDelegate shareAppDelegate] showInstruction:url title:@"教练等级说明" WithController:self];
                    };
                }
                if (cell.blockReturn == nil) {
                    cell.blockReturn = ^(id data){
                        TeachingCoachModel *m = (TeachingCoachModel *)data;

                        [self toPersonalHomeControllerByMemberId:m.coachId displayName:m.displayName target:self blockFollow:^(id data) {
                            [self getCoachDetails];
                        }];
                    };
                }
                return cell;
            }
                break;
            case 1:
            {
                ActionBarTableViewCell *cell = (ActionBarTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ActionBarTableViewCell" forIndexPath:indexPath];
                cell.teachingCoachModel = tcm;
                if (cell.blockHome == nil) {
                    cell.blockHome = ^(id data){
                        // 数据上报采集点
                        [[BaiduMobStat defaultStat] logEvent:@"btnCoachDetail" eventLabel:@"教练详情按钮点击"];
                        [MobClick event:@"btnCoachDetail" label:@"教练详情按钮点击"];

                        [self toPersonalHomeControllerByMemberId:tcm.coachId displayName:tcm.displayName target:self blockFollow:^(id data) {
                            [self getCoachDetails];
                        }];
                        
                    };
                }
                if (cell.blockChat == nil) {
                    cell.blockChat = ^(id data){
                        // 数据上报采集点
                        [[BaiduMobStat defaultStat] logEvent:@"btnConsultCoach" eventLabel:@"咨询按钮点击"];
                        [MobClick event:@"btnConsultCoach" label:@"咨询按钮点击"];
                        if (![LoginManager sharedManager].loginState) {
                            [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES blockRetrun:^(id data) {
                                [self _toChatViewController];
                            }];
                            return;
                        }
                        [self _toChatViewController];
                    };
                }
                [cell followed:tcm.followed];
                
                if (cell.loginDelegeate == nil) {
                    cell.loginDelegeate = self;
                }
                if (cell.blockAdd == nil) {
                    cell.blockAdd = ^(id data){
                        // 数据上报采集点
                        [[BaiduMobStat defaultStat] logEvent:@"btnFollowCoach" eventLabel:@"关注教练按钮点击"];
                        [MobClick event:@"btnFollowCoach" label:@"关注教练按钮点击"];
                        tcm.followed = [data boolValue];
                        [SVProgressHUD setDefaultMaskType:(SVProgressHUDMaskTypeNone)];
                        [ServerService userFollowAddWithSessionId:[[LoginManager sharedManager] getSessionId] toMemberId:tcm.coachId nameRemark:nil operation:([data boolValue] ? 1:2) success:^(id data) {
                            int operation = [data[@"operation"] intValue];
                            UserFollowModel *model = [[UserFollowModel alloc] init];
                            model.memberId = _coachId;
                            model.isFollowed = [data[@"is_followed"] intValue];
                            NSDictionary *dictionary = @{@"flag":@(operation), @"data":model};
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshAttentList" object:dictionary];
                            switch (operation) {
                                case 1:
                                    if ([data[@"is_followed"] intValue] == 6) {
                                        [SVProgressHUD showInfoWithStatus:@"对方不允许你关注TA"];
                                    } else {
                                        [SVProgressHUD showSuccessWithStatus:@"关注成功"];
                                    }
                                    break;
                                case 2:
                                    [SVProgressHUD showInfoWithStatus:@"已取消关注"];
                                    break;
                                case 4:
                                    break;
                                case 5:
                                    [SVProgressHUD showSuccessWithStatus:@"已屏蔽"];
                                    break;
                                case 6:
                                    [SVProgressHUD showSuccessWithStatus:@"已取消屏蔽"];
                                    break;
                                case 7:
                                    [SVProgressHUD showSuccessWithStatus:@"已移出，可重新关注"];
                                    break;
                                default:
                                    break;
                            }
                        } failure:^(HttpErroCodeModel *error) {
                            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",error.errorMsg]];
                        }];
                        [self.tableView reloadData];
                    };
                }
                return cell;
            }
                break;
            default:
                break;
        }
    }
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                return [self cellForHeaderTitle:@"教学地点" tableView:tableView indexPath:indexPath accessoryType:UITableViewCellAccessoryNone];
                break;
            case 1:
            {
                LocationTableViewCell *cell = (LocationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"LocationTableViewCell" forIndexPath:indexPath];
                cell.labelName.text = tcm.teachingSite;
                cell.labelLocationName.text = [NSString stringWithFormat:@"%.2fkm  %@",tcm.distance,tcm.address];
                return cell;
            }
                break;
            default:
                break;
        }
        
    }
    if (indexPath.section == 2) {
        if (tcm.productList.count > 0) { //有特惠课程就返回
            if (indexPath.row == 0) {
                return [self cellForHeaderTitle:@"特惠课程" tableView:tableView indexPath:indexPath accessoryType:UITableViewCellAccessoryNone];
            }
            TeachProductDetail *pd = tcm.productList[indexPath.row - 1];
            NSString *identifier = pd.giveYunbi > 0 ? @"CoachProductTableViewCell1":@"CoachProductTableViewCell";
            CoachProductTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
            // 套课和专项课显示购买
            BOOL isBuy = (pd.classType == TeachingCourseTypeMulti || pd.classType == TeachingCourseTypeSpecial);
            [cell.btnAction setTitle:isBuy ? @"购买":@"预约" forState:(UIControlStateNormal)];
            cell.labelName.text = pd.productName;
            cell.labelOldPrice.text = [NSString stringWithFormat:@"%d",pd.originalPrice];
            cell.tpd = pd;
            cell.labelPrice.text = [NSString stringWithFormat:@"%d",pd.sellingPrice];
            cell.labelFanxian.text = [NSString stringWithFormat:@" 返%d ",pd.giveYunbi];
            if (cell.blockReturn == nil) {
                ygweakify(self);
                cell.blockReturn = ^(id data){
                    if ([LoginManager sharedManager].loginState) {
                        TeachProductDetail *_pd = (TeachProductDetail *)data;
                        [self buy:_pd];
                    }else{
                        [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES blockRetrun:^(id dat) {
                            ygstrongify(self);
                            TeachProductDetail *_pd = (TeachProductDetail *)data;
                            [self buy:_pd];
                        }];
                    }
                };
            }
            return cell;
        }
        
        return [self cellForCommentSectionByTableView:tableView indexPath:indexPath];
    }
    
    if (indexPath.section == 3) {
        if (tcm.productList.count > 0 ){
            return [self cellForCommentSectionByTableView:tableView indexPath:indexPath];
        }
        return [self cellForTableView:tableView indexPath:indexPath];
    }
    
    if (indexPath.section == 4) {
        if (tcm.productList.count > 0){
            return [self cellForTableView:tableView indexPath:indexPath];
        }
        if (tcm.publicClassList.count > 0) {
            return [self cellForPubliceClass:tableView indexPath:indexPath];
        }
        
    }
    
    if (indexPath.section == 5) {
        if (tcm.publicClassList.count > 0) {
            return [self cellForPubliceClass:tableView indexPath:indexPath];
        }
    }
    
    return [[UITableViewCell alloc] init];
}

//返回公开课的cell
- (UITableViewCell *)cellForPubliceClass:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        UITableViewCell *cell = [self cellForHeaderTitle:@"公开课" tableView:tableView indexPath:indexPath accessoryType:UITableViewCellAccessoryNone];
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
        }
        return cell;
    }
    PublicCourseCell *cell = (PublicCourseCell *)[tableView dequeueReusableCellWithIdentifier:@"PublicCourseCell" forIndexPath:indexPath];
    cell.publicCourse = tcm.publicClassList[indexPath.row - 1];
    return cell;
}


//个人详情的section
- (UITableViewCell *)cellForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            return [self cellForHeaderTitle:@"详细介绍" tableView:tableView indexPath:indexPath accessoryType:UITableViewCellAccessoryNone];
            break;
        case 1:
            return [self cellForTitleValueByTableView:tableView indexPath:indexPath title:@"所属学院" value:tcm.academyName cellIdentifier:@"TitleValueTableViewCell" accessoryType:UITableViewCellAccessoryDisclosureIndicator];
            break;
        case 2:{
            UITableViewCell *cell = [self cellForTitleValueByTableView:tableView indexPath:indexPath title:@"教龄" value:[NSString stringWithFormat:@"%d年",tcm.seniority] cellIdentifier:@"TitleValueTableViewCell" accessoryType:UITableViewCellAccessoryNone];
            if (arrOthers.count ==0) {
                if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                    cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
                }
            }
            return cell;
        }
            break;
        case 3:
        {
            NSDictionary *nd = [arrOthers firstObject];
            if (nd) {
                return [self cellForTitleValueByTableView:tableView indexPath:indexPath title:nd[@"title"] value:nd[@"value"] cellIdentifier:@"TitleValueTableViewCell2" accessoryType:(UITableViewCellAccessoryNone)];
            }
        }
            break;
        case 4:
        {
            if (showAll) {
                NSDictionary *nd = arrOthers[1];
                if (nd) {
                    TitleValueTableViewCell *cell = [self cellForTitleValueByTableView:tableView indexPath:indexPath title:nd[@"title"] value:nd[@"value"] cellIdentifier:@"TitleValueTableViewCell2" accessoryType:(UITableViewCellAccessoryNone)];
                    if (arrOthers.count == 2) {
                        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                            cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
                        }
                    }
                    return cell;
                }
            }else{
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MoreButtonTableViewCell" forIndexPath:indexPath];
                if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                    cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
                }

                return cell;
            }
        }
            break;
        case 5:
        {
            NSDictionary *nd = [arrOthers lastObject];
            if (nd) {
                TitleValueTableViewCell *cell = [self cellForTitleValueByTableView:tableView indexPath:indexPath title:nd[@"title"] value:nd[@"value"] cellIdentifier:@"TitleValueTableViewCell2" accessoryType:(UITableViewCellAccessoryNone)];
                if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                    cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
                }
                return cell;
            }
        }
            break;
        default:
            break;
    }
    return [[UITableViewCell alloc] init];
}

//个人详情中的单个cell
- (TitleValueTableViewCell *)cellForTitleValueByTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath title:(NSString *)title value:(NSString *)value cellIdentifier:(NSString *)identifier accessoryType:(UITableViewCellAccessoryType)type{
    TitleValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.labelTitle.text = title;
    cell.labelValue.text = value;
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    cell.accessoryType = type;
    if (type == UITableViewCellAccessoryDisclosureIndicator) {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }else{
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (UITableViewCell *)cellForCommentSectionByTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return [self cellForHeaderTitle:[NSString stringWithFormat:@"客户评价(%d)",tcm.commentCount] tableView:tableView indexPath:indexPath accessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentTableViewCell" forIndexPath:indexPath];
    [cell loadData:tcm.commentList[indexPath.row - 1]];
    NSLog(@"%@",NSStringFromCGSize(cell.labelComment.frame.size));
    if (cell.blockReturn == nil) {
        cell.blockReturn = ^(id data){
            CoachDetailCommentModel *m = (CoachDetailCommentModel *)data;
            [self toPersonalHomeControllerByMemberId:m.memberId displayName:m.displayName target:self];
        };
    }
    
    return cell;
}



- (HeaderTableViewCell *)cellForHeaderTitle:(NSString *)title tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath accessoryType:(UITableViewCellAccessoryType)type{
    HeaderTableViewCell *cell = (HeaderTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"HeaderTableViewCell" forIndexPath:indexPath];
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    cell.labelHeaderTitle.text = title;
    if (type == UITableViewCellAccessoryDisclosureIndicator) {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }else{
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    cell.accessoryType = type;
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)buy:(TeachProductDetail *)tpd{
    
    if (tcm.coachId == [LoginManager sharedManager].session.memberId && [LoginManager sharedManager].session.memberId > 0) {
        // 专项课 和 套课
        BOOL isBuy = (tpd.classType == TeachingCourseTypeMulti || tpd.classType == TeachingCourseTypeSpecial);
        NSString *alertMsg = isBuy ? @"不能购买自己的课程" : @"不能预约自己的课程";
        [SVProgressHUD showInfoWithStatus:alertMsg];
        return;
    }
    
    if (tpd.productId == 1) {
        [[API shareInstance] statisticalWithBuriedpoint:6 Success:nil failure:nil];//埋点
    }
    //课程点击
    CourseBuyView *view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([CourseBuyView class]) owner:self options:nil] firstObject];
    view.width = Device_Width - 50.f;
    view.height = Device_Height - 2 * 60.f;
    
    [view loadData:tpd teachingCoachModel:tcm];
    JCAlertView *alert = [[JCAlertView alloc] initWithCustomView:view dismissWhenTouchedBackground:NO];
    [alert show];
    
    view.blockHide = ^(id data){
        [alert dismissWithCompletion:NULL];
    };
    
    if (view.blockReturn == nil) {
        view.blockReturn = ^(id data){
            [alert dismissWithCompletion:NULL];
            TeachProductDetail *tpd = (TeachProductDetail *)data;
            // 专项课 和 套课
            BOOL isBuy = (tpd.classType == TeachingCourseTypeMulti || tpd.classType == TeachingCourseTypeSpecial);
            if (isBuy){
                [self pushWithStoryboard:@"Jiaoxue" title:@"确认订单" identifier:@"JXConfirmOrderController" completion:^(BaseNavController *controller) {
                    JXConfirmOrderController *o = (JXConfirmOrderController*)controller;
                    o.teachingCoach = tcm;
                    o.productId = tpd.productId;
                    o.productName = tpd.productName;
                    o.sellingPrice = tpd.sellingPrice;
                    o.classHour = tpd.classHour;
                    o.classType = tpd.classType;
                    o.academyId = tcm.academyId;
                    o.returnCash = tpd.giveYunbi;
                    ygweakify(self);
                    o.blockReturn = ^(id data){
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            ygstrongify(self);
                            [self getCoachDetails];
                        });
                        [self.navigationController popToViewController:self animated:YES];
                    };
                }];
            }else{
                [self pushWithStoryboard:@"Jiaoxue" title:@"选择预约时间" identifier:@"JXChooseTimeController" completion:^(BaseNavController *controller) {
                    JXChooseTimeController *c = (JXChooseTimeController*)controller;
                    c.teachingCoach = tcm;
                    c.productId = tpd.productId;
                    c.productName = tpd.productName;
                    c.sellingPrice = tpd.sellingPrice;
                    c.classHour = tpd.classHour;
                    c.classNo = 1;
                    c.classType = tpd.classType;
                    c.academyId = tcm.academyId;
                    c.returnCash = tpd.giveYunbi;
                    c.blockReturn = ^(id data){
                        [self.navigationController popToViewController:self animated:YES];
                    };
                }];
            }
        };
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 1 && indexPath.row == 1) {

        ClubModel *club = [[ClubModel alloc] init];
        club.clubName = tcm.academyName;
        club.address = tcm.address;
        club.latitude = tcm.latitude;
        club.longitude = tcm.longitude;
        
        YGMapViewCtrl *vc = [YGMapViewCtrl instanceFromStoryboard];
        vc.clubList = @[club];
        [self.navigationController pushViewController:vc animated:YES];
    }
   
    if (indexPath.section == 2) {
        if (tcm.productList.count > 0) { //有特惠课程就返回
            if (indexPath.row == 0) {
                return;
            }
            if (indexPath.row > 0) {
                
                if ([LoginManager sharedManager].loginState) {
                    [self buy:tcm.productList[indexPath.row - 1]];
                }else{
                    ygweakify(self);
                    [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES blockRetrun:^(id dat) {
                        ygstrongify(self);
                        [self buy:tcm.productList[indexPath.row - 1]];
                    }];
                }
                return;
            }
        }
        //评论点击
        [self showCommentListViewController];
        return;
    }
    
    if (indexPath.section == 3) {
        if (tcm.productList.count > 0 ){
            [self showCommentListViewController];
            return;
        }
        if (indexPath.row == 1) {
            [self showSourseSchoolDetail];
        }
        if (!showAll && indexPath.row == 4) {
            showAll = YES;
            [self.tableView reloadData];
        }
    }
    
    if (indexPath.section == 4) {
        if (tcm.productList.count > 0){
            if (indexPath.row == 1) {
                [self showSourseSchoolDetail];
                return;
            }
            if (!showAll && indexPath.row == 4) {
                showAll = YES;
//                [self.tableView deleteRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:4] withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView reloadData];
            }
            return;
        }
        if (tcm.publicClassList.count > 0 && indexPath.row > 0) {
            [self showPublicCourseDetailController:indexPath];
        }
    }
    if (indexPath.section == 5) {
        if (tcm.publicClassList.count > 0 && indexPath.row > 0) {
            [self showPublicCourseDetailController:indexPath];
        }
    }
}

- (void)showPublicCourseDetailController:(NSIndexPath *)indexPath{
    // 数据上报采集点
    [[BaiduMobStat defaultStat] logEvent:@"btnCoachPublicClass" eventLabel:@"教练公开课点击"];
    [MobClick event:@"btnCoachPublicClass" label:@"教练公开课点击"];
    [self pushWithStoryboard:@"Jiaoxue" title:@"公开课详情" identifier:@"PublicCourseDetailController" completion:^(BaseNavController *controller) {
        PublicCourseDetailController *vc = (PublicCourseDetailController*)controller;
        PublicCourseModel *model = tcm.publicClassList[indexPath.row -1];
        vc.publicClassId = model.publicClassId;
        vc.blockRefresh  =^(id data){
            [self getCoachDetails];
        };
    }];
}

- (void)showCommentListViewController{
    [self pushWithStoryboard:@"Teach" title:@"客户评价" identifier:@"CommentListViewController" completion:^(BaseNavController *controller) {
        CommentListViewController *vc = (CommentListViewController *)controller;
        vc.coachId = tcm.coachId;
        vc.starLevel = tcm.starLevel;
        vc.commentCount = tcm.commentCount;
    }];
}

- (void)showSourseSchoolDetail{
    [self pushWithStoryboard:@"Teach" title:@"学院详情" identifier:@"CourseSchoolDetailsViewController" completion:^(BaseNavController *controller) {
        CourseSchoolDetailsViewController *vc = (CourseSchoolDetailsViewController *)controller;
        vc.academyId = tcm.academyId;
    }];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithHexString:@"#f1f0f6"];
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    return 87;  //顶部头像认证的单元格
                    break;
                case 1:
                    return 40;  //顶部三个按钮的工具栏
                    break;
                default:
                    break;
            }
            break;
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                    return 40;
                    break;
                case 1:
                {
                    NSString *text = [NSString stringWithFormat:@"%.2fkm  %@",tcm.distance,tcm.address];
                    CGSize size = [text boundingRectWithSize:CGSizeMake(Device_Width - 62, CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0]} context:nil].size;
                    return (size.height < 17 ? 17:size.height) + 53;//具体教学地点的cell
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            return 40;
        }
        if (tcm.productList.count > 0) {
            return 44;
        }
        return [self heightForCommentCell:indexPath];
    }
    if (indexPath.section == 3) {
        if (tcm.productList.count > 0){
            return [self heightForCommentCell:indexPath];
        }
        return [self heightForIntroductionForIndexPath:indexPath];
    }
    if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            return 40;
        }
        if (tcm.productList.count > 0){
            return [self heightForIntroductionForIndexPath:indexPath];
        }
        if (tcm.publicClassList.count > 0) {
            return 232;
        }
    }
    if (indexPath.section == 5) {
        if (indexPath.row == 0) {
            return 40;
        }
        return 232;
    }
    
    return 0;
}

- (CGFloat)heightForIntroductionForIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            return 40;
            break;
        case 1:
        case 2:
            return 44;
            break;
        case 3:
        {
            NSDictionary *nd = [arrOthers firstObject];
            if (nd) {
                return [self heightForTitleValueCell2:nd[@"value"]];
            }
        }
            break;
        case 4:
        {
            if (showAll) {
                NSDictionary *nd = arrOthers[1];
                if (nd) {
                    return [self heightForTitleValueCell2:nd[@"value"]];
                }
            }else{
                return 40;//更多按钮行
            }
        }
            break;
        case 5:
        {
            NSDictionary *nd = [arrOthers lastObject];
            if (nd) {
                return [self heightForTitleValueCell2:nd[@"value"]];
            }
        }
            break;
        default:
            break;
    }
    return 0;
}

- (CGFloat)heightForTitleValueCell2:(NSString *)text{
    CGSize size = [text boundingRectWithSize:CGSizeMake(Device_Width - 26, CGFLOAT_MAX)
                                  options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                               attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0]}
                                  context:nil].size;
    return size.height + 50;
}

- (CGFloat)heightForCommentCell:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 40;
    }
    CoachDetailCommentModel *dcm = tcm.commentList[indexPath.row - 1];
    return [dcm contentSize:CGSizeMake(labelContentWidth,17*3) addReply:NO isCoach:NO];
}

@end
