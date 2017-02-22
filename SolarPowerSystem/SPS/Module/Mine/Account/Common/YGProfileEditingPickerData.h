//
//  YGProfileEditingPickerData.h
//  Golf
//
//  Created by bo wang on 2016/12/29.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YGProfileEditingPickerData : NSObject

// 性别
+ (NSArray<NSString *> *)gender;

// 差点 -20~+50
+ (NSArray<NSNumber *> *)handicap;

// 得分 50~140
+ (NSArray<NSNumber *> *)score;

// 年龄 1~100
+ (NSArray<NSNumber *> *)age;

// 教龄 1~50
+ (NSArray<NSNumber *> *)seniority;

@end
