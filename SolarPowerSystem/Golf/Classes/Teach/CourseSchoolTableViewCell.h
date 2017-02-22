//
//  CourseSchoolTableViewCell.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/15.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourseSchoolTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgLogo;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelTeacherCount;
@property (weak, nonatomic) IBOutlet UILabel *labelLocation;

@property (strong, nonatomic) id data;

@end
