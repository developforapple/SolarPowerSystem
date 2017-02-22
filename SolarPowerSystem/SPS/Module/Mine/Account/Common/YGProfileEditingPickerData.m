//
//  YGProfileEditingPickerData.m
//  Golf
//
//  Created by bo wang on 2016/12/29.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGProfileEditingPickerData.h"

NSArray<NSNumber *> *numberArray(NSInteger from, NSInteger to){
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i=from; i<=to; i++) {
        [array addObject:@(i)];
    }
    return array;
}

@implementation YGProfileEditingPickerData

+ (NSArray<NSString *> *)gender
{
    return @[@"男",@"女"];
}

+ (NSArray<NSNumber *> *)handicap
{
    static NSArray *tmp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tmp = numberArray(-20, 50);
    });
    return tmp;
}

+ (NSArray<NSNumber *> *)score
{
    static NSArray *tmp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tmp = numberArray(50, 140);
    });
    return tmp;
}

+ (NSArray<NSNumber *> *)age
{
    static NSArray *tmp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tmp = numberArray(1, 100);
    });
    return tmp;
}

+ (NSArray<NSNumber *> *)seniority
{
    static NSArray *tmp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tmp = numberArray(1, 50);
    });
    return tmp;
}

@end
