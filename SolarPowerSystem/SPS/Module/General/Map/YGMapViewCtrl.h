//
//  YGMapViewCtrl.h
//  Golf
//
//  Created by bo wang on 2016/12/20.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

@interface YGMapViewCtrl : BaseNavController

@property (strong, nonatomic) NSArray<ClubModel *> *clubList;

@property (copy, nonatomic) void (^didSelectedClub)(ClubModel *club);

@end
