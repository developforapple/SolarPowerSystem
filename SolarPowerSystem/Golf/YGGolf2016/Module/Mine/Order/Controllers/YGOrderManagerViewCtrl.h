//
//  YGOrderManagerViewCtrl.h
//  Golf
//
//  Created by bo wang on 2016/12/9.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

typedef NS_ENUM(NSUInteger, YGOrderManagerSegment) {
    YGOrderManagerSegmentRecent = 0,
    YGOrderManagerSegmentSummary = 1
};

/**
 订单管理界面
 */
@interface YGOrderManagerViewCtrl : BaseNavController

@end
