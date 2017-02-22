//
//  TeetimeSubViewController.h
//  Golf
//
//  Created by 黄希望 on 15/10/29.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

@interface TeetimeSubViewController : BaseNavController

@property (nonatomic,copy) BlockReturn blockclick;
@property (nonatomic,strong) ClubModel *club;
@property (nonatomic,strong) ConditionModel *cm;

@property (nonatomic,strong) TTModel *ttm;

@property (nonatomic,strong) NSArray *teetimes;
@property (nonatomic,assign) BOOL canBack;
@property (nonatomic,assign) BOOL isVip;

// 是否为抢购
@property (nonatomic,assign) BOOL isSpree;

// index=0表示弹出到列表 index=1表示弹出到预定
- (void)showView:(BOOL)show index:(NSInteger)index;

@end
