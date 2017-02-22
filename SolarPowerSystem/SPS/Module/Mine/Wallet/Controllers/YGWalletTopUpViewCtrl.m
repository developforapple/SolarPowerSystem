//
//  YGWalletTopUpViewCtrl.m
//  Golf
//
//  Created by 黄希望 on 12-7-18.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import "YGWalletTopUpViewCtrl.h"
#import "YGWalletTopUpPlatformViewCtrl.h"

@interface YGWalletTopUpViewCtrl () {
    BOOL _keyboardShown;
    CGPoint _scrollOffset;
    BOOL _isChooseOther;
    UIImageView *markView;
    
    CGPoint _originOffset;
}

@property (nonatomic,strong) NSIndexPath *lastSelectPath;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation YGWalletTopUpViewCtrl
@synthesize lastSelectPath = _lastSelectPath;


- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!_chargeArray) {
        _chargeArray = [[NSArray alloc] initWithObjects:@"￥1000",@"￥2000",@"￥5000",@"￥10000",@"￥20000",@"其它金额", nil];
    }
    
    _chargeMoney = 0;
    
    [self.view addSubview:_tableView];
    
    _toolBar = [[GToolBar alloc] initWithFrame:CGRectMake(0.0, 0.0, Device_Width, 44.0)];
    _toolBar.toolBarDelegate = self;
    _toolBar.isCancelBtnHide = YES;
    
    [self getDeposit];
}

- (void)viewDidUnload
{
    _tableView = nil;
    _chargeArray = nil;
    self.myDepositInfo = nil;
    [super viewDidUnload];
}

# pragma tableview delegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _isChooseOther ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0 ? 6 : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    if (indexPath.section == 0) {
        if (self.lastSelectPath && self.lastSelectPath.row == indexPath.row && indexPath.row < 5) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        
        cell.textLabel.text = [_chargeArray objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }else {
        if (_tfCharge) {
            [_tfCharge removeFromSuperview];
            _tfCharge = nil;
        }
        _tfCharge = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, Device_Width-40, 40)];
        _tfCharge.borderStyle= UITextBorderStyleNone;
        _tfCharge.delegate = self;
        [_tfCharge setBorderStyle:UITextBorderStyleNone];
        [_tfCharge setKeyboardType:UIKeyboardTypeNumberPad];
        _tfCharge.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _tfCharge.inputAccessoryView = _toolBar;
        _tfCharge.placeholder = @"请输入充值金额";
        _tfCharge.font = [UIFont systemFontOfSize:14];
        [cell.contentView addSubview:_tfCharge];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.lastSelectPath = indexPath;
    
    if (indexPath.row == 5) {
        _isChooseOther = YES;
        _chargeMoney = [_tfCharge.text intValue];
    }else{
        _isChooseOther = NO;
        [_tfCharge resignFirstResponder];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *money = [cell.textLabel.text stringByReplacingOccurrencesOfString:@"￥" withString:@""];
        _chargeMoney = [money intValue];
    }
    
    [_tableView reloadData];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"请选择您要充值的金额";
    }
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0 ? 40 : 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    CGFloat contentH = self.tableView.contentSize.height;
    
    CGFloat targetY = Device_Height - 260.f;
    
    CGPoint point = CGPointMake(0, contentH);
    CGPoint point2 = [self.tableView convertPoint:point toView:self.tableView.window];
    
    CGFloat offset = point2.y - targetY;
    if (offset > 0.f) {
        CGPoint contentOffset = self.tableView.contentOffset;
        _originOffset = contentOffset;
        contentOffset.y += offset;
        [self.tableView setContentOffset:contentOffset animated:YES];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.tableView setContentOffset:_originOffset animated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"])
    {
        return YES;
    }
    NSString * StringOne = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([textField isEqual:_tfCharge])
    {
        if ([StringOne length] > 7) {
            textField.text = [StringOne substringToIndex:7];
            return NO;
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_tfCharge resignFirstResponder];
    return YES;
}

- (void)toolBarActionWithIndex:(NSInteger)index{
    _chargeMoney = [_tfCharge.text intValue];
    [_tfCharge resignFirstResponder];
}

- (void)getDeposit{
    [[ServiceManager serviceManagerWithDelegate:self] getDepositInfo:[[LoginManager sharedManager] getSessionId] needCount:1];
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray*)data;
    if (Equal(flag, @"deposit_info")) {
        if (array&&array.count>0) {
            self.myDepositInfo = [array objectAtIndex:0];
        }
    }
}

- (IBAction)nextStep{
    [_tfCharge resignFirstResponder];
    if (self.lastSelectPath.row == 5) {
        [self toolBarActionWithIndex:2];
    }
    
    NSString *errorMsg = nil;
    if (_chargeMoney < 1) {
        errorMsg = @"充值金额需大于0元";
    }
    else if (self.myDepositInfo.banlance + _chargeMoney >= 100000) {
        errorMsg = [NSString stringWithFormat:@"保证金总额上限为99999元,您最多还可以充入%ld元", 99999 - self.myDepositInfo.banlance];
    }
    if (errorMsg) {
        [SVProgressHUD showErrorWithStatus:errorMsg];
        return;
    }
    
    YGWalletTopUpPlatformViewCtrl *vc = [YGWalletTopUpPlatformViewCtrl instanceFromStoryboard];
    vc.chargeAmount = _chargeMoney;
    vc.blockReturn = _blockReturn;
    [self pushViewController:vc title:@"在线充值" hide:YES];
}


@end
