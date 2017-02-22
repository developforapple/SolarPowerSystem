//
//  YGWebBrowser.h
//  Golf
//
//  Created by bo wang on 2016/9/29.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

@class ActivityModel;
@class ConditionModel;


@interface YGWebBrowser : BaseNavController

- (void)loadURL:(NSURL *)url;

#pragma mark - Activity
@property (nonatomic, strong) ActivityModel *activityModel;
@property (nonatomic, strong) ConditionModel *myCondition;
@property (nonatomic,copy) NSString *activityPage;
@property (nonatomic,copy) NSString *activityCode;
@property (nonatomic) int activityId;

@end
