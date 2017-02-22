//
//  YGSearchYueduCell.h
//  Golf
//
//  Created by bo wang on 16/7/27.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGSearchBaseCell.h"

@interface YGSearchYueduCell : YGSearchBaseCell
@property (weak, nonatomic) IBOutlet UIImageView *yueduImageView;
@property (weak, nonatomic) IBOutlet UIImageView *yueduVideoIndicator;
@property (weak, nonatomic) IBOutlet YYLabel *yueduTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightInfoLabel;
@end
