//
//  YGMallAddressListViewCtrl.h
//  Golf
//
//  Created by bo wang on 2016/11/29.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

@interface YGMallAddressListViewCtrl : BaseNavController

@property (assign, nonatomic) NSInteger addreddId;
@property (assign, nonatomic) BOOL isSetDefaultAddress;

@property (copy, nonatomic) void (^didSelectedAddress)(YGMallAddressModel *address);

@end
