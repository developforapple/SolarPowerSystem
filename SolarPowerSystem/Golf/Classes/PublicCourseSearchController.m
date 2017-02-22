//
//  PublicCourseSearchController.m
//  Golf
//
//  Created by 黄希望 on 15/5/8.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "PublicCourseSearchController.h"
#import "GolfSearchRecordADM.h"
#import "PublicCourseDetailController.h"
#import "NoMoreTableViewCell.h"

@interface PublicCourseSearchController ()<UISearchBarDelegate,UIScrollViewDelegate>{
    UISearchBar *_searchBar;
    UITableView *_recordTableView;
    NSString *_term;
}

@property (nonatomic,strong) NSMutableArray *recordList;

@end

@implementation PublicCourseSearchController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self noLeftButton];
    [self rightButtonAction:@"取消"];
    
    self.isMore = YES;
    self.page = 1;
    self.recordList = [NSMutableArray array];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self newSearchBar];
    });
    
    [self getRecordData];
    [self createRecordListView];
    
    [self initization];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.dataSource.count == 0) {
        [_searchBar becomeFirstResponder];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (![self.navigationController.viewControllers containsObject:self]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PUBLIC_COURSE_OBSERVER_REFRESH" object:nil];
    }
}

- (void)newSearchBar{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(8, 0, Device_Width-55, 44)];
        _searchBar.delegate = self;
        _searchBar.showsCancelButton = NO;
        _searchBar.placeholder = @"按公开课名称搜索";
        _searchBar.realBackgroundColor = [UIColor clearColor];
        [self.navigationItem setTitleView:_searchBar];
    }
}

- (void)doRightNavAction{
    [_searchBar resignFirstResponder];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)createRecordListView{
    [GolfSearchRecordADM recordListWithCacheName:@"PUBLIC_COURSE_SEARCH_RECORD_LIST" controller:self completion:^(id obj) {
        _term = [obj description];
        _searchBar.text = _term;
        self.isMore = YES;
        self.page = 1;
        [self loadDataPageNo:self.page];
    } clearCompletion:^{
        [self.recordList removeAllObjects];
    } disappearKeyboard:^{
        [_searchBar resignFirstResponder];
    }];
}

- (void)getRecordData{
    [self.recordList removeAllObjects];
    NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:@"PUBLIC_COURSE_SEARCH_RECORD_LIST"];
    [self.recordList addObjectsFromArray:arr];
}

- (void)loadDataPageNo:(int)page{
    if (_term.length > 0) {
        [_searchBar resignFirstResponder];
        if (self.isMore) {
            [[ServiceManager serviceManagerWithDelegate:self] getPublicListWithLo:[LoginManager sharedManager].currLongitude la:[LoginManager sharedManager].currLatitude keyWord:_term cityId:self.cityId pageNo:page pageSize:20];
        }else{
            [self.tableView.mj_footer endRefreshing];
        }
    }
}


#pragma mark - UISearchBar delegate

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
        self.isMore = YES;
        self.page = 1;
        _term = searchBar.text;
        [self loadDataPageNo:self.page];
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
    [[NSUserDefaults standardUserDefaults] setObject:arr forKey:@"PUBLIC_COURSE_SEARCH_RECORD_LIST"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_searchBar resignFirstResponder];
}
@end
