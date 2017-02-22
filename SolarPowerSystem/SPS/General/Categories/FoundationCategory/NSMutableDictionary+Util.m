//
//  NSMutableDictionary+Util.m
//  SWWY
//
//  Created by GuoChenghao on 15/1/28.
//  Copyright (c) 2015年 GuoChenghao. All rights reserved.
//

#import "NSMutableDictionary+Util.h"

@implementation NSMutableDictionary (Util)

- (void)setObjectPassNil:(id)anObject forKey:(id<NSCopying>)aKey
{
    if (anObject != nil) [self setObject:anObject forKey:aKey];
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey ifNil:(id)objectIfNil
{
    anObject ? [self setObject:anObject forKey:aKey] : [self setObject:objectIfNil forKey:aKey];
}

- (void)setObjectNilToNull:(id)anObject forKey:(id<NSCopying>)aKey
{
    [self setObject:anObject forKey:aKey ifNil:[NSNull null]];
}

- (void)setObjectNilToEmptyString:(id)anObject forKey:(id<NSCopying>)aKey
{
    [self setObject:anObject forKey:aKey ifNil:@""];
}

@end
