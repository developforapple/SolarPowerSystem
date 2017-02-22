//
//  TeachingOrderStatus.h
//  Golf
//
//  Created by 黄希望 on 15/5/13.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#ifndef Golf_TeachingOrderStatus_h
#define Golf_TeachingOrderStatus_h

typedef NS_ENUM(NSInteger, TeachingOrderStatus) {
    TeachingOrderStatusTeaching = 1,           // 教学中
    TeachingOrderStatusSuccess = 2,       // 完成交易
    TeachingOrderStatusCancel = 4,        // 已取消
    TeachingOrderStatusWaitPay = 6,      // 等待支付
};

#endif
