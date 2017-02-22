//
//  ClubMainViewController.h
//  Golf
//
//  Created by 黄希望 on 15/10/26.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "BaseNavController.h"
#import "ChatViewController.h"
#import "ClubSpreeModel.h"

@interface ClubMainViewController : ChatViewController

@property (nonatomic,strong) ConditionModel *cm;
@property (nonatomic,assign) int agentId;
@property (nonatomic,assign) int clubId;

// 是否为抢购
@property (nonatomic,assign) BOOL rush;
@property (nonatomic,assign) int spreeId;
// 抢购数据
@property (nonatomic,strong) ClubSpreeModel *csm;

@property (nonatomic,copy) BlockReturn callRefreshBlock;

@end
