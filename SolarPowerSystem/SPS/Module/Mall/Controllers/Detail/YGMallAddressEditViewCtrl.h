//
//  YGMallAddressEditViewCtrl.h
//  Golf
//
//  Created by bo wang on 2016/11/29.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

typedef NS_ENUM(NSUInteger, YGMallAddressEditType) {
    YGMallAddressEditTypeAdd = 1,   //增
    YGMallAddressEditTypeUpdate = 2,    //修改
    YGMallAddressEditTypeSetDefault = 3,    //设为默认
    YGMallAddressEditTypeDelete = 4 //删除
};

@class YGMallAddressModel;

@interface YGMallAddressEditViewCtrl : BaseNavController

@property (strong, nonatomic) YGMallAddressModel *address;

@property (copy, nonatomic) void (^didEditAddress)(YGMallAddressModel *address,YGMallAddressEditType editType);

@end
