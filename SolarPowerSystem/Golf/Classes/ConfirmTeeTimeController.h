//
//  ConfirmTeeTimeController.h
//  Golf
//
//  Created by 黄希望 on 15/10/29.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

@interface ConfirmTeeTimeController : BaseNavController

@property (nonatomic,strong) NSArray *teetimes;

@property (nonatomic,strong) ClubModel *club;
@property (nonatomic,strong) ConditionModel *cm;
@property (nonatomic,assign) BOOL canBack;
@property (nonatomic,assign) BOOL isVip;

// 是否为抢购
@property (nonatomic,assign) BOOL isSpree;

- (void)show:(BOOL)show index:(NSInteger)index data:(TTModel*)data;

@end
