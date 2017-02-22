//
//  YGDatePickerViewCtrl.m
//  Golf
//
//  Created by bo wang on 2016/12/20.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGDatePickerViewCtrl.h"
#import "YGDatePickerCell.h"

@interface YGDatePickerViewCtrl () <UICollectionViewDelegate,UICollectionViewDataSource>
{
    BOOL _futureDatesSelectable_isset;
    BOOL _previousDatesSelectable_isset;
}
@property (weak, nonatomic) IBOutlet UIView *backBlurView;
@property (weak, nonatomic) IBOutlet UIView *datePicker;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

@property (weak, nonatomic) IBOutlet UILabel *yearMonthLabel;
@property (weak, nonatomic) IBOutlet UIButton *lastMonthBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextMonthBtn;

@property (strong, nonatomic) NSDateComponents *dateCompontents;        //当前选择的日期
@property (strong, nonatomic) NSDateComponents *curMonthCompontents;    //当前显示的月份的第一天的日期
@property (strong, nonatomic) NSDateComponents *nowCompontents;         //今天的日期

@property (assign, nonatomic) NSInteger selectableStartDateCompareNumber;
@property (assign, nonatomic) NSInteger selectableEndDateCompareNumber;

@property (assign, nonatomic) NSInteger firstDayIndex;
@property (assign, nonatomic) NSInteger numberOfDays;

@end

@implementation YGDatePickerViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!_futureDatesSelectable_isset) {
        self.futureDatesSelectable = NO;
    }
    if (!_previousDatesSelectable_isset) {
        self.previousDatesSelectable = YES;
    }
    
    [self initUI];
    [self setupCurDateCompontents];
    [self setupFirstDayWithYear:self.dateCompontents.year month:self.dateCompontents.month];
    [self update];
}

- (void)initUI
{
    [self.view layoutIfNeeded];
    self.datePicker.transform = CGAffineTransformMakeTranslation(0.f, CGRectGetHeight(self.datePicker.bounds));
    CGFloat w = (Device_Width-self.flowLayout.sectionInset.left-self.flowLayout.sectionInset.right-6*self.flowLayout.minimumInteritemSpacing) / 7.f;
    w = floor(w);
    self.flowLayout.itemSize = CGSizeMake(w, 40.f);
    
    ygweakify(self);
    [self.collectionView whenSwipDirection:UISwipeGestureRecognizerDirectionLeft block:^(UISwipeGestureRecognizer *swipe) {
        ygstrongify(self);
        [self gotoNextMonth];
    }];
    [self.collectionView whenSwipDirection:UISwipeGestureRecognizerDirectionRight block:^(UIGestureRecognizer *gr) {
        ygstrongify(self);
        [self gotoLastMonth];
    }];
}

- (void)setFutureDatesSelectable:(BOOL)futureDatesSelectable
{
    _futureDatesSelectable = futureDatesSelectable;
    _futureDatesSelectable_isset = YES;
}

- (void)setPreviousDatesSelectable:(BOOL)previousDatesSelectable
{
    _previousDatesSelectable = previousDatesSelectable;
    _previousDatesSelectable_isset = YES;
}

- (void)setupCurDateCompontents
{
    NSDate *date = self.date?:[NSDate date];
    self.dateCompontents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    self.nowCompontents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
}

- (void)setSelectableStartDate:(NSDate *)selectableStartDate
{
    _selectableStartDate = selectableStartDate;
    
    NSDateComponents *compontents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:selectableStartDate];
    self.selectableStartDateCompareNumber = [self dateCompareNumber:compontents];
    if (selectableStartDate && !self.selectableEndDate) {
        self.selectableEndDate = [NSDate distantFuture];
    }
}

- (void)setSelectableEndDate:(NSDate *)selectableEndDate
{
    _selectableEndDate = selectableEndDate;
    NSDateComponents *compontents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:selectableEndDate];
    self.selectableEndDateCompareNumber = [self dateCompareNumber:compontents];
    if (selectableEndDate && !self.selectableStartDate) {
        self.selectableStartDate = [NSDate distantPast];
    }
}

- (void)setupFirstDayWithYear:(NSInteger)year month:(NSInteger)month
{
    NSDateComponents *firstDay = [NSDateComponents new];
    firstDay.year = year;
    firstDay.month = month;
    firstDay.day = 1;
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:firstDay];
    firstDay = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday fromDate:date];
    self.firstDayIndex = firstDay.weekday-1;
    self.curMonthCompontents = firstDay;
    NSRange range = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    self.numberOfDays = range.length;
}

- (void)update
{
    self.yearMonthLabel.text = [NSString stringWithFormat:@"%ld年%02ld月",(long)self.curMonthCompontents.year,(long)self.curMonthCompontents.month];
    [self.collectionView reloadData];
}

- (void)gotoLastMonth
{
    NSInteger year = self.curMonthCompontents.year;
    NSInteger month = self.curMonthCompontents.month;
    month--;
    if (month <= 0) {
        month = 12;
        year--;
    }
    
    [self setupFirstDayWithYear:year month:month];      
    [self update];
}

- (void)gotoNextMonth
{
    NSInteger year = self.curMonthCompontents.year;
    NSInteger month = self.curMonthCompontents.month;
    month++;
    if (month > 12) {
        month = 1;
        year++;
    }
    [self setupFirstDayWithYear:year month:month];
    [self update];
}

- (void)cancel
{
    if ([self.delegate respondsToSelector:@selector(datePickerDidCanceled:)]) {
        [self.delegate datePickerDidCanceled:self];
    }
    [self dismiss];
}

- (NSInteger)dateCompareNumber:(NSDateComponents *)compontents
{
    return compontents.year * 10000 + compontents.month * 100 + compontents.day;
}

- (BOOL)shouleSelectedItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger day = indexPath.item - self.firstDayIndex + 1;
    self.curMonthCompontents.day = day;
    
    BOOL selectable = YES;
    if (day > 0 && day <= self.numberOfDays) {
        NSInteger cellDateNumber = [self dateCompareNumber:self.curMonthCompontents];
        NSInteger nowNumber = [self dateCompareNumber:self.nowCompontents];
        
        if (self.selectableStartDate && self.selectableEndDate) {
            if (cellDateNumber < self.selectableStartDateCompareNumber ||
                cellDateNumber >= self.selectableEndDateCompareNumber) {
                selectable = NO;
            }
        }else{
            if (!self.futureDatesSelectable && cellDateNumber > nowNumber) {
                selectable = NO;
            }else if (!self.previousDatesSelectable && cellDateNumber < nowNumber){
                selectable = NO;
            }
        }
    }else{
        selectable = NO;
    }
    return selectable;
}

#pragma mark - Actions
- (IBAction)cancelAction:(id)sender
{
    [self cancel];
}

- (IBAction)lastMonthAction:(id)sender
{
    [self gotoLastMonth];
}

- (IBAction)nextMonthAction:(id)sender
{
    [self gotoNextMonth];
}

#pragma mark - Disappear
- (void)show
{
    [super show];
    [UIView animateWithDuration:.3f animations:^{
        self.datePicker.transform = CGAffineTransformIdentity;
    }];
}

- (void)dismiss
{
    [UIView animateWithDuration:.3f animations:^{
        self.datePicker.transform = CGAffineTransformMakeTranslation(0.f, CGRectGetHeight(self.datePicker.bounds));;
    } completion:^(BOOL finished) {
        [super dismiss];
    }];
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 42.f;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YGDatePickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kYGDatePickerCell forIndexPath:indexPath];
    NSInteger day = indexPath.item - self.firstDayIndex + 1;
    self.curMonthCompontents.day = day;

    if (day <= 0 || day > self.numberOfDays) {
        cell.dateLabel.text = @"";
        cell.selected = NO;
    }else{

        NSInteger curDateNumber = self.date?[self dateCompareNumber:self.dateCompontents]:-1;
        NSInteger cellDateNumber = [self dateCompareNumber:self.curMonthCompontents];
        NSInteger nowNumber = [self dateCompareNumber:self.nowCompontents];
        BOOL isSelected = curDateNumber == cellDateNumber;
        BOOL isToday = cellDateNumber == nowNumber;
        
        cell.dateLabel.text = isToday?@"今天":[@(day) stringValue];
        cell.selected = isSelected;
        if (isSelected) {
            cell.dateLabel.textColor = [UIColor whiteColor];
        }else if (self.selectableStartDate && self.selectableEndDate){
            BOOL selectable = cellDateNumber >= self.selectableStartDateCompareNumber && cellDateNumber < self.selectableEndDateCompareNumber;
            if (selectable) {
                cell.dateLabel.textColor = [UIColor blackColor];
            }else{
                cell.dateLabel.textColor = [UIColor lightGrayColor];
            }
        }else{
            BOOL isFuture = cellDateNumber > nowNumber;
            BOOL isPrevious = cellDateNumber < nowNumber;
            if(isFuture && !self.futureDatesSelectable){
                cell.dateLabel.textColor = [UIColor lightGrayColor];
            }else if(isPrevious && !self.previousDatesSelectable){
                cell.dateLabel.textColor = [UIColor lightGrayColor];
            }else{
                cell.dateLabel.textColor = [UIColor blackColor];
            }
        }
    }
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self shouleSelectedItemAtIndexPath:indexPath];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self shouleSelectedItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger day = indexPath.item - self.firstDayIndex + 1;
    NSDateComponents *compontents = [NSDateComponents new];
    compontents.year = self.curMonthCompontents.year;
    compontents.month = self.curMonthCompontents.month;
    compontents.day = day;
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:compontents];
    self.date = date;
    [self setupCurDateCompontents];
    [self update];
    if ([self.delegate respondsToSelector:@selector(datePicker:didSelectedDate:)]) {
        [self.delegate datePicker:self didSelectedDate:date];
    }
}

@end

