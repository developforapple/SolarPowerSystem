//
//  MyStrViewCell.h
//  test2
//
//  Created by 廖瀚卿 on 15/6/3.
//  Copyright (c) 2015年 额度. All rights reserved.
//

#import "MDSpreadViewCell.h"

typedef NS_ENUM(NSInteger, CourseType) {
    CourseTypeGroup = 0,
    CourseTypePublic
};


@interface MyStrViewCell : MDSpreadViewCell

@property (nonatomic) CourseType courseType;
@property (nonatomic,strong) UILabel *labelCount;


- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
