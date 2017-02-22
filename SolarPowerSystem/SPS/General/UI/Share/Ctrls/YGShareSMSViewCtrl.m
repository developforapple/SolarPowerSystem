//
//  YGShareSMSViewCtrl.m
//  Golf
//
//  Created by user on 13-5-8.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import "YGShareSMSViewCtrl.h"

@interface YGShareSMSViewCtrl (){
    NSMutableArray *_tempPhones;
    NSMutableArray *_names;
    GToolBar *_toolBar;
}

@end

@implementation YGShareSMSViewCtrl
@synthesize tableview = _tableview;
@synthesize tfLinker = _tfLinker;
@synthesize btnAdd = _btnAdd;
@synthesize btnSure = _btnSure;
@synthesize phones = _phones;
@synthesize body = _body;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStyleDone target:self action:@selector(tableViewEdit:)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    
    _toolBar = [[GToolBar alloc] initWithFrame:CGRectMake(0.0, 0.0, Device_Width, 44.0)];
    _toolBar.toolBarDelegate = self;
    
    _names = [[NSMutableArray alloc] initWithCapacity:0];
    _tempPhones = [[NSMutableArray alloc] initWithCapacity:0];
    _phones = [[NSMutableArray alloc] initWithCapacity:0];
}

- (IBAction)btnAddAction:(id)sender{
    self.navigationItem.rightBarButtonItem.title = @"编辑";
    self.tableview.editing = NO;
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    picker.navigationBarHidden = NO;
    //[[UIApplication sharedApplication] setStatusBarStyle:(UIStatusBarStyleDefault)];
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person NS_AVAILABLE_IOS(8_0){
    [self fetchPersonInfo:peoplePicker withPersonRecord:person];
}

// Called after a property has been selected by the user.
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier NS_AVAILABLE_IOS(8_0) {
    [self fetchPersonInfo:peoplePicker withPersonRecord:person];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    [self fetchPersonInfo:peoplePicker withPersonRecord:person];
    return NO;
}

- (void)fetchPersonInfo:(ABPeoplePickerNavigationController *)peoplePicker withPersonRecord:(ABRecordRef)person{
    ABMutableMultiValueRef phoneMulti = ABRecordCopyValue(person, kABPersonPhoneProperty);
    NSString *phone = (NSString *)CFBridgingRelease(ABMultiValueCopyValueAtIndex(phoneMulti, 0));
    NSString *phoneStr = [Utilities formatPhoneNum:phone];
    NSString *nameStr = (NSString *)CFBridgingRelease(ABRecordCopyCompositeName(person));
    if (phoneStr) {
        if (_tempPhones.count >= 8) {
            [[GolfAppDelegate shareAppDelegate] alert:nil message:@"您选择的收件人过多，不要超过8个"];
        }
        else{
            if (![_tempPhones containsObject:phoneStr]) {
                if (!nameStr) {
                    [_names addObject:phoneStr];
                    [_phones addObject:phoneStr];
                    [_tempPhones addObject:phoneStr];
                }
                else{
                    [_names addObject:nameStr];
                    [_phones addObject:phoneStr];
                    [_tempPhones addObject:phoneStr];
                }
            }
        }
    }
    
    _btnSure.enabled = _phones.count > 0 ? YES : NO;
    
    [_tableview reloadData];
    
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
    CFRelease(phoneMulti);
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_tempPhones count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    //    if (!cell) {
    //        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    //        cell.textLabel.font = [UIFont systemFontOfSize:14];
    //    }
    
    NSString *phoneStr = [_tempPhones objectAtIndex:indexPath.row];
    NSString *nameStr = [_names objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)",phoneStr,nameStr];
    if ([phoneStr isEqualToString:nameStr]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@",phoneStr];
    }
    if ([_phones containsObject:phoneStr]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 35;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *phoneStr = [_tempPhones objectAtIndex:indexPath.row];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [_phones removeObject:phoneStr];
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [_phones insertObject:phoneStr atIndex:0];
    }
    _btnSure.enabled = _phones.count > 0 ? YES : NO;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableViewEdit:(id)sender{
    UIBarButtonItem *item = (id)sender;
    item.title = !self.tableview.editing ? @"完成" : @"编辑"  ;
    _btnSure.enabled = self.tableview.editing && _phones.count > 0;
    [_tableview setEditing:!self.tableview.editing animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *phoneStr = [_tempPhones objectAtIndex:indexPath.row];
        [_phones removeObject:phoneStr];
        [_names removeObjectAtIndex:indexPath.row];
        [_tempPhones removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    _btnSure.enabled = _phones.count > 0&&!self.tableview.editing ? YES : NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    self.navigationItem.rightBarButtonItem.title = @"编辑";
    self.tableview.editing = NO;
    textField.inputAccessoryView = _toolBar;
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"])  //按会车可以改变
    {
        return YES;
    }
    
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    
    if ([toBeString length] > 11) { //如果输入框内容大于20则弹出警告
        textField.text = [toBeString substringToIndex:11];
        return NO;
    }
    return YES;
}

- (IBAction)btnSureAction:(id)sender{
    NSArray *phoneList = [NSArray arrayWithArray:_phones];
    if (phoneList.count > 0) {
        NSMutableString *componentStr = [NSMutableString string];
        for (NSString *str in phoneList){
            NSInteger index = [phoneList indexOfObject:str];
            if (index == phoneList.count-1) {
                [componentStr appendFormat:@"%@",str];
            }
            else{
                [componentStr appendFormat:@"%@,",str];
            }
        }
        
        NSString *myPhoneNum = [[NSUserDefaults standardUserDefaults] objectForKey:KGolfSessionPhone];
        if (!myPhoneNum) {
            myPhoneNum = @"";
        }
        [[ServiceManager serviceManagerInstance] userRecommendTel:myPhoneNum phoneList:componentStr callBack:^(NSDictionary *dic) {
            if (dic) {
                if (![MFMessageComposeViewController canSendText]) {
                    return;
                }
                MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
                picker.messageComposeDelegate = self;
                picker.navigationBar.tintColor= [UIColor blackColor];
                picker.recipients = _phones;
                picker.body = _body;
                [self presentViewController:picker animated:YES completion:nil];
            }
        }];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultSent:{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"信息已发送成功" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alertView show];
        }
            break;
        case MessageComposeResultFailed:{
            [[GolfAppDelegate shareAppDelegate] alert:@"提示" message:@"发送失败"];
        }
            break;
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)toolBarActionWithIndex:(NSInteger)index{
    if (index == 2) {
        if (_tempPhones.count >= 8) {
            [[GolfAppDelegate shareAppDelegate] alert:nil message:@"您选择的收件人过多,请不要超过8个"];
        } else  if (_tfLinker.text.length > 0 && ![_tempPhones containsObject:_tfLinker.text]) {
            [_names addObject:_tfLinker.text];
            [_phones addObject:_tfLinker.text];
            [_tempPhones addObject:_tfLinker.text];
        }
        _tfLinker.text = nil;
        [_tableview reloadData];
        _btnSure.enabled = _phones.count > 0&&!self.tableview.editing ? YES : NO;
    }
    [_tfLinker resignFirstResponder];
}



@end
