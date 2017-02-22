//
//  OnlyOneLineCell.h
//  Golf
//
//  Created by 黄希望 on 15/10/16.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OnlyOneLineCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *showTextLabel;

@property (nonatomic,copy) BlockReturn blockDone;

@end
