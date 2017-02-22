//
//  YGStatisticsHelper.m
//  Golf
//
//  Created by bo wang on 16/7/7.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGStatisticsHelper.h"
#import <YYCache/YYCache.h>

@interface YGStatisticsHelper ()
{
    BOOL _uploading;
}
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) YYCache *cache;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *,NSNumber *> *tempDict;
@end

@implementation YGStatisticsHelper

+ (instancetype)shared
{
    static YGStatisticsHelper *helper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [YGStatisticsHelper new];
        helper.uploadAutomatic = YES;
        helper.uploadInterval = 30*60*60;
        helper.cache = [[YYCache alloc] initWithName:@"com.golf.YGStatistics"];
        helper.tempDict = [NSMutableDictionary dictionary];
    });
    return helper;
}

- (void)recordPoint:(NSUInteger)point
{
    if (_uploading) {
        NSNumber *key = @(point);
        self.tempDict[key] = @(self.tempDict[key].integerValue+1);
        return;
    }
    
    NSString *k = [NSString stringWithFormat:@"%lu",(unsigned long)point];
    [[self points] addIndex:point];
    
    NSNumber *count = (NSNumber *)[self.cache objectForKey:k];
    NSUInteger c = count.integerValue;
    c++;
    [self.cache setObject:@(c) forKey:k];
}

// 埋点列表
- (NSMutableIndexSet *)points
{
    static NSString *k = @"Points";
    NSMutableIndexSet *p = (id)[self.cache objectForKey:k];
    if (!p) {
        p = [NSMutableIndexSet indexSet];
        [self.cache setObject:p forKey:k];
    }
    return p;
}

- (void)upload
{
}

- (void)uploadCompleted
{
    [self.cache removeAllObjects];
    [self saveTempPoints];
}

- (void)saveTempPoints
{
    NSMutableIndexSet *points = [self points];
    for (NSNumber *k in self.tempDict) {
        NSNumber *c = self.tempDict[k];
        [points addIndex:k.integerValue];
        [self.cache setObject:c forKey:k.description];
    }
    [self.cache setObject:points forKey:@"Points"];
    [self.tempDict removeAllObjects];
}

- (void)clear
{
    [self.cache removeAllObjects];
    [self.tempDict removeAllObjects];
}

#pragma mark - Timer
- (void)prepareUpload:(NSTimer *)timer
{
    self.timer = nil;
    [self upload];
}

- (void)startTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.uploadInterval target:self selector:@selector(prepareUpload:) userInfo:nil repeats:NO];
}

@end
