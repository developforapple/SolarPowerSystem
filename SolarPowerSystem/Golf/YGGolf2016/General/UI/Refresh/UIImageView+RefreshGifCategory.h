//
//  UIImageView+RefreshGifCategory.h
//  Golf
//
//  Created by bo wang on 16/9/5.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

//typedef void (^YGAnimationDidStart)(CAAnimation *anim);
//typedef void (^YGAnimationFinishedBlock)(CAAnimation *anim,BOOL flag);
//
//@protocol YGAnimaitonProtocol <NSObject>
//@property (copy, nonatomic) YGAnimationFinishedBlock yg_animationDidFinished;
//@end


@interface UIImageView (RefreshGifCategory)
//<YGAnimaitonProtocol>

/*!
 *  当使用animationImages进行动画时，当动画结束时，是否停留在当前状态，而不是恢复到初始状态
 */
@property (assign, nonatomic) BOOL yg_animationKeepLastStatus;
@end
