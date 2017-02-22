//
//  DDShareUnit.h
//  QuizUp
//
//  Created by Normal on 16/4/18.
//  Copyright © 2016年 zhenailab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDShareCommon.h"

typedef void(^DDShareCallback)(void);

@interface DDShareUnit : NSObject

@property (readonly, assign, nonatomic) DDShareType type;
@property (readonly, strong, nonatomic) NSString *title;
@property (readonly, strong, nonatomic) UIImage *image;
@property (readonly, strong, nonatomic) UIImage *highlightImage;
@property (copy, nonatomic) DDShareCallback callback;

// 单独的内建分享类型。
+ (instancetype)unitWithType:(DDShareType)type callback:(DDShareCallback)callback;

// 自定义类型
+ (instancetype)unitWithTitle:(NSString *)title
                        image:(UIImage *)image
               highlightImage:(UIImage *)highlightImage
                     callback:(DDShareCallback)callback;
@end

typedef void(^DDShareBuildInUnitCallback)(DDShareType type);

@interface DDShareUnit (BuildIn)
// 内置的分享和操作类型
+ (NSArray<DDShareUnit *> *)createBuildInUnits:(DDShareBuildInUnitCallback)unitCallback;
@end