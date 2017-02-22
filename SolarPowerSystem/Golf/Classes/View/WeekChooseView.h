//
//  WeekChooseView.h
//  Golf
//
//  Created by user on 13-6-18.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WeekChooseViewDelegate <NSObject>

- (void)weekChooseViewDelegateWithIndex:(NSInteger)index;

@end

@interface WeekChooseView : UIView

@property (nonatomic,strong) IBOutlet UIButton *mondayBtn;
@property (nonatomic,strong) IBOutlet UIButton *tuesdayBtn;
@property (nonatomic,strong) IBOutlet UIButton *wednesdayBtn;
@property (nonatomic,strong) IBOutlet UIButton *thursdayBtn;
@property (nonatomic,strong) IBOutlet UIButton *fridayBtn;
@property (nonatomic,strong) IBOutlet UIButton *saturdayBtn;
@property (nonatomic,strong) IBOutlet UIButton *sundayBtn;

@property (nonatomic,strong) IBOutlet UIImageView *scrollView;
@property (nonatomic,weak) id<WeekChooseViewDelegate> delegate;
@property (nonatomic) NSInteger weekIndex;

@property (weak, nonatomic) IBOutlet UILabel *lableToday;
@property (weak, nonatomic) IBOutlet UILabel *lableYesteday;
@property (weak, nonatomic) IBOutlet UILabel *lableThirdDay;
@property (weak, nonatomic) IBOutlet UILabel *lableFourthDay;
@property (weak, nonatomic) IBOutlet UILabel *lableFifthDay;
@property (weak, nonatomic) IBOutlet UILabel *lableSixthDay;
@property (weak, nonatomic) IBOutlet UILabel *lableSeventhDay;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewConstraint;
- (IBAction)pressWeekBtn:(id)sender;

- (void)setWeekWithIndex:(NSInteger)index;



@end
