//
//  YGWalletTopUpViewCtrl.h
//  Golf
//
//  Created by 黄希望 on 12-7-18.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DepositInfoModel.h"
#import "BaseNavController.h"
#import "GToolBar.h"

/**
 充值
 */
@interface YGWalletTopUpViewCtrl : BaseNavController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,GToolBarDelegate>{
    UITextField     *_tfCharge;
    NSArray         *_chargeArray;
    GToolBar      *_toolBar;
    int            _chargeMoney;
    int            _tranId;
}

@property (nonatomic,strong) DepositInfoModel *myDepositInfo;
@property (nonatomic,copy) BlockReturn blockReturn;
@end
