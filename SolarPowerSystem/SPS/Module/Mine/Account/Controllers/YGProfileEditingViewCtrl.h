//
//  YGProfileEditingViewCtrl.h
//  Golf
//
//  Created by 黄希望 on 14-9-18.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "BaseNavController.h"
#import "YGProfileViewCtrl.h"


@interface YGProfileEditingViewCtrl : BaseNavController

@property (nonatomic,strong) UserDetailModel *userDetail;
@property (nonatomic,strong) YGProfileViewCtrl *personalHomeController;
@property (nonatomic,weak) id delegate;
@property (nonatomic,copy) BlockReturn blockReturn;


@end
