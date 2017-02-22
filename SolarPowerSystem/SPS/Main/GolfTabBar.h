//
//  GolfTabBar.h
//  Golf
//
//  Created by lyf on 16/5/9.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TheTabBarButton;

@interface GolfTabBar : UITabBar
@property (strong, nonatomic) TheTabBarButton *theTabBarButton;
- (void)setMiddleBtnTappedAction:(void (^)(void))middleBtnTappedAction;
@end
