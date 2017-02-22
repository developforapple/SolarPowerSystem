//
//  NSObject+KVCExceptionCatch.m
//  Golf
//
//  Created by bo wang on 16/6/28.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "NSObject+KVCExceptionCatch.h"

@implementation NSObject (KVCExceptionCatch)

#pragma mark - Exception Catch

DDSwizzleMethod

+ (void)load
{
    /*!
     *  IB中 IBInspectable 使用的是 KVC进行设值。
     *  当使用KVC设置值，key不正确时通常会crash。所以在这里需要做异常处理。
     *  key不正确时，会调用 setValue:forUndefinedKey: 方法。这里进行了方法替换来捕捉异常。
     */
    SEL oldSel = @selector(setValue:forUndefinedKey:);
    SEL newSel = @selector(yg_setValue:forUndefinedKey:);
    [self swizzleInstanceSelector:oldSel withNewSelector:newSel];
}

- (void)yg_setValue:(id)value forUndefinedKey:(NSString *)key
{
    // 防止Crash就可以了
    @try {
        [self yg_setValue:value forUndefinedKey:key];
    }
    @catch (NSException *exception) {
        NSLog(@"KVC Error Key: %@",key);
        NSLog(@"exception: %@",exception);
    }
}

@end
