//
//  CoachTableViewController.h
//  Golf
//  教练列表
//  Created by 廖瀚卿 on 15/5/8.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoachTableViewController : BaseNavController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *datas;
@property (strong, nonatomic) SearchCityModel *selectedCityModel; //城市列表中选中的城市modal
@property (nonatomic) BOOL useControls;//是否显示空闲时间，推荐排序，搜索等功能
@property (nonatomic) int academyId;//学院id，可以不传递
@property (nonatomic) int productId;
@property (nonatomic) int sortCondition;

@property (copy,nonatomic) BlockReturn blockCancel;
@property (nonatomic,assign) BOOL hasSearchButton;
@property (nonatomic,assign) BOOL isSearchViewController;


@end
