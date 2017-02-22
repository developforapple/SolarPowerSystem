//
//  YGRedEnvelpoeViewCtrl.h
//  Golf
//
//  Created by 黄希望 on 14-8-25.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

@interface YGRedEnvelpoeViewCtrl : BaseNavController{
    IBOutlet UIScrollView *scrollView;
    IBOutlet UILabel *totalAmountRedPaperLabel_r;
    IBOutlet UILabel *noRedPaperNoteLabel;
}

- (IBAction)checkAction:(id)sender;

@end
