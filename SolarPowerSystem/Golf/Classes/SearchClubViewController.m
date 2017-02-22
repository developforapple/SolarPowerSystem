//
//  SearchClubViewController.m
//  Golf
//
//  Created by 黄希望 on 15/10/15.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "SearchClubViewController.h"
#import "ClubListCell.h"
#import "UIButton+Custom.h"
#import "ClubListViewController.h"
#import "OnlyOneLineCell.h"
#import "ClubMainViewController.h"
#import "ButtonTagCell.h"

@interface SearchClubViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>{
    UISearchBar *_searchBar;
    NSInteger _searchStatus; // 0.未搜索 1.及时搜索 2.已搜索出结果
    CGPoint _posPoint;
    BOOL canOpenKeyBoard;
    NoResultView *_noResultView;
}

@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *hotKeyArr; // 热门搜索词
@property (nonatomic,strong) NSMutableArray *searchResultArr; // 搜索结果
@property (nonatomic,strong) NSMutableArray *historyArr; // 历史搜索

@end

@implementation SearchClubViewController{
    UILabel *sectionLabel0,*sectionLabel1;
}

- (UILabel *)sectionLabelWithString:(NSString *)str{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, Device_Width, 30)];
    label.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
    label.textColor = [UIColor colorWithHexString:@"999999"];
    label.font = [UIFont systemFontOfSize:12];
    label.text =str;
    return label;
}

- (void)viewDidLoad {
    self.title = @"球场搜索";
    YGPostBuriedPoint(YGCoursePointSearchList);
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(64.f, 0, 0, 0);
    
    sectionLabel0 = [self sectionLabelWithString:@"     热门搜索"];
    sectionLabel1 = [self sectionLabelWithString:@"     历史搜索"];
    
    // Do any additional setup after loading the view.
    
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(8, 0, Device_Width-55, 44)];
        _searchBar.delegate = self;
        _searchBar.showsCancelButton = NO;
        _searchBar.placeholder = @"球场名称";
        [_searchBar setBarTintColor:[Utilities R:246.0 G:244.0 B:236.0]];
        [_searchBar setTintColor:MainHighlightColor];
        [self.navigationItem setTitleView:_searchBar];
        //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_searchBar becomeFirstResponder];
        //});
    }
    
    [self initizationData];
}

- (void)initizationData{
    [self noLeftButton];
    self.navigationItem.hidesBackButton = YES;
    [self rightButtonAction:@"取消"];
    
    _tableView.backgroundColor = [UIColor clearColor];
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor colorWithHexString:@"f0f0f0"];
    self.tableView.tableFooterView = bgView;
    
    [self initSourceData];
}

// 初始化数据源
- (void)initSourceData{
    
    __weak typeof(self) ws = self;
    _noResultView = [NoResultView text:@"没有搜索结果" type:NoResultTypeSearch superView:self.view show:^{
        ws.tableView.hidden = YES;
    } hide:^{
        ws.tableView.hidden = NO;
    }];
    
    _posPoint = CGPointZero;
    self.searchResultArr = [NSMutableArray array];

    // 热门搜素
    self.hotKeyArr = [NSMutableArray array];
    if ([GolfAppDelegate shareAppDelegate].systemParamInfo.hotClubKeyword.length>0) {
        NSArray *arr = [[GolfAppDelegate shareAppDelegate].systemParamInfo.hotClubKeyword componentsSeparatedByString:@","];
        if (arr) {
            _posPoint = [self gridButtonsWithArray:arr pt:CGPointMake(13, 15) contentArray:_hotKeyArr];
        }
    }
    
    // 历史搜索记录
    self.historyArr = [NSMutableArray array];
    NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"ClubHistorySearchList"];
    if (array) {
        [_historyArr addObjectsFromArray:array];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_searchBar resignFirstResponder];
}

// 取消
- (void)doRightNavAction{
    [super back];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    _cm.clubName = @"";
}


#pragma mark - 创建热门搜索词
- (CGPoint)gridButtonsWithArray:(NSArray*)array pt:(CGPoint)pt contentArray:(NSMutableArray*)aa{
    for (int i=0; i < MIN(10, array.count) ; i++) {
        NSString *buttonTitle = array[i];
        UIButton *button = [self buttonWithTitle:buttonTitle color:nil];
        button.tag = i+1;
        
        pt = [self pointWithButton:button cgpt:pt];
        [aa addObject:button];
    }
    pt.y += 40;
    return pt;
}

- (CGPoint)pointWithButton:(UIButton*)button cgpt:(CGPoint)pt{
    if (pt.x+button.frame.size.width > Device_Width-13) {
        pt.x = 13;
        pt.y = pt.y+40;
    }
    
    CGRect rt = button.frame;
    rt.origin.x = pt.x;
    rt.origin.y = pt.y;
    button.frame = rt;
    
    CGFloat x = button.frame.size.width+pt.x+10;
    CGFloat y = pt.y;
    if (x > Device_Width-13) {
        x = 13;
        y = pt.y + 40;
    }
    return CGPointMake(x, y);
}

- (UIButton*)buttonWithTitle:(NSString *)title color:(UIColor *)color{
    CGSize sz = [Utilities getSize:title withFont:[UIFont systemFontOfSize:12] withWidth:Device_Width-52];
    
    UIButton *button = [UIButton myButton:self Frame:CGRectMake(0, 0, sz.width+26, 30) NormalImage:nil SelectImage:nil Title:title TitleColor:color? color : [Utilities R:51 G:51 B:51] Font:12 Action:@selector(hotKeyButtonAtion:)];
    [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [Utilities drawView:button radius:3 borderColor: color ? color :[UIColor colorWithHexString:@"dddddd"]];
    return button;
}

- (void)hotKeyButtonAtion:(UIButton*)sender{
    [_searchBar resignFirstResponder];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [ServerService clubListWithLon:[LoginManager sharedManager].currLongitude lat:[LoginManager sharedManager].currLatitude pageNo:1 pageSize:100 keyword:sender.currentTitle success:^(NSArray *list) {
            if (list.count > 1) {
                [self pushWithStoryboard:@"BookTeetime" title:[NSString stringWithFormat:@"%@",_cm.clubName] identifier:@"ClubListViewController" completion:^(BaseNavController *controller) {
                    ClubListViewController *vc = (ClubListViewController*)controller;
                    vc.cm = _cm;
                    vc.cm.clubName = sender.currentTitle;
                    vc.keyword = sender.currentTitle;
                }];
            }else if (list.count == 1){
                SearchClubModel *scm = [list firstObject];
                ConditionModel *nextCondition = [_cm copy];
                nextCondition.clubId = scm.clubId;
                nextCondition.clubName = scm.clubName;
                nextCondition.address = scm.address;
                [self pushWithStoryboard:@"BookTeetime" title:scm.clubName identifier:@"ClubMainViewController" completion:^(BaseNavController *controller) {
                    ClubMainViewController *vc = (ClubMainViewController*)controller;
                    vc.cm = nextCondition;
                    vc.agentId = -1;
                }];
            }
        } failure:^(id error) {
        }];
    });
}


#pragma mark - UITableView delegate && dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _searchStatus > 0 ? 1 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_searchStatus == 0) {
        return section == 0 ? 1 : [_historyArr count] + 1;
    }
    return [_searchResultArr count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_searchStatus == 0) {

        if (indexPath.section == 0) {
            ButtonTagCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonTagCell" forIndexPath:indexPath];
            if (!cell.tagsLoaded) {
                for (UIButton *btn in _hotKeyArr) {
                    [cell.contentView addSubview:btn];
                }
            }
            
            return cell;
        }else{
            if (_historyArr.count > 0 && indexPath.row < _historyArr.count) {
                OnlyOneLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OnlyOneLineCell" forIndexPath:indexPath];
                cell.showTextLabel.text = _historyArr[indexPath.row];
                return cell;
            }else{
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:(_historyArr.count > 0 ? @"Club_Clear_Cell" : @"Club_History_Type_None") forIndexPath:indexPath];
                return cell;
            }
        }
    }else if (_searchStatus == 1){
        OnlyOneLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OnlyOneLineCell" forIndexPath:indexPath];
        if (indexPath.row < _searchResultArr.count) {
            SearchClubModel *sc = _searchResultArr[indexPath.row];
            cell.showTextLabel.text = sc.clubName;
        }
        return cell;
    }else{
        ClubListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClubListCell" forIndexPath:indexPath];
        cell.cm = _cm;
        if (indexPath.row < _searchResultArr.count) {
            cell.club = _searchResultArr[indexPath.row];
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_searchStatus == 0) {
        if (indexPath.section == 0) {
            return _posPoint.y>0 ? _posPoint.y + 5 : 0;
        }else{
            return indexPath.row == _historyArr.count ? 40 : 44;
        }
    }else if (_searchStatus == 1){
        return 44;
    }else {
        return 88;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_searchStatus == 0) {
        if (section == 0) {
            return _hotKeyArr.count > 0 ? 30 : 0;
        }
        return 30;
    }
    return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (_searchStatus == 0) {
        if ((section == 0 && _hotKeyArr.count > 0) || section == 1) {
            switch (section) {
                case 0:
                    return sectionLabel0;
                    break;
                case 1:
                    return sectionLabel1;
                    break;
                default:
                    break;
            }
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && _searchStatus == 0) {
        return;
    }
    [_searchBar resignFirstResponder];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_searchStatus == 0) {
            if (_historyArr.count > 0) {
                if (indexPath.row == _historyArr.count) { // 删除历史纪录
                    [_historyArr removeAllObjects];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ClubHistorySearchList"];
                    [_tableView reloadData];
                }else {
                    _cm.clubName = _historyArr[indexPath.row];
                    [self storeHistoryData];
                    [self pushWithStoryboard:@"BookTeetime" title:[NSString stringWithFormat:@"%@",_cm.clubName] identifier:@"ClubListViewController" completion:^(BaseNavController *controller) {
                        ClubListViewController *vc = (ClubListViewController*)controller;
                        vc.cm = _cm;
                        vc.keyword = _cm.clubName;
                    }];
                }
            }
        }else if (_searchStatus == 1){
            _cm.clubName = _searchBar.text;
            [self storeHistoryData];
            
            if (indexPath.row<_searchResultArr.count) {
                SearchClubModel *scm = _searchResultArr[indexPath.row];
                ConditionModel *nextCondition = [_cm copy];
                nextCondition.clubId = scm.clubId;
                nextCondition.clubName = scm.clubName;
                nextCondition.address = scm.address;
                [self pushWithStoryboard:@"BookTeetime" title:scm.clubName identifier:@"ClubMainViewController" completion:^(BaseNavController *controller) {
                    ClubMainViewController *vc = (ClubMainViewController*)controller;
                    vc.cm = nextCondition;
                    vc.agentId = -1;
                }];
            }
        }
    });
}

#pragma mark - UISearchBar - 相关
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    canOpenKeyBoard = YES;
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length > 0) {
        _searchStatus = 1;
        [ServerService clubListWithLon:[LoginManager sharedManager].currLongitude lat:[LoginManager sharedManager].currLatitude pageNo:1 pageSize:100 keyword:searchText success:^(NSArray *list) {
            [_searchResultArr removeAllObjects];
            [_searchResultArr addObjectsFromArray:list];
            [_tableView reloadData];
            if (_noResultView) {
                [_noResultView show:_searchResultArr.count>0?NO:YES];
            }
        } failure:^(id error) {
        }];
    }else{
        [_searchResultArr removeAllObjects];
        _searchStatus = 0;
        [_tableView reloadData];
        if (_noResultView) {
            [_noResultView show:NO];
        }
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if (searchBar.text.length>0) {
        _cm.clubName = searchBar.text;
        [self storeHistoryData];
        [self pushWithStoryboard:@"BookTeetime" title:[NSString stringWithFormat:@"%@",_cm.clubName] identifier:@"ClubListViewController" completion:^(BaseNavController *controller) {
            ClubListViewController *vc = (ClubListViewController*)controller;
            vc.cm = [_cm copy];
            vc.cm.cityName = @"";
            vc.keyword = searchBar.text;
        }];
    }
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    if (serviceManager.success) {
        [_searchResultArr removeAllObjects];
        NSArray *clubArray = [NSArray arrayWithArray:data];
        [_searchResultArr addObjectsFromArray:clubArray];
        [_tableView reloadData];
    }
}

// 存储历史搜索记录
- (void)storeHistoryData{
    if (_cm.clubName.length>0) {
        if (_historyArr.count > 0) {
            if ([_historyArr containsObject:_cm.clubName]) {
                [_historyArr removeObject:_cm.clubName];
            }
        }
        [_historyArr insertObject:_cm.clubName atIndex:0];
        if (_historyArr.count > 10) {
            [_historyArr removeLastObject];
        }
        [[NSUserDefaults standardUserDefaults] setObject:_historyArr forKey:@"ClubHistorySearchList"];
    }
}

#pragma uiscrollView - 相关
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (!canOpenKeyBoard) {
        [_searchBar resignFirstResponder];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    canOpenKeyBoard = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        canOpenKeyBoard = NO;
    }
}

@end
