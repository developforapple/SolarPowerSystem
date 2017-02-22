//
//  PCHeadView.h
//  Golf
//
//  Created by 黄希望 on 15/6/24.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCHeadView : UIView

@property (nonatomic,weak) IBOutlet UILabel *joinLabel;
@property (nonatomic,weak) IBOutlet UILabel *totalLabel;
@property (nonatomic,weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic,weak) IBOutlet UIButton *joinBtn;

@property (nonatomic,copy) BlockReturn resp;
@property (nonatomic,weak) IBOutlet UIView *lineView;

@end
