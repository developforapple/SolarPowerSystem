//
//  YGStatisticsHelper.h
//  Golf
//
//  Created by bo wang on 16/7/7.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YGStatisticsHelper : NSObject

+ (instancetype)shared;

// 自动上传数据。默认YES。
@property (assign, nonatomic) BOOL uploadAutomatic;
// 上传埋点数据的间隔。默认30分钟；
@property (assign, nonatomic) NSTimeInterval uploadInterval;

// 记录一个埋点数据
- (void)recordPoint:(NSUInteger)point;

@end
