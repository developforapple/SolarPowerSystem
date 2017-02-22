//
//  TwoButtonView.h
//  test2
//
//  Created by 廖瀚卿 on 15/6/3.
//  Copyright (c) 2015年 额度. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwoButtonView : UIView

@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIButton *btn2;
@property (weak, nonatomic) IBOutlet UILabel *labelMessage;
@property (copy, nonatomic) BlockReturn blockReturn;
@property (nonatomic) id data;
@end