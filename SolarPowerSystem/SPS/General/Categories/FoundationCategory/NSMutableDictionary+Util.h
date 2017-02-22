//
//  NSMutableDictionary+Util.h
//  SWWY
//
//  Created by GuoChenghao on 15/1/28.
//  Copyright (c) 2015年 GuoChenghao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Util)

/**
 *  设置字典值时如果传值为nil则不设置
 *
 *  @param anObject The value for aKey. A strong reference to the object is maintained by the dictionary.
 *  @param aKey     The key for value.
 */
- (void)setObjectPassNil:(id)anObject forKey:(id<NSCopying>)aKey;

/**
 *  设置字典值时如果传值为nil时设为默认值objectIfNil
 *
 *  @param anObject    The value for aKey. A strong reference to the object is maintained by the dictionary.
 *  @param aKey        The key for value.
 *  @param objectIfNil anObject为nil时用该默认值代替
 */
- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey ifNil:(id)objectIfNil;

/**
 *  设置字典值时如果传值为nil时设为默认值NSNull
 *
 *  @param anObject The value for aKey. A strong reference to the object is maintained by the dictionary.
 *  @param aKey     The key for value.
 */
- (void)setObjectNilToNull:(id)anObject forKey:(id<NSCopying>)aKey;

/**
 *  设置字典值时如果传值为nil时设为默认值空字符串(@"")
 *
 *  @param anObject The value for aKey. A strong reference to the object is maintained by the dictionary.
 *  @param aKey     The key for value.
 */
- (void)setObjectNilToEmptyString:(id)anObject forKey:(id<NSCopying>)aKey;

@end
