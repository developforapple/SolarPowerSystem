//
//  YGMallAddressEditViewCtrl.m
//  Golf
//
//  Created by bo wang on 2016/11/29.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallAddressEditViewCtrl.h"
#import "YGMallAddressModel.h"
#import "YGMallAddressEditCell.h"
#import <IQKeyboardManager/IQKeyboardManager.h>

@interface YGMallAddressEditViewCtrl () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) YGMallAddressModel *aNewAddress;
@property (strong, nonatomic) NSArray *editModels;

@property (strong, nonatomic) NSMutableDictionary *heightCache;

@end

@implementation YGMallAddressEditViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.aNewAddress = [YGMallAddressModel new];
    self.editModels = [YGMallAddressEditModel createEditModel:self.address];
    self.heightCache = [NSMutableDictionary dictionary];
    
    if (self.address) {
        self.navigationItem.title = @"编辑地址";
    }else{
        self.navigationItem.title = @"新增地址";
    }
    [self rightButtonAction:@"完成"];
}

- (void)doRightNavAction
{
    [self.view endEditing:YES];
    
    YGMallAddressModel *aAddress = [YGMallAddressEditModel createAddressModel:self.editModels];
    if (self.address) {
        aAddress.address_id = self.address.address_id;
    }
    
    //CHECK
    if (![aAddress.link_man isNotBlank]) {
        [SVProgressHUD showErrorWithStatus:@"请填写联系人姓名"];
    }else if (![aAddress.link_phone isNotBlank]){
        [SVProgressHUD showErrorWithStatus:@"请填写联系人手机号码"];
    }else if (![Utilities phoneNumMatch:aAddress.link_phone]){
        [SVProgressHUD showErrorWithStatus:@"手机号填写不正确"];
    }else if (![aAddress.province_name isNotBlank] || ![aAddress.city_name isNotBlank]){
        [SVProgressHUD showErrorWithStatus:@"请选择省市"];
    }else if (![aAddress.address isNotBlank]){
        [SVProgressHUD showErrorWithStatus:@"请填写详细地址"];
    }else{
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        NSDictionary *addressInfo = [aAddress yy_modelToJSONObject];
        YGMallAddressEditType type = self.address?YGMallAddressEditTypeUpdate:YGMallAddressEditTypeAdd;
        
        [SVProgressHUD show];
        [ServerService maintainMallAddress:type info:addressInfo callBack:^(id obj) {
            
            [SVProgressHUD showSuccessWithStatus:@"完成"];
            aAddress.address_id = [obj[@"address_id"] integerValue];
            
            if (self.didEditAddress) {
                self.didEditAddress(aAddress,type);
            }
    
            self.navigationItem.rightBarButtonItem.enabled = YES;
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(id error) {
            [SVProgressHUD showErrorWithStatus:@"当前网络不可用"];
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }];
    }
}

- (void)deleteAddress
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认删除该地址？" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        [SVProgressHUD show];
        NSDictionary *addressInfo = [self.address yy_modelToJSONObject];
        [ServerService maintainMallAddress:YGMallAddressEditTypeDelete info:addressInfo callBack:^(id obj) {
            [SVProgressHUD dismiss];
            if (self.didEditAddress) {
                self.didEditAddress(self.address,YGMallAddressEditTypeDelete);
            }
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(id error) {
            [SVProgressHUD showErrorWithStatus:@"当前网络不可用"];
        }];
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.address?2:1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.editModels.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        YGMallAddressEditCell *cell = [tableView dequeueReusableCellWithIdentifier:kYGMallAddressEditCell forIndexPath:indexPath];
        ygweakify(self);
        
        [cell setShouldUpdateHeight:^(YGMallAddressEditModel *editModel, CGFloat h) {
            ygstrongify(self);
            NSInteger idx = [self.editModels indexOfObject:editModel];
            self.heightCache[@(idx)] = @(MAX(49.f, h));
            [self.tableView reloadRow:idx inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        }];
        [cell configureWithEditModel:self.editModels[indexPath.row]];
        return cell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellDelete" forIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return 48.f;
    }
    
    NSNumber *k = @(indexPath.row);
    NSNumber *h = self.heightCache[k];
    if (!h) {
        h = @49.f;
        self.heightCache[k] = h;
    }
    return [h floatValue];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        //删除
        [self deleteAddress];
    }
}

@end
