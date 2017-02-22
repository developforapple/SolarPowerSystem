//
//  SpecialOfferListViewController.h
//  Golf
//
//  Created by user on 13-1-10.
//  Copyright (c) 2013年 大展. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseNavController.h"
//#import "SpecialOfferTableViewCell.h"
#import "SearchService.h"
#import "ConditionModel.h"
#import "SelectedCitysController.h"
#import "WeekChooseView.h"
#import "ServiceManager.h"

@interface SpecialOfferListViewController : BaseNavController<UITableViewDelegate,UITableViewDataSource,WeekChooseViewDelegate,ServiceManagerDelegate>{
    ConditionModel *_myCondition;
    NSInteger _weekDay;
    NSInteger lastTime;
    NSString *_cityName;
    
    NSMutableArray *_dateArray;
    UITableView *_tableView;
    WeekChooseView *_weekChooseView;
    
    NSArray *_specialOfferList;
    NSArray *_packageList;
    
    UILabel *_noneLabel;
    
    BOOL _refreshing;
    BOOL _isSpecialOffer;
}

@property (nonatomic,strong) ConditionModel *myCondition;

@end
