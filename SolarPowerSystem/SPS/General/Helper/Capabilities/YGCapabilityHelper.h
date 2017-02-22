//
//  YGCapabilityHelper.h
//  Golf
//
//  Created by bo wang on 16/8/16.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YGCapabilityHelper : NSObject

+ (void)call:(NSString *)phoneNumber;
+ (void)call:(NSString *)phoneNumber needConfirm:(BOOL)needConfirm;

@end
