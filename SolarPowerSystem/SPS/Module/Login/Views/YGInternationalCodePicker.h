//
//  YGInternationalCodePicker.h
//  Golf
//
//  Created by bo wang on 2016/12/27.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGBasePopViewController.h"

@class YGInternationalCode;

@interface YGInternationalCodePicker : YGBasePopViewController

@property (strong, nonatomic) NSArray<YGInternationalCode *> *codeItems;

@property (copy, nonatomic) void (^codeChangedBlock)(YGInternationalCode *code);

+ (void)selectChinaCodes:(void (^)(YGInternationalCode *code))callback;

@end


@interface YGInternationalCode : NSObject
@property (copy, nonatomic) NSString *area;
@property (copy, nonatomic) NSString *code;

+ (NSArray<YGInternationalCode *> *)chinaCodes;

@end
