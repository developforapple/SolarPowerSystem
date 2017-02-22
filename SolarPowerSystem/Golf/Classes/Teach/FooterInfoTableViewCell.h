//
//  FooterInfoTableViewCell.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/21.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FooterInfoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelFooterInfo;
@property (strong,nonatomic) NSString *mobilePhone;
@property (copy, nonatomic) BlockReturn blockReturn;
@property (weak, nonatomic) IBOutlet UIButton *btnCall;

@end
