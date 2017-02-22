//
//  ClubManagerTableViewCell.h
//  Golf
//
//  Created by 黄希望 on 15/9/30.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClubManagerTableViewCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIImageView *headImageView;
@property (nonatomic,weak) IBOutlet UILabel *memberNameLabel;
@property (nonatomic,weak) IBOutlet UILabel *clubTitleLabel;
@property (nonatomic,weak) IBOutlet UIImageView *memberLevelImg;

@property (nonatomic,copy) BlockReturn sendMsgBlock;

@property (nonatomic,strong) NSDictionary *clubManagerData;

@end
