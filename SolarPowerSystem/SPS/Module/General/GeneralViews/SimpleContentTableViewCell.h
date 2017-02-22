//
//  SimpleContentTableViewCell.h
//  Golf
//
//  Created by 廖瀚卿 on 15/12/8.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimpleContentTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *btnAction;
@property (weak, nonatomic) IBOutlet UILabel *labelContent;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (copy, nonatomic) BlockReturn blockReturn;
@end
