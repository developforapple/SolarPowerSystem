//
//  JXJoinView.h
//  Golf
//
//  Created by 黄希望 on 15/5/21.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JXJoinView : UIView

@property (nonatomic,weak) IBOutlet UIButton *joinBtn;
@property (nonatomic,copy) BlockReturn buttonAction;

@end
