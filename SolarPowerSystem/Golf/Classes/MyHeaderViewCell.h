//
//  MyHeaderViewCell.h
//  test2
//
//  Created by 廖瀚卿 on 15/6/2.
//  Copyright (c) 2015年 额度. All rights reserved.
//

#import "MDSpreadViewCell.h"
#import "CoachTimetable.h"
#import "MyButton.h"

@interface MyHeaderViewCell : MDSpreadViewCell

@property (nonatomic,strong) UILabel *labelWeek;
@property (nonatomic,strong) UILabel *labelDay;
@property (nonatomic,strong) UILabel *labelCount;
@property (nonatomic,strong) MyButton *btnAction;
@property (nonatomic,strong) CoachTimetable *data;
@property (nonatomic,copy) BlockReturn blockReturn;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
