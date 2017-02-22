//
//  YGMallCartFeatureViewCtrl.h
//  Golf
//
//  Created by bo wang on 2016/10/17.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "BaseNavController.h"
#import "YGMallCart.h"

@interface YGMallCartFeatureViewCtrl : BaseNavController

@property (strong, nonatomic) YGMallCart *cart;
@property (assign, nonatomic) BOOL visible;

@end
