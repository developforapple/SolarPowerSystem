//
//  SelectedCitysController.m
//  Golf
//
//  Created by 黄希望 on 15/10/16.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "SelectedCitysController.h"
#import "OnlyOneLineCell.h"
#import "SearchCityButtonCell.h"
#import "ProvinceChooseCell.h"
#import "Province.h"
#import "ClubListViewController.h"
#import "SimpleCityModel.h"
#import "SearchProvinceModel.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface SelectedCitysController ()<UITableViewDelegate,UITableViewDataSource,UISearchDisplayDelegate,UISearchBarDelegate>{
    UISegmentedControl *_segmentedControl;
    NSInteger _searchCityType; // 0->全部 1->海外
    NSTimeInterval lastCheckTime;
    
    NSInteger _currentSelectCityCount;
    NSInteger _currentSelectIndex;
    NSInteger _currentSelectSection;
    NSInteger _lastSelectCityCount;
    NSInteger _lastSelectIndex;
    NSInteger _lastSelectSection;
}

@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,weak) IBOutlet UISearchBar *searchBar;

@property (nonatomic,strong) NSMutableArray *tempArr;
@property (nonatomic,strong) NSMutableArray *historyArr;

@property (nonatomic,strong) NSArray *pArr;
@property (nonatomic,strong) NSArray *cArr;

// 省份
@property (nonatomic,strong) NSMutableArray *provinceArr;
// 海外(国名)省份
@property (nonatomic,strong) NSMutableArray *overseasPArr;

@end

@implementation SelectedCitysController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initizationData];
}

// 初始化
- (void)initizationData{
    [self createNavSegmentControl];
    
    [self initArr];
}

- (void)initArr{
    // 城市默认不展开
    _currentSelectIndex = -1;
    _currentSelectCityCount = 0;
    _currentSelectSection = 0;
    _lastSelectIndex = -1;
    _lastSelectCityCount = 0;
    _lastSelectSection = 0;

    lastCheckTime = 0.0f;
    
    self.tempArr = [NSMutableArray array];
    self.historyArr = [NSMutableArray array];
    self.provinceArr = [NSMutableArray array];
    self.overseasPArr = [NSMutableArray array];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getCities];
    });
}

// 切换按钮(全部/海外)
- (void)createNavSegmentControl{
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"全部",@"海外"]];
    _segmentedControl.width = 120;
    _segmentedControl.selectedSegmentIndex = 0;
    [_segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    [self.navigationItem setTitleView:_segmentedControl];
}

- (void)segmentAction:(UISegmentedControl*)seg{
    _searchCityType = seg.selectedSegmentIndex;
    _currentSelectIndex = -1;
    _currentSelectCityCount = 0;
    _currentSelectSection = 0;
    _lastSelectIndex = -1;
    _lastSelectCityCount = 0;
    _lastSelectSection = 0;
    [_tableView reloadData];
}

// 获取城市数据
- (void)getCities{
    // 获取历史城市列表
    [self getHistoryList];
    
    // 获取省份和城市列表
    lastCheckTime = [[[NSUserDefaults standardUserDefaults] objectForKey:@"lastCheckTime"] doubleValue];
    if ([NSDate timeIntervalSinceReferenceDate] - lastCheckTime > 600.0f) {
        lastCheckTime = [NSDate timeIntervalSinceReferenceDate];
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithDouble:lastCheckTime] forKey:@"lastCheckTime"];
        
        [SelectedCitysController getProvinceListSuccess:^(NSArray *list) {
            [self resultList:list flag:@"dict_province"];
        }];
        [SelectedCitysController getCityListSuccess:^(NSArray *list) {
            [self resultList:list flag:@"dict_city"];
        }];
    }else{
        // 缓存本地的省份数据
        self.pArr = [SelectedCitysController getLocalProvinceOrCity:0];
        // 缓存本地的城市数据
        self.cArr = [SelectedCitysController getLocalProvinceOrCity:1];
        
        if (self.pArr.count>0 && self.cArr.count>0) {
            [self handleData];
        }else{
            if (self.cArr.count == 0) {
                [SelectedCitysController getProvinceListSuccess:^(NSArray *list) {
                    [self resultList:list flag:@"dict_province"];
                }];
            }
            if (self.cArr.count == 0) {
                [SelectedCitysController getCityListSuccess:^(NSArray *list) {
                    [self resultList:list flag:@"dict_city"];
                }];
            }
            lastCheckTime = [NSDate timeIntervalSinceReferenceDate];
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithDouble:lastCheckTime] forKey:@"lastCheckTime"];
        }
    }
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *arr = (NSArray*)data;
    if (arr.count > 0) {
        if (Equal(flag, @"dict_city")) {
            self.cArr = arr;
        }else if (Equal(flag, @"dict_province")){
            self.pArr = arr;
        }
        if (self.cArr.count>0&&self.pArr.count>0) {
            [self handleData];
        }
        
        if (self.cArr.count+self.pArr.count==0) {
            [SVProgressHUD showErrorWithStatus:@"获取城市信息失败"];
        }
    }
}

// 获取省份列表
+ (void)getProvinceListSuccess:(void (^)(NSArray *list))success{
    [ServerService getProvinceWithSuccess:^(NSArray *list) {
        success(list);
    } failure:^(id error) {
    }];
}

// 获取城市列表
+ (void)getCityListSuccess:(void (^)(NSArray *list))success{
    [ServerService getCityListWithHotCity:0 success:^(NSArray *list) {
        success(list);
    } failure:^(id error) {
    }];
}

- (void)resultList:(NSArray*)arr flag:(NSString *)flag{
    if (arr.count > 0) {
        if (Equal(flag, @"dict_city")) {
            self.cArr = arr;
        }else if (Equal(flag, @"dict_province")){
            self.pArr = arr;
        }
        if (self.cArr.count>0 && self.pArr.count>0) {
            [self handleData];
        }
        if (self.cArr.count+self.pArr.count==0) {
            [SVProgressHUD showErrorWithStatus:@"获取城市信息失败"];
        }
    }
}

// 获取历史城市列表
- (void)getHistoryList{
    NSString *path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString *filename=[path stringByAppendingPathComponent:@"GolfBrowseCityInfo.plist"];
    NSArray *localArray = [NSArray arrayWithContentsOfFile:filename];

    [_historyArr removeAllObjects];
    if (localArray) {
        for (id obj in localArray) {
            SimpleCityModel *cityModel = [[SimpleCityModel alloc] initWithDic:obj];
            [_historyArr addObject:cityModel];
        }
    }
}

// 获取本地的省份/城市
+ (NSArray *)getLocalProvinceOrCity:(int)flag{
    NSString *path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString *plist = flag > 0 ? @"GolfCityInfo.plist" : @"GolfProvinceInfo.plist";
    NSString *filename=[path stringByAppendingPathComponent:plist];
    NSArray *localArray = [NSArray arrayWithContentsOfFile:filename];
    
    if (localArray) {
        NSMutableArray *localList = [NSMutableArray array];
        for (id obj in localArray) {
            if (flag > 0) {
                SearchCityModel *model = [[SearchCityModel alloc] initWithDic:obj];
                [localList addObject:model];
            }
            else{
                SearchProvinceModel *model = [[SearchProvinceModel alloc] initWithDic:obj];
                [localList addObject:model];
            }
        }
        return localList;
    }
    return nil;
}

- (void)handleData{
    BOOL hasHotList = _hotCityArr.count>0 ? YES : NO;
    NSMutableArray *hots = nil;
    BOOL isAddOver = NO;
    if (!hasHotList) {
        hots = [NSMutableArray array];
    }
    for (SearchProvinceModel *spm in _pArr) {
        NSMutableArray *citys = [NSMutableArray array];
        Province *p = [[Province alloc] init];
        p.pId = spm.provinceId;
        p.pName = spm.provinceName;
        
        // 第一行插入省份
        SearchCityModel *pscm = [[SearchCityModel alloc] init];
        pscm.cityId = 0;
        pscm.cityName = spm.provinceName;
        pscm.provinceId = spm.provinceId;
        [citys addObject:pscm];
        
        for (SearchCityModel *scm in _cArr) {
            if (scm.provinceId == spm.provinceId && !Equal(scm.cityName, spm.provinceName)) {
                [citys addObject:scm];
            }
            if (scm.isHotCity==1 && !hasHotList && !isAddOver) {
                [hots addObject:scm];
            }
        }
        
        isAddOver = YES;
        
        p.citys = citys;
        if (spm.international == 0) {
            [_provinceArr addObject:p];
        }else{
            [_overseasPArr addObject:p];
        }
    }
    if (hots&&hots.count>0) {
        _hotCityArr = hots;
    }
    [_tableView reloadData];
}

#pragma mark - UITableview 相关
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == self.searchDisplayController.searchResultsTableView) return 1;
    return _searchCityType == 0 ? 5 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [_tempArr count];
    }else{
        if (section == 0) {
            return 1;
        }else if (section == 1){
            return _searchCityType == 0 ? (_historyArr.count%3==0 ? _historyArr.count/3 : _historyArr.count/3+1) : _overseasPArr.count+_currentSelectCityCount;
        }else if (section == 2){
            return _searchCityType == 0 ? (_hotCityArr.count%3==0 ? _hotCityArr.count/3 : _hotCityArr.count/3+1) : 0;
        }else if (section == 3){
            return _provinceArr.count + (_currentSelectSection==3?_currentSelectCityCount:0);
        }else{
            return _overseasPArr.count + (_currentSelectSection==4?_currentSelectCityCount:0);
        }
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        static NSString *cellIdentifier = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier]
            ;
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.textColor = [UIColor colorWithHexString:@"333333"];
        }
        cell.textLabel.text = @"";
        if (indexPath.row<_tempArr.count) {
            id data = _tempArr[indexPath.row];
            if ([data isKindOfClass:[SearchCityModel class]]) {
                SearchCityModel *scm = (SearchCityModel*)data;
                cell.textLabel.text = scm.cityName;
            }else if ([data isKindOfClass:[SearchProvinceModel class]]){
                SearchProvinceModel *scm = (SearchProvinceModel*)data;
                cell.textLabel.text = scm.provinceName;
            }
        }
        return cell;
    }else{
        if (indexPath.section == 0) {
            OnlyOneLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OnlyOneLineCell" forIndexPath:indexPath];
            cell.showTextLabel.text = @"当前位置";
            return cell;
        }else if (indexPath.section == 1){
            if (_searchCityType == 0) {
                SearchCityButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCityButtonCell_Delete" forIndexPath:indexPath];
                cell.isHotCity = NO;
                NSInteger my = _historyArr.count%3 ;
                NSInteger zc = _historyArr.count/3 ;
                NSInteger c = my==0 ? zc : zc+1;
                if (c>0) {
                    if (indexPath.row == c-1) {
                        cell.citys = [_historyArr subarrayWithRange:NSMakeRange(indexPath.row*3, my==0?3:my)];
                    }else{
                        cell.citys = [_historyArr subarrayWithRange:NSMakeRange(indexPath.row*3, 3)];
                    }
                }else{
                    cell.citys = nil;
                }
                cell.clickBlock = ^(id data){
                    [self choose:data];
                    [_tableView reloadData];
                };
                cell.deleteBlock = ^(id data){
                    [_historyArr removeObject:data];
                    if (_searchCityType == 0) {
                        [_tableView reloadData];
                    }
                    [self store:_historyArr];
                };
                return cell;
            }else{
                if (_currentSelectIndex != -1 && _currentSelectSection == 1) {
                    if (indexPath.row>_currentSelectIndex && indexPath.row<=_currentSelectIndex+_currentSelectCityCount) {
                        OnlyOneLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OnlyOneLineCell_City" forIndexPath:indexPath];
                        Province *p = _overseasPArr[_currentSelectIndex];
                        
                        SearchCityModel *scm = p.citys[indexPath.row-_currentSelectIndex-1];
                        cell.showTextLabel.text = scm.cityName;
                        return cell;
                    }
                }
                ProvinceChooseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProvinceChooseCell" forIndexPath:indexPath];
                if (_currentSelectIndex == -1) {
                    cell.province = _overseasPArr[indexPath.row];
                }else{
                    if (indexPath.row<=_currentSelectIndex) {
                        cell.province = _overseasPArr[indexPath.row];
                    }else{
                        cell.province = _overseasPArr[indexPath.row-_currentSelectCityCount];
                    }
                }
                return cell;
            }
        }else if (indexPath.section == 2){
            SearchCityButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCityButtonCell" forIndexPath:indexPath];
            cell.isHotCity = YES;
            NSInteger my = _hotCityArr.count%3 ;
            NSInteger zc = _hotCityArr.count/3 ;
            NSInteger c = my==0 ? zc : zc+1;
            if (c > 0) {
                if (indexPath.row == c-1) {
                    cell.citys = [_hotCityArr subarrayWithRange:NSMakeRange(indexPath.row*3, my==0?3:my)];
                }else{
                    cell.citys = [_hotCityArr subarrayWithRange:NSMakeRange(indexPath.row*3, 3)];
                }
            }else{
                cell.citys = nil;
            }
            cell.clickBlock = ^(id data){
                [self choose:data];
                if (_searchCityType == 0) {
                    [_tableView reloadData];
                }
            };
            return cell;
        }else{ // 国内和海外
            NSArray *arr =  indexPath.section == 3 ? _provinceArr : _overseasPArr;
            if (_currentSelectIndex != -1 && _currentSelectSection == indexPath.section) {
                if (indexPath.row>_currentSelectIndex && indexPath.row<=_currentSelectIndex+_currentSelectCityCount) {
                    OnlyOneLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OnlyOneLineCell_City" forIndexPath:indexPath];
                    if (_currentSelectIndex < arr.count) {
                        Province *p = arr[_currentSelectIndex];
                        if (indexPath.row-_currentSelectIndex-1<p.citys.count) {
                            SearchCityModel *scm = p.citys[indexPath.row-_currentSelectIndex-1];
                            cell.showTextLabel.text = scm.cityName;
                        }
                    }
                    return cell;
                }
            }
            ProvinceChooseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProvinceChooseCell" forIndexPath:indexPath];
            if (_currentSelectIndex == -1 || (_currentSelectSection != indexPath.section && _currentSelectIndex != -1)) {
                if (indexPath.row<arr.count) {
                    cell.province = arr[indexPath.row];
                }
            }else{
                if (indexPath.row<=_currentSelectIndex) {
                    if (indexPath.row<arr.count) {
                        cell.province = arr[indexPath.row];
                    }
                }else{
                    if (indexPath.row-_currentSelectCityCount<arr.count) {
                        cell.province = arr[indexPath.row-_currentSelectCityCount];
                    }
                }
            }
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_searchCityType == 0 && (indexPath.section == 1||indexPath.section == 2)) {
        return 47;
    }
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return [self tableView:tableView headerHeightInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSString *title = @"";
    CGFloat height = [self tableView:tableView headerHeightInSection:section];
    CGRect labelRt = CGRectZero;
    if (section == 0) {
        title = @"";
        labelRt = CGRectZero;
    }else{
        if (_searchCityType == 0) {
            if (section == 1) {
                if (_historyArr.count>0) {
                    title = @"历史访问城市";
                    labelRt = CGRectMake(13, 10, 150, 20);
                }else{
                    title = @"";
                    labelRt = CGRectZero;
                }
            }else if (section == 2){
                if (_historyArr.count == 0) {
                    labelRt = CGRectMake(13, 10, 150, 20);
                }else{
                    labelRt = CGRectMake(13, 4, 150, 20);
                }
                title = _hotCityArr.count>0 ? @"热门城市" : @"";
            }else if (section == 3){
                title = _provinceArr.count > 0 ? @"国内城市" : @"";
                if (_historyArr.count+_hotCityArr.count==0) {
                    labelRt = CGRectMake(13, 10, 150, 20);
                }else{
                    labelRt = CGRectMake(13, 4, 150, 20);
                }
            }else{
                title = _overseasPArr.count > 0 ? @"国际城市" : @"";
                labelRt = CGRectMake(13, 10, 150, 20);
            }
        }else{
            title = _overseasPArr.count > 0 ? @"国际城市" : @"";
            labelRt = CGRectMake(13, 10, 150, 20);
        }
    }
    
    if (height > 0.1) {
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Device_Width, height)];
        header.backgroundColor = [UIColor colorWithHexString:@"f1f0f6"];
        UILabel *label = [[UILabel alloc] initWithFrame:labelRt];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithHexString:@"999999"];
        label.font = [UIFont systemFontOfSize:13];
        label.text = title;
        [header addSubview:label];
        return header;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView*)tableView headerHeightInSection:(NSInteger)section{
    CGFloat height = 0.1;
    if (section == 0) {
        height = 0.1;
    }else{
        if (_searchCityType == 0) {
            if (section == 1) {
                height = _historyArr.count>0 ? 34 : 0.1;
            }else if (section == 2){
                if (_historyArr.count == 0) {
                    height = _hotCityArr.count>0 ? 34 : 0.1;
                }else{
                    height = _hotCityArr.count>0 ? 28 : 0.1;
                }
            }else if (section == 3){
                if (_hotCityArr.count+_historyArr.count == 0) {
                    height = _provinceArr.count > 0 ? 40 : 0.1;
                }else{
                    height = _provinceArr.count > 0 ? 34 : 0.1;
                }
            }else{
                height = _overseasPArr.count > 0 ? 40 : 0.1;
            }
        }else{
            height = _overseasPArr.count > 0 ? 40 : 0.1;
        }
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        id data = _tempArr[indexPath.row];
        [self choose:data];
        [self.searchDisplayController.searchBar endEditing:YES];
    }else{
        if (indexPath.section == 0) {
            [self choose:[self currentLocation]];
        }
        
        if (_searchCityType == 0) {
            if (indexPath.section > 2) {
                if ((indexPath.section == _lastSelectSection && _lastSelectSection > 2) || _lastSelectSection == 0) {
                    [self tableView:tableView selectedIndexPath:indexPath arr:indexPath.section == 3 ? _provinceArr : _overseasPArr];
                }else{
                    [self tableView:tableView selectedIndexPath:indexPath arr1:_provinceArr arr2:_overseasPArr];
                }
            }
        }else{
            if (indexPath.section == 1) {
                [self tableView:tableView selectedIndexPath:indexPath arr:_overseasPArr];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView selectedIndexPath:(NSIndexPath*)indexPath arr1:(NSArray*)arr1 arr2:(NSArray*)arr2{
    _currentSelectIndex = indexPath.row;
    _currentSelectSection = indexPath.section;
    if (_lastSelectSection == 3) {
        Province *lp = arr1[_lastSelectIndex];
        lp.open = NO;
        // 打开
        Province *p = arr2[_currentSelectIndex];
        p.open = YES;
        _currentSelectCityCount = p.citys.count;
    }else if (_lastSelectSection == 4){
        Province *lp = arr2[_lastSelectIndex];
        lp.open = NO;
        // 打开
        Province *p = arr1[_currentSelectIndex];
        p.open = YES;
        _currentSelectCityCount = p.citys.count;
    }
    NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 2)];
    [_tableView reloadSections:set withRowAnimation:UITableViewRowAnimationFade];
    _lastSelectIndex = _currentSelectIndex;
    _lastSelectCityCount = _currentSelectCityCount;
    _lastSelectSection = indexPath.section;
}

- (void)tableView:(UITableView *)tableView selectedIndexPath:(NSIndexPath*)indexPath arr:(NSArray*)arr{
    _currentSelectIndex = indexPath.row;
    _currentSelectSection = indexPath.section;
    if (_lastSelectIndex!=-1&&_lastSelectCityCount>0) {
        Province *lp = arr[_lastSelectIndex];
        // 相等关闭
        if (_currentSelectIndex == _lastSelectIndex) {
            _currentSelectIndex = -1;
            _currentSelectCityCount = 0;
        }else{
            // 打开本次
            if (_currentSelectIndex < _lastSelectIndex) {
                Province *p = arr[_currentSelectIndex];
                p.open = YES;
                _currentSelectCityCount = p.citys.count;
            }else{
                if (indexPath.row>_lastSelectIndex && indexPath.row <= _lastSelectIndex+_lastSelectCityCount) {
                    SearchCityModel *scm = lp.citys[indexPath.row-_lastSelectIndex-1];
                    
                    [self choose:scm];
                    if (_searchCityType == 0) {
                        [_tableView reloadData];
                    }
                    return;
                }else{
                    _currentSelectIndex = _currentSelectIndex-_lastSelectCityCount;
                    Province *p = arr[_currentSelectIndex];
                    p.open = YES;
                    _currentSelectCityCount = p.citys.count;
                }
            }
        }
        // 关闭上次的打开
        lp.open = NO;
    }else{
        // 打开
        Province *p = arr[_currentSelectIndex];
        p.open = YES;
        _currentSelectCityCount = p.citys.count;
    }
    
    NSRange rg = _searchCityType == 0 ? NSMakeRange(3, 2) : NSMakeRange(1, 1);
    NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:rg];
    [_tableView reloadSections:set withRowAnimation:UITableViewRowAnimationFade];
    _lastSelectIndex = _currentSelectIndex;
    _lastSelectCityCount = _currentSelectCityCount;
    _lastSelectSection = indexPath.section;
}

- (void)choose:(id)data{
    SimpleCityModel *model = [[SimpleCityModel alloc] init];
    if ([data isKindOfClass:[SearchCityModel class]]) {
        SearchCityModel *scm = (SearchCityModel*)data;
        model.cityId = scm.cityId;
        model.provinceId = scm.cityId>0?0 : scm.provinceId;
        model.name = scm.cityName;
    }else if ([data isKindOfClass:[SimpleCityModel class]]){
        model = (SimpleCityModel*)data;
    }else if ([data isKindOfClass:[SearchProvinceModel class]]){
        SearchProvinceModel *scm = (SearchProvinceModel*)data;
        model.cityId = 0;
        model.provinceId = scm.provinceId;
        model.name = scm.provinceName;
    }
    
    [self storeCity:model];
    if (_chooseBlock) {
        _chooseBlock (model);
        [self back];
    }else{
        [self pushWithStoryboard:@"BookTeetime" title:@"" identifier:@"ClubListViewController" completion:^(BaseNavController *controller) {
            ClubListViewController *vc = (ClubListViewController*)controller;
            vc.cm = [_cm copy];
            vc.cm.cityId = model.cityId;
            vc.cm.provinceId = model.provinceId;
            vc.cm.cityName = model.name;
        }];
    }
}

- (SearchCityModel *)currentLocation{
    SearchCityModel *scm = [[SearchCityModel alloc] init];
    scm.cityId = [LoginManager sharedManager].city.cityId;
    scm.cityName = @"当前位置";
    scm.longitude = [LoginManager sharedManager].currLongitude;
    scm.latitude = [LoginManager sharedManager].currLatitude;
    return scm;
}

- (void)storeCity:(SimpleCityModel *)scm{
    if (scm.cityId==0&&scm.provinceId==0) {
        return;
    }
    for (SimpleCityModel *model in _historyArr){
        if (model.cityId == scm.cityId && model.cityId > 0) {
            [_historyArr removeObject:model];
            break;
        }
        if (model.provinceId == scm.provinceId && model.provinceId > 0 && model.cityId == scm.cityId) {
            [_historyArr removeObject:model];
            break;
        }
    }
    [_historyArr insertObject:scm atIndex:0];
    if (_historyArr.count > 6) {
        [_historyArr removeLastObject];
    }
    [self store:_historyArr];
}

- (void)store:(NSArray*)array_{
    NSArray *array = [NSArray arrayWithArray:array_];
    if (array) {
        NSMutableArray *dicArray = [NSMutableArray arrayWithCapacity:0];
        for (SimpleCityModel *model in array){
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
            [dic setValue:[NSNumber numberWithInt:model.cityId] forKey:@"city_id"];
            [dic setValue:[NSNumber numberWithInt:model.provinceId] forKey:@"province_id"];
            [dic setValue:model.name forKey:@"name"];
            [dic setValue:model.pinYin forKey:@"pinyin"];
            [dicArray addObject:dic];
        }
        
        NSString *path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
        NSString *filename=[path stringByAppendingPathComponent:@"GolfBrowseCityInfo.plist"];
        BOOL isOk = [dicArray writeToFile:filename atomically:YES];
        if (isOk) {
            NSLog(@"*** ok");
        }
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self.tempArr removeAllObjects];
    for (SearchCityModel *cityModel in _cArr)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF BEGINSWITH[cd] %@)", searchText];
        [cityModel.cityName compare:searchText options:NSCaseInsensitiveSearch];
        BOOL resultSimplePin = [predicate evaluateWithObject:cityModel.simplePin];
        BOOL resultPinYin = [predicate evaluateWithObject:cityModel.pinYin];
        BOOL resultName = [predicate evaluateWithObject:cityModel.cityName];
        BOOL resultFirstLetter = [predicate evaluateWithObject:cityModel.firstLetter];
        if (resultName || resultPinYin || resultSimplePin || resultFirstLetter) {
            [self.tempArr addObject:cityModel];
        }
    }
    
    for (SearchProvinceModel *spm in self.pArr) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF BEGINSWITH[cd] %@)", searchText];
        [spm.provinceName compare:searchText options:NSCaseInsensitiveSearch];
        BOOL resultName = [predicate evaluateWithObject:spm.provinceName];
        if (resultName) {
            [self.tempArr addObject:spm];
        }
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

@end

#pragma clang diagnostic pop
