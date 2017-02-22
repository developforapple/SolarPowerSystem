//
//  YGOrderTeachingCell.h
//  Golf
//
//  Created by bo wang on 2016/12/9.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGOrderCell.h"

@class TeachingOrderModel;

UIKIT_EXTERN NSString *const kYGOrderTeachingCell;

@interface YGOrderTeachingCell : YGOrderCell

- (TeachingOrderModel *)order;

@end
