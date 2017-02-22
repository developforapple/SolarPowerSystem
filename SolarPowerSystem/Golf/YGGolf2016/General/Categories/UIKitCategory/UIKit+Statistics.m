//
//  UIControl+Statistics.m
//  Golf
//
//  Created by bo wang on 16/7/5.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "UIKit+Statistics.h"
#import <UMMobClick/MobClick.h>
#import "BaiduMobStat.h"

#define YGTarget [_YGPuppetTarget instance]
#define YGAction @selector(logEvent:)

@interface _YGPuppetTarget : NSObject
+ (instancetype)instance;
- (void)logEvent:(id <YGStatistics>)sender;
@end

@implementation _YGPuppetTarget
+ (instancetype)instance
{
    static _YGPuppetTarget *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [_YGPuppetTarget new];
    });
    return instance;
}

- (void)logEvent:(id <YGStatistics>)sender
{
    NSString *token;
    NSString *label;
    
    if ([sender respondsToSelector:@selector(eventId_)]) {
        token = [sender eventId_];
    }
    if ([sender respondsToSelector:@selector(eventLabel_)]) {
        label = [sender eventLabel_];
    }
    
    if (token) {
        if (label) {
            [MobClick event:token label:label];
            [[BaiduMobStat defaultStat] logEvent:token eventLabel:label];
        }else{
            [MobClick event:token];
            [[BaiduMobStat defaultStat] logEvent:token eventLabel:@""];
        }
    }
}
@end

static void * kYGEventIdKey = &kYGEventIdKey;
static void * kYGEventLabelKey = &kYGEventLabelKey;

#define EventIDGetter -(NSString *)eventId_{return objc_getAssociatedObject(self, kYGEventIdKey);}
#define EventIDSetter(code) - (void)setEventId_:(NSString *)eventId_{\
    objc_setAssociatedObject(self, kYGEventIdKey, eventId_, OBJC_ASSOCIATION_RETAIN_NONATOMIC);\
    {\
        code\
    }\
}
#define EventLabelGetter - (NSString *)eventLabel_{return objc_getAssociatedObject(self, kYGEventLabelKey);}
#define EventLabelSetter - (void)setEventLabel_:(NSString *)eventLabel_{objc_setAssociatedObject(self, kYGEventLabelKey, eventLabel_, OBJC_ASSOCIATION_RETAIN_NONATOMIC);}

@implementation UIControl (YGStatistics)
EventLabelGetter
EventLabelSetter
EventIDGetter
EventIDSetter({
    
    // UIButton UIDatePicker UIPageControl UIRefreshControl UISegmentedControl UISlider UISwitch
    
    if ([self isKindOfClass:[UIButton class]]){
        [self addTarget:YGTarget action:YGAction forControlEvents:UIControlEventTouchUpInside];
    }else{
        [self addTarget:YGTarget action:YGAction forControlEvents:UIControlEventValueChanged];
    }
})
@end

@implementation UIGestureRecognizer (YGStatistics)
EventLabelGetter
EventLabelSetter
EventIDGetter
EventIDSetter({
    
    if ([self isKindOfClass:[UITapGestureRecognizer class]] ||
        [self isKindOfClass:[UILongPressGestureRecognizer class]]){
        [self addTarget:YGTarget action:YGAction];
    }
})

@end

@implementation UIBarButtonItem (YGStatistics)
EventLabelGetter
EventLabelSetter
EventIDGetter
EventIDSetter()

DDSwizzleMethod;

+ (void)load
{
    // 这是私有方法。需要这样处理字符串。
    NSString *oldSelString = [NSString stringWithFormat:@"_sen%@ctio%@hEve%@",@"dA",@"n:wit",@"nt:"];   //_sendAction:withEvent:
    NSString *newSelString = [NSString stringWithFormat:@"yg_sen%@ctio%@hEve%@",@"dA",@"n:wit",@"nt:"];
    
    SEL oldSel = NSSelectorFromString(oldSelString);
    SEL newSel = NSSelectorFromString(newSelString);
    [self swizzleInstanceSelector:oldSel withNewSelector:newSel];
}

- (void)yg_sendAction:(id)action withEvent:(id)event
{
    [self yg_sendAction:action withEvent:event];
    [YGTarget logEvent:self];
}

@end

@implementation UITableViewCell (YGStatistics)
EventLabelGetter
EventLabelSetter
EventIDGetter
EventIDSetter()

DDSwizzleMethod

+ (void)load
{
    SEL oldSel = @selector(setSelected:animated:);
    SEL newSel = @selector(yg_setSelected:animated:);
    [self swizzleInstanceSelector:oldSel withNewSelector:newSel];
}

- (void)yg_setSelected:(BOOL)selected animated:(BOOL)animated
{
    [self yg_setSelected:selected animated:animated];
    if (selected) {
        [YGTarget logEvent:self];
    }
}

@end

@implementation UICollectionViewCell (YGStatistics)
EventLabelGetter
EventLabelSetter
EventIDGetter
EventIDSetter()

DDSwizzleMethod

+ (void)load
{
    SEL oldSel = @selector(setSelected:);
    SEL newSel = @selector(yg_setSelected:);
    [self swizzleInstanceSelector:oldSel withNewSelector:newSel];
}

- (void)yg_setSelected:(BOOL)selected
{
    [self yg_setSelected:selected];
    if (selected) {
        [YGTarget logEvent:self];
    }
}

@end
