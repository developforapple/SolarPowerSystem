//
//  YGArticleSearchViewCtrl.m
//  Golf
//
//  Created by bo wang on 16/6/16.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGArticleSearchViewCtrl.h"
#import "YGCollectionViewLayout.h"
#import "YGThriftInclude.h"
#import "YGArticleSearchResultViewCtrl.h"
#import "UIView+Animation.h"

static NSString * const  kYGArticleSearchHistorySaveKey = @"YGArticleSearchHistory";
static NSString * const  kYGArticleSearchCellID = @"YGArticleSearchCell";
static NSUInteger const  kYGArticleSearchCellTitleTag = 10086;
static NSString * const  kYGArticleHotKeywordsCellID = @"YGArticleHotKeywordsCell";
static NSUInteger const  kYGArticleHotKeywordsTitleTag = 10010;
static NSString * const  kYGArticleSearchResultSegueID = @"YGArticleSearchResultSegue";

static NSUInteger const  kYGArticleHotKeywordsMaximumLines = 3;//热点最多显示3行

@interface YGArticleSearchViewCtrl ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *placeholderGrayHeaderView;
@property (weak, nonatomic) IBOutlet UIView *cleanHistoryView;
@property (weak, nonatomic) IBOutlet UIView *hotKeywordsContainer;
@property (weak, nonatomic) IBOutlet UICollectionView *hotKeywordsCollectionView;
@property (weak, nonatomic) IBOutlet YGLeftAlignmentFlowLayout *hotKeywordsFlowLayout;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *resultContainer;
@property (strong, nonatomic) YGArticleSearchResultViewCtrl *resultViewCtrl;

@property (strong, nonatomic) NSMutableArray *hotKeywords;
@property (strong, nonatomic) NSMutableArray *searchHistory;
@end

@implementation YGArticleSearchViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
    [self loadHotKeywords];
    [self loadHistory];
    
    if (self.beginKeywords) {
        [self startSearch:self.beginKeywords];
        //搜索热词的埋点统计
        YGPostBuriedPoint(YGYueduStatistics_SearchHotKeywords);
        YGRecordEvent(YueduEvent_HotKeywords, nil);
    }else{
        [self.searchBar becomeFirstResponder];
    }
    
    // 打开搜索界面的埋点统计
    YGPostBuriedPoint(YGYueduStatistics_AlbumDetail);
    self.statisticsToken = YueduPage_Search;
}

- (void)initUI
{
    self.tableView.contentInset = UIEdgeInsetsMake(44.f, 0, 0, 0);
    self.searchBar.text = self.beginKeywords;
}

- (void)exit:(id)sender
{
    [self.searchBar endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - History
- (void)loadHistory
{
    NSArray *history =  [[NSUserDefaults standardUserDefaults] objectForKey:kYGArticleSearchHistorySaveKey];
    self.searchHistory = [NSMutableArray arrayWithArray:history];
    self.tableView.tableFooterView.hidden = self.searchHistory.count==0;
}

- (void)addKeywords:(NSString *)keywords
{
    if (keywords.length == 0) return;
    
    if ([self.searchHistory containsObject:keywords]) {
        [self.searchHistory removeObject:keywords];
        [self.searchHistory insertObject:keywords atIndex:0];
        [self.tableView reloadData];
    }else{
        [self.searchHistory insertObject:keywords atIndex:0];
        if (self.searchHistory.count > 15) {
            NSRange range = NSMakeRange(15, self.searchHistory.count-15);
            [self.searchHistory removeObjectsInRange:range];
            [self.tableView reloadData];
        }else{
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    self.tableView.tableFooterView.hidden = NO;
    [self saveHistory];
}

- (void)saveHistory
{
    [[NSUserDefaults standardUserDefaults] setObject:self.searchHistory forKey:kYGArticleSearchHistorySaveKey];
}

- (IBAction)cleanHistory:(id)sender
{
    [self.searchHistory removeAllObjects];
    [self saveHistory];
    self.tableView.tableFooterView.hidden = YES;
    [self.tableView reloadData];
}

#pragma mark - Search
- (void)startSearch:(NSString *)keywords
{
    if (!keywords) return;
    
    ygweakify(self);
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    [SVProgressHUD show];
    [self.resultViewCtrl setCompletion:^{
        ygstrongify(self);
        [SVProgressHUD dismiss];
        
        [self.tableView setHidden:YES animated:YES];
        [self.resultContainer setHidden:NO animated:YES];
    }];
    [self.resultViewCtrl search:keywords];
}

#pragma mark - UISearchBar
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.tableView setHidden:NO animated:YES];
    [self.resultContainer setHidden:YES animated:YES];
    [self.resultViewCtrl reset];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar endEditing:YES];
    [self addKeywords:searchBar.text];
    [self startSearch:searchBar.text];
    
    //搜索关键词的埋点统计
    YGPostBuriedPoint(YGYueduStatistics_SearchKeywords);
    YGRecordEvent(YueduEvent_Keywords, nil);
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self exit:[searchBar cancelButton]];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchHistory.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kYGArticleSearchCellID forIndexPath:indexPath];
    UILabel *label = [cell viewWithTag:kYGArticleSearchCellTitleTag];
    label.text = self.searchHistory[indexPath.row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.searchHistory.count==0?nil:self.placeholderGrayHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.searchHistory.count==0?0.f:10.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *keywords = self.searchHistory[indexPath.row];
    [self.searchBar endEditing:YES];
    self.searchBar.text = keywords;
    [self startSearch:keywords];
}

#pragma mark - HotKeywords
- (void)loadHotKeywords
{
    [YGRequest fetchArticleHotKeywords:^(BOOL suc, id object) {
        YueduHotTopicList *list = object;
        if (suc) {
            NSMutableArray *keywords = [NSMutableArray array];
            for (YueduHotTopicBean *bean in [list hotTopics]) {
                [keywords addObject:bean.name];
            }
            self.hotKeywords = keywords;
        }else{
            [SVProgressHUD showImage:nil status:list.err.errorMsg];
        }
        [self reloadHotKeywords];
    } failure:^(Error *err) {
        [SVProgressHUD showImage:nil status:@"当前网络不可用"];
        [self reloadHotKeywords];
    }];
}

- (void)reloadHotKeywords
{
    if (self.hotKeywords.count == 0) {
        self.tableView.tableHeaderView = nil;
        [self.tableView reloadData];
    }else{
        // 最多显示3行的最大高度
        CGFloat maximumHeight = self.hotKeywordsFlowLayout.sectionInset.top +
                                30.f*kYGArticleHotKeywordsMaximumLines +
                                self.hotKeywordsFlowLayout.minimumLineSpacing * (kYGArticleHotKeywordsMaximumLines-1);
        
        // 这里需要先手动修改下frame。否则 collectionViewContentSize 将会根据 xib中的宽度来计算结果
        self.hotKeywordsCollectionView.frame = CGRectMake(0, 0, Device_Width, 10000);
        [self.hotKeywordsCollectionView reloadData];
        CGFloat height = [self.hotKeywordsFlowLayout collectionViewContentSize].height;
        if (height > maximumHeight) {
            height = maximumHeight;
        }
        CGFloat headerHeight = 20.f + 16.f + height + 25.f;
        self.hotKeywordsContainer.frame = CGRectMake(0, 0, Device_Width, ceilf(headerHeight));
        self.tableView.tableHeaderView = self.hotKeywordsContainer;
        [self.tableView reloadData];
    }
}

#pragma mark - UICollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.hotKeywords.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kYGArticleHotKeywordsCellID forIndexPath:indexPath];
    UILabel *label = [cell viewWithTag:kYGArticleHotKeywordsTitleTag];
    label.text = self.hotKeywords[indexPath.item];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *keywords = self.hotKeywords[indexPath.item];
    CGFloat width = [keywords sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}].width;
    CGSize size = CGSizeMake(width + 24.f, 30.f);
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *keywords = self.hotKeywords[indexPath.item];
    [self.searchBar endEditing:YES];
    self.searchBar.text = keywords;
    [self startSearch:keywords];
    
    //搜索热词的埋点统计
    YGPostBuriedPoint(YGYueduStatistics_SearchHotKeywords);
    YGRecordEvent(YueduEvent_HotKeywords, nil);
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kYGArticleSearchResultSegueID]) {
        self.resultViewCtrl = segue.destinationViewController;
    }
}

@end
