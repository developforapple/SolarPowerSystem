//
//  YGWalletTransferConfirmViewCtrl.h
//  Golf
//
//  Created by zhengxi on 15/12/15.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PersonInAddressList;

/**
 转账确认
 */
@interface YGWalletTransferConfirmViewCtrl : BaseNavController
@property (strong, nonatomic) PersonInAddressList *person;
@property (strong, nonatomic) UserFollowModel *model;

@end