//
//  YGAboutViewCtrl.h
//  Golf
//
//  Created by User on 11-12-5.
//  Copyright 2011 大展. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginManager.h"
#import "BaseNavController.h"

@interface YGAboutViewCtrl : BaseNavController{
    //    提示文本
    UILabel *_lblfeedBack;
    //    意见反馈文本框
    UITextView *_feedback;
}


@end
