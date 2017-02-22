//
//  PublicCourseJoinView.h
//  Golf
//
//  Created by 黄希望 on 15/5/14.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PublicCourseJoinView : UIView

+ (void)popWithSupView:(UIView*)aView price:(int)price completion:(void(^)(NSString *phoneNum,NSInteger actionTag))completion;

@end
