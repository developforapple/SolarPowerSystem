//
//  YGMallAddressListViewCtrl.m
//  Golf
//
//  Created by bo wang on 2016/11/29.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallAddressListViewCtrl.h"
#import "YGMallAddressCell.h"
#import "YGMallAddressModel.h"
#import "YGMallAddressEditViewCtrl.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface YGMallAddressListViewCtrl () <UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>

@property (assign, nonatomic) BOOL isLoading;
@property (assign, nonatomic) BOOL isError;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray<YGMallAddressModel *> *addressList;
@end

@implementation YGMallAddressListViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 71.f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self initUI];
    [self loadData];
}

- (void)initUI
{
    ygweakify(self);
    [self.tableView setRefreshHeaderEnable:YES footerEnable:NO callback:^(YGRefreshType type) {
        ygstrongify(self);
        [self loadData];
    }];
    [self rightButtonAction:@"新增地址"];
}

- (void)loadData
{
    self.isLoading = YES;
    self.isError = NO;
    
    [YGMallAddressModel fetchAddressList:^(NSArray *addressList) {
        if (addressList) {
            self.isLoading = NO;
            self.isError = NO;
            self.addressList = addressList;
            
            [self.loadingIndicator stopAnimating];
            [self.tableView.mj_header endRefreshing];
            [self updateSelectedAddress];
            [self.tableView reloadData];
        }else{
            self.isError = YES;
            [self.loadingIndicator stopAnimating];
            [self.tableView.mj_header endRefreshing];
            [self.tableView reloadEmptyDataSet];
        }
    }];
}

- (void)updateSelectedAddress
{
    if (self.addreddId == 0 || self.addreddId == -1) {
        for (YGMallAddressModel *address in self.addressList) {
            if(address.is_default){
                self.addreddId = address.address_id;
                break;
            }
        }
    }
}

- (void)editAddress:(YGMallAddressModel *)address
{
    YGMallAddressEditViewCtrl *vc = [YGMallAddressEditViewCtrl instanceFromStoryboard];
    vc.address = address;
    ygweakify(self);
    [vc setDidEditAddress:^(YGMallAddressModel *aAddress, YGMallAddressEditType editType) {
        ygstrongify(self);
        [self handleAddressEdited:editType address:aAddress];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)handleAddressEdited:(YGMallAddressEditType)editType address:(YGMallAddressModel *)aAddress
{
    NSMutableArray *list = [NSMutableArray arrayWithArray:self.addressList];
    switch (editType) {
        case YGMallAddressEditTypeAdd:{
            self.addreddId = aAddress.address_id;
            [self.tableView scrollToRow:0 inSection:0 atScrollPosition:UITableViewScrollPositionTop animated:NO];
            [list insertObject:aAddress atIndex:0];
            self.addressList = list;
            [self.tableView reloadData];
        }   break;
        case YGMallAddressEditTypeUpdate:{
            NSInteger idx = NSNotFound;
            for (YGMallAddressModel *theAddress in list) {
                if (theAddress.address_id == aAddress.address_id) {
                    idx = [self.addressList indexOfObject:theAddress];
                    break;
                }
            }
            if (idx != NSNotFound) {
                [list replaceObjectAtIndex:idx withObject:aAddress];
                self.addressList = list;
                [self.tableView reloadRow:idx inSection:0 withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }   break;
        case YGMallAddressEditTypeSetDefault:{}   break;
        case YGMallAddressEditTypeDelete:{
            NSInteger idx = NSNotFound;
            for (YGMallAddressModel *theAddress in list) {
                if (theAddress.address_id == aAddress.address_id) {
                    idx = [self.addressList indexOfObject:theAddress];
                    break;
                }
            }
            if (idx != NSNotFound) {
                [list removeObjectAtIndex:idx];
                self.addressList = list;
                if (self.addreddId == aAddress.address_id) {
                    self.addreddId = 0;
                }
                [self.tableView deleteRow:idx inSection:0 withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }   break;
    }
}

- (void)doRightNavAction
{
    [self editAddress:nil];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.addressList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YGMallAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:kYGMallAddressCell forIndexPath:indexPath];
    [cell configureWithAddress:self.addressList[indexPath.row]];
    cell.selectedIndicator.highlighted = cell.address.address_id == self.addreddId;
    ygweakify(self);
    [cell setWillEditAddress:^(YGMallAddressModel *address) {
        ygstrongify(self);
        [self editAddress:address];
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.isSetDefaultAddress) {
        [SVProgressHUD show];
        YGMallAddressModel *address = self.addressList[indexPath.row];
        NSDictionary *info = [address yy_modelToJSONObject];
        [ServerService maintainMallAddress:YGMallAddressEditTypeSetDefault info:info callBack:^(id obj) {
            [SVProgressHUD showSuccessWithStatus:@"修改成功"];
            if (self.didSelectedAddress) {
                self.didSelectedAddress(address);
            }
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(id error) {
            [SVProgressHUD showErrorWithStatus:@"当前网络不可用"];
        }];
        
    }else{
        if (self.didSelectedAddress) {
            self.didSelectedAddress(self.addressList[indexPath.row]);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Empty


@end
