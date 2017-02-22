//
//  JXChooseTime.m
//  Golf
//
//  Created by 黄希望 on 15/5/6.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "JXChooseTime.h"
#import "RegexKitLite.h"

#define JXNORMALCOLOR_TOP [Utilities R:153 G:153 B:153]
#define JXNORMALCOLOR_BOT [Utilities R:102 G:102 B:102]
#define JXDISABLECOLOR [Utilities R:230 G:230 B:230]

static JXChooseTime *instance = nil;

@interface JXChooseTime ()

@property (nonatomic,weak) IBOutlet UILabel *lbs1;
@property (nonatomic,weak) IBOutlet UILabel *lbs2;
@property (nonatomic,weak) IBOutlet UILabel *lbs3;
@property (nonatomic,weak) IBOutlet UILabel *lbs4;
@property (nonatomic,weak) IBOutlet UILabel *lbs5;
@property (nonatomic,weak) IBOutlet UILabel *lbs6;
@property (nonatomic,weak) IBOutlet UILabel *lbs7;
@property (nonatomic,weak) IBOutlet UILabel *lb1;
@property (nonatomic,weak) IBOutlet UILabel *lb2;
@property (nonatomic,weak) IBOutlet UILabel *lb3;
@property (nonatomic,weak) IBOutlet UILabel *lb4;
@property (nonatomic,weak) IBOutlet UILabel *lb5;
@property (nonatomic,weak) IBOutlet UILabel *lb6;
@property (nonatomic,weak) IBOutlet UILabel *lb7;
@property (nonatomic,weak) IBOutlet UIView *bgView;
@property (nonatomic,weak) IBOutlet UILabel *lineLabel;
@property (nonatomic,weak) IBOutlet UIButton *unSelBtn;
@property (nonatomic,weak) IBOutlet UIButton *infoBtn;
@property (nonatomic,strong) IBOutletCollection(UIButton) NSArray *buttons;

@property (nonatomic,strong) UIButton *timeBtn;
@property (nonatomic,strong) UIControl *control;

@property (nonatomic,assign) BOOL animated;

@property (nonatomic,strong) NSDictionary *disTimeDic;
@property (nonatomic,strong) NSString *defaultDate;
@property (nonatomic,strong) NSString *selectedDate;
@property (nonatomic,strong) NSString *selectedTime;
@property (nonatomic,assign) int timeNum;
@property (nonatomic,assign) int maxNum;
@property (nonatomic,assign) TeachingCourseType classType;
@property (nonatomic,assign) BOOL lastSelected;
@property (nonatomic,copy) void(^completion)(NSString *date, NSString *time);
@property (nonatomic,copy) void(^showed)();
@property (nonatomic,copy) void(^hided)();
@property (nonatomic,copy) void(^cleanCompletion)();

@property (nonatomic,strong) NSMutableArray *dayArray;
@property (nonatomic,strong) NSMutableArray *weekArray;
@property (nonatomic,strong) NSArray *buttonArr;

@end

@implementation JXChooseTime

+ (void)jxWithDisableTime:(NSDictionary*)timeDic
                     date:(NSString*)date
                     time:(NSString*)time
                   maxNum:(int)maxNum
                classType:(TeachingCourseType)classType
                  supView:(UIView*)aView
                     posY:(CGFloat)posY
               completion:(void(^)(NSString *date, NSString *time))completion{
    if (instance) {
        if (instance.superview) {
            [instance removeFromSuperview];
        }
        instance = nil;
    }
    
    instance = [[[NSBundle mainBundle] loadNibNamed:@"JXChooseTM" owner:self options:nil] lastObject];
    instance.frame = CGRectMake(0, posY, Device_Width, 265);
    instance.bgView.frame = CGRectMake(0, 0, Device_Width, 265);
    [aView addSubview:instance];
    
    if (classType != TeachingCourseTypeGroup) {
        instance.infoBtn.hidden = YES;
    }
    
    instance.disTimeDic = timeDic;
    instance.defaultDate = date;
    instance.selectedTime = time;
    instance.maxNum = maxNum;
    instance.classType = classType;
    instance.completion = completion;
    [instance initizationSetting:1];
    [instance initData];
}

+ (void)jxAnimatedDate:(NSString *)date
                  time:(NSString *)time
               supView:(UIView *)aView
          belowSubview:(UIView *)siblingSubview
                  posY:(CGFloat)posY
            completion:(void (^)(NSString *, NSString *))completion
       cleanCompletion:(void (^)())cleanCompletion
                showed:(void (^)())showed
                 hided:(void (^)())hided{
    
    if (instance) {
        if (instance.superview) {
            [instance removeFromSuperview];
        }
        instance = nil;
    }
    
    instance = [[[NSBundle mainBundle] loadNibNamed:@"JXChooseTime" owner:self options:nil] lastObject];
    instance.frame = CGRectMake(0, posY, Device_Width, Device_Height);
    instance.bgView.frame = CGRectMake(0, -314, Device_Width, 314);
    [aView insertSubview:instance belowSubview:siblingSubview];
    
    
    instance.control = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, Device_Width, Device_Height)];
    instance.control.backgroundColor = [UIColor colorWithHexString:@"#333333"];
    instance.control.alpha = 0.5;
    
    [instance insertSubview:instance.control atIndex:0];
    [instance.control addTarget:instance action:@selector(hideView:) forControlEvents:UIControlEventTouchUpInside];
    
    instance.animated = YES;
    instance.defaultDate = date;
    instance.selectedTime = time;
    instance.completion = completion;
    instance.cleanCompletion = cleanCompletion;
    instance.showed = showed;
    instance.hided = hided;
    [instance initizationSetting:1];
    [instance initData];
    
    UIToolbar *tb = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, Device_Width, instance.bgView.height)];
    [instance.bgView insertSubview:tb atIndex:0];
    [UIView animateWithDuration:0.2 animations:^{
        instance.bgView.frame = CGRectMake(0, 0, Device_Width, 314);
        instance.control.frame = CGRectMake(0, instance.bgView.height - 10, Device_Width, Device_Height);
    } completion:^(BOOL finished) {
        if (instance.showed) {
            instance.showed();
        }
    }];
}


- (UIColor*)btnTitleColor:(NSInteger)status{
    // status 0,未选中 1,选中 3，禁选
    if (status == 0) {
        return self.animated ? JXNORMALCOLOR_BOT : MainHighlightColor;
    }else if (status == 1){
        return self.animated ? MainHighlightColor : [UIColor colorWithHexString:@"#E6E6E6"];
    }else {
        return [UIColor colorWithHexString:@"#E6E6E6"];
    }
}

- (UIColor*)btnBgColor:(NSInteger)status{
    // status 0,未选中 1,选中 3，禁选
    if (status == 0) {
        return [UIColor whiteColor];
    }else if (status == 1){
        return MainHighlightColor;
    }else {
        return [Utilities R:200 G:200 B:200];
    }
}

- (void)initData{
    self.dayArray = [NSMutableArray array];
    self.weekArray = [NSMutableArray array];
    
    self.buttonArr = [_buttons sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        UIButton *btn1 = (UIButton*)obj1;
        UIButton *btn2 = (UIButton*)obj2;
        NSComparisonResult result = [@(btn1.tag) compare:@(btn2.tag)];
        if (result == NSOrderedDescending) {
            return 1;
        }else if (result == NSOrderedAscending){
            return -1;
        }
        return 0;
    }];
    
    if (self.animated) {
        self.timeNum = [[Utilities getCurrentTimeWithFormatter:@"HH"] intValue];
    }
    
    int selectedDayIndex = -1;
    for (int i=0; i<7; i++) {
        NSDate *date = [Utilities getTheDay:[NSDate date] withNumberOfDays:i];
        
        if (self.defaultDate && selectedDayIndex == -1) {
            NSString *d = [Utilities stringwithDate:date];
            if (Equal(self.defaultDate, d)) {
                self.selectedDate = self.defaultDate;
                selectedDayIndex = i;
            }
        }
        
        NSString *dateStr = [Utilities getDay1ByDate:date];
        NSString *week = [Utilities getWeekDayByDate:date];
        if (dateStr) {
            if (Equal(dateStr, @"1")) {
                week = [[Utilities getMonth1ByDate:date] stringByAppendingString:@"月"];
            }
            if (i==0) {
                [self.dayArray addObject:@"今天"];
            }else{
                [self.dayArray addObject:dateStr];
            }
            [self.weekArray addObject:week];
        }
    }
    
    [self setUnSelBtnStatus:self.selectedTime.length > 0 ? YES : NO];
    
    self.lb1.text = self.dayArray[0]; self.lbs1.text = self.weekArray[0];
    self.lb2.text = self.dayArray[1]; self.lbs2.text = self.weekArray[1];
    self.lb3.text = self.dayArray[2]; self.lbs3.text = self.weekArray[2];
    self.lb4.text = self.dayArray[3]; self.lbs4.text = self.weekArray[3];
    self.lb5.text = self.dayArray[4]; self.lbs5.text = self.weekArray[4];
    self.lb6.text = self.dayArray[5]; self.lbs6.text = self.weekArray[5];
    self.lb7.text = self.dayArray[6]; self.lbs7.text = self.weekArray[6];
    
    if (selectedDayIndex > -1) {
        [self setLabelColor:selectedDayIndex+1];
        [self setlineMoveWithCenterX:[self lineX:selectedDayIndex]];
    }else if (self.selectedDate == nil){
        self.selectedDate = [Utilities getCurrentTimeWithFormatter:@"yyyy-MM-dd"];
    }
    
    [self initizationSetting:2];
}

- (void)createTuanKeBtnWithNum:(int)num forBtn:(UIButton*)btn{
    if (_classType != TeachingCourseTypeGroup) {
        return;
    }
    
    for (UIView *view in btn.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *b = (UIButton*)view;
            if (num<0) {
                [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
                [b removeFromSuperview];
            }
            return;
        }
    }
    
    if (num<0) {
        return;
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.userInteractionEnabled = NO;
    button.backgroundColor = [UIColor whiteColor];
    if (btn.enabled) {
        [button setImage:[UIImage imageNamed:@"ic_tuan_blue"] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHexString:@"99d9f2"] forState:UIControlStateNormal];
        [Utilities drawView:button radius:1 bordLineWidth:0.5 borderColor:[UIColor colorWithHexString:@"99d9f2"]];
    }else{
        [button setImage:[UIImage imageNamed:@"ic_tuan_gray"] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHexString:@"c8c8c8"] forState:UIControlStateNormal];
        [Utilities drawView:button radius:1 bordLineWidth:0.5 borderColor:[UIColor colorWithHexString:@"a6a6a6"]];
    }
    NSString *title = [NSString stringWithFormat:@" %d/%d人 ",num,_maxNum];
    CGSize sz = [Utilities getSize:title withFont:[UIFont systemFontOfSize:9] withWidth:100];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:9];
    button.frame = CGRectMake((btn.width-sz.width-13)/2., 28, 13+sz.width, 13);
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 16, 0)];
    [btn addSubview:button];
}

- (void)initizationSetting:(int)type{
    UIColor *textNorColor = [self btnTitleColor:0];
    UIColor *textSelColor = [self btnTitleColor:1];
    
    UIColor *bgNorColor = [self btnBgColor:0];
    UIColor *bgSelColor = [self btnBgColor:1];
    
    if (instance) {
        
        if (type == 1) {
            [self.unSelBtn setTitleColor:[Utilities R:200 G:200 B:200] forState:UIControlStateNormal];
            [self.unSelBtn setTitleColor:MainHighlightColor forState:UIControlStateSelected];
        }
        
        NSArray *timeList = self.disTimeDic ? self.disTimeDic[self.selectedDate] : nil;
        NSString *today = [Utilities getCurrentTimeWithFormatter:@"yyyy-MM-dd"];
        
        int i=0;
        for (UIView *view in self.buttonArr) {
            UIButton *btn = (UIButton*)view;
            if (type == 1) { // 设置按钮的选中颜色
                [btn setTitleColor:textNorColor forState:UIControlStateNormal];
                [btn setTitleColor:textSelColor forState:UIControlStateSelected];
            }else if (type == 2){ // 清楚所有选中(保留原来选中)
                [btn setTitleColor:textNorColor forState:UIControlStateNormal];
                [btn setTitleColor:textSelColor forState:UIControlStateSelected];
                if (self.animated) {
                    btn.enabled = YES;
                    if (Equal(self.selectedTime, btn.titleLabel.text)&&Equal(self.selectedDate, self.defaultDate)) {
                        btn.selected = YES;
                    }else{
                        btn.selected = NO;
                    }
                    
                    // 如果为今天，禁掉已过的时间
                    if (Equal(self.selectedDate, today)) {
                        int n = [[btn.titleLabel.text substringToIndex:btn.titleLabel.text.length-3] intValue];
                        if (self.timeNum >= n) {
                            btn.selected = NO;
                            btn.enabled = NO;
                            [btn setTitleColor:JXDISABLECOLOR forState:UIControlStateNormal];
                        }
                    }
                }else{
                    UIColor *bgDisColor = [self btnBgColor:2];
                    UIColor *textDisColor = [self btnTitleColor:2];
                    if (timeList.count > 0) {
                        int value = [timeList[i] intValue];
                        if (value<0) {//被禁用
                            btn.enabled = NO;
                            [btn setTitleColor:textDisColor forState:UIControlStateNormal];
                            btn.backgroundColor = bgDisColor;
                        }else{
                            btn.enabled = YES;
                            if (Equal(self.selectedTime, btn.titleLabel.text)&&Equal(self.selectedDate, self.defaultDate)) {
                                btn.selected = self.lastSelected ? YES : NO;
                                btn.backgroundColor = self.lastSelected ? bgSelColor : bgNorColor;
                            }else{
                                btn.selected = NO;
                                btn.backgroundColor = bgNorColor;
                            }
                        }
                        [self createTuanKeBtnWithNum:value forBtn:btn];
                        i++;
                    }else {
                        btn.enabled = NO;
                        [btn setTitleColor:textDisColor forState:UIControlStateNormal];
                        btn.backgroundColor = bgDisColor;
                    }
                }
            }
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self.bgView];
    int index = -1;
    if (CGRectContainsPoint(self.lb1.superview.frame, pt)) {
        index = 0;
    }else if (CGRectContainsPoint(self.lb2.superview.frame, pt)){
        index = 1;
    }else if (CGRectContainsPoint(self.lb3.superview.frame, pt)){
        index = 2;
    }else if (CGRectContainsPoint(self.lb4.superview.frame, pt)){
        index = 3;
    }else if (CGRectContainsPoint(self.lb5.superview.frame, pt)){
        index = 4;
    }else if (CGRectContainsPoint(self.lb6.superview.frame, pt)){
        index = 5;
    }else if (CGRectContainsPoint(self.lb7.superview.frame, pt)){
        index = 6;
    }
    
    if (index > -1) {
        self.selectedDate = [Utilities stringwithDate:[Utilities getTheDay:[NSDate date] withNumberOfDays:index]];
        
        [self setLabelColor:index+1];
        [self setlineMoveWithCenterX:[self lineX:index]];
        [self initizationSetting:2];

        if (self.selectedTime) {
            [self setUnSelBtnStatus:YES];
        }else{
            [self setUnSelBtnStatus:NO];
        }
    }
}

- (void)setUnSelBtnStatus:(BOOL)selected{
    if (self.animated) {
        if (selected) {
            self.unSelBtn.userInteractionEnabled = YES;
            self.unSelBtn.selected = YES;
            [Utilities drawView:self.unSelBtn radius:3 borderColor:MainHighlightColor];
        }else{
            self.unSelBtn.userInteractionEnabled = NO;
            self.unSelBtn.selected = NO;
            [Utilities drawView:self.unSelBtn radius:3 borderColor:[Utilities R:210 G:210 B:210]];
        }
    }
}

- (CGFloat)lineX:(NSInteger)index{
    if (index == 0) {
        return self.lb1.superview.center.x;
    }else if (index == 1){
        return self.lb2.superview.center.x;
    }else if (index == 2){
        return self.lb3.superview.center.x;
    }else if (index == 3){
        return self.lb4.superview.center.x;
    }else if (index == 4){
        return self.lb5.superview.center.x;
    }else if (index == 5){
        return self.lb6.superview.center.x;
    }else if (index == 6){
        return self.lb7.superview.center.x;
    }else{
        return self.lb1.superview.center.x;
    }
}

- (void)setlineMoveWithCenterX:(CGFloat)x{
    [UIView animateWithDuration:0.3 animations:^{
        [self.lineLabel setCenter:CGPointMake(x, 59)];
    }];
}

- (void)setLabelColor:(int)index{
    self.lb1.textColor = JXNORMALCOLOR_BOT;
    self.lb2.textColor = JXNORMALCOLOR_BOT;
    self.lb3.textColor = JXNORMALCOLOR_BOT;
    self.lb4.textColor = JXNORMALCOLOR_BOT;
    self.lb5.textColor = JXNORMALCOLOR_BOT;
    self.lb6.textColor = JXNORMALCOLOR_BOT;
    self.lb7.textColor = JXNORMALCOLOR_BOT;
    self.lbs1.textColor = JXNORMALCOLOR_TOP;
    self.lbs2.textColor = JXNORMALCOLOR_TOP;
    self.lbs3.textColor = JXNORMALCOLOR_TOP;
    self.lbs4.textColor = JXNORMALCOLOR_TOP;
    self.lbs5.textColor = JXNORMALCOLOR_TOP;
    self.lbs6.textColor = JXNORMALCOLOR_TOP;
    self.lbs7.textColor = JXNORMALCOLOR_TOP;
    
    if (index == 1) {
        self.lb1.textColor = MainHighlightColor;
        self.lbs1.textColor = MainHighlightColor;
    }else if (index == 2){
        self.lb2.textColor = MainHighlightColor;
        self.lbs2.textColor = MainHighlightColor;
    }else if (index == 3){
        self.lb3.textColor = MainHighlightColor;
        self.lbs3.textColor = MainHighlightColor;
    }else if (index == 4){
        self.lb4.textColor = MainHighlightColor;
        self.lbs4.textColor = MainHighlightColor;
    }else if (index == 5){
        self.lb5.textColor = MainHighlightColor;
        self.lbs5.textColor = MainHighlightColor;
    }else if (index == 6){
        self.lb6.textColor = MainHighlightColor;
        self.lbs6.textColor = MainHighlightColor;
    }else if (index == 7){
        self.lb7.textColor = MainHighlightColor;
        self.lbs7.textColor = MainHighlightColor;
    }
}

- (IBAction)timeBtnAction:(UIButton*)sender{
    self.timeBtn = sender;
    
    self.defaultDate = self.selectedDate;
    self.selectedTime = sender.titleLabel.text;
    self.lastSelected = sender.selected;
    
    [self initizationSetting:2];
    
    if (!self.animated) {
        sender.selected = !sender.selected;
        sender.backgroundColor = [self btnBgColor:sender.selected?1:0];// 选中
        if (!sender.selected) {
            self.defaultDate = nil;
            self.selectedTime = nil;
        }
        self.lastSelected = sender.selected;
        self.completion(self.defaultDate,self.selectedTime);
    }else{
        if (!self.defaultDate && self.animated) {
            self.defaultDate = [Utilities stringwithDate:[NSDate date]];
        }
        
        self.completion(self.defaultDate,self.selectedTime);
        [self hideView:nil];
    }
}

- (IBAction)unSelectedAction:(id)sender{
    self.selectedTime = nil;
    [self setUnSelBtnStatus:NO];
    [self initizationSetting:2];
    if (instance.cleanCompletion) {
        instance.cleanCompletion();
    }
}

- (void)hideView:(UIControl*)control{
    [UIView animateWithDuration:0.2 animations:^{
        instance.bgView.frame = CGRectMake(0, -314, Device_Width, 314);
        instance.control.frame = CGRectMake(0, 0, Device_Width, Device_Height);
        if (instance.hided) {
            instance.hided();
        }
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.07 animations:^{
            instance.alpha = 0.;
        } completion:^(BOOL finished) {
            [instance removeFromSuperview];
            instance = nil;
        }];
    }];
}

+ (void)hide{
    if (instance) {
        if (instance.superview) {
            [instance hideView:nil];
        }
    }
}

+ (void)hideAnimate:(BOOL)animate{
    if (instance) {
        if (instance.superview) {
            if (animate) {
                [instance hideView:nil];
            }else{
                [instance removeFromSuperview];
                if (instance.hided) {
                    instance.hided();
                }
                instance = nil;
            }
        }
    }
}

+ (void)deSelected{
    if (instance.timeBtn.selected) {
        [instance timeBtnAction:instance.timeBtn];
    }
}

@end
