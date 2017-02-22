//
//  JXChooseSort.h
//  Golf
//  排序列表
//  Created by 廖瀚卿 on 15/5/8.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JXChooseSort : UIView

// 显示推荐排序列表
+ (void)show:(int)sort
     supView:(UIView *)supView
belowSubview:(UIView *)siblingSubview
        posY:(CGFloat)posY
  controller:(UIViewController *)controller
  completion:(void (^)(id))completion
      showed:(void (^)())showed
       hided:(void (^)())hided;

+ (void)hide;
+ (void)hideAnimate:(BOOL)animate;

@end
