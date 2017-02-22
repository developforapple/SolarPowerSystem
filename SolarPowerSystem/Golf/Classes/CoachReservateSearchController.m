//
//  CoachReservateSearchController.m
//  Golf
//
//  Created by 黄希望 on 15/6/16.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CoachReservateSearchController.h"
#import "GolfSearchRecordADM.h"
#import "MJRefresh.h"

@interface CoachReservateSearchController ()<UISearchBarDelegate,UIScrollViewDelegate>{
    UISearchBar *_searchBar;
    BOOL canOpenKeyBoard;
    NoResultView *noResultView;
}

@property (nonatomic,strong) NSMutableArray *recordList;

@end

@implementation CoachReservateSearchController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self noLeftButton];
    [self rightButtonAction:@"取消"];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.recordList = [NSMutableArray array];
    [self.recordList addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"COACH_RESERVATION_SEARCH_RECORD_LIST"]];
    
    [self createRecordListView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self newSearchBar];
    });
    
    __weak CoachReservateSearchController *weakSelf = self;
    noResultView = [NoResultView text:@"暂未搜索到预约课程" type:NoResultTypeList superView:self.view show:^{
        weakSelf.tableView.hidden = YES;
    } hide:^{
        weakSelf.tableView.hidden = NO;
    }];
    
    self.tableView.contentInset = UIEdgeInsetsMake(64.f, 0, 0, 0);
}

- (void)newSearchBar{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(8, 0, Device_Width-55, 44)];
        _searchBar.delegate = self;
        _searchBar.showsCancelButton = NO;
        _searchBar.placeholder = @"按学员名字查找";
        [_searchBar setBarTintColor:[Utilities R:246.0 G:244.0 B:236.0]];
        [self.navigationItem setTitleView:_searchBar];
    }

    [[GolfAppDelegate shareAppDelegate] performBlock:^{
        [_searchBar becomeFirstResponder];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } afterDelay:0.4];
}

- (void)doRightNavAction{
    [_searchBar resignFirstResponder];
    [self back];
}

- (void)createRecordListView{
    __weak CoachReservateSearchController *weakSelf = self;
    [GolfSearchRecordADM recordListWithCacheName:@"COACH_RESERVATION_SEARCH_RECORD_LIST" controller:self completion:^(id obj) {
        [_searchBar resignFirstResponder];
        _searchBar.text = [obj description];
        weakSelf.term = [obj description];
        [super loadDataPageNo:1];
    } clearCompletion:^{
        [self.recordList removeAllObjects];
    } disappearKeyboard:^{
        [_searchBar resignFirstResponder];
    }];
}



#pragma mark - UISearchBar delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    canOpenKeyBoard = YES;
    return YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    canOpenKeyBoard = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        canOpenKeyBoard = NO;
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchBar.text.length == 0) {
        [self createRecordListView];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    if (searchBar.text.length>0) {
        [GolfSearchRecordADM hide];
        [self insertRecordWithString:searchBar.text];
        self.term = searchBar.text;
        [super loadDataPageNo:1];
    }else{
        [SVProgressHUD showInfoWithStatus:@"请输入搜索内容"];
    }
}

- (void)insertRecordWithString:(NSString*)str{
    if (!str || str.length == 0) {
        return;
    }
    if ([self.recordList containsObject:str]) {
        [self.recordList removeObject:str];
    }
    [self.recordList insertObject:str atIndex:0];
    NSArray *arr = nil;
    if (self.recordList.count > 10) {
        arr = [self.recordList subarrayWithRange:NSMakeRange(0, 10)];
    }else{
        arr = self.recordList;
    }
    [[NSUserDefaults standardUserDefaults] setObject:arr forKey:@"COACH_RESERVATION_SEARCH_RECORD_LIST"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (!canOpenKeyBoard) {
        [_searchBar resignFirstResponder];
    }
}

@end
