//
//  YGSearchUserCell.h
//  Golf
//
//  Created by bo wang on 16/7/27.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGSearchBaseCell.h"

@interface YGSearchUserCell : YGSearchBaseCell
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet YYLabel *userNameLabel;
@property (weak, nonatomic) IBOutlet YYLabel *userInfoLabel;
@end
