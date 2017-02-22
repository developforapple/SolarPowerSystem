//
//  PackageFillViewController.h
//  Golf
//
//  Created by user on 12-12-18.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseNavController.h"
#import "PackageFillCell.h"
#import "PriceSpecModel.h"
#import "NoteViewController.h"
#import "PackageConfirmViewController.h"
#import "PackageConditionModel.h"

@interface PackageFillViewController : BaseNavController<UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate>{
    NSArray *_specList;
    UITableView *_tableView;
    NSArray *_titleArray;
    NSArray *_placeholderArray;
    int num;
    
    UIButton *decreaseButton;
    UIButton *increaseButton;
    UIButton *numshowButton;
    UIButton *sureButton;
    UIButton *cancelButton;
    UIButton *nextButton;
    UIPickerView *_pricePickerView;
    UIToolbar *_toolBar;
    UITextField *_tfSpec;
    UILabel * giveYunbiLabel;//lyf 加
    
    UILabel * orderMoney1;
    UILabel * orderTitle1;
    UILabel * orderMoney2;
    UILabel * orderTitle2;
    
    NSDate *_start;
    NSDate *_end;
    
    BOOL _isSure;
    BOOL _isScroll;
    int _newHeight;
    int _price;
    
    PackageConditionModel *_myCondition;
}

@property (nonatomic,strong) NSArray *specList;
@property (nonatomic,strong) PackageConditionModel *myCondition;

@end
