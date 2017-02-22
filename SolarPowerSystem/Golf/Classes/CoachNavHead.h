//
//  CoachNavHead.h
//  Golf
//
//  Created by 黄希望 on 15/6/12.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoachNavHead : UIView

@property (nonatomic,weak) IBOutlet UIImageView *bgView;
@property (nonatomic,copy) BlockReturn respEvent;

- (void)actionWithIndex:(NSInteger)index;

@end
