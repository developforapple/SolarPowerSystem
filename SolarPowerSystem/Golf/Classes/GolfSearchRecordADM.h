//
//  GolfSearchRecordADM.h
//  Golf
//
//  Created by 黄希望 on 15/5/22.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GolfSearchRecordADM : NSObject

+ (void)recordListWithCacheName:(NSString*)name
                     controller:(BaseNavController*)controller
                     completion:(void(^)(id obj))completion
                clearCompletion:(void(^)(void))clearCompletion
              disappearKeyboard:(void(^)(void))disappearKeyboard;
+ (void)hide;
@end
