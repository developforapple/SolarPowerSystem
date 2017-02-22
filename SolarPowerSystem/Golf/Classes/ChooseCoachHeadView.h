//
//  ChooseCoachHeadView.h
//  Golf
//
//  Created by 黄希望 on 15/5/12.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseCoachHeadView : UIView

@property (nonatomic,weak) IBOutlet UILabel *academyNameLabel;
@property (nonatomic,weak) IBOutlet UILabel *addressLabel;

@property (nonatomic,copy) void(^daohang)(void);

@end
