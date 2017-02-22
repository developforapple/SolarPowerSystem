//
//  ChooseDateController.h
//  Golf
//
//  Created by 黄希望 on 15/10/21.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

@interface ChooseDateController : BaseNavController

+ (void)controllerWithTarget:(UIViewController*)target date:(NSString*)date clubId:(int)clubId completion:(void(^)(NSString *selectDate))completion;

@end
