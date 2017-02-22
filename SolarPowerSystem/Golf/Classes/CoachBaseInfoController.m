//
//  CoachBaseInfoController.m
//  Golf
//
//  Created by 黄希望 on 15/6/16.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CoachBaseInfoController.h"
#import "CoachHeadCell.h"
#import "CCActionSheet.h"
#import "YGSystemImagePicker.h"
#import "HXPickerView.h"
#import "CoachItemInfoCell.h"
#import "ChooseAcademyController.h"
#import "CoachInfoReviewController.h"
#import "YGInputViewCtrl.h"

@interface CoachBaseInfoController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *titleArray;

@end

@implementation CoachBaseInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleArray = @[@[@"头像",@"名字",@"性别",@"年龄"],@[@"所属学院",@"教龄",@"个人简介",@"所获成就",@"教学成果"]];
    
    if (self.baseInfo == nil) {
        self.baseInfo = [[CoachBaseinfo alloc] init];
        self.baseInfo.gender = [LoginManager sharedManager].session.gender; // 未知
        self.baseInfo.nickName = [LoginManager sharedManager].session.nickName;
        self.baseInfo.birthday = [LoginManager sharedManager].session.birthday;
        self.baseInfo.headImageUrl = [LoginManager sharedManager].session.headImage;
    }
}

#pragma mark - UITableView delegate && dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 4;
    }else{
        return 5;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            CoachHeadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CoachHeadCell" forIndexPath:indexPath];
            if (self.baseInfo.headImage) {
                cell.headImageV.image = self.baseInfo.headImage;
            }else if (self.baseInfo.headImageUrl.length>0) {
                [cell.headImageV sd_setImageWithURL:[NSURL URLWithString:self.baseInfo.headImageUrl] placeholderImage:[UIImage imageNamed:@"head_member"]];
            }else{
                cell.headImageV.image = [UIImage imageNamed:@"head_member"];
            }
            return cell;
        }else{
            CoachItemInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CoachItemInfoCell" forIndexPath:indexPath];
            cell.itemTitleLabel.text = self.titleArray[indexPath.section][indexPath.row];
            if (indexPath.row == 1) {
                cell.itemContentLabel.text = self.baseInfo.nickName.length>0 ? self.baseInfo.nickName : @"";
            }else if (indexPath.row == 2){
                if (self.baseInfo.gender == 0) {
                    cell.itemContentLabel.text = @"女";
                }else if (self.baseInfo.gender == 1){
                    cell.itemContentLabel.text = @"男";
                }else{
                    cell.itemContentLabel.text = @"";
                }
            }else if (indexPath.row == 3){
                if (self.baseInfo.birthday>0) {
                    cell.itemContentLabel.text = @"";
                    int currentYear = [[Utilities getCurrentTimeWithFormatter:@"yyyy"] intValue];
                    if (self.baseInfo.birthday.length>4) {
                        int selectedYear = [[self.baseInfo.birthday substringWithRange:NSMakeRange(0, 4)] intValue];
                        if (currentYear>selectedYear) {
                            cell.itemContentLabel.text = [NSString stringWithFormat:@"%d",currentYear-selectedYear];
                        }
                    }
                }else{
                    cell.itemContentLabel.text = @"";
                }
            }
            return cell;
        }
    }else{
        CoachItemInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CoachItemInfoCell" forIndexPath:indexPath];
        cell.itemTitleLabel.text = self.titleArray[indexPath.section][indexPath.row];
        if (indexPath.row == 0) {
            cell.itemContentLabel.text = self.baseInfo.academyName.length>0?self.baseInfo.academyName:@"请务必正确选择所属学院，否则无法通过审核";
        }else if (indexPath.row == 1){
            cell.itemContentLabel.text = self.baseInfo.seniority>0?[NSString stringWithFormat:@"%d",self.baseInfo.seniority]:@"";
        }else if (indexPath.row == 2){
            cell.itemContentLabel.text = self.baseInfo.personalProfile.length>0?self.baseInfo.personalProfile:@"";
        }else if (indexPath.row == 3){
            cell.itemContentLabel.text = self.baseInfo.achievement.length>0?self.baseInfo.achievement:@"";
        }else{
            cell.itemContentLabel.text = self.baseInfo.teachHarvest.length>0?self.baseInfo.teachHarvest:@"";
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) return 58;
        return 44;
    }else{
        if (indexPath.row == 0) {
            return [self cellHeight:self.baseInfo.academyName.length>0?self.baseInfo.academyName:@"请务必正确选择所属学院，否则无法通过审核"];
        }else if (indexPath.row == 1){
            return 44;
        }else if (indexPath.row == 2){
            return [self cellHeight:self.baseInfo.personalProfile];
        }else if (indexPath.row == 3){
            return [self cellHeight:self.baseInfo.achievement];
        }else{
            return [self cellHeight:self.baseInfo.teachHarvest];
        }
    }
}

- (CGFloat)cellHeight:(NSString*)text{
    CGSize size = CGSizeZero;
    size = [Utilities getSize:text withFont:[UIFont systemFontOfSize:14.0] withWidth:Device_Width - 133];
    return MAX(size.height+28, 44);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) return 0.1;
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Device_Width, 15)];
        view.backgroundColor = [Utilities R:241 G:240 B:246];
        return view;
    }
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
            [YGSystemImagePicker presentSheetFrom:self modes:YGSystemImagePickerModes allowEditing:YES completion:^(UIImage *aImage) {
                self.baseInfo.headImage = aImage;
                NSString *imageData = [Utilities imageDataWithImage:aImage];
                self.baseInfo.headImageData = imageData;
                [self.tableView reloadData];
            }];
            
        }else if (indexPath.row == 1){
            [self editWithDefaultText:self.baseInfo.nickName placeHolder:@"请输入名字" isTextField:YES length:8 title:@"名字" complete:^(id obj) {
                self.baseInfo.nickName = [obj description];
                [self.tableView reloadData];
            }];
        }else if (indexPath.row == 2){
            [self pickViewWithIdentifier:@"gender" defaultData:[NSString stringWithFormat:@"%d",self.baseInfo.gender] compltetion:^(id obj) {
                self.baseInfo.gender = [obj intValue];
                [self.tableView reloadData];
            }];
        }else{
            [self pickViewWithIdentifier:@"birthday" defaultData:self.baseInfo.birthday compltetion:^(id obj) {
                self.baseInfo.birthday = [obj description];
                [self.tableView reloadData];
            }];
        }
    }else{
        if (indexPath.row == 0) {
            [self pushWithStoryboard:@"Coach" title:@"选择学院" identifier:@"ChooseAcademyController" completion:^(BaseNavController *controller) {
                ChooseAcademyController *chooseAcademy = (ChooseAcademyController*)controller;
                chooseAcademy.blockReturn = ^(id obj){
                    AcademyModel *am = (AcademyModel*)obj;
                    self.baseInfo.academyId = am.academyId;
                    self.baseInfo.academyName = am.academyName;
                    [self.tableView reloadData];
                };
            }];
        }else if (indexPath.row == 1){
            [self pickViewWithIdentifier:@"seniority" defaultData:[NSString stringWithFormat:@"%d",self.baseInfo.seniority] compltetion:^(id obj) {
                self.baseInfo.seniority = [obj intValue];
                [self.tableView reloadData];
            }];
        }else if (indexPath.row == 2){
            [self editWithDefaultText:self.baseInfo.personalProfile placeHolder:@"请填写个人简介" isTextField:NO length:100 title:@"个人简介" complete:^(id obj) {
                self.baseInfo.personalProfile = [obj description];
                [self.tableView reloadData];
            }];
        }else if (indexPath.row == 3){
            [self editWithDefaultText:self.baseInfo.achievement placeHolder:@"请填写所获成就" isTextField:NO length:100 title:@"所获成就" complete:^(id obj) {
                self.baseInfo.achievement = [obj description];
                [self.tableView reloadData];
            }];
        }else{
            [self editWithDefaultText:self.baseInfo.teachHarvest placeHolder:@"请填写教学成果" isTextField:NO length:100 title:@"教学成果" complete:^(id obj) {
                self.baseInfo.teachHarvest = [obj description];
                [self.tableView reloadData];
            }];
        }
    }
}

// 文本编辑
- (void)editWithDefaultText:(NSString*)defaultText placeHolder:(NSString*)placeHolder isTextField:(BOOL)isTextField length:(int)length title:(NSString*)title complete:(BlockReturn)complete{
    YGInputViewCtrl *vc = [YGInputViewCtrl instanceFromStoryboard];
    vc.title = title;
    vc.blockReturn = complete;
    vc.isTextField = isTextField;
    vc.placeHolderText = placeHolder;
    vc.defaultText = defaultText;
    vc.maxLength = length;
    [self.navigationController pushViewController:vc animated:YES];
}

// 选择器
- (void)pickViewWithIdentifier:(NSString*)identifier defaultData:(NSString*)data compltetion:(BlockReturn)completion{
    [HXPickerView sharePickerViewInView:self.view identifier:identifier data:data completion:completion];
}

- (IBAction)submitInfo:(id)sender{
    NSString *errorMsg = nil;
    if (!self.baseInfo.headImage&&self.baseInfo.headImageUrl.length==0) {
        errorMsg = @"请设置头像";
    }else if (self.baseInfo.nickName.length==0){
        errorMsg = @"请填写教练名字";
    }else if (self.baseInfo.gender==2){
        errorMsg = @"请选择性别";
    }else if (self.baseInfo.birthday.length==0){
        errorMsg = @"请选择出生年月";
    }else if (self.baseInfo.academyName.length==0){
        errorMsg = @"请选择所属学院";
    }else if (self.baseInfo.seniority<=0){
        errorMsg = @"请选择教龄";
    }
    if (errorMsg) {
        [SVProgressHUD showInfoWithStatus:errorMsg];
        return;
    }
    
    [[ServiceManager serviceManagerWithDelegate:self] UserEditInfo:[[LoginManager sharedManager] getSessionId] memberName:[LoginManager sharedManager].session.memberName nickName:self.baseInfo.nickName gender:self.baseInfo.gender headImageData:self.baseInfo.headImageData photoImageData:nil birthday:self.baseInfo.birthday signature:nil location:nil handicap:-100 personalTag:nil academyId:self.baseInfo.academyId seniority:self.baseInfo.seniority introduction:self.baseInfo.personalProfile careerAchievement:self.baseInfo.achievement teachingAchievement:self.baseInfo.teachHarvest];
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    if (Equal(flag, @"user_edit_info")) {
        if (serviceManager.success) {
            if (_blockReturn) {
                NSArray *arr = (NSArray*)data;
                if (arr.count > 0) {
                    NSDictionary *dic = [arr firstObject];
                    [LoginManager sharedManager].session.nickName = dic[@"nick_name"];
                    [LoginManager sharedManager].session.headImage = dic[@"head_image"];
                    _blockReturn (nil);
                }
            }
            [self pushWithStoryboard:@"Coach" title:@"申请开通教练" identifier:@"CoachInfoReviewController" completion:^(BaseNavController *controller){
                CoachInfoReviewController *coachInfoReview = (CoachInfoReviewController*)controller;
                coachInfoReview.isReview = NO;
            }];
        }
    }
}

@end
