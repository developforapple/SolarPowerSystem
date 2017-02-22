//
//  YGShareSMSViewCtrl.h
//  Golf
//
//  Created by user on 13-5-8.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseNavController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "GToolBar.h"

@interface YGShareSMSViewCtrl : BaseNavController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,ABPeoplePickerNavigationControllerDelegate,MFMessageComposeViewControllerDelegate,GToolBarDelegate,UIAlertViewDelegate>

@property (nonatomic,strong) IBOutlet UITableView *tableview;
@property (nonatomic,strong) IBOutlet UITextField *tfLinker;
@property (nonatomic,strong) IBOutlet UIButton *btnAdd;
@property (nonatomic,strong) IBOutlet UIButton *btnSure;
@property (nonatomic,strong) NSMutableArray *phones;
@property (nonatomic,copy) NSString *body;

- (IBAction)btnAddAction:(id)sender;
- (IBAction)btnSureAction:(id)sender;

@end
