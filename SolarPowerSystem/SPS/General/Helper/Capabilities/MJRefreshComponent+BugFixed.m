//
//  MJRefreshComponent+BugFixed.m
//  Golf
//
//  Created by Main on 2016/9/29.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "MJRefreshComponent+BugFixed.h"
#import "NSBundle+MJRefresh.h"


@implementation MJRefreshComponent (BugFixed)


- (NSString *)localizedStringForKey:(NSString *)key withDefault:(NSString *)defaultString{
    static NSBundle *bundle = nil;
    if (bundle == nil) {
        // 获得设备的语言
        NSString *language = [NSLocale preferredLanguages].firstObject;
        // 如果是iOS9以上，截取前面的语言标识
        if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0) {
            NSRange range = [language rangeOfString:@"-" options:NSBackwardsSearch];
            //应该加上 NSNotFound。当language为“en”时下面的获取子串报错
            if (range.location != NSNotFound) {
                language = [language substringToIndex:range.location];
            }
            
        }
        
        if (language.length == 0) {
            language = @"zh-Hans";
        }
        
        // 先从MJRefresh.bundle中查找资源
        NSBundle *refreshBundle = [NSBundle mj_refreshBundle];
        if ([refreshBundle.localizations containsObject:language]) {
            bundle = [NSBundle bundleWithPath:[refreshBundle pathForResource:language ofType:@"lproj"]];
        }
    }
    defaultString = [bundle localizedStringForKey:key value:defaultString table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:defaultString table:nil];
}


@end
