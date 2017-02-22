//
//  ClubChooseDTCell.h
//  Golf
//
//  Created by 黄希望 on 15/10/26.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClubChooseDTCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIButton *dateBtn;
@property (nonatomic,weak) IBOutlet UIButton *timeBtn;

@property (nonatomic,copy) BlockReturn blockClick;

@end
