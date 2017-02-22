//
//  TeachInfoDetailTableViewController.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/21.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "TeachInfoDetailTableViewController.h"
#import "TeachInfoDetailTableViewCell.h"
#import "ReservationModel.h"
#import "FooterInfoTableViewCell.h"
#import "ActionTableViewCell.h"
#import "TeachCommentContentTableViewCell.h"
#import "TeachInfoCommentTableViewController.h"
#import "CoachDetailsViewController.h"
#import "CCAlertView.h"
#import "ThreeActionTableViewCell.h"
#import "MyStudentDetailController.h"
#import "YGMapViewCtrl.h"
#import "YGMyStudentDetailViewCtrl.h"

@interface TeachInfoDetailTableViewController ()

//@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@end

@implementation TeachInfoDetailTableViewController{
    ReservationModel *rm;
    CGFloat commentHeight,replyHeight,addressHeight,productNameHeight;
}

#pragma mark - 界面相关

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hidesClearText = YES;
    self.dimissHidden = YES;
    self.inputToolbar.hidden = YES;
    
    [self.tableView setContentInset:UIEdgeInsetsMake(15, 0, 15, 0)];
    [self getDetails];
}

- (void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressRightBarButton:(UIButton *)sender
{
    [self sendContent:self.inputToolbar.contentView.textView.text];
}

- (void)sendContent:(NSString*)text{
    [self.inputToolbar.contentView.textView setText:@""];
    if (text && text.length > 0) {
        if (text.length > 200) {
            [SVProgressHUD showInfoWithStatus:@"您输入的文字过长，不能超过200字符"];
            return;
        }
        @weakify(self)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self)
            [[ServiceManager serviceManagerWithDelegate:self] teachingCommentReplyContent:text commentId:rm.commentId sessionId:[[LoginManager sharedManager] getSessionId]];
        });
    }
}

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (_blockReturn) {
        _blockReturn(rm);
    }
}


#pragma mark - 逻辑方法

- (void)getDetails{
    @weakify(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self)
        [[ServiceManager serviceManagerWithDelegate:self] getTeachInfoDetailByReservationId:_reservationId
                                                                              sessionId:[[LoginManager sharedManager] getSessionId] coachId:_coachId];
    });
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (rm.publicClassId > 0) {
        if (rm.reservationStatus == 1) { //待上课状态。报名成功以后显示为待上课状态。
            return 2;
        }
        if (rm.reservationStatus == 2) {
            if (rm.commentId > 0) {
                return 2;
            }
            return 1;
        }
        if (rm.reservationStatus == 6) {
            return _coachId > 0 ? 2:3;
        }
    }else{
        if (rm.reservationStatus == 1) { //待上课
            if (_coachId > 0) {
                return 2;
            }else{
                return rm.canCancel ? 3:2;
            }
        }
        if (rm.reservationStatus == 2) { //已完成
            if (rm.commentId > 0) {
                return 2;
            }
            return 1;
        }
        if (rm.reservationStatus == 3) { //未到场
            return 2;
        }
        if (rm.reservationStatus == 4) { //已取消
            return 2;
        }
        if (rm.reservationStatus == 5) {
            return 2;
        }
        if (rm.reservationStatus == 6) { //待评价
            return _coachId > 0 ? 2:3;
        }
    }
    return 0;
}

- (UITableViewCell *)cellForActionTableViewCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    ActionTableViewCell *cell = (ActionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ActionTableViewCell3" forIndexPath:indexPath];
    [cell.btnAction setTitle:@"取消预约" forState:UIControlStateNormal];
    cell.btnAction.layer.borderColor = [UIColor colorWithHexString:@"#c8c8c8"].CGColor;
    [cell.btnAction setTitleColor:[UIColor whiteColor] forState:(UIControlStateHighlighted)];
    @weakify(self)
    if (cell.blockReturn == nil) {
        cell.blockReturn = ^(id data){
            if ([LoginManager sharedManager].loginState) {
                @strongify(self)
                [self cancelReservation];
            }
        };
    }
    return cell;
}

-(void)cancelReservation{
    CCAlertView *alert = [[CCAlertView alloc] initWithTitle:@"" message:@"确认取消当前预约吗？"];
    [alert addButtonWithTitle:@"再想想" block:nil];
    [alert addButtonWithTitle:@"取消预约" block:^{
        [[ServiceManager serviceManagerWithDelegate:self] teachingMemberClassCancelByReservationId:rm.reservationId coachId:_coachId sessionId:[[LoginManager sharedManager] getSessionId] periodId:rm.periodId];
    }];
    [alert show];
}

- (UITableViewCell *)cellForTeachInfoWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{

    TeachInfoDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:rm.publicClassId > 0 ? @"TeachInfoDetailTableViewCell":@"TeachInfoDetailTableViewCell2" forIndexPath:indexPath];
    [cell loadData:rm];
    cell.blockReturn = ^(id data){
        ReservationModel *tcm = (ReservationModel *)data;
        ClubModel *club = [[ClubModel alloc] init];
        club.clubName = tcm.teachingSite;
        club.address = tcm.address;
        club.latitude = tcm.latitude;
        club.longitude = tcm.longitude;
        club.trafficGuide = tcm.address;
        
        YGMapViewCtrl *vc = [YGMapViewCtrl instanceFromStoryboard];
        vc.clubList = @[club];
        [self.navigationController pushViewController:vc animated:YES];
    };
    cell.blockImagePressed = ^(id data){
        ReservationModel *tcm = (ReservationModel *)data;
        if (_coachId > 0) {
            [[BaiduMobStat defaultStat] logEvent:@"btnReservationDetailHeadImage" eventLabel:@"预约详情头像点击"];
            [MobClick event:@"btnReservationDetailHeadImage" label:@"预约详情头像点击"];
            if (self.plsBack) {
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                
//                [self pushWithStoryboard:@"Coach" title:@"学员详情" identifier:@"MyStudentDetailController" completion:^(BaseNavController *controller) {
//                    MyStudentDetailController *msd = (MyStudentDetailController*)controller;
//                    msd.memberId = tcm.memberId;
//                }];
                
                YGMyStudentDetailViewCtrl *vc = [YGMyStudentDetailViewCtrl instanceFromStoryboard];
                vc.memberId = tcm.memberId;
                ygweakify(self)
                vc.myStudentDetailRefreshBllock = ^() {
                    ygstrongify(self)
                    [self getDetails];
                    if (self.blockRefresh) {
                        self.blockRefresh(self->rm);
                    }
                };
                [self.navigationController pushViewController:vc animated:YES];
                
            }
           
        }else{
            [self pushWithStoryboard:@"Teach" title:@"教练详情" identifier:@"CoachDetailsViewController" completion:^(BaseNavController *controller) {
                CoachDetailsViewController *vc = (CoachDetailsViewController *)controller;
                vc.coachId = tcm.coachId;
            }];
        }
        
    };
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"TeachInfoCommentTableViewController"]) {
        TeachInfoCommentTableViewController *vc = segue.destinationViewController;
        vc.reservationId = rm.reservationId;
        vc.blockReturn = ^(id data){
            [self.navigationController popToViewController:self animated:YES];
            commentHeight = 0;
            if (_blockReturn) {
                _blockReturn(nil);
            }
            [self getDetails];
        };
    }
}

- (void)heightByCommentContentCell:(TeachCommentContentTableViewCell *)cell{
    for (NSLayoutConstraint *nc in [cell.labelContent constraints]) {
        if (nc.firstAttribute == NSLayoutAttributeHeight) {
            commentHeight = nc.constant;
            break;
        }
    }
    for (NSLayoutConstraint *nc in [cell.labelReplyContent constraints]) {
        if (nc.firstAttribute == NSLayoutAttributeHeight) {
            replyHeight = nc.constant;
            break;
        }
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (rm.publicClassId > 0) {
        if (rm.reservationStatus == 1) {
            if (indexPath.row == 0) {
                return [self cellForTeachInfoWithTableView:tableView indexPath:indexPath];
            }
            if (indexPath.row == 1) {
                FooterInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FooterInfoTableViewCell" forIndexPath:indexPath];
                cell.labelFooterInfo.text = @"公开课暂不支持取消，快去体验高尔夫的魅力吧！";
                return cell;
            }
        }
        if (rm.reservationStatus == 2) {
            if (indexPath.row == 0) {
                return [self cellForTeachInfoWithTableView:tableView indexPath:indexPath];
            }
            if (indexPath.row == 1) {
                TeachCommentContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TeachCommentContentTableViewCell" forIndexPath:indexPath];
                [cell loadCommentContent:rm.commentContent andReplyContent:[rm getReplyContentIfNotNull] starLevel:rm.starLevel];
                [self heightByCommentContentCell:cell];
                return cell;
            }
        }
        if (rm.reservationStatus == 6) {
            if (indexPath.row == 0) {
                return [self cellForTeachInfoWithTableView:tableView indexPath:indexPath];
            }
            
            if (_coachId > 0) {
                FooterInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FooterInfoTableViewCell" forIndexPath:indexPath];
                cell.labelFooterInfo.text = @"学员尚未做出评价，如果学员7天内未做出评价，系统将自动默认好评。";
                cell.btnCall.hidden = YES;
                return cell;
            }else{
                if (indexPath.row == 1) {
                    ActionTableViewCell *cell = (ActionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ActionTableViewCell" forIndexPath:indexPath];
                    [cell.btnAction setTitle:@"评价" forState:UIControlStateNormal];
                    if (cell.blockReturn == nil) {
                        cell.blockReturn = ^(id data){
                            [self performSegueWithIdentifier:@"TeachInfoCommentTableViewController" sender:nil];
                        };
                    }
                    return cell;
                }
                if (indexPath.row == 2) {
                    FooterInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FooterInfoTableViewCell" forIndexPath:indexPath];
                    cell.labelFooterInfo.text = @"如果您7天内未作出评价，系统将自动默认好评。";
                    return cell;
                }
            }
            
            
        }
    }else{
        if (rm.reservationStatus == 1) {
            if (indexPath.row == 0) {
                return [self cellForTeachInfoWithTableView:tableView indexPath:indexPath];
            }
            if (indexPath.row == 1) {
                if (_coachId > 0) {
                    return [self cellForActionTableViewCellWithTableView:tableView indexPath:indexPath];
                }else{
                    if (rm.canCancel) {
                        return [self cellForActionTableViewCellWithTableView:tableView indexPath:indexPath];
                    }else{
                        FooterInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FooterInfoTableViewCell" forIndexPath:indexPath];
                        cell.mobilePhone = rm.mobilePhone;
                        cell.btnCall.hidden = NO;
                        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
                        UIColor *fontColor = [UIColor colorWithHexString:@"#bbbbbb"];
                        [str appendAttributedString:[[NSAttributedString alloc] initWithString:@"距离课程开始低于12小时，不能取消课程；如果您需要取消课程，" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.f],NSForegroundColorAttributeName:fontColor}]];
                        [str appendAttributedString:[[NSAttributedString alloc] initWithString:@"请致电教练。"
                                                                                    attributes:@{
                                                                                                 NSFontAttributeName:[UIFont systemFontOfSize:12.0f],
                                                                                                 NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle],
                                                                                                 NSForegroundColorAttributeName:[UIColor colorWithRed:85/255.0 green:192/255.0 blue:234/255.0 alpha:1.0]
                                                                                                 }
                                                     ]];
                        
                        cell.labelFooterInfo.attributedText = str;
                        return cell;
                    }
                }
                
            }
            if (indexPath.row == 2) {
                FooterInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FooterInfoTableViewCell" forIndexPath:indexPath];
                cell.labelFooterInfo.text = @"如果您需要取消课程，请在课程开始之前12小时取消。";
                cell.btnCall.hidden = YES;
                return cell;
            }
        }
        if (rm.reservationStatus == 2) {
            if (indexPath.row == 0) {
                return [self cellForTeachInfoWithTableView:tableView indexPath:indexPath];
            }
            if (indexPath.row == 1) {
                if (_coachId > 0) {
                    if (rm.replyContent && rm.replyContent.length > 0) {
                        TeachCommentContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TeachCommentContentTableViewCell" forIndexPath:indexPath];
                        [cell loadCommentContent:rm.commentContent andReplyContent:[rm getReplyContentIfNotNull] starLevel:rm.starLevel];
                        [self heightByCommentContentCell:cell];
                        return cell;
                    }else{
                        TeachCommentContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TeachReplyButtonTableViewCell" forIndexPath:indexPath];
                        [cell loadCommentContent:rm.commentContent andReplyContent:[rm getReplyContentIfNotNull] starLevel:rm.starLevel];
                        [self heightByCommentContentCell:cell];
                        cell.blockReply = ^(id data){
                            self.viewAction = data;
                            [self showChatWithPlaceHolder:nil];
                        };
                        return cell;
                    }
                }else{
                    TeachCommentContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TeachCommentContentTableViewCell" forIndexPath:indexPath];
                    [cell loadCommentContent:rm.commentContent andReplyContent:[rm getReplyContentIfNotNull] starLevel:rm.starLevel];
                    [self heightByCommentContentCell:cell];
                    return cell;
                }
            }
        }
        if (rm.reservationStatus == 3) {
            if (indexPath.row == 0) {
                return [self cellForTeachInfoWithTableView:tableView indexPath:indexPath];
            }
            if (indexPath.row == 1) {
                FooterInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FooterInfoTableViewCell" forIndexPath:indexPath];
                cell.labelFooterInfo.text = _coachId > 0 ? @"学员未及时到场上课，该节课时已扣除！":@"您未及时到场上课，该节课时已扣除！";
                cell.btnCall.hidden = YES;
                return cell;
            }
        }
        if (rm.reservationStatus == 4) {
            if (indexPath.row == 0) {
                return [self cellForTeachInfoWithTableView:tableView indexPath:indexPath];
            }
            if (indexPath.row == 1) {
                FooterInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FooterInfoTableViewCell" forIndexPath:indexPath];
                cell.labelFooterInfo.text = [NSString stringWithFormat:@"课程已取消。"];
                return cell;
            }
        }
        if (rm.reservationStatus == 5) {
            if (indexPath.row == 0) {
                return [self cellForTeachInfoWithTableView:tableView indexPath:indexPath];
            }
            if (indexPath.row == 1) {
                if (_coachId > 0) {
                    ThreeActionTableViewCell *cell = (ThreeActionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ThreeActionTableViewCell" forIndexPath:indexPath];
                    cell.btn1Return = ^(id data){
                        if ([LoginManager sharedManager].loginState) {
                            CCAlertView *alert = [[CCAlertView alloc] initWithTitle:@"" message:@"确认已完成该教学？"];
                            [alert addButtonWithTitle:@"取消" block:nil];
                            [alert addButtonWithTitle:@"确定完成" block:^{
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    [[ServiceManager serviceManagerInstance] teachingMemberReservationComplete:[[LoginManager sharedManager] getSessionId] coachId:[LoginManager sharedManager].session.memberId reservationId:rm.reservationId opteraton:1 periodId:rm.periodId callBack:^(BOOL boolen) {
                                        if (boolen) {
                                            if (_blockCanceled) {
                                                _blockCanceled(@(6));
                                            }
                                            [self getDetails];
                                            [SVProgressHUD showSuccessWithStatus:@"确认成功"];
                                        }
                                    }];
                                });
                            }];
                            [alert show];
                        }
                    };
                    cell.btn2Return = ^(id data){
                        if ([LoginManager sharedManager].loginState) {
                            [self cancelReservation];
                        }
                    };
                    cell.btn3Return = ^(id data){
                        CCAlertView *alert = [[CCAlertView alloc] initWithTitle:@"" message:@"该学员未到场完成教学？"];
                        [alert addButtonWithTitle:@"取消" block:nil];
                        [alert addButtonWithTitle:@"确定未到场" block:^{
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                if ([LoginManager sharedManager].loginState) {
                                    [[ServiceManager serviceManagerInstance] teachingMemberReservationComplete:[[LoginManager sharedManager] getSessionId] coachId:[LoginManager sharedManager].session.memberId reservationId:rm.reservationId opteraton:2 periodId:rm.periodId callBack:^(BOOL boolen) {
                                        if (boolen) {
                                            if (_blockCanceled) {
                                                _blockCanceled(@(3));
                                            }
                                            [self getDetails];
                                            [SVProgressHUD showSuccessWithStatus:@"确认成功"];
                                        }
                                    }];
                                }
                            });
                        }];
                        [alert show];
                    };
                    return cell;
                }else{
                    FooterInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FooterInfoTableViewCell" forIndexPath:indexPath];
                    cell.labelFooterInfo.text = @"已过上课时间，等待教练确认。";
                    cell.btnCall.hidden = YES;
                    return cell;
                }
            }
        }
        if (rm.reservationStatus == 6) {
            if (indexPath.row == 0) {
                return [self cellForTeachInfoWithTableView:tableView indexPath:indexPath];
            }
            if (_coachId > 0) {
                FooterInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FooterInfoTableViewCell" forIndexPath:indexPath];
                cell.labelFooterInfo.text = @"学员尚未做出评价，如果学员7天内未做出评价，系统将自动默认好评。";
                cell.btnCall.hidden = YES;
                return cell;
            }else{
                if (indexPath.row == 1) {
                    ActionTableViewCell *cell = (ActionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ActionTableViewCell" forIndexPath:indexPath];
                    [cell.btnAction setTitle:@"评价" forState:UIControlStateNormal];
                    if (cell.blockReturn == nil) {
                        cell.blockReturn = ^(id data){
                            [self performSegueWithIdentifier:@"TeachInfoCommentTableViewController" sender:nil];
                        };
                    }
                    return cell;
                }
                if (indexPath.row == 2) {
                    FooterInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FooterInfoTableViewCell" forIndexPath:indexPath];
                    cell.labelFooterInfo.text = @"如果您7天内未作出评价，系统将自动默认好评。";
                    cell.btnCall.hidden = YES;
                    return cell;
                }
            }
        }
    }
    
    return [[UITableViewCell alloc] init];
}

- (void)serviceResult:(ServiceManager*)serviceManager Data:(id)data flag:(NSString*)flag{
    NSArray *arr = (NSArray *)data;
    if (Equal(flag, @"teaching_member_reservation_cancel")) {
        if (arr != nil) {
            if (_blockCanceled) {
                _blockCanceled(@(4));
            }
            [self getDetails];
        }
    }
    if (Equal(flag, @"teaching_comment_reply")) {
        BOOL result = [[arr firstObject] boolValue];
        if (result) {
            [SVProgressHUD showSuccessWithStatus:@"回复成功"];
            if (_blockReturn) {
                _blockReturn(nil);
            }
            [self getDetails];
            [self hideKeyboard];
        }
    }
    if (Equal(flag, @"teaching_member_reservation_detail")) {
        rm = [arr firstObject];
        if (rm) {
            if (_blockRefresh) {
                _blockRefresh(rm);
            }
        }
    }
    
    if (_loadingView) {
        [_loadingView removeFromSuperview];
    }
    self.tableView.hidden = NO;
    [self.tableView reloadData];
}


#pragma mark - TableViewDelegate

- (CGFloat)heightForTeachInfoCell{
    CGSize sizeProductName = CGSizeZero;
    CGSize size = CGSizeZero;
    NSString *text = [NSString stringWithFormat:@"%.2fkm %@",rm.distance,rm.address];
    sizeProductName = [rm.productName boundingRectWithSize:CGSizeMake(Device_Width - (rm.publicClassId > 0 ? 99:49), CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0]} context:nil].size;  //计算课程名称的高度
    
    size = [text boundingRectWithSize:CGSizeMake(Device_Width -129, 17 * 2) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0]} context:nil].size;
    
    return sizeProductName.height + size.height + 234;
    
}

- (CGFloat)heightForCommentContentCell{
    CGFloat h = 66;
    if (Device_Width > 320) {
        h = 70-8;
    }
    if (rm.publicClassId > 0) {
        h = 81;
        if (Device_Width > 320) {
            h = 81-15;
        }
    }
    
    h += commentHeight;
    if (rm.replyContent && rm.replyContent.length > 0) {
        h += replyHeight;
    }else{
        if (rm.publicClassId > 0) {
            h -= 15;
        }
    }
    
    
    return h;
}

- (CGFloat)heightForCommentButtonContentCell{
    CGFloat h = 96;
    h += commentHeight;
    return h;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return [self heightForTeachInfoCell];
    }
    if (rm.publicClassId > 0) {
        if (rm.reservationStatus == 1) {
            if (indexPath.row == 1) {
                return 60;
            }
        }
        if (rm.reservationStatus == 2) {
            if (indexPath.row == 1) {
                return [self heightForCommentContentCell];
            }
        }
        if (rm.reservationStatus == 6) {
            if (indexPath.row == 1) {
                if (_coachId > 0) {
                    return 60;
                }
                return 64;
            }
            if (indexPath.row == 2) {
                return 60;
            }
        }
    }else{
        if (rm.reservationStatus == 1) {
            if (indexPath.row == 1) {
                return 50;
            }
            if (indexPath.row == 2) {
                return 60;
            }
        }
        if (rm.reservationStatus == 2) {
            if (indexPath.row == 1) {
                if (_coachId > 0) {
                    if (rm.replyContent && rm.replyContent.length > 0) {
                        return [self heightForCommentContentCell];
                    }else{
                        return [self heightForCommentButtonContentCell];
                    }
                }else{
                    return [self heightForCommentContentCell];
                }
            }

        }
        if (rm.reservationStatus == 3) {
            if (indexPath.row == 1) {
                return 64;
            }
        }
        if (rm.reservationStatus == 4) {
            if (indexPath.row == 1) {
                return 64;
            }
        }
        if (rm.reservationStatus == 5) {
            if (indexPath.row == 1) {
                return _coachId > 0 ? 114:60;
            }
        }
        if (rm.reservationStatus == 6) {
            if (indexPath.row == 1) {
                if (_coachId > 0) {
                    return 60;
                }
                return 64;
            }
            if (indexPath.row == 2) {
                return 60;
            }
        }
    }
    return 0;
}

@end
