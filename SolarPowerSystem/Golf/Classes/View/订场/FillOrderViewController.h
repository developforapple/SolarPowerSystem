//
//  FillOrderViewController.h
//  Golf
//
//  Created by user on 13-6-5.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseNavController.h"
#import "ConditionModel.h"
#import "TeeTimeModel.h"
#import "TeeTimeAgentModel.h"
#import "GToolBar.h"
#import "SelectPeopleView.h"

@interface FillOrderViewController : BaseNavController<UITextFieldDelegate,GToolBarDelegate,UITableViewDelegate,UITableViewDataSource,SelectPeopleViewDelegate>{
    UITextField *phoneTextField;
    IBOutlet UIButton *bookBtn;
    IBOutlet UIView *payNumShowView;
    IBOutlet UIView *depositView;
    
    IBOutlet UIScrollView *scrollView;
    
    UITableView *_tableview;
    
    GToolBar *_toolBar;
    
    UIControl *blackView;
    int _currentTime;
}

@property (nonatomic,strong) ConditionModel *myCondition;
@property (nonatomic,strong) TTModel *ttmodel;
@property (nonatomic,copy) NSString *nameStr;
@property (nonatomic) int isVip;
@property (nonatomic,assign) BOOL isSpree;

- (IBAction)bookAction:(id)sender;
- (IBAction)depositExplain:(id)sender;

@end
