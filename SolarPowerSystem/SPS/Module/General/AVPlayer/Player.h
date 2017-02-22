//
//  Player.h
//  Golf
//
//  Created by 黄希望 on 15/7/13.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Player : UIViewController

+ (instancetype)playWithUrl:(NSString*)url
                         rt:(CGRect)rt
              supportSlowed:(BOOL)sptSlowed
              supportCircle:(BOOL)sptCircle
                         vc:(UIViewController*)vc
                 completion:(void(^)(void))completion;

@end
