//
//  ChooseTimeController.h
//  Golf
//
//  Created by 黄希望 on 15/10/21.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

@interface ChooseTimeController : BaseNavController

+ (void)controllerWithTarget:(UIViewController*)target
                        date:(NSString*)date
                        time:(NSString*)time
                      clubId:(int)clubId
                  completion:(void(^)(NSString *selectTime))completion;

@end
