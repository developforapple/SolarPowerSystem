//
//  ClubRushTypesCell.m
//  Golf
//
//  Created by 黄希望 on 15/11/4.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "ClubRushTypesCell.h"
#import "CalendarClass.h"
#import "CCAlertView.h"
#import "ClubMainViewController.h"

@interface ClubRushTypesCell (){
    BOOL _hasSetted;
}

@property (nonatomic,weak) IBOutlet UILabel *hourLabel;
@property (nonatomic,weak) IBOutlet UILabel *minuteLabel;
@property (nonatomic,weak) IBOutlet UILabel *secondLabel;
@property (nonatomic,weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic,weak) IBOutlet UIButton *doneBtn;
@property (nonatomic,assign) NSTimeInterval timeInteval;
@property (nonatomic,strong) NSTimer *theTimer;

@property (nonatomic,assign) int dayIndex; // 0:今天  1:明天 2:后天 ...

@end

@implementation ClubRushTypesCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _descriptionLabel.text = @"";
}

+ (NSTimeInterval)timeIntervalWithCompareResult:(NSString*)time timeInterGab:(NSTimeInterval)timeInterGab{
    if (!time) {
        return -1;
    }
    NSDate *today = [CalendarClass dateForStandardTodayAll];
    today = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([today timeIntervalSinceReferenceDate] + timeInterGab)];
    NSDate *dt = [Utilities getDateFromString:time WithFormatter:@"yyyy-MM-dd HH:mm:ss"];
    return [dt timeIntervalSinceDate:today];
}

- (void)setCsm:(ClubSpreeModel *)csm{
    _csm = csm;
    if (_csm) {
        NSDate *spreeDate = [Utilities getDateFromString:_csm.spreeTime WithFormatter:@"yyyy-MM-dd HH:mm:ss"];
        _dayIndex = [spreeDate timeIntervalSinceDate:[CalendarClass dateForToday]] / (3600*24);
        
        _hasSetted = _csm.hasSetted;
        // 已抢光
        _doneBtn.userInteractionEnabled = YES;
        if (_csm.stockQuantity-_csm.soldQuantity<=0) {
            [_descriptionLabel setText:@"亲来晚了，都被抢光了!"];
            [Utilities drawView:_doneBtn radius:3 bordLineWidth:1 borderColor:[UIColor colorWithHexString:@"ff6d00"]];
        }else{
            _timeInteval = [ClubRushTypesCell timeIntervalWithCompareResult:_csm.spreeTime timeInterGab:[LoginManager sharedManager].timeInterGab];
            if (_timeInteval / (24*3600) <= 0) {
                // 正在抢购(do nothing ...)
                [Utilities drawView:_doneBtn radius:3 bordLineWidth:1 borderColor:[UIColor colorWithHexString:@"ff6d00"]];
            }else {
                if (_dayIndex == 0) {
                    if (_timeInteval / (24*3600) < 1){                // 小于24小时
                        if (_timeInteval < 600){
                            [Utilities drawView:_doneBtn radius:3 bordLineWidth:1 borderColor:[UIColor colorWithHexString:@"C8C8C8"]];
                            [_doneBtn setBackgroundColor:[UIColor colorWithHexString:@"C8C8C8"]];
                            [_doneBtn setTitleColor:[UIColor colorWithHexString:@"999999"] forState:UIControlStateNormal];
                            [_doneBtn setTitle:@"即将开抢" forState:UIControlStateNormal];
                            [_doneBtn setImage:nil forState:UIControlStateNormal];
                            _doneBtn.userInteractionEnabled = NO;
                        }else{
                            [Utilities drawView:_doneBtn radius:3 bordLineWidth:1 borderColor:[UIColor colorWithHexString:_csm.hasSetted?@"C8C8C8":@"ff6d00"]];
                        }
                        [self setLabels];
                        if (_theTimer) {
                            [_theTimer invalidate];
                            _theTimer = nil;
                        }
                        _theTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(spreeCountDown:) userInfo:nil repeats:YES];
                    }else{ // 这个情况基本不存在，走下面的else了
                        [_descriptionLabel setText:[Utilities getDateStringFromString:_csm.spreeTime WithAllFormatter:@"yyyy年MM月dd日 HH:mm开抢"]];
                        [Utilities drawView:_doneBtn radius:3 bordLineWidth:1 borderColor:[UIColor colorWithHexString:_csm.hasSetted?@"C8C8C8":@"ff6d00"]];
                    }
                }else if (_dayIndex == 1){
                    [_descriptionLabel setText:[Utilities getDateStringFromString:_csm.spreeTime WithAllFormatter:@"明天 HH:mm开抢"]];
                    [Utilities drawView:_doneBtn radius:3 bordLineWidth:1 borderColor:[UIColor colorWithHexString:_csm.hasSetted?@"C8C8C8":@"ff6d00"]];
                }else{
                    [_descriptionLabel setText:[Utilities getDateStringFromString:_csm.spreeTime WithAllFormatter:@"yyyy年MM月dd日 HH:mm开抢"]];
                    [Utilities drawView:_doneBtn radius:3 bordLineWidth:1 borderColor:[UIColor colorWithHexString:_csm.hasSetted?@"C8C8C8":@"ff6d00"]];
                }
            }
        }
    }
}

- (IBAction)bookAction:(id)sender{
    if (_timeInteval<=10) {
        [ServerService getClubSpreeListWithSpreeType:0 spreeId:_csm.spreeId pageNo:1 pageSize:1 longitude:[LoginManager sharedManager].currLongitude latitude:[LoginManager sharedManager].currLatitude success:^(NSArray *list) {
            _csm = [list firstObject];
            _csm.hasSetted = _hasSetted;
            if (_refreshBlock) {
                _refreshBlock (_csm);
                [self handleData];
            }
        } failure:^(id error) {
        }];
    }else{
        [self handleData];
    }
}

- (void)handleData{
    if (_csm.stockQuantity-_csm.soldQuantity<=0) {
        [[GolfAppDelegate shareAppDelegate].currentController pushWithStoryboard:@"BookTeetime" title:@"" identifier:@"ClubMainViewController" completion:^(BaseNavController *controller) {
            ClubMainViewController *vc = (ClubMainViewController*)controller;
            vc.cm = _cm;
            vc.clubId = _cm.clubId;
            vc.agentId = -1;
        }];
    }else{
        _timeInteval = [ClubRushTypesCell timeIntervalWithCompareResult:_csm.spreeTime timeInterGab:[LoginManager sharedManager].timeInterGab];
        if (_timeInteval / (24*3600) <= 0) {
            // 正在抢购(do nothing ...)
            [self booking];
        }else if (_timeInteval < 600){ // 小于10分钟
            // 即将抢购(do nothing ...)
        }else{
            _csm.hasSetted = !_csm.hasSetted;
            if (_csm.hasSetted) {
                [self addCallNum:_csm.spreeId];
                if (_callRefreshBlock) {
                    _callRefreshBlock (nil);
                }
                [self createLocalNotification:_csm];
            }else{
                [self deleteCallNum:_csm.spreeId];
                if (_callRefreshBlock) {
                    _callRefreshBlock (nil);
                }
                [self cancelLocalNotification:_csm];
            }
            if (_callRefreshBlock) {
                _callRefreshBlock (nil);
            }
        }
    }
}

#pragma mark - 本地通知相关
- (void)addCallNum:(int)spreeId{ // 增加设置提醒的个数
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSArray *array = [userDefault objectForKey:@"ClubCallSetting"];
    NSMutableArray *mutArray = nil;
    if (array && array.count > 0) {
        mutArray = [NSMutableArray arrayWithArray:array];
        [mutArray addObject:@(spreeId)];
    }else{
        mutArray = [NSMutableArray arrayWithObject:@(spreeId)];
    }
    [userDefault setObject:mutArray forKey:@"ClubCallSetting"];
    [SVProgressHUD showSuccessWithStatus:@"设置成功，开抢前10分钟会提醒您"];
}

- (void)deleteCallNum:(int)spreeId{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSArray *array = [userDefault objectForKey:@"ClubCallSetting"];
    
    if ([array containsObject:@(spreeId)]) {
        NSMutableArray *mt = [NSMutableArray arrayWithArray:array];
        [mt removeObject:@(spreeId)];
        [userDefault setObject:mt forKey:@"ClubCallSetting"];
    }
    [SVProgressHUD showInfoWithStatus:@"已取消提醒"];
}

- (void)createLocalNotification:(ClubSpreeModel*)csm{
    UILocalNotification *newNotification = [[UILocalNotification alloc] init];
    if (newNotification) {
        newNotification.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        newNotification.fireDate = [[Utilities getDateFromString:csm.spreeTime WithFormatter:@"yyyy-MM-dd HH:mm:ss"]dateByAddingTimeInterval:-600];
        newNotification.alertBody = @"您关注的球场即将开抢了，赶紧去抢购吧！";
        newNotification.applicationIconBadgeNumber += 1;
        newNotification.soundName = UILocalNotificationDefaultSoundName;
        newNotification.repeatInterval = 0;
        
        NSDictionary *infoDic = @{@"spree_id":@(csm.spreeId),@"club_id":@(_cm.clubId),@"call_type":@"club"};
        newNotification.userInfo = infoDic;
        
        UIApplication *app = [UIApplication sharedApplication];
        [app scheduleLocalNotification:newNotification];
    }
}

- (void)cancelLocalNotification:(ClubSpreeModel*)csm{
    NSArray *narry=[[UIApplication sharedApplication] scheduledLocalNotifications];
    if (narry.count > 0) {
        for (int i=0; i<narry.count; i++) {
            UILocalNotification *localNotification = [narry objectAtIndex:i];
            NSDictionary *userInfo = localNotification.userInfo;
            if (Equal(@"club", userInfo[@"call_type"])) {
                if ([userInfo[@"spree_id"] intValue] == csm.spreeId) {
                    UIApplication *app = [UIApplication sharedApplication];
                    [app cancelLocalNotification:localNotification];
                }
            }
        }
    }
}

- (void)booking{
    if (_csm.startTime.length>0 && _csm.endTime.length>0) {
        NSArray *arr = [_csm.startTime componentsSeparatedByString:@":"];
        int minute_start = [arr[0] intValue]*60 + ([arr[1] intValue]+29)/30*30;
        arr = [_csm.endTime componentsSeparatedByString:@":"];
        int minute_end = [arr[0] intValue]*60 + [arr[1] intValue];
        
        NSMutableArray *mt = [NSMutableArray array];
        for (int i=minute_start; i<=minute_end; i+=30) {
            TTModel *ttm = [[TTModel alloc] init];
            ttm.spreeId = _csm.spreeId;
            ttm.agentId = _csm.agentId;
            ttm.agentName = _csm.agentName;
            ttm.depositEachMan = _csm.prepayAmount;
            ttm.price = _csm.currentPrice;
            ttm.mans = _csm.stockQuantity-_csm.soldQuantity;
            ttm.payType = _csm.payType;
            ttm.priceContent = _csm.priceContent;
            ttm.description = _csm.description_;
            ttm.cancelNote = _csm.cancelNote;
            ttm.bookNote = @"";
            ttm.yunbi = _csm.giveYunbi;
            ttm.hasInvoice = _csm.hasInvoice;
            ttm.canBook = 1;
            ttm.minBuyQuantity = _csm.minBuyQuantity;
            ttm.teetime = [NSString stringWithFormat:@"%02d:%02d",i/60,i%60];
            ttm.date = _csm.teeDate;
            [mt addObject:ttm];
        }
        if (_bookBlock) {
            if (![LoginManager sharedManager].loginState) {
                [[LoginManager sharedManager] loginWithDelegate:nil controller:[GolfAppDelegate shareAppDelegate].currentController animate:YES blockRetrun:^(id data) {
                    _bookBlock (mt);
                }];
                return;
            }
            _bookBlock (mt);
        }
    }
}

- (void)spreeCountDown:(NSTimer*)timer{
    if (--_timeInteval < 0) {
        [timer invalidate];
        if (_refreshBlock) {
            _refreshBlock (nil);
        }
        return;
    }
    
    [self setLabels];
}

- (void)setLabels{
    NSDate *date = [[CalendarClass dateForToday] dateByAddingTimeInterval:_timeInteval];
    [_hourLabel setText:[Utilities getHourByDate:date]];
    [_minuteLabel setText:[Utilities getMinuteByDate:date]];
    [_secondLabel setText:[Utilities getSecodeByDate:date]];
}

@end
