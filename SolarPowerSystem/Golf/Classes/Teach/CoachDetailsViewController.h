//
//  CoachDetailsViewController.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/12.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TeachingCoachModel.h"


@interface CoachDetailsViewController : BaseNavController<UITableViewDataSource,UITableViewDelegate>


@property (nonatomic) int coachId;

@end
