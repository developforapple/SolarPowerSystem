//
//  YGOrderMallCell.h
//  Golf
//
//  Created by bo wang on 2016/10/28.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGOrderCell.h"

@class YGMallOrderModel;

UIKIT_EXTERN NSString *const kYGOrderMallCell;

/**
 显示在订单列表中商品订单cell。 使用前，先使用YGOrderCell的方法进行注册。
 */
@interface YGOrderMallCell : YGOrderCell

- (YGMallOrderModel *)order;

@end
