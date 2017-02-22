//
//  MyTeachActionTableViewCell.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/20.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTeachActionTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIButton *btnYueTeacher;
@property (weak, nonatomic) IBOutlet UIButton *btnCourseTime;

@property (nonatomic,copy) BlockReturn blockCourseTimeReturn;
@property (nonatomic,copy) BlockReturn blockYueTeacher;

@end
