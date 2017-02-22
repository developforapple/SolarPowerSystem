//
//  CourseSchoolDetailsViewController.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/15.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AcademyModel.h"

@interface CourseSchoolDetailsViewController : BaseNavController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic) int cityId;
@property (nonatomic) int academyId;
@property (nonatomic) AcademyModel *academyModel;//可以不传递

@end
