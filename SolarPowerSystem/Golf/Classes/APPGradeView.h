//
//  APPGradeView.h
//  Golf
//
//  Created by liangqing on 16/9/18.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface APPGradeView : UIView
@property (weak, nonatomic) IBOutlet UIButton *buttonRefuse;
@property (weak, nonatomic) IBOutlet UIButton *buttonEvaluate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonRefuseWidthConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonEaluateWidthConst;

@property (nonatomic,copy) BlockReturn blockCancel;
@property (nonatomic,copy) BlockReturn blockEvaluate;
+ (instancetype)loadAPPGradeViewFromNib;
@end
