//
//  FillOrderViewController.m
//  Golf
//
//  Created by user on 13-6-5.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import "FillOrderViewController.h"
#import "AddPlayersViewController.h"
#import "OrderSubmitParamsModel.h"
#import "OpenUDID.h"
#import "CouponModel.h"
#import "LoginManager.h"
#import "LoginService.h"
#import "FillOrderCell.h"
#import "InvoiceViewController.h"
#import "SubmitSuccessController.h"
#import "YGCapabilityHelper.h"
#import "PayOnlineViewController.h"
#import "VIPClubModel.h"

@interface FillOrderViewController ()<UITextViewDelegate, UIScrollViewDelegate>{
    UILabel *_invoiceLabel;
}

@property (nonatomic,copy) NSString *textviewText;
@property (nonatomic) CGFloat textviewHeight;
@property (nonatomic,strong) UITextView *textView;
@property (nonatomic,strong) Invoice *invoice;

@end

@implementation FillOrderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    scrollView.frame = [UIScreen mainScreen].bounds;
    scrollView.hidden = YES;
    self.textviewText = @"其它要求请留言:";
    
    if (self.ttmodel.payType == PayTypeDeposit && self.ttmodel.depositEachMan > 0) {
        depositView.hidden = NO;
    }else{
        depositView.hidden = YES;
    }
    
    _toolBar = [[GToolBar alloc] initWithFrame:CGRectMake(0.0, 0.0, Device_Width, 35.0)];
    _toolBar.toolBarDelegate = self;
    _toolBar.isCancelBtnHide = YES;
    
    phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(Device_Width-200, 7, 180, 30)];
    phoneTextField.delegate = self;
    phoneTextField.font = [UIFont systemFontOfSize:16];
    phoneTextField.textColor = [UIColor colorWithHexString:@"333333"];
    phoneTextField.placeholder = @"用于接收通知短信";
    phoneTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    phoneTextField.textAlignment = NSTextAlignmentRight;
    phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    phoneTextField.returnKeyType = UIReturnKeyDone;
    phoneTextField.borderStyle = UITextBorderStyleNone;
    
    _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, Device_Width, 246) style:UITableViewStyleGrouped];
    _tableview.separatorColor = [UIColor colorWithHexString:@"e6e6e6"];
    _tableview.delegate = self;
    _tableview.dataSource = self;
    _tableview.scrollEnabled = NO;
    [scrollView addSubview:_tableview];
    scrollView.delegate = self;//lyf 加
    [_tableview registerNib:[UINib nibWithNibName:@"FillOrderCell_1" bundle:NULL] forCellReuseIdentifier:@"FillOrderCell_1"];
        
    [self setPayViewData];
    [self refreshView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self leftButtonAction];
    [self.navigationItem setRightBarButtonItems:[self navBtnTitleAndImageItems:@[@{@"btnImageName":@"btn_ic_phone",@"btnTitle":@"客服"}]]];
    [GolfAppDelegate shareAppDelegate].currentController = self;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:KLastPersonPhone]) {
        phoneTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:KLastPersonPhone];
    }else if ([[NSUserDefaults standardUserDefaults] objectForKey:KGolfSessionPhone]) {
        phoneTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:KGolfSessionPhone];
    }
    
    NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"playersName"];
    if (array.count > 0) {
        NSMutableString *names = [[NSMutableString alloc] init];
        for (NSString *string in array){
            if([string length] > 0) {
                [names appendFormat:@";%@",string];
            }
        }
        if([names length]>0) {
            self.nameStr = [names substringFromIndex:1];
        }
    }else{
        self.nameStr = @"请添加打球人名字";
    }
    
    if ([LoginManager sharedManager].loginState) {
        [[ServiceManager serviceManagerInstance] getDepositInfoData:[[LoginManager sharedManager] getSessionId] callBack:^(DepositInfoModel *model) {
            [LoginManager sharedManager].myDepositInfo = model;
            
            scrollView.hidden = NO;
            [_tableview reloadData];
            [self refreshView];
        }];
    }else{
        [_tableview reloadData];
        [self refreshView];
        [[LoginManager sharedManager] loginWithDelegate:nil controller:self animate:YES blockRetrun:^(id data) {
            bookBtn.enabled = YES;
            phoneTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:KGolfSessionPhone];
            
            [[ServiceManager serviceManagerInstance] getDepositInfoData:[[LoginManager sharedManager] getSessionId] callBack:^(DepositInfoModel *model) {
                [LoginManager sharedManager].myDepositInfo = model;
                
                scrollView.hidden = NO;
                [self bookAction:nil];
            }];
        }];
    }
}

- (void)rightItemsButtonAction:(UIButton*)button{
    [phoneTextField resignFirstResponder];
    [self keyDownAction];
    [YGCapabilityHelper call:[Utilities getGolfServicePhone] needConfirm:YES];
}

- (void)setPayViewData{
    UILabel *label_1 = (UILabel*)[payNumShowView viewWithTag:1];
    UILabel *label_2 = (UILabel*)[payNumShowView viewWithTag:2];
    UILabel *label_3 = (UILabel*)[payNumShowView viewWithTag:3];
    UILabel *label_4 = (UILabel*)[payNumShowView viewWithTag:4];
    UILabel *label_5 = (UILabel*)[payNumShowView viewWithTag:5];
    
    if (self.isVip&&self.ttmodel.agentId==0) {
        label_5.text = @"当前正已球会会员身份进行预订，实际付款金额请以球会前台确认为准";
    }else {
        NSString *payNumString = nil;
        if ((self.ttmodel.payType == PayTypeDeposit && self.ttmodel.depositEachMan<=0) || self.ttmodel.payType == PayTypeOnline) {
            label_1.text = PayType[self.ttmodel.payType];
            payNumString = [NSString stringWithFormat:@"¥%d",self.ttmodel.price*_myCondition.people];
        }else if (self.ttmodel.payType == PayTypeDeposit && self.ttmodel.depositEachMan > 0){
            label_1.text = [NSString stringWithFormat:@"球场现付¥%d，预付押金",self.ttmodel.price*_myCondition.people];
            payNumString = [NSString stringWithFormat:@"¥%d",self.ttmodel.depositEachMan*_myCondition.people];
        }else if (self.ttmodel.payType == PayTypeOnlinePart){
            label_1.text = [NSString stringWithFormat:@"球场现付¥%d，在线预付",self.ttmodel.price*_myCondition.people-self.ttmodel.depositEachMan*_myCondition.people];
            payNumString = [NSString stringWithFormat:@"¥%d",self.ttmodel.depositEachMan*_myCondition.people];
        }
        label_2.attributedText = [Utilities attributedStringWithString:payNumString value1:[UIFont systemFontOfSize:11] range1:NSMakeRange(0, 1) value2:nil range2:NSMakeRange(0, 0) font:18 otherValue:nil otherRange:NSMakeRange(0, 0)];
        if (self.ttmodel.payType == PayTypeOnlinePart) {
            NSString *sss = [NSString stringWithFormat:@"总价 ¥%d",self.ttmodel.price*_myCondition.people];
            label_3.attributedText = [Utilities attributedStringWithString:sss value1:[UIColor colorWithHexString:@"ff6d00"] range1:NSMakeRange(3, sss.length-3) value2:[UIFont systemFontOfSize:11] range2:NSMakeRange(3, 1) font:14 otherValue:nil otherRange:NSMakeRange(0, 0)];
        }
        
        if (self.ttmodel.yunbi>0) {
            label_4.text = [NSString stringWithFormat:@"返%d云币",self.ttmodel.yunbi*_myCondition.people];
        }
        
        CGSize sz = [label_2.attributedText boundingRectWithSize:label_2.frame.size options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) context:nil].size; //[Utilities getSize:label_2.text attributes:@{[]} withWidth:label_2.frame.size.width];
        CGRect rt = label_1.frame;
        rt.origin.x = label_2.frame.origin.x+label_2.frame.size.width-sz.width-label_1.frame.size.width-18;
        label_1.frame = rt;
        
        sz = [Utilities getSize:label_4.text withFont:label_4.font withWidth:label_4.frame.size.width];
        rt = label_3.frame;
        if (self.ttmodel.yunbi==0) {
            rt.origin.x = label_4.frame.origin.x+label_4.frame.size.width-sz.width-label_3.frame.size.width;
        }else{
            rt.origin.x = label_4.frame.origin.x+label_4.frame.size.width-sz.width-label_3.frame.size.width-10;
        }
        label_3.frame = rt;
    }
}

- (void)refreshView{
    CGRect frame = _tableview.frame;
    frame.size.height = _tableview.contentSize.height;
    _tableview.frame = frame;
    
    frame = payNumShowView.frame;
    frame.origin.y = _tableview.frame.size.height + 5;
    if ((_myCondition.payType == PayTypeDeposit || _myCondition.payType == PayTypeOnline) && self.ttmodel.yunbi==0) {
        frame.size.height = 30;
    }
    frame.origin.x = 13;//lyf 加
    frame.size.width = [UIScreen mainScreen].bounds.size.width - 26;//lyf 加
    payNumShowView.frame = frame;
    
    frame = depositView.frame;
    frame.origin.y = payNumShowView.frame.origin.y + payNumShowView.frame.size.height;
    depositView.frame = frame;
    
    if (depositView.hidden) {
        frame = bookBtn.frame;
        frame.origin.x = 13;//lyf 加
        frame.size.width = [UIScreen mainScreen].bounds.size.width - 26;//lyf 加
        if (_ttmodel.yunbi>0) {
            frame.origin.y = payNumShowView.frame.origin.y + payNumShowView.frame.size.height + 6;
        }else if (self.ttmodel.payType == PayTypeOnlinePart || _isVip){
            frame.origin.y = payNumShowView.yg_y + 52 + 6;
        }else{
            frame.origin.y = payNumShowView.frame.origin.y +40;
        }
        bookBtn.frame = frame;
    }else{
        frame = bookBtn.frame;
        frame.origin.x = 13;//lyf 加
        frame.size.width = [UIScreen mainScreen].bounds.size.width - 26;//lyf 加
        frame.origin.y = depositView.frame.origin.y + depositView.frame.size.height + 15;
        bookBtn.frame = frame;
    }
    
    [scrollView setContentSize:CGSizeMake(Device_Width, bookBtn.yg_y + bookBtn.height + 30)];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _ttmodel.hasInvoice ? 3 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 4;
            break;
        case 2:
            return 1;
            break;
            
        default:
            break;
    }
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
//        FillOrderCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FillOrderCell_1" owner:self options:nil] lastObject];
        FillOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FillOrderCell_1" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.mainLabel.text = _myCondition.clubName;
        NSString *payButtonTitle = nil;

        NSString *date = [Utilities getDateStringFromString:_ttmodel.date WithFormatter:@"MM月dd日"];
        NSString *weekStr = [Utilities getWeekDayByDate:[Utilities getDateFromString:_ttmodel.date]];

        if (self.ttmodel.agentId == 0) {
            if (_isVip || (self.ttmodel.payType == PayTypeDeposit && self.ttmodel.depositEachMan == 0)) {
                payButtonTitle = @"确认并预订";
            }else{
                payButtonTitle = @"确认并支付";
            }
            
            NSString *string = [NSString stringWithFormat:@"%@ %@  %@ %@",date,weekStr,self.ttmodel.teetime,self.ttmodel.courseName.length>0?self.ttmodel.courseName:@""];
            NSMutableAttributedString *mas = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}];
            [mas setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"999999"]} range:NSMakeRange(date.length+1, weekStr.length)];
            if (_ttmodel.courseName.length>0) {
                [mas setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"999999"]} range:NSMakeRange(string.length-self.ttmodel.courseName.length, self.ttmodel.courseName.length)];
            }
            cell.subLabel.attributedText = mas;
        }else{
            payButtonTitle = @"确认并预订";
            
            NSString *string = [NSString stringWithFormat:@"%@ %@  %@",date,weekStr,self.ttmodel.teetime];
            NSMutableAttributedString *mas = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}];
            [mas setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"999999"]} range:NSMakeRange(date.length+1, weekStr.length)];
            cell.subLabel.attributedText = mas;
        }
        [cell.infoBtn setTitle:[NSString stringWithFormat:@" 将为您预订%@前后30分钟内的开球时间",_ttmodel.teetime] forState:UIControlStateNormal];
        [bookBtn setTitle:payButtonTitle forState:UIControlStateNormal];
        return cell;
    }else if (indexPath.section == 1){
        FillOrderCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FillOrderCell_2" owner:self options:nil] lastObject];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row == 0) {
            cell.mainLabel.text = @"人数";
            SelectPeopleView *view = [[[NSBundle mainBundle] loadNibNamed:@"SelectPeopleView" owner:self options:nil] lastObject];
            view.delegate = self;
            [view selectPeopleWithRemainMans:self.ttmodel.mans minBuyQuantity:self.ttmodel.minBuyQuantity curMans:_myCondition.people];
            cell.accessoryView = view;
        }else if (indexPath.row == 1){
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.mainLabel.text = @"姓名";
            cell.subLabel.textColor = [UIColor colorWithHexString:@"999999"];
            cell.subLabel.text = @"请添加打球人名字";
            if (_nameStr&&![_nameStr isEqualToString:@"请添加打球人名字"]) {
                cell.subLabel.textColor = [UIColor colorWithHexString:@"333333"];
                cell.subLabel.text = _nameStr;
            }
        }else if (indexPath.row == 2){
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.mainLabel.text = @"手机号";
            cell.accessoryView = phoneTextField;
        }else{
            UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Device_Width-28, 32)];
            bgView.backgroundColor  = [UIColor colorWithHexString:@"e6e6e6"];
            bgView.layer.cornerRadius = 3.f;

            self.textView = [[UITextView alloc] initWithFrame:CGRectMake(5, 0, bgView.width-10, bgView.height)];
            self.textView.backgroundColor  = [UIColor clearColor];
            self.textView.text = self.textviewText;
            self.textView.textColor = Equal(self.textviewText, @"其它要求请留言:") ? [UIColor colorWithHexString:@"999999"] : [UIColor colorWithHexString:@"333333"];
            self.textView.font = [UIFont systemFontOfSize:14];
            self.textView.delegate = self;
            self.textView.returnKeyType = UIReturnKeyDone;
            [bgView addSubview:self.textView];
            cell.accessoryView = bgView;
        }
        return cell;
    }else{
        FillOrderCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FillOrderCell_2" owner:self options:nil] lastObject];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.mainLabel.text = @"发票";
        _invoiceLabel = cell.subLabel;
        cell.subLabel.text = _invoice.invoiceTitle.length>0?_invoice.invoiceTitle : @"";
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1 && indexPath.row == 1) {
        [phoneTextField resignFirstResponder];
        [self keyDownAction];
        AddPlayersViewController *addPlayers = [[AddPlayersViewController alloc] initWithNibName:@"AddPlayersViewController" bundle:nil];
        [self pushViewController:addPlayers title:@"添加打球人" hide:YES];
    }else if (indexPath.section == 2 && indexPath.row == 0){
        [self pushWithStoryboard:@"BookTeetime" title:@"发票" identifier:@"InvoiceViewController" completion:^(BaseNavController *controller) {
            InvoiceViewController *vc = (InvoiceViewController*)controller;
            vc.ttm = _ttmodel;
            vc.cm = _myCondition;
            vc.invoice = _invoice;
            vc.blockReturn = ^(id data){
                _invoice = (Invoice*)data;
                _invoiceLabel.text = _invoice.invoiceTitle;
            };
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.1;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return _ttmodel.agentId == 0 ? 75 : 118;
    }else if (indexPath.section == 1){
        if (indexPath.row == 3) {
            CGSize sz = [Utilities getSize:self.textviewText withFont:[UIFont systemFontOfSize:14] withWidth:Device_Width-40];
            self.textviewHeight = sz.height + 14;
            return sz.height + 30;
        }
        return 44;
    }else{
        return 44;
    }
}

- (void)selectPeopleViewDelegateWithCount:(int)count{
    [self keyDownAction];
    if (count == 0) {
        count = 1;
    }
    _myCondition.people = count;
    [self setPayViewData];
}

- (IBAction)depositExplain:(id)sender{
    NSString *title = nil;
    NSString *info = nil;
    if (_ttmodel.payType == PayTypeDeposit) {
        title = @"押金说明";
        info = @"为保障球场利益，球场要求预定需预先支付押金作为担保，押金不可抵用打球费用，打球后球会前台支付订单全额。打球后24小时内或在规定时间内取消订单，押金将返还至您的账号。如未到场，将扣除押金。";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:info delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)getVipList{
    _isVip = NO;

    NSArray *array = [LoginManager sharedManager].vipList;
    for (VIPClubModel *model in array){
        if (_myCondition.clubId == model.clubId) {
            _isVip = YES;
            break;
        }
    }
}


- (IBAction)bookAction:(id)sender{
    bookBtn.enabled = NO;
    NSString *errorMsg = nil;
    if (self.nameStr.length==0 || [_nameStr isEqualToString:@"请添加打球人名字"]) {
        errorMsg = @"请添加打球人名字";
    }
    if (phoneTextField.text.length==0) {
        errorMsg = @"请输入手机号码";
    }else if (phoneTextField.text.length<11){
        errorMsg = @"手机号码位数不够";
    }
    if (errorMsg) {
        [[GolfAppDelegate shareAppDelegate] alert:nil message:errorMsg];
        bookBtn.enabled = YES;
        return;
    }
    
    _myCondition.personName = _nameStr;
    _myCondition.personPhone = phoneTextField.text;
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (![LoginManager sharedManager].loginState) {
        NSString *userPhone = [userDefault objectForKey:KGolfSessionPhone];
        if(userPhone.length == 0) {
            userPhone = _myCondition.personPhone;
            [userDefault setObject:userPhone forKey:KGolfSessionPhone];
        }
        [[LoginManager sharedManager] judgeLoginOrRegestWithPhoneNum:userPhone delegate:nil blockRetrun:^(id data) {
            bookBtn.enabled = YES;
            phoneTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:KGolfSessionPhone];
            
            [[ServiceManager serviceManagerInstance] getDepositInfoData:[[LoginManager sharedManager] getSessionId] callBack:^(DepositInfoModel *model) {
                [LoginManager sharedManager].myDepositInfo = model;
                
                scrollView.hidden = NO;
                [self bookAction:nil];
            }];
        }];
        bookBtn.enabled = YES;
        return;
    }
    [userDefault setObject:_myCondition.personPhone forKey:KLastPersonPhone];

    
    if(_myCondition.payType == PayTypeVip && !_isVip) {
        [[GolfAppDelegate shareAppDelegate] alert:Nil message:@"该球会仅支持会员预订, 如果您是该球会会员, 请拨打该球会服务电话, 要求验证您在云高高尔夫上的会员身份, 即可享受该球会的在线预订服务."];
        bookBtn.enabled = YES;
        return;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HHmmss"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    _currentTime = [dateStr intValue];
    
    OrderSubmitParamsModel *model = [[OrderSubmitParamsModel alloc] init];
    model.teeTimeDate = _ttmodel.date;
    model.clubId = _myCondition.clubId;
    model.memberNum = _myCondition.people;
    model.sessionId = [[LoginManager sharedManager] getSessionId];
    model.imeiNum = [OpenUDID value];
    model.serialNo = _currentTime;
    model.useAccount = 0;
    model.memberName = _myCondition.personName;
    model.mobilePhone = _myCondition.personPhone;
    model.isMobile = 1;
    model.onlySubmit = 1;
    model.teeTimeTime = self.ttmodel.teetime;
    model.courseId = self.ttmodel.courseId;
    model.agentId = self.ttmodel.agentId;
    model.description = Equal(self.textviewText, @"其它要求请留言:") ? @"" : self.textviewText;
    
    if (self.ttmodel.agentId > 0)
        model.payType = self.ttmodel.payType;
    else
        model.payType = _isVip ? PayTypeVip : self.ttmodel.payType;
    if (self.ttmodel.payType == PayTypeDeposit || self.ttmodel.payType == PayTypeOnlinePart) {
        model.payAmount = self.ttmodel.depositEachMan * _myCondition.people;
    }else{
        model.payAmount = self.ttmodel.price * _myCondition.people;
    }
    
    if (_ttmodel.hasInvoice) {
        if (_invoice && _invoice.invoiceTitle.length>0) {
            model.needInvoice = 1;
            model.invoiceTitle = _invoice.invoiceTitle;
            model.linkMan = _invoice.linkMan;
            model.linkPhone = _invoice.linkPhone;
            model.address = _invoice.address;
        }
    }
    
    BOOL isOfficial = NO;
    if (self.ttmodel.agentId>0) {
        isOfficial = NO;
    }else{
        isOfficial = YES;
        BOOL noPay = NO;
        if(_isVip == YES) {
            noPay = YES;
        }else if(_myCondition.payType == PayTypeDeposit && self.ttmodel.depositEachMan == 0) {
            noPay = YES;
        }else if(_myCondition.payType == PayTypeOnline && self.ttmodel.price == 0) {
            noPay = YES;
        }
        if (noPay) {
            model.payAmount = 0;
        }
    }
    
    __weak FillOrderViewController *vc = self;
    if (_isSpree) {
        [ServerService orderSubmitSpree:[[LoginManager sharedManager] getSessionId]
                                spreeId:_ttmodel.spreeId
                                teetime:_ttmodel.teetime
                              memberNum:_myCondition.people
                               serialNo:_currentTime
                             memberName:_myCondition.personName
                            mobilePhone:_myCondition.personPhone
                               userMemo:Equal(self.textviewText, @"其它要求请留言:") ? @"" : self.textviewText
                               isMobile:1
                            needInvoice:_ttmodel.hasInvoice
                           invoiceTitle:model.invoiceTitle
                                linkMan:model.linkMan
                              linkPhone:model.linkPhone
                                address:model.address
                                success:^(OrderSubmitModel *osm) {
                                    if (osm) {
                                        if (osm.orderState == 6) {
                                            PayOnlineViewController *payOnline = [[PayOnlineViewController alloc] init];
                                            payOnline.payTotal = osm.payTotal;
                                            payOnline.orderTotal = _myCondition.people*vc.ttmodel.price;
                                            payOnline.orderId = osm.orderId;
                                            payOnline.waitPayFlag = 1;
                                            payOnline.isOffical = YES;
                                            payOnline.clubId = _myCondition.clubId;
                                            [vc pushViewController:payOnline title:@"在线支付" hide:YES];
                                        }else if(osm.orderState == 5 || osm.orderState == 1 ){ // 等待确认
                                            [self pushWithStoryboard:@"BookTeetime" title:@"提交成功" identifier:@"SubmitSuccessController" completion:^(BaseNavController *controller) {
                                                SubmitSuccessController *vc = (SubmitSuccessController*)controller;
                                                vc.orderId = osm.orderId;
                                            }];
                                        }
                                    }
            bookBtn.enabled = YES;
        } failure:^(id error) {
            bookBtn.enabled = YES;
        }];
    }else{
        [OrderService orderSubmitUnionpay:model success:^(OrderSubmitModel *osm) {
            if (osm) {
                if (osm.orderState == 6) {
                    PayOnlineViewController *payOnline = [[PayOnlineViewController alloc] init];
                    payOnline.payTotal = osm.payTotal;
                    payOnline.orderTotal = _myCondition.people*vc.ttmodel.price;
                    payOnline.orderId = osm.orderId;
                    payOnline.waitPayFlag = 1;
                    payOnline.isOffical = YES;
                    payOnline.clubId = _myCondition.clubId;
                    [vc pushViewController:payOnline title:@"在线支付" hide:YES];
                }else if(osm.orderState == 5 || osm.orderState == 1 ){ // 等待确认
                    [self pushWithStoryboard:@"BookTeetime" title:@"提交成功" identifier:@"SubmitSuccessController" completion:^(BaseNavController *controller) {
                        SubmitSuccessController *vc = (SubmitSuccessController*)controller;
                        vc.orderId = osm.orderId;
                    }];
                }
            }
            bookBtn.enabled = YES;
        } failure:^(id error) {
            bookBtn.enabled = YES;
        }];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    textField.inputAccessoryView = _toolBar;
    CGRect rt = scrollView.frame;
    rt.origin.y = -50;
    [UIView animateWithDuration:0.3 animations:^{
        scrollView.frame = rt;
    }];
    scrollView.alwaysBounceVertical = YES;//lyf 加
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString * beString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([phoneTextField isEqual:textField]) {
        if ([beString length] > 12) {
            textField.text = [toBeString substringToIndex:12];
            return NO;
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    scrollView.alwaysBounceVertical = NO;//lyf 加
    [textField resignFirstResponder];
    [self keyDownAction];
    return YES;
}

- (void)toolBarActionWithIndex:(NSInteger)index{
    [phoneTextField resignFirstResponder];
    [self keyDownAction];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    CGRect rt = scrollView.frame;
    rt.origin.y = -80;
    [UIView animateWithDuration:0.3 animations:^{
        scrollView.frame = rt;
    }];
    
    if (Equal(textView.text, @"其它要求请留言:")) {
        textView.text = @"";
    }
    _textView.textColor = [UIColor blackColor];
    scrollView.alwaysBounceVertical = YES;//lyf 加
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return YES;
    }
    NSString * toBeString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    NSString * beString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if ([beString length] > 100) {
        textView.text = [toBeString substringToIndex:100];
    }
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    scrollView.alwaysBounceVertical = NO;//lyf 加
    [self keyDownAction];

    if (textView.text.length==0 || Equal(textView.text, @"")) {
        self.textviewText = @"其它要求请留言:";
    }else{
        self.textviewText = textView.text;
    }
    [_tableview reloadData];
    [self refreshView];
}

- (void)keyDownAction{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rt = scrollView.frame;
        rt.origin.y = 0;
        scrollView.frame = rt;
    }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {//lyf 加
    [_textView resignFirstResponder];
}

@end
