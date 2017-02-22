//
//  VipValidateViewController.h
//  Golf
//
//  Created by user on 12-11-14.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseNavController.h"

@interface VipValidateViewController : BaseNavController<UITextFieldDelegate,UIAlertViewDelegate>{
    UITextField *_cardNoTextField;
    UITextField *_nameTextField;
    UIButton *_sendButton;
    int _clubId;
    NSString *_phoneNum;
}

@property (nonatomic) int clubId;
@property (nonatomic,copy) NSString *phoneNum;
@property (nonatomic,copy) BlockReturn blockReturn;

@end
