//
//  CityTableViewController.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/7.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CityTableViewController.h"
#import "UnOpenTableViewCell.h"
#import "SearchService.h"

@interface CityTableViewController ()

@property(nonatomic,weak) IBOutlet UITableView *tableView;
@property(nonatomic,weak) IBOutlet UIActivityIndicatorView *loadingView;

@end

@implementation CityTableViewController{
    NSMutableArray *arrCities;
    SearchCityModel *scm; //当前地理所在城市包含在列表中的那个城市modal
    UITableViewCell *_tempCell;
    NSArray *arrHeaderTitles;
    
}




#pragma mark - 视图控制
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self leftNavButtonImg:@"f_close"];
    
    ygweakify(self)
    arrCities = [NSMutableArray new];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [CityTableViewController loadCitiesToArray:arrCities bySupportType:self.supportType success:^(id data) {
            ygstrongify(self)
            arrHeaderTitles = @[@"我的位置",@"已开通服务城市"];
            scm = [CityTableViewController inCityListByCities:arrCities];
            [self.tableView reloadData];
            self.tableView.hidden = NO;
            self.loadingView.hidden = YES;
        }];
    });
}

-(void)doLeftNavAction{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 业务逻辑方法
//加载服务器存储本地的开通教学服务的城市列表数据到数据源
+ (void)loadCitiesToArray:(NSMutableArray *)arr bySupportType:(SupportType)supportType success:(BlockReturn)success{
    [SearchService getCityList:1 success:^(NSArray *list) {
        switch (supportType) {
            case SupportCoachType:
                for (SearchCityModel *obj in list) {
                    if (obj.supportCoach == 1) {
                        [arr addObject:obj];
                    }
                }
                break;
            case SupportPackageType:
                for (SearchCityModel *obj in list) {
                    if (obj.supportPackage == 1) {
                        [arr addObject:obj];
                    }
                }
                break;
            default:
                break;
        }
        
        if (success) {
            success(nil);
        }
    } failure:^(id error) {
        
    }];
}

//- (void)loadCities{
//    if (arrCities == nil) {
//        arrCities = [[NSMutableArray alloc] init];
//    }
//    ygweakify(self)
//    [SearchService getCityList:1 success:^(NSArray *list) {
//        ygstrongify(self)
//        switch (self.supportType) {
//            case SupportCoachType:
//                for (SearchCityModel *obj in list) {
//                    if (obj.supportCoach == 1) {
//                        [arrCities addObject:obj];
//                    }
//                }
//                break;
//            case SupportPackageType:
//                for (SearchCityModel *obj in list) {
//                    if (obj.supportPackage == 1) {
//                        [arrCities addObject:obj];
//                    }
//                }
//                break;
//            default:
//                break;
//        }
//        
//        arrHeaderTitles = @[@"我的位置",@"已开通服务城市"];
//        scm = [CityTableViewController inCityListByCities:arrCities];
//        [self.tableView reloadData];
//        self.tableView.hidden = NO;
//        self.loadingView.hidden = YES;
//    } failure:^(id error) {
//        
//    }];
//}


//检测当前用户所在地经纬度的城市是否涵盖在开通城市列表中
+ (SearchCityModel *)inCityListByCities:(NSMutableArray *)cities{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (SearchCityModel *m in cities) {
        if ([LoginManager sharedManager].currLatitude > 0 && [LoginManager sharedManager].currLongitude > 0 && m.longitude > 0 && m.latitude > 0) {
            
            NSCoor c1 = NSCoorMake([LoginManager sharedManager].currLatitude, [LoginManager sharedManager].currLongitude);
            NSCoor c2 = NSCoorMake(m.latitude, m.longitude);
            double distance = distanceBetween(c1, c2)/1000.f;
            if (distance <= 150) {
                [arr addObject:@{[NSString stringWithFormat:@"%f",distance]:m}];
            }
        }
    }
    if (arr.count >= 1) {
        [arr sortUsingComparator:^NSComparisonResult(NSDictionary *obj1,NSDictionary *obj2) {
            return [[[obj1 allKeys] firstObject] compare:[[obj2 allKeys] firstObject]];
        }];
        return [[[arr lastObject] allValues] firstObject];
    }
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if ([cell.textLabel.text isEqualToString:@"城市定位失败"]) {
                [[GolfAppDelegate shareAppDelegate] startUpdateLocation];
                return;
            }
            if (scm) {
                if(_blockReturn){
                    if (_tempCell != nil) {
                        _tempCell.accessoryType = UITableViewCellAccessoryNone;
                    }
                    _blockReturn(scm);
                }
            }else{
                [SVProgressHUD showInfoWithStatus:@"该城市暂未开通服务"];
                return;
            }
        }else if (indexPath.row == 1){
            if(_blockReturn){
                [self selectRowCell:[tableView cellForRowAtIndexPath:indexPath]];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    _blockReturn(nil);
                });
            }
        }
        
    }else{
        if (_blockReturn) {
            [self selectRowCell:[tableView cellForRowAtIndexPath:indexPath]];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _blockReturn(arrCities[indexPath.row]);
            });
        }
    }
}

- (void)selectRowCell:(UITableViewCell *)cell{
    if (_tempCell != nil) {
        _tempCell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    _tempCell = cell;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return arrHeaderTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return arrHeaderTitles == nil ? 0:1;
    }
    if (section == 1) {
        return arrCities.count;
    }
    return 0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (arrHeaderTitles) {
        return arrHeaderTitles[section];
    }
    return @"";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            NSString *city = [GolfAppDelegate shareAppDelegate].currentCity;
            
            if (![LoginManager sharedManager].positionIsValid) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CityCell" forIndexPath:indexPath];
                cell.textLabel.text = @"城市定位失败";
                cell.accessoryType = UITableViewCellAccessoryNone;
                return cell;
            }else{
                if (scm) {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CityCell" forIndexPath:indexPath];
                    cell.textLabel.text = scm.cityName;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    return cell;
                }else{
                    UnOpenTableViewCell *cell = (UnOpenTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"UnOpenTableViewCell" forIndexPath:indexPath];
                    cell.labelCityName.text = city;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    return cell;
                }
            }
        }
    }
    
    SearchCityModel *m = arrCities[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CityCell" forIndexPath:indexPath];
    cell.textLabel.text = m.cityName;
    if (_cityName != nil && _cityName.length > 0 && [m.cityName containsString:_cityName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        _tempCell = cell;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

@end
