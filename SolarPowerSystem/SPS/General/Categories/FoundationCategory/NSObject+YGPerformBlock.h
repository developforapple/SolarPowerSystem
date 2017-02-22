//
//  NSObject+YGPerformBlock.h
//  Golf
//
//  Created by bo wang on 2016/12/8.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^YGPerformBlock)(void);

/**
 想要在特定线程里执行block，需要在block里面指定线程。而不是在 performBlock:调用的地方
 调用此方法总是取消上一次调用
 */
@interface NSObject (YGPerformBlock)
- (void)performBlock:(YGPerformBlock)block;
- (void)performBlock:(YGPerformBlock)block afterDelay:(NSTimeInterval)delay;
@end
