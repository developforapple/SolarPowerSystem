//
//  YGTeachBookingOrderTableViewCell.h
//  Golf
//
//  Created by bo wang on 16/9/19.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGOrderCell.h"

@class VirtualCourseOrderBean;

UIKIT_EXTERN NSString *const kYGOrderTeachBookingCell;

@interface YGOrderTeachBookingCell : YGOrderCell

- (VirtualCourseOrderBean *)order;

@end
