//
//  YGMallFeedbackViewCtrl.h
//  Golf
//
//  Created by 黄希望 on 12-8-28.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseNavController.h"

@interface YGMallFeedbackViewCtrl : BaseNavController<UIAlertViewDelegate,UITextViewDelegate,UITextFieldDelegate>{
    IBOutlet UIScrollView *scrollView;
    IBOutlet UILabel *holdPlaceLabel;
    IBOutlet UITextView *textView;
    IBOutlet UITextField *phoneNumTf;
    IBOutlet UILabel *descriptionLabel;
}

@property (nonatomic) BOOL isCommodity;

@end
