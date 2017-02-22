//
//  SelectedCitysController.h
//  Golf
//
//  Created by 黄希望 on 15/10/16.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

@interface SelectedCitysController : BaseNavController

// 热门城市
@property (nonatomic,strong) NSArray *hotCityArr;
@property (nonatomic,strong) ConditionModel *cm;

// 选择城市(返回)
@property (nonatomic,copy) BlockReturn chooseBlock;

+ (NSArray *)getLocalProvinceOrCity:(int)flag; //flag 0省份数据   1城市数据

+ (void)getProvinceListSuccess:(void (^)(NSArray *list))success;//从服务器加载省份数据
+ (void)getCityListSuccess:(void (^)(NSArray *list))success;//从服务器加载城市数据到本地
@end
