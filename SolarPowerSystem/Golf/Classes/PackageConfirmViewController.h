//
//  PackageConfirmViewController.h
//  Golf
//
//  Created by user on 12-12-20.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseNavController.h"
#import "PackageConditionModel.h"
#import "ConditionModel.h"
#import "TeeTimeModel.h"
#import "TeeTimeAgentModel.h"
#import "OrderSubmitParamsModel.h"
#import "OrderSubmitModel.h"
#import "DetailInfoView.h"

@interface PackageConfirmViewController : BaseNavController{
    IBOutlet UILabel *_lblTishiTitle;
    IBOutlet UILabel *_lblTishiLabel;
    IBOutlet UIButton *_btnSubmit;
    
    PackageConditionModel *_myCondition;
    ConditionModel *_conditionModel;
    TeeTimeModel * _teetimeModel;
    TeeTimeAgentModel *_teetimeAgent;
    int _serialNum;
}

@property (nonatomic,strong) PackageConditionModel *myCondition;

- (IBAction)buttonSubmit:(id)sender;

@end
