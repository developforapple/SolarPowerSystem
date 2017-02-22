//
//  JXChooseTime.h
//  Golf
//
//  Created by 黄希望 on 15/5/6.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TeachingCourseType.h"

@interface JXChooseTime : UIView

/*
 * 功能：选择预约时间
 * 参数：timeDic 被禁止选择的时间
 * 参数：date 被选中的日期 格式 yyyy-MM-dd
 * 参数：time 被选中的时间 格式 HH:mm 或者 HH:mm:ss
 * 参数：posY y坐标
 * 参数：completion 选中时间后的回调
 */
+ (void)jxWithDisableTime:(NSDictionary*)timeDic
                     date:(NSString*)date
                     time:(NSString*)time
                   maxNum:(int)maxNum
                classType:(TeachingCourseType)classType
                  supView:(UIView*)aView
                     posY:(CGFloat)posY
               completion:(void(^)(NSString *date, NSString *time))completion;


/*
 * 功能：选择预约时间(动态弹出)
 * 参数：selectedDay 被选中的日期 格式 yyyy-MM-dd
 * 参数：selectedTime 被选中的时间 格式 HH:mm 或者 HH:mm:ss
 * 参数：lposY y坐标
 * 参数：completion 选中时间后的回调
 * 参数：cleanCompletion 选择不限时间后的回调
 * 参数：showed 显示后的回调
 * 参数：hided 隐藏后的回调
 */
+ (void)jxAnimatedDate:(NSString *)date
                  time:(NSString *)time
               supView:(UIView *)aView
          belowSubview:(UIView *)siblingSubview
                  posY:(CGFloat)posY
            completion:(void (^)(NSString *, NSString *))completion
       cleanCompletion:(void (^)())cleanCompletion
                showed:(void (^)())showed
                 hided:(void (^)())hided;

+ (void)hide;
+ (void)hideAnimate:(BOOL)animate;
+ (void)deSelected;

@end
