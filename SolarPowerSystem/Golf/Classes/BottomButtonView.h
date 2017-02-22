//
//  BottomButtonView.h
//  Golf
//
//  Created by zhengxi on 15/12/24.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BottomButtonView : UIView
@property (weak, nonatomic) IBOutlet UIButton *cancelOrderButton;
@property (weak, nonatomic) IBOutlet UIButton *contactCustomerServiceButton;
@property (strong, nonatomic) void (^cancelButtonBlock) (void);
@property (strong, nonatomic) void (^customerButtonBlock) (void);

@end
