//
//  PackageFillViewController.m
//  Golf
//
//  Created by user on 12-12-18.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import "PackageFillViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIButton+Custom.h"
#import "AddPlayersViewController.h"
#import "YGDatePickerViewCtrl.h"

@interface PackageFillViewController () <YGDatePickerDelegate>

@end

@implementation PackageFillViewController
@synthesize specList = _specList;
@synthesize myCondition = _myCondition;

- (void)loadView{
    [super loadView];
    
    UIControl *control = [[UIControl alloc] initWithFrame:self.view.bounds];
    [control addTarget:self action:@selector(resetBounds) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:control];
    
    _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.contentInset = UIEdgeInsetsMake(64.f, 0, 50.f, 0);
    [self.view addSubview:_tableView];
    
    _pricePickerView = [[UIPickerView alloc] init];
    _pricePickerView.delegate = self;
    _pricePickerView.dataSource = self;
    _pricePickerView.backgroundColor = [UIColor whiteColor];
    _pricePickerView.showsSelectionIndicator = YES;
    
    orderMoney2 = [[UILabel alloc] initWithFrame:CGRectMake(Device_Width-120, 30, 90, 20)];
    orderMoney2.backgroundColor = [UIColor clearColor];
    orderMoney2.font = [UIFont systemFontOfSize:20];
    orderMoney2.textColor = [UIColor orangeColor];
    orderMoney2.textAlignment = NSTextAlignmentRight;
    orderMoney2.text = [NSString stringWithFormat:@"￥0"];
    
    nextButton = [UIButton myButton:self Frame:CGRectMake(10, Device_Height-50.f, Device_Width-20, 40) NormalImage:@"yellowbtn.png" SelectImage:@"yellowbtn_s.png" Title:@"下一步" TitleColor:[UIColor whiteColor] Font:14. Action:@selector(nextAction)];
    [self.view addSubview:nextButton];
    
    if(!_toolBar){
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, Device_Width, 44.0)];
    }
    _toolBar.barStyle = UIBarStyleBlackTranslucent;
    
    sureButton = [self createButtonWith:CGRectMake(Device_Width-60, 7.0, 50.0, 30.0) Tag:3 size:14.0f title:@"确定" image:@"tool_sure.png"];
    [sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_toolBar addSubview:sureButton];
    
    cancelButton = [self createButtonWith:CGRectMake(10.0, 7.0, 50, 30.0) Tag:4 size:14.0f title:@"取消" image:@"tool_cancel.png"];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_toolBar addSubview:cancelButton];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];//lq 改
    self.fontSize = 16;
    
    num = 1;
    _isSure = NO;
    _isScroll = NO;
    _titleArray = [[NSArray alloc] initWithObjects:@"套餐类型",@"到达时间",@"预订人数",@"打球人名字",@"打球人手机",@"备注信息", nil];
    _placeholderArray = [[NSArray alloc] initWithObjects:@"请选择相应的套餐",@"请选择到达球会日期",@"",@"请添加打球人名字",@"请填写预定人手机号码",@"如有特殊说明或要求，请填写", nil];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"SpecialNoteInformation"]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SpecialNoteInformation"];
    }
    NSDate *date = [Utilities getTheDay:[NSDate date] withNumberOfDays:1];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
        
    _myCondition.arriveDate = [formatter stringFromDate:date];
    
    _myCondition.price = _price;
    _myCondition.people = num;

    NSDate *startD = [formatter dateFromString:_myCondition.startDate];
    NSDate *endD = [formatter dateFromString:_myCondition.endDate];
    
    _start = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:[startD timeIntervalSinceReferenceDate]];
    if ([_start timeIntervalSinceNow] < 0) {
        _start = nil;
        _start = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:[[formatter dateFromString:_myCondition.arriveDate] timeIntervalSinceReferenceDate]];
    }
    else{
        _start = nil;
        _start = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:[startD timeIntervalSinceReferenceDate]];
    }
    _end = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:[endD timeIntervalSinceReferenceDate]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"playersName"];
    if (array.count > 0) {
        NSMutableString *names = [[NSMutableString alloc] init];
        for (NSString *string in array){
            if([string length] > 0) {
                [names appendFormat:@";%@",string];
            }
        }
        if([names length]>0) {
            PackageFillCell *cell = (PackageFillCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
            cell.textField.text = [names substringFromIndex:1];
            _myCondition.memberName = [names substringFromIndex:1];        }
    }
    else{
        PackageFillCell *cell = (PackageFillCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
        cell.textField.text = @"";
        _myCondition.memberName = @"";
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"SpecialNoteInformation"]){
        PackageFillCell *cell = (PackageFillCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
        cell.textField.hidden = YES;
        
        NSString *note = [[NSUserDefaults standardUserDefaults] objectForKey:@"SpecialNoteInformation"];
        cell.noteLabel.text = note;
        cell.noteLabel.textAlignment = NSTextAlignmentRight;
        _myCondition.noteInfo = cell.noteLabel.text;
    }
    else{
        _newHeight = 40;
    }
}

# pragma tableView
# pragma tableView delegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"PackageFillCell";
    PackageFillCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PackageFillCell" owner:self options:nil] lastObject];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.noteLabel.hidden = YES;
    cell.titleLabel.text = [_titleArray objectAtIndex:indexPath.row];
    cell.textField.delegate = self;
    cell.textField.placeholder = [_placeholderArray objectAtIndex:indexPath.row];

    if (indexPath.row == 0) {
        cell.textField.tag = 1;
        if (Device_SysVersion<7.0) {
            [Utilities lineviewWithFrame:CGRectMake(0, 0, Device_Width, 1) forView:cell.contentView];
        }
        cell.textField.text = [self defaultChooseSpec:0];
        cell.textField.inputAccessoryView = _toolBar;
        cell.textField.inputView = _pricePickerView;
        _tfSpec = cell.textField;
    }else if (indexPath.row == 1){
        cell.textField.enabled = NO;
        cell.textField.tag = 2;
    }else if (indexPath.row == 2){
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textField.hidden = YES;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textField.tag = 3;
        CGRect f = cell.titleLabel.frame;
        f.origin.y = 15;
        cell.titleLabel.frame = f;
        [self bookNumWithView:cell];
    }else if (indexPath.row == 3){
        cell.textField.enabled = NO;
        cell.textField.tag = 4;
        cell.textField.text = _myCondition.memberName;
    }else if (indexPath.row == 4){
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textField.tag = 5;
        if ([[NSUserDefaults standardUserDefaults] objectForKey:KLastPersonPhone] ) {
            cell.textField.text = [[NSUserDefaults standardUserDefaults] objectForKey:KLastPersonPhone];
            _myCondition.memberPhone = cell.textField.text;
        }
        else if ([[NSUserDefaults standardUserDefaults] objectForKey:KGolfSessionPhone]){
            cell.textField.text = [[NSUserDefaults standardUserDefaults] objectForKey:KGolfSessionPhone];
            _myCondition.memberPhone = cell.textField.text;
        }
        cell.textField = [self setTextfield:cell.textField];
        cell.textField.inputAccessoryView = _toolBar;
        CGRect rt = cell.textField.frame;
        rt.origin.x -= 15;
        cell.textField.frame = rt;
    }else{
        cell.noteLabel.hidden = NO;
        cell.textField.enabled = NO;
        cell.textField.tag = 6;
        cell.noteLabel.numberOfLines = 0;
        if (![cell.noteLabel.text isEqualToString:@""]) {
            cell.textField.hidden = YES;
        }
    }

    return cell;
}

- (UITextField *)setTextfield:(UITextField *)textField{
    textField.delegate = self;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.font = [UIFont systemFontOfSize:13];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:KLastPersonPhone]){
        textField.text = [[NSUserDefaults standardUserDefaults] objectForKey:KLastPersonPhone];
    }
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.returnKeyType = UIReturnKeyDone;
    textField.borderStyle = UITextBorderStyleNone;
    return textField;
}

- (void)bookNumWithView:(PackageFillCell *)cell{
    decreaseButton = [self createButtonWith:CGRectMake(Device_Width-125, 10, 30, 30) Tag:1 size:0 title:nil image:@"undecrease.png"];
    [cell.contentView addSubview:decreaseButton];
    
    increaseButton = [self createButtonWith:CGRectMake(Device_Width-50, 10, 30, 30) Tag:2 size:0 title:nil image:@"add_icon.png"];
    [cell.contentView addSubview:increaseButton];
    
    numshowButton = [self createButtonWith:CGRectMake(Device_Width-90, 10, 35, 30) Tag:0 size:20 title:[NSString stringWithFormat:@"%d",num] image:@"number.png"];
    [cell.contentView addSubview:numshowButton];
}

- (UIButton *)createButtonWith:(CGRect)frame
                           Tag:(NSInteger)tag
                          size:(float)size
                         title:(NSString *)title
                         image:(NSString *)imageStr{
    UIButton *customButton =[UIButton buttonWithType:UIButtonTypeCustom];
    customButton.frame = frame;
    customButton.titleLabel.font = [UIFont boldSystemFontOfSize:size];
    customButton.tag = tag;
    [customButton setTitle:title forState:UIControlStateNormal];
    [customButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [customButton setBackgroundImage:[UIImage imageNamed:imageStr] forState:UIControlStateNormal];
    customButton.enabled = NO;
    if (tag < 5) {
        customButton.enabled = YES;
        [customButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return customButton;
}

- (void)buttonPressed:(id)sender{
    _isSure = NO;
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == 3) {
        _isSure = YES;
        [self resetBounds];
        for (PackageFillCell *cell in [_tableView visibleCells]){
            [cell.textField resignFirstResponder];
        }
    }
    else if (btn.tag == 4){
        for (PackageFillCell *cell in [_tableView visibleCells]){
            [cell.textField resignFirstResponder];
        }
    }
    else{
        if(btn.tag == 1)
            num --;
        else if (btn.tag == 2)
            num ++;
        
        if(num < 1)
            num = 1;
        else if(num > 12)
            num = 12;
        
        if (num == 1) {
            decreaseButton.enabled = NO;
            [decreaseButton setBackgroundImage:[UIImage imageNamed:@"undecrease.png"] forState:UIControlStateNormal];
            [numshowButton setTitle:[NSString stringWithFormat:@"%d",num] forState:UIControlStateNormal]
            ;
        }
        else if (num == 12) {
            increaseButton.enabled = NO;
            [increaseButton setBackgroundImage:[UIImage imageNamed:@"unadd.png"] forState:UIControlStateNormal];
            [numshowButton setTitle:[NSString stringWithFormat:@"%d",num] forState:UIControlStateNormal];
        }
        else {
            decreaseButton.enabled = YES;
            increaseButton.enabled = YES;
            [decreaseButton setBackgroundImage:[UIImage imageNamed:@"decrease_icon.png"] forState:UIControlStateNormal];
            [increaseButton setBackgroundImage:[UIImage imageNamed:@"add_icon.png"] forState:UIControlStateNormal];
            [numshowButton setTitle:[NSString stringWithFormat:@"%d",num] forState:UIControlStateNormal];
        }
        _myCondition.people = num;
        orderMoney1.text = [NSString stringWithFormat:@"￥%d",_price*num];
        [self resetPaylabelFrame:orderTitle1 WithLabel:orderMoney1];
        if (_myCondition.prepayAmount > 0) {
            orderMoney2.text = [NSString stringWithFormat:@"￥%d",_myCondition.prepayAmount*num];
            [self resetPaylabelFrame:orderTitle2 WithLabel:orderMoney2];
            [self addGiveYunbiLabel:orderMoney2 inView:orderMoney2.superview];
        } else {
            [self addGiveYunbiLabel:orderMoney1 inView:orderMoney1.superview];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {
        [self changeTheDate];
    }
    if (indexPath.row == 3) {
        [self addPlayerName];
    }
    if (indexPath.row == 5) {
        NoteViewController *noteInfo = [[NoteViewController alloc] init];
        [self pushViewController:noteInfo title:@"备注信息" hide:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)addPlayerName{
    for (PackageFillCell *cell in [_tableView visibleCells]){
        [cell.textField resignFirstResponder];
    }
    
    AddPlayersViewController *addPlayers = [[AddPlayersViewController alloc] initWithNibName:@"AddPlayersViewController" bundle:nil];
    [self pushViewController:addPlayers title:@"添加打球人" hide:YES];
}

- (void)changeTheDate{
    [_tfSpec resignFirstResponder];
    
    [GolfAppDelegate shareAppDelegate].selectedDate = [Utilities getDateFromString:_myCondition.arriveDate];
    
    YGDatePickerViewCtrl *vc = [YGDatePickerViewCtrl instanceFromStoryboard];
    vc.delegate = self;
    vc.selectableEndDate = _end;
    vc.selectableStartDate = _start;
    [vc show];
}

- (void)datePicker:(YGDatePickerViewCtrl *)datePicker didSelectedDate:(NSDate *)date
{
    [datePicker dismiss];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *theDate = [formatter stringFromDate:date];
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    NSString *dateStr = [formatter stringFromDate:date];
    NSString *week = [Utilities getWeekDayByDate:date];
    
    PackageFillCell *cell = (PackageFillCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    cell.textField.text = [NSString stringWithFormat:@"%@ %@",dateStr,week];
    _myCondition.arriveDate = theDate;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Device_Width-20, 60)];
    bgView.backgroundColor = [Utilities R:241 G:240 B:246];
    
    orderMoney1 = [[UILabel alloc] initWithFrame:CGRectMake(Device_Width-120, 5, 90, 20)];
    orderMoney1.backgroundColor = [UIColor clearColor];
    orderMoney1.font = [UIFont systemFontOfSize:20];
    orderMoney1.textColor = [UIColor orangeColor];
    orderMoney1.textAlignment = NSTextAlignmentRight;
    orderMoney1.text = [NSString stringWithFormat:@"￥%d",_price*num];
    [bgView addSubview:orderMoney1];
    
    orderTitle1 = [[UILabel alloc] initWithFrame:CGRectMake(150, 5, 60, 20)];
    orderTitle1.backgroundColor = [UIColor clearColor];
    orderTitle1.font = [UIFont systemFontOfSize:14];
    orderTitle1.text = @"订单总价";
    [bgView addSubview:orderTitle1];
    
    [self resetPaylabelFrame:orderTitle1 WithLabel:orderMoney1];
    
    if (_myCondition.payType != 3 && _myCondition.prepayAmount > 0) {
        
        [bgView addSubview:orderMoney2];
        
        orderTitle2 = [[UILabel alloc] initWithFrame:CGRectMake(150, 30, 60, 20)];
        orderTitle2.backgroundColor = [UIColor clearColor];
        orderTitle2.font = [UIFont systemFontOfSize:14];
        orderTitle2.text = _myCondition.payType == PayTypeDeposit ? @"支付押金" : @"预付金额";
        [bgView addSubview:orderTitle2];
        
        [self resetPaylabelFrame:orderTitle2 WithLabel:orderMoney2];
        [self addGiveYunbiLabel:orderMoney2 inView:bgView];//lyf 加
    } else {
        [self addGiveYunbiLabel:orderMoney1 inView:bgView];//lyf 加
    }
    
    return bgView;
}

- (void)addGiveYunbiLabel:(UILabel *)label inView:(UIView *)theView { //lyf 加
    int giveYunbi = _myCondition.giveYunbi;
    if (giveYunbi > 0) {
        if (!giveYunbiLabel) {
            giveYunbiLabel = [[UILabel alloc] init];
        }
        giveYunbiLabel.text = [NSString stringWithFormat:@"返%d云币", giveYunbi*num];
        CGRect rect = label.frame;
        CGSize size1 = [giveYunbiLabel.text sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:13]}];
        giveYunbiLabel.textColor = [UIColor colorWithHexString:@"#ff6d00"];
        giveYunbiLabel.textAlignment = NSTextAlignmentRight;
        giveYunbiLabel.font = [UIFont systemFontOfSize:11];
        giveYunbiLabel.frame = CGRectMake(rect.origin.x + rect.size.width - size1.width, rect.origin.y + rect.size.height + 5, size1.width, size1.height);
        
        rect = theView.frame;
        rect.size.height += 30;
        theView.frame = rect;
        rect = _tableView.frame;
        rect.size.height += 30;
        _tableView.frame = rect;
        [theView addSubview:giveYunbiLabel];
    }
}

- (void)resetPaylabelFrame:(UILabel *)lb1 WithLabel:(UILabel *)lb2{
    CGSize size = [Utilities getSize:lb2.text withFont:lb2.font withWidth:Device_Width];
    CGRect f = lb1.frame;
    f.origin.x =lb2.frame.origin.x + (lb2.frame.size.width - size.width) - lb1.frame.size.width;
    lb1.frame = f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 2) {
        return 50;
    }
    if (indexPath.row == 5) {
        return _newHeight;
    }
    return 40;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField.tag == 5) {
        cancelButton.hidden = YES;
        if (!_isScroll) {
            [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
            [UIView setAnimationDuration:0.3f];
            CGRect f = self.view.frame;
            f.origin.y -= 70.0;
            self.view.frame = f;
            [UIView commitAnimations];
            _isScroll = YES;
        }
    }
    return YES;
}

#pragma mark - UITextfieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"])
    {
        return YES;
    }
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString * beString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField.tag == 5) {
        if ([beString length] > 12) {
            textField.text = [toBeString substringToIndex:12];
            return NO;
        }
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if (textField.tag == 1) {
        if (_isSure == YES) {
            
            textField.text = [self defaultChooseSpec:[_pricePickerView selectedRowInComponent:0]];
        }
    }
    if (textField.tag == 5) {
        _myCondition.memberPhone = textField.text;
    }
    return YES;
}

- (NSString*)defaultChooseSpec:(NSInteger)index{
    if (_specList.count == 0) {
        return @"";
    }
    
    PriceSpecModel *model = [_specList objectAtIndex:index];
    _price = model.currentPrice;
    orderMoney1.text = [NSString stringWithFormat:@"￥%d",_price*num];
    [self resetPaylabelFrame:orderTitle1 WithLabel:orderMoney1];
    if (_myCondition.prepayAmount > 0) {
        orderMoney2.text = [NSString stringWithFormat:@"￥%d",_myCondition.prepayAmount*num];
        [self resetPaylabelFrame:orderTitle2 WithLabel:orderMoney2];
    }
    
    _myCondition.packageType = [NSString stringWithFormat:@"%@ ￥%d",model.specName,model.currentPrice];
    _myCondition.price = _price;
    _myCondition.specId = model.specId;
    return _myCondition.packageType;

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIPickerViewDataSource Methods

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [_specList count];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *showLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,0.0f,Device_Width,30.0f)];
    PriceSpecModel *price = [_specList objectAtIndex:row];
    showLabel.text = [NSString stringWithFormat:@"%@ ￥%d",price.specName,price.currentPrice];
    showLabel.font = [UIFont systemFontOfSize:18];
	showLabel.backgroundColor = [UIColor clearColor];
	showLabel.textAlignment = NSTextAlignmentCenter;
	return showLabel;
}

//picker的列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (void)resetBounds{
    if (_isScroll) {
        [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
        [UIView setAnimationDuration:0.3f];
        CGRect f = self.view.frame;
        f.origin.y += 70.0;
        self.view.frame = f;
        [UIView commitAnimations];
        _isScroll = NO;
    }
}

- (void)nextAction{
    NSArray *msgArray = [NSArray arrayWithObjects:@"请选择套餐类型",@"请填写到达时间",@"",@"请添加打球人名字",@"请填写联系电话",@"", nil];
    for (PackageFillCell *cell in [_tableView visibleCells]){
        BOOL condition = cell.textField.tag == 3 || cell.textField.tag == 6 ? NO : YES;
        if (cell.textField.tag == 5 && ![Utilities phoneNumMatch:cell.textField.text]) {
            [SVProgressHUD showErrorWithStatus:@"手机号码输入不正确"];
            return;
        }
        if (condition && ([cell.textField.text isEqualToString:@""] || cell.textField.text == nil)) {
            [SVProgressHUD showErrorWithStatus:[msgArray objectAtIndex:cell.textField.tag - 1]];
            return;
        }
    }
        
    [[NSUserDefaults standardUserDefaults] setObject:_myCondition.memberPhone forKey:KLastPersonPhone];
    
    PackageConfirmViewController *packageConfirm = [[PackageConfirmViewController alloc] initWithNibName:@"PackageConfirmViewController" bundle:nil];
    packageConfirm.myCondition = _myCondition;
    [self pushViewController:packageConfirm title:@"确认套餐" hide:YES];
}

@end
