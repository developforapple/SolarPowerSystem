//
//  SudokuTableViewCell.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/6.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ActivityModel;

@interface SudokuTableViewCell : UITableViewCell
@property (copy, nonatomic) BlockReturn blockReturn;
@property (nonatomic,strong) IBOutlet UIView *bottomLine;


@property (strong, nonatomic) ActivityModel *activityModel1;
@property (strong, nonatomic) ActivityModel *activityModel2;
@property (copy, nonatomic) BlockReturn blockReturn1;
@property (copy, nonatomic) BlockReturn blockReturn2;
@property (strong, nonatomic) NSArray *datas;

- (void)loadDatas:(NSArray *)datas;
@end
