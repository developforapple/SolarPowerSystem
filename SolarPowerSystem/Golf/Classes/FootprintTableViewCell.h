//
//  FootprintTableViewCell.h
//  Golf
//
//  Created by 廖瀚卿 on 15/12/10.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FootprintTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelGanCount; //多少杆
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelContent;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UIImageView *imageFootprint;
@property (weak, nonatomic) IBOutlet UILabel *labelPictureCount;
@property (weak, nonatomic) IBOutlet UIImageView *imageLock;
@property (weak, nonatomic) IBOutlet UIImageView *imageForm;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintRight;


@end
