//
//  YGChangePasswordViewCtrl.h
//  Eweek
//
//  Created by user on 13-9-25.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseNavController.h"

@interface YGChangePasswordViewCtrl : BaseNavController<UITextFieldDelegate>{
    IBOutlet UITextField *_tfOldPwd;
    IBOutlet UITextField *_tfNewPwd;
    NSString *oldPwdString;
    NSString *newPwdString;
}

- (IBAction)sureAction:(id)sender;

@end
