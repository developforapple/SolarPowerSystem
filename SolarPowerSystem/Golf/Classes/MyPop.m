//
//  MyPop.m
//  test2
//
//  Created by 廖瀚卿 on 15/6/3.
//  Copyright (c) 2015年 额度. All rights reserved.
//

#import "MyPop.h"
#import "CMPopTipView.h"

#import "OneButtonView.h"
#import "TwoButtonView.h"
#import "TeachingWaitView.h"
#import "TeachingFinishedView.h"
#import "TeachingListView.h"
#import "TeachingNoneView.h"
#import "ThreeButtonView.h"
#import "BaiduMobStat.h"


@interface MyPop()<CMPopTipViewDelegate>

@property (nonatomic, strong) NSMutableArray *visiblePopTipViews;
@property (nonatomic, strong) id currentPopTipViewTarget;
@property (nonatomic, strong) ThreeButtonView *cv;

@end

@implementation MyPop

- (void)showFromTarget:(id)target inView:(UIView *)view withData:(id)data block:(BlockReturn)blockReturn show:(BlockReturn)show hide:(BlockReturn)hide{
    self.show = show;
    self.hide = hide;
    
    if (target == self.currentPopTipViewTarget) {
        self.currentPopTipViewTarget = nil;
        return;
    }
    
    _cv = [[[NSBundle mainBundle] loadNibNamed:@"ThreeButtonView" owner:nil options:0] firstObject];
    _cv.blockReturn = blockReturn;
    
    CMPopTipView *popTipView = [[CMPopTipView alloc] initWithCustomView:_cv];
    popTipView.bubblePaddingY = 0;
    popTipView.bubblePaddingX = 10;
    
    popTipView.delegate = self;
    popTipView.animation = CMPopTipAnimationSlide;
    popTipView.has3DStyle = NO;
    popTipView.hasGradientBackground = NO;
    popTipView.cornerRadius = 1.5;
    popTipView.hasShadow = NO;
    popTipView.dismissTapAnywhere = YES;
    popTipView.borderWidth = .5;
    popTipView.maxWidth = [[UIScreen mainScreen] bounds].size.width - 50;
    popTipView.pointerSize = 8;
    popTipView.borderColor = [UIColor colorWithRed:27/255.0 green:27/255.0 blue:27/255.0 alpha:.98];
    popTipView.backgroundColor = [UIColor colorWithRed:71/255.0 green:71/255.0 blue:71/255.0 alpha:.98];
    popTipView.hided = ^(){
        self.currentPopTipViewTarget = nil;
        hide(nil);
    };
    [popTipView presentPointingAtView:target inView:view animated:YES];
    
    if (self.show) {
        self.show(nil);
    }
    
    [self.visiblePopTipViews addObject:popTipView];
    _cv.isFollowed = _isFollowed; //lyf 加
    self.currentPopTipViewTarget = target;
}

- (void)showWithType:(PopType)popType fromTarget:(id)target inView:(UIView *)view withData:(id)data block:(BlockReturn)blockReturn show:(BlockReturn)show hide:(BlockReturn)hide{
    self.show = show;
    self.hide = hide;
    if (target == self.currentPopTipViewTarget) {
        self.currentPopTipViewTarget = nil;
        return;
    }
    
    CMPopTipView *popTipView;
    
    
    switch (popType) {
        case PopTypeTeachingNone:
        {
            TeachingNoneView *cv = [[[NSBundle mainBundle] loadNibNamed:@"TeachingNoneView" owner:nil options:0] firstObject];
            cv.labelMessage.text = [NSString stringWithFormat:@"%@",data[@"title"]];
            popTipView = [[CMPopTipView alloc] initWithCustomView:cv];
            popTipView.bubblePaddingY = 0;
            popTipView.bubblePaddingX = 10;
        }
            break;
        case PopTypeSubscribeReOpen:
        {
            OneButtonView *cv = [[[NSBundle mainBundle] loadNibNamed:@"OneButtonView" owner:nil options:0] firstObject];
            cv.labelMessage.text = [NSString stringWithFormat:@"%@",data[@"title"]];
            cv.blockReturn = blockReturn;
            cv.data = data[@"data"];
            popTipView = [[CMPopTipView alloc] initWithCustomView:cv];
            popTipView.bubblePaddingY = 0;
            popTipView.bubblePaddingX = 10;
            [[BaiduMobStat defaultStat] logEvent:@"btnTimetableTimeOpen" eventLabel:@"我的时间表开放预约点击"];
            [MobClick event:@"btnTimetableTimeOpen" label:@"我的时间表开放预约点击"];
        }
            break;
        case PopTypeTodayOpenOrClose:
        {
            TwoButtonView *cv = [[[NSBundle mainBundle] loadNibNamed:@"TwoButtonView" owner:nil options:0] firstObject];
            cv.labelMessage.text = [NSString stringWithFormat:@"%@",data[@"title"]];
            cv.blockReturn = blockReturn;
            [cv.btn1 setTitle:@"开放当天预约" forState:(UIControlStateNormal)];
            [cv.btn2 setTitle:@"不开放当天预约" forState:UIControlStateNormal];
            cv.data = data[@"data"];
            popTipView = [[CMPopTipView alloc] initWithCustomView:cv];
            popTipView.bubblePaddingY = 0;
            popTipView.bubblePaddingX = 10;
        }
            break;
        case PopTypeSubscribeOrClose:
        {
            TwoButtonView *cv = [[[NSBundle mainBundle] loadNibNamed:@"TwoButtonView" owner:nil options:0] firstObject];
            cv.labelMessage.text = [NSString stringWithFormat:@"%@",data[@"title"]];
            cv.blockReturn = blockReturn;
            cv.data = data[@"data"];
            popTipView = [[CMPopTipView alloc] initWithCustomView:cv];
            popTipView.bubblePaddingY = 0;
            popTipView.bubblePaddingX = 10;
        }
            break;
        case PopTypeTeachingWait:
        {
            ReservationModel *rm = data[@"data"];
            TeachingWaitView *cv = [[[NSBundle mainBundle] loadNibNamed:@"TeachingWaitView" owner:nil options:0] firstObject];
            cv.reservationModel = rm;
            cv.labelName.text = rm.nickName;
            cv.viewLine.hidden = YES;
            switch (rm.reservationStatus) {
                case 1:
                    cv.labelStatus.text = @"待上课";
                    break;
                case 2:
                    cv.labelStatus.text = @"已完成";
                    break;
                case 3:
                    cv.labelStatus.text = @"未到场";
                    break;
                case 4:
                    cv.labelStatus.text = @"已取消";
                    break;
                case 5:
                    cv.labelStatus.text = @"待确认";
                    break;
                case 6:
                    cv.labelStatus.text = @"待评价";
                    break;
                default:
                    break;
            }
            
            cv.labelDatetime.text = [NSString stringWithFormat:@"%@",data[@"title"]];
            cv.blockCellPressed = blockReturn;
            popTipView = [[CMPopTipView alloc] initWithCustomView:cv];
            popTipView.bubblePaddingY = 10;
            popTipView.bubblePaddingX = 10;
        }
            break;
        case PopTypeTeachingFinished:
        {
            ReservationModel *rm = data[@"data"];
            TeachingFinishedView *cv = [[[NSBundle mainBundle] loadNibNamed:@"TeachingFinishedView" owner:nil options:0] firstObject];
            cv.reservationModel = rm;
            cv.viewLine.hidden = YES;
            cv.labelName.text = rm.nickName;
            cv.labelDatetime.text = [NSString stringWithFormat:@"%@",data[@"title"]];
            cv.blockCellPressed = blockReturn;
            cv.blockRightPressed = blockReturn;
            popTipView = [[CMPopTipView alloc] initWithCustomView:cv];
            popTipView.bubblePaddingY = 10;
            popTipView.bubblePaddingX = 10;
        }
            break;
        case PopTypeTeachingList:
        {
            TeachingListView *cv = [[[NSBundle mainBundle] loadNibNamed:@"TeachingListView" owner:nil options:0] firstObject];
            [cv loadList:data];
            cv.blockCellPressed = blockReturn;
            cv.blockRightPressed = blockReturn;
            popTipView = [[CMPopTipView alloc] initWithCustomView:cv];
            popTipView.bubblePaddingY = 0;
            popTipView.bubblePaddingX = 10;
        }
            break;
        default:
            popTipView = [[CMPopTipView alloc] initWithMessage:@""];
            break;
    }
    
    popTipView.delegate = self;
    popTipView.animation = CMPopTipAnimationSlide;
    popTipView.has3DStyle = NO;
    popTipView.hasGradientBackground = NO;
    popTipView.cornerRadius = 1.5;
    popTipView.hasShadow = NO;
    popTipView.dismissTapAnywhere = YES;
    popTipView.borderWidth = .5;
    popTipView.maxWidth = [[UIScreen mainScreen] bounds].size.width - 50;
    popTipView.pointerSize = 6;
    popTipView.borderColor = [UIColor colorWithRed:27/255.0 green:27/255.0 blue:27/255.0 alpha:.98];
    popTipView.backgroundColor = [UIColor colorWithRed:71/255.0 green:71/255.0 blue:71/255.0 alpha:.98];
    popTipView.hided = ^(){
        self.currentPopTipViewTarget = nil;
        hide(nil);
    };
    [popTipView presentPointingAtView:target inView:view animated:YES];
    
    if (self.show) {
        self.show(nil);
    }
    
    [self.visiblePopTipViews addObject:popTipView];
    self.currentPopTipViewTarget = target;
}

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
        
    });
    return _sharedObject;
}

-(instancetype)init{
    if (self == [super init]) {
        self.visiblePopTipViews = [NSMutableArray array];
    }
    return self;
}

- (void)dismiss
{
    while ([self.visiblePopTipViews count] > 0) {
        CMPopTipView *popTipView = [self.visiblePopTipViews objectAtIndex:0];
        [popTipView dismissAnimated:YES];
        [self.visiblePopTipViews removeObjectAtIndex:0];
    }
}


#pragma mark - CMPopTipViewDelegate methods

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    [self.visiblePopTipViews removeObject:popTipView];
    self.currentPopTipViewTarget = nil;
}


@end
