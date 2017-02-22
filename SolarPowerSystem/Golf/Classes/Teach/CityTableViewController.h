//
//  CityTableViewController.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/7.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    SupportCoachType, //针对开通教学的城市
    SupportPackageType, //针对开通旅游套餐的城市
} SupportType; //城市选择列表对应的业务逻辑

@interface CityTableViewController : BaseNavController<UITableViewDataSource,UITableViewDelegate>


@property(nonatomic, strong) NSString *cityName;
@property(nonatomic, copy) BlockReturn blockReturn;
@property(nonatomic, assign) SupportType supportType;

//加载服务器存储本地的开通教学服务的城市列表数据到数据源
+ (void)loadCitiesToArray:(NSMutableArray *)arr bySupportType:(SupportType)supportType success:(BlockReturn)success;

//检测当前用户所在地经纬度的城市是否涵盖在开通城市列表中
+ (SearchCityModel *)inCityListByCities:(NSMutableArray *)cities;

@end
