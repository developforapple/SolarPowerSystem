//
//  YGProfileViewCtrl.h
//  Golf
//
//  Created by 廖瀚卿 on 15/12/3.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "BaseNavController.h"
#import "ChatViewController.h"
#import "PlayedClubModel.h"

@interface YGProfileViewCtrl : ChatViewController

@property (nonatomic,strong) UserDetailModel *userDetail;
@property (nonatomic,strong) UserPlayedClubListModel *userPlayedClubListModel;
@property (nonatomic,copy) BlockReturn blockFollow;
@property (nonatomic,assign) int showIndex;//0显示动态,1显示足迹
@property (nonatomic,assign) BOOL isFromYQ;//是否从约球进入
@property (nonatomic,assign) BOOL isJoinYQ;//是否加入约球，未加入隐藏底部发消息按钮

-(void)refreshUserInfo;

@end
