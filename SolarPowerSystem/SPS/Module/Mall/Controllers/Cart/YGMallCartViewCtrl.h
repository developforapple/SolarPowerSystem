//
//  YGMallCartViewCtrl.h
//  Golf
//
//  Created by bo wang on 2016/10/10.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

@interface YGMallCartViewCtrl : BaseNavController

// 进入购物车时默认选中的商品。以 commodityId-skuid 字符串作为标识
@property (strong, nonatomic) NSSet<NSString *> *defaultSelectionInfo;

- (void)reload;

@end
