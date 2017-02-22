//
//  CoachDataHead.h
//  Golf
//
//  Created by 黄希望 on 15/6/12.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoachDataHead : UIView

@property (nonatomic,assign) int orderTotal;
@property (nonatomic,assign) int orderCount;
@property (nonatomic,assign) int teachCount;

@property (nonatomic,weak) IBOutlet UIImageView *bgView;

- (void)loadData;

@end
