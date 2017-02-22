//
//  YGBindingListPhoneCell.h
//  Golf
//
//  Created by liangqing on 16/9/19.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YGBindingListPhoneCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelPhone;
@property (weak, nonatomic) IBOutlet UIButton *buttonBinding;
@property (nonatomic,strong) UIViewController *controller;

@property (nonatomic,copy) NSString *mobil;//手机号
@end
