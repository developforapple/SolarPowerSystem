//
//  MyPop.h
//  test2
//
//  Created by 廖瀚卿 on 15/6/3.
//  Copyright (c) 2015年 额度. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PopType) {
    PopTypeSubscribeOrClose = 0,
    PopTypeSubscribeReOpen,
    PopTypeTodayOpenOrClose,
    PopTypeTeachingWait,
    PopTypeTeachingFinished,
    PopTypeTeachingList,
    PopTypeTeachingNone,
};

@interface MyPop : NSObject

@property (copy, nonatomic) BlockReturn blockReturn;
@property (copy, nonatomic) BlockReturn show;
@property (copy, nonatomic) BlockReturn hide;
@property (nonatomic) int isFollowed;

+ (id)sharedInstance;

- (void)dismiss;

- (void)showFromTarget:(id)target inView:(UIView *)view withData:(id)data block:(BlockReturn)blockReturn show:(BlockReturn)show hide:(BlockReturn)hide;
- (void)showWithType:(PopType)popType fromTarget:(id)target inView:(UIView *)view withData:(id)data block:(BlockReturn)blockReturn show:(BlockReturn)show hide:(BlockReturn)hide;
@end
