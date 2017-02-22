//
//  InvoiceCell.h
//  Golf
//
//  Created by 黄希望 on 15/11/2.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InvoiceCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UISwitch *swt;
@property (nonatomic,weak) IBOutlet UITextField *inputField;
@property (nonatomic,weak) IBOutlet UILabel *addressLabel;

@end
