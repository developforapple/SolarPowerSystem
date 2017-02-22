//
//  YGRedEnvelpoeDetailViewCtrl.h
//  Golf
//
//  Created by 黄希望 on 14-8-26.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

@interface YGRedEnvelpoeDetailViewCtrl : BaseNavController{
    IBOutlet UILabel *oneLabel;
    IBOutlet UILabel *twoLabel;
    IBOutlet UIButton *shareBtn;
}

@property (nonatomic) int redPaperId;

- (IBAction)shareAction:(id)sender;

@end
