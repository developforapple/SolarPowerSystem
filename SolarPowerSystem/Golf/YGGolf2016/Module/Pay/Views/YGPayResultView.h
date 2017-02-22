//
//  YGPayResultView.h
//  Golf
//
//  Created by bo wang on 2016/11/11.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YGPayment;

@interface YGPayResultView : UIView

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *sucPanel;
@property (weak, nonatomic) IBOutlet UIImageView *sucApplePayIcon;
@property (weak, nonatomic) IBOutlet UIView *failPanel;
@property (weak, nonatomic) IBOutlet UILabel *failNoteLabel;
@property (weak, nonatomic) IBOutlet UIButton *redEnvelopeBtn;

@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;

@property (weak, nonatomic) IBOutlet UIView *couponPanel;
@property (weak, nonatomic) IBOutlet UILabel *couponNoteLabel;

@property (copy, nonatomic) void (^leftBtnAction)(void);
@property (copy, nonatomic) void (^rightBtnAction)(void);

- (void)updateWithResult:(YGPayment *)payment;

@end
