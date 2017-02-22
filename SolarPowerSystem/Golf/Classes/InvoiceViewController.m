//
//  InvoiceViewController.m
//  Golf
//
//  Created by 黄希望 on 15/10/30.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "InvoiceViewController.h"
#import "InvoiceCell.h"
#import "YGMallAddressListViewCtrl.h"
#import "YGMallAddressEditViewCtrl.h"
#import "YGMallAddressModel.h"

@interface InvoiceViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>{
    BOOL _needInvoice; // 是否需要发票
    UITextField *_tf;
}

@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *deliveryAddressList;
@property (nonatomic,strong) YGMallAddressModel *addressModel;

@end

@implementation InvoiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self rightButtonAction:@"完成"];
    if (![LoginManager sharedManager].loginState) {
        [[LoginManager sharedManager] loginWithDelegate:nil controller:self animate:YES blockRetrun:^(id data) {
            [[ServiceManager serviceManagerWithDelegate:self] getDeliveryAddressList:[[LoginManager sharedManager] getSessionId]];
        }];
        return;
    }
    
    if (!_invoice ||  _invoice.invoiceTitle.length == 0) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.invoice = [[Invoice alloc] init];
    }else{
        _needInvoice = 1;
    }
    
    ygweakify(self);
    [YGMallAddressModel fetchDefaultAddress:^(YGMallAddressModel *address) {
        ygstrongify(self);
        self.addressModel = address;
        [self.tableView reloadData];
    }];
}

- (void)doRightNavAction{
    [_tf resignFirstResponder];
    NSString *errorMsg = nil;
    if (_invoice.invoiceTitle.length==0) {
        errorMsg = @"请输入发票抬头";
    }else if (_invoice.linkMan.length==0||_invoice.linkPhone.length==0||_invoice.address.length==0){
        errorMsg = @"请输入地址";
    }
    
    if (errorMsg) {
        [SVProgressHUD showErrorWithStatus:errorMsg];
        return;
    }
    
    if (_blockReturn) {
        [[NSUserDefaults standardUserDefaults] setObject:_invoice.invoiceTitle forKey:@"InvoiceTitle"];
        _blockReturn (_invoice);
        [self back];
    }
}

#pragma mark - UITableView 相关
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _needInvoice ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0 ? 1 : 4;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = [NSString stringWithFormat:@"InvoiceCell_%tu%tu",indexPath.section,indexPath.row];
    InvoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (indexPath.section == 0) {
        cell.swt.on = _needInvoice;
        [cell.swt addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    }else{
        if (indexPath.row == 0) {
            cell.inputField.delegate = self;
            _tf = cell.inputField;
            _tf.returnKeyType = UIReturnKeyDone;
            if (_invoice.invoiceTitle.length>0) {
                _tf.text = _invoice.invoiceTitle;
            }else{
                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                if ([userDefault objectForKey:@"InvoiceTitle"]) {
                    _tf.text = [userDefault objectForKey:@"InvoiceTitle"];
                    _invoice.invoiceTitle = _tf.text;
                }
            }
        }
        if (indexPath.row == 2) {
            cell.addressLabel.text = [self addressAppendingString];
        }
    }
    return cell;
}

- (void)changeSwitch:(UISwitch*)swt{
    _needInvoice = swt.on ? 1 : 0;
    self.navigationItem.rightBarButtonItem.enabled = _needInvoice;
    [_tableView reloadData];
    _blockReturn (nil);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1 && indexPath.row == 2) {
        NSString *addressString = [self addressAppendingString];
        CGSize sz = [Utilities getSize:addressString withFont:[UIFont systemFontOfSize:14] withWidth:Device_Width-147];
        return sz.height+26;
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (_needInvoice > 0) {
        return section == 1 ? 44 : 0.1;
    }else{
        return 44;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (_needInvoice > 0) {
        if (section == 1) {
            return [tableView dequeueReusableCellWithIdentifier:@"InvoiceCell_Footer"];
        }
    }else{
        if (section == 0) {
            return [tableView dequeueReusableCellWithIdentifier:@"InvoiceCell_Footer"];
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1 && indexPath.row == 2) {
        
        ygweakify(self);
        if (self.addressModel) {
            YGMallAddressListViewCtrl *vc = [YGMallAddressListViewCtrl instanceFromStoryboard];
            vc.addreddId = self.addressModel.address_id;
            [vc setDidSelectedAddress:^(YGMallAddressModel *address) {
                ygstrongify(self);
                self.addressModel = address;
                [self.tableView reloadData];
            }];
            [self.navigationController pushViewController:vc animated:YES];
            
        }else{
            YGMallAddressEditViewCtrl *vc = [YGMallAddressEditViewCtrl instanceFromStoryboard];
            [vc setDidEditAddress:^(YGMallAddressModel *address, YGMallAddressEditType type) {
                ygstrongify(self);
                self.addressModel = address;
                [self.tableView reloadData];
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)setAddressModel:(YGMallAddressModel *)addressModel{
    _addressModel = addressModel;
    if (_addressModel) {
        _invoice.linkMan = _addressModel.link_man;
        _invoice.linkPhone = _addressModel.link_phone;
        if (_addressModel.post_code.length>0) {
            _invoice.address = [NSString stringWithFormat:@"%@%@%@%@  邮编%@",_addressModel.province_name,_addressModel.city_name,_addressModel.district_name,_addressModel.address,_addressModel.post_code];
        }else{
            _invoice.address = [NSString stringWithFormat:@"%@%@%@%@",_addressModel.province_name,_addressModel.city_name,_addressModel.district_name,_addressModel.address];
        }
    }
}

- (NSString *)addressAppendingString{
    NSString *aas = @"";
    if (_addressModel&&_addressModel.link_man.length>0&&_addressModel.link_phone.length>0&&_addressModel.address.length>0) {
        if (_addressModel.post_code.length>0) {
            aas = [NSString stringWithFormat:@"%@  %@\n%@%@%@%@  邮编%@",_addressModel.link_man,_addressModel.link_phone,_addressModel.province_name,_addressModel.city_name,_addressModel.district_name,_addressModel.address,_addressModel.post_code];
        }else{
            aas = [NSString stringWithFormat:@"%@  %@\n%@%@%@%@",_addressModel.link_man,_addressModel.link_phone,_addressModel.province_name,_addressModel.city_name,_addressModel.district_name,_addressModel.address];
        }
    }
    return aas;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString * StringOne = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([StringOne length] > 50) {
        return NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    _invoice.invoiceTitle = textField.text;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_tf resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    _invoice.invoiceTitle = textField.text;
    return YES;
}

@end
