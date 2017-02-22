//
//  JXChooseTimeController.m
//  Golf
//
//  Created by 黄希望 on 15/5/6.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "JXChooseTimeController.h"
#import "JXChooseTime.h"
#import "TeachingOrderStatus.h"
#import "TeachingReservationSuccessController.h"
#import "JXConfirmOrderController.h"
#import "CoachDetailsViewController.h"
#import "TeachingCourseType.h"
#import "CalendarClass.h"

#import "PayOnlineViewController.h"

@interface JXChooseTimeController ()<UITextFieldDelegate>
{
    UIControl *coverView;
}
@property (nonatomic,weak) IBOutlet UILabel *productNameLabel;
@property (nonatomic,weak) IBOutlet UIImageView *headImageV;
@property (nonatomic,weak) IBOutlet UILabel *coachNameLabel;
@property (nonatomic,weak) IBOutlet UILabel *dateLabel;
@property (nonatomic,weak) IBOutlet UILabel *shortAddressLabel;
@property (nonatomic,weak) IBOutlet UITextField *phoneNumField;
@property (nonatomic,weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic,weak) IBOutlet UIView *phoneNumView;
@property (nonatomic,weak) IBOutlet UIButton *doneBtn;
@property (nonatomic,weak) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgViewBottomConstraint;
@property (nonatomic,weak) IBOutlet UILabel *fxLabel1;
@property (nonatomic,weak) IBOutlet UILabel *fxLabel2;
@property (nonatomic,weak) IBOutlet UIView *fxView;

@property (nonatomic,strong) NSString *selectedDate;
@property (nonatomic,strong) NSString *selectedTime;
@property (nonatomic,strong) NSDictionary *disTimeDic; // 被禁止掉的时间

@property (nonatomic,strong) TeachProductDetail *tpd;

// 前一个页面有键盘通知，如果监听了，会自动弹起选择时间的确认视图
@property (assign, nonatomic) BOOL isViewCtrlDidAppear;

@end

@implementation JXChooseTimeController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initization];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getTeachingProduct];
    [self.phoneNumField endEditing:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.isViewCtrlDidAppear = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    self.isViewCtrlDidAppear = NO;
    [self.phoneNumField endEditing:YES];
    [self resume:coverView];
}

- (void)getTeachingProduct{
    [[ServiceManager serviceManagerWithDelegate:self] teachingProductDetail:self.productId];
}

- (void)getTimeList{
    [[ServiceManager serviceManagerWithDelegate:self] teachingCoachProductTime:self.teachingCoach.coachId productId:self.productId classNo:self.classNo];
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    if (serviceManager.success) {
        NSArray *array = (NSArray*)data;
        if (array.count > 0){
            if (Equal(flag, @"teaching_coach_product_timetable")) {
                self.disTimeDic = array[0];
                [self systemChoooseSelectedDate];
                [self createChooseTimeView];
            }
            if (Equal(flag, @"teaching_order_submit")) {
                TeachingSubmitInfo *si = array[0];
                if (si.orderState == TeachingOrderStatusTeaching) {
                    [self pushWithStoryboard:@"Jiaoxue" title:@"预约成功" identifier:@"TeachingReservationSuccessController" completion:^(BaseNavController *controller) {
                        TeachingReservationSuccessController *vc = (TeachingReservationSuccessController*)controller;
                        vc.teachingCoachModel = self.teachingCoach;
                        vc.date = self.selectedDate;
                        vc.time = self.selectedTime;
                        vc.productId = self.productId;
                        vc.blockReturn = _blockReturn;
                    }];
                }else if (si.orderState == TeachingOrderStatusWaitPay){
                    PayOnlineViewController *vc = [[PayOnlineViewController alloc] init];
                    vc.payTotal = si.orderTotal;
                    vc.orderTotal = si.orderTotal;
                    vc.orderId = si.orderId;
                    vc.waitPayFlag = 3;
                    vc.productId = si.productId;
                    vc.academyId = si.academyId;
                    vc.classType = si.classType;
                    vc.classHour = self.classHour;
                    vc.blockReturn = _blockReturn;
                    [self pushViewController:vc title:@"在线支付" hide:YES];
                }
            }
            if (Equal(flag, @"teaching_member_reservation_add")) {
                ReservationModel *model = array[0];
                
                self.teachingCoach = [[TeachingCoachModel alloc] init];
                self.teachingCoach.coachId = model.coachId;
                self.teachingCoach.nickName = model.nickName;
                self.teachingCoach.headImage = model.headImage;
                self.teachingCoach.teachingSite = model.teachingSite;
                self.teachingCoach.address = model.address;
                self.teachingCoach.longitude = model.longitude;
                self.teachingCoach.latitude = model.latitude;
                self.teachingCoach.distance = model.distance;
                
                [self pushWithStoryboard:@"Jiaoxue" title:@"预约成功" identifier:@"TeachingReservationSuccessController" completion:^(BaseNavController *controller) {
                    TeachingReservationSuccessController *vc = (TeachingReservationSuccessController*)controller;
                    vc.teachingCoachModel = self.teachingCoach;
                    vc.date = self.selectedDate;
                    vc.time = self.selectedTime;
                    vc.productId = self.productId;
                    vc.blockReturn = _blockReturn;
                }];
            }
            if (Equal(flag, @"teaching_product_detail")){
                _tpd = (TeachProductDetail*)array[0];
                [self getTimeList];
            }
        }
    }
}

- (void)initization{
    
    self.selectedDate = [Utilities stringwithDate:[NSDate date]];
    self.selectedTime = @"";
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enterCoachHome:)];
    [self.headImageV addGestureRecognizer:tap];
    
    [Utilities drawView:self.phoneNumView radius:3 bordLineWidth:0.5 borderColor:[Utilities R:200 G:200 B:200]];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:KGolfSessionPhone]) {
        self.phoneNumField.text = [[NSUserDefaults standardUserDefaults] objectForKey:KGolfSessionPhone];
    }
    
    [self.productNameLabel setText:_productName];
    [self.headImageV sd_setImageWithURL:[NSURL URLWithString:_teachingCoach.headImage] placeholderImage:self.defaultImage];
    [self.coachNameLabel setText:_teachingCoach.nickName];
    [self.shortAddressLabel setText:_teachingCoach.teachingSite];
    
    if (_returnCash > 0) {
        _fxLabel1.layer.borderColor = [UIColor colorWithHexString:@"#ff9547"].CGColor;
        [_fxLabel1 setText:[NSString stringWithFormat:@" 返%d ",_returnCash]];
        [_fxLabel2 setText:[NSString stringWithFormat:@"购买课程后返%d云币，1云币价值1元现金",_returnCash]];
    }else{
        _fxView.hidden = YES;
    }
    
    if (_classId > 0 && self.remainHour > 0) {
        if (self.classType == TeachingCourseTypeMulti || self.classType == TeachingCourseTypeMulti) {
            [self.doneBtn setTitle:[NSString stringWithFormat:@"确认预约，消耗1课时"] forState:UIControlStateNormal];
        }else{
            [self.doneBtn setTitle:@"确认预约" forState:UIControlStateNormal];
        }
    }else if (_classId == 0 && self.remainHour == 0) {
        if (_sellingPrice > 0) {
            [self.doneBtn setTitle:[NSString stringWithFormat:@"确认预约，去支付¥%d",_sellingPrice] forState:UIControlStateNormal];
        }else{
            [self.doneBtn setTitle:@"确认预约" forState:UIControlStateNormal];
        }
    }else{
        [self.doneBtn setTitle:@"确认预约" forState:UIControlStateNormal];
    }
    
    ygweakify(self)
    [self.bgView whenTapped:^(id gr){
        ygstrongify(self)
        [self.phoneNumField resignFirstResponder];
    }];
    
//    [self setBgViewHidden:YES];
}

- (void)systemChoooseSelectedDate{
    NSArray *keyArr = [self.disTimeDic allKeys];
    NSArray *newArr = [keyArr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *dateA = [obj1 description];
        NSString *dateB = [obj2 description];
        NSDate *dA = [Utilities getDateFromString:dateA];
        NSDate *dB = [Utilities getDateFromString:dateB];
        NSComparisonResult result = [dA compare:dB];
        if (result == NSOrderedDescending) {
            return 1;
        }else if (result == NSOrderedAscending){
            return -1;
        }
        return 0;
    }];
    int p = 0;
    for (id obj in newArr) {
        if (p == 1) {
            break;
        }
        NSArray *arr = self.disTimeDic[obj];
        for (id a in arr) {
            if ([a intValue] == 0) {
                self.selectedDate = [obj description];
                p = 1;
                break;
            }
        }
    }
}

- (void)createChooseTimeView{
    int maxNum = _tpd.personLimit>0 ? MIN(_tpd.personLimit, _tpd.classHour) : _tpd.classHour;
    [JXChooseTime jxWithDisableTime:self.disTimeDic date:self.selectedDate time:self.selectedTime maxNum:maxNum classType:_classType supView:self.view posY:64.f completion:^(NSString *date, NSString *time) {
        if (date.length != 0 && time.length != 0) {
            
            if (!coverView) {
                coverView = [[UIControl alloc] initWithFrame:self.view.bounds];
            }
            coverView.backgroundColor = [UIColor blackColor];
            coverView.alpha = 0.6;
            [coverView addTarget:self action:@selector(resume:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.view addSubview:coverView];
            [self.view bringSubviewToFront:self.bgView];
           
            self.selectedDate = date;
            self.selectedTime = time;
            
            NSString *d = [Utilities getDateStringFromString:self.selectedDate WithFormatter:@"MM月dd日"];
            NSString *week = [Utilities getWeekDayByDate:[Utilities getDateFromString:self.selectedDate]];
            self.dateLabel.text = [NSString stringWithFormat:@"%@ %@ %@",d,week,self.selectedTime];
            self.doneBtn.enabled = YES;
            
            NSString *theTime = [time substringToIndex:time.length-@":00".length];
            theTime = [NSString stringWithFormat:@"%02d:00",[theTime intValue]];
            
            NSString *date = [NSString stringWithFormat:@"%@ %@:00",self.selectedDate,theTime];
            NSDate *dd = [Utilities getDateFromString:date WithFormatter:@"yyyy-MM-dd HH:mm:ss"];
            NSTimeInterval timeInterval = [dd timeIntervalSinceNow];
            if (timeInterval > 2*3600) {
                self.descriptionLabel.text = @"如需取消请提前2小时，超时后不可取消";
            }else if (timeInterval > 0){
                self.descriptionLabel.text = @"预约的时间小于2小时，预约后不可取消";
            }else{
                self.descriptionLabel.text = @"您选择的时间小于当前时间，不可预约";
                [SVProgressHUD showInfoWithStatus:@"您选择的时间小于当前时间，不可预约"];
                self.doneBtn.enabled = NO;
            }
            
            [self setBgViewHidden:NO];
        }else{
            [self setBgViewHidden:YES];
        }
    }];
}

- (void)resume:(UIControl*)control
{
    if ([self.phoneNumField isFirstResponder]) {
        //隐藏键盘
        [self.phoneNumField endEditing:YES];
    }else{
        // 隐藏支付信息
        [JXChooseTime deSelected];
        [self setBgViewHidden:YES];
        if (control.superview) {
            [control removeFromSuperview];
            control = nil;
            
        }
        
    }
}

- (void)setBgViewHidden:(BOOL)hidden
{
    if (hidden) {
        CGSize bestSize = [self.bgView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        [UIView animateWithDuration:.2f animations:^{
            self.bgViewBottomConstraint.constant = -bestSize.height;
            [self.view layoutIfNeeded];
        }];
        
    }else{
        [UIView animateWithDuration:.4f animations:^{
            self.bgViewBottomConstraint.constant = 0.f;
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)keyboardFrameWillChanged:(NSNotification *)noti
{
    if (self.isViewCtrlDidAppear) {
        
        NSDictionary *info = noti.userInfo;
        
        CGRect keyboardFrame = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        NSTimeInterval duration = [info[UIKeyboardAnimationDurationUserInfoKey] floatValue];
        
        CGFloat offset = Device_Height - CGRectGetMinY(keyboardFrame);
        
        [UIView animateWithDuration:duration animations:^{
            self.bgViewBottomConstraint.constant = offset;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField endEditing:YES];
        return NO;
    }
    
    NSString * StringOne = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([StringOne length] > 12) {
        textField.text = [StringOne substringToIndex:12];
        return NO;
    }
    return YES;
}

- (IBAction)payAction:(id)sender{
    NSString *errorMsg = nil;
    if (self.selectedDate.length==0 || self.selectedTime.length==0) {
        errorMsg = @"请选择预约时间";
    }else if (![Utilities phoneNumMatch:self.phoneNumField.text]){
        errorMsg = @"手机号错误";
    } else if (_teachingCoach.coachId == [LoginManager sharedManager].session.memberId) {
        errorMsg = @"不能预约自己";
    }
    
    if (errorMsg) {
        [SVProgressHUD showErrorWithStatus:errorMsg];
        return;
    }
    
    if (self.classId > 0) {
        if (self.remainHour > 0) {
            [[ServiceManager serviceManagerWithDelegate:self] teachingMemberReservation:[[LoginManager sharedManager] getSessionId] classId:self.classId date:self.selectedDate time:self.selectedTime longitude:[LoginManager sharedManager].currLongitude latitude:[LoginManager sharedManager].currLatitude periodId:self.periodId];
        }else{
            [SVProgressHUD showInfoWithStatus:@"没有可预约的课时"];
        }
    }else{
        if (self.classType == TeachingCourseTypeMulti) {
            [self pushWithStoryboard:@"Jiaoxue" title:@"确认订单" identifier:@"JXConfirmOrderController" completion:^(BaseNavController *controller) {
                JXConfirmOrderController *jxConfirmOrder = (JXConfirmOrderController*)controller;
                jxConfirmOrder.teachingCoach = self.teachingCoach;
                jxConfirmOrder.productId = self.productId;
                jxConfirmOrder.classHour = self.classHour;
            }];
        }else{
            [[ServiceManager serviceManagerWithDelegate:self] teachingSubmitOrder:[[LoginManager sharedManager] getSessionId] publicClassId:self.publicClassId productId:self.productId coachId:self.teachingCoach.coachId date:self.selectedDate time:self.selectedTime phoneNum:self.phoneNumField.text];
        }
    }
}

- (void)enterCoachHome:(UITapGestureRecognizer *)tap{
    // 进入教练主页
    [self pushWithStoryboard:@"Teach" title:@"教练主页" identifier:@"CoachDetailsViewController" completion:^(BaseNavController *controller) {
        CoachDetailsViewController *coachDetails = (CoachDetailsViewController*)controller;
        coachDetails.coachId = self.teachingCoach.coachId;
    }];
}


@end
