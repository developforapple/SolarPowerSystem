//
//  YGUserRemarkNameViewCtrl.h
//  Golf
//  用户备注
//  Created by 梁荣辉 on 2016/9/23.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGBaseViewController.h"

@interface YGUserRemarkNameViewCtrl : YGBaseViewController

// 备注回调
@property (strong, nonatomic) void(^userRemarkBlock)(NSString *remarkName);

// 用户Id
@property (assign, nonatomic) int memberId;
// 备注名称
@property (strong, nonatomic) NSString *remarkName;
// 用户昵称
@property (strong, nonatomic) NSString *nickName;

@end
