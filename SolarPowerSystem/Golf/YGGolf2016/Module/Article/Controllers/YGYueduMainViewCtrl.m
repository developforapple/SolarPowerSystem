//
//  YGArticleMainViewCtrl.m
//  Golf
//
//  Created by wwwbbat on 16/5/27.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGYueduMainViewCtrl.h"
#import "YGArticleListViewCtrl.h"
#import "YGAlbumListViewCtrl.h"
#import "DDSegmentScrollView.h"
#import "YGYueduCommon.h"
#import "YGThriftRequestManager.h"

static NSString *const kYGYueduMainPageViewControllerSegueID = @"YGYueduMainPageViewControllerSegueID";

@interface YGYueduMainViewCtrl () <UIPageViewControllerDelegate,UIPageViewControllerDataSource>
@property (weak, nonatomic) IBOutlet DDSegmentScrollView *segmentView;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *,UIViewController *> *vcs;
@property (strong, nonatomic) UIPageViewController *pageVC;
@property (strong, nonatomic) YueduColumnList *columnList;
@property (strong, nonatomic) NSArray *columnTitles;
@end

@implementation YGYueduMainViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.statisticsToken = YueduPage_Main;
    
    self.vcs = [NSMutableDictionary dictionary];
    self.columnList = [YueduColumnList archivedList];
    self.columnTitles = [self.columnList allColumnNames];
    
    [self initUI];
    [self fetchCategories];
}

- (void)initUI
{
    self.segmentView.titles = self.columnTitles;
    [self setupPageViewController];
}

- (void)updateUI
{
    self.columnTitles = [self.columnList allColumnNames];
    self.segmentView.titles = self.columnTitles;
    NSUInteger idx = [self.columnList indexOfColumnId:self.columnId];
    if (idx == NSNotFound) {
        idx = 0;
    }
    self.segmentView.currentIndex = idx;
    [self setupPageViewController];
}

- (void)fetchCategories
{
    [YGRequest fetchYueDuCategories:^(BOOL suc, id object) {
        if (suc) {
            self.columnList = object;
            [self.columnList archive];
            RunOnMainQueue(^{
                [self updateUI];
            });
        }
    } failure:^(Error *err) {
        [SVProgressHUD showImage:nil status:@"当前网络不可用"];
    }];
}

#pragma mark - Action
- (IBAction)segmentViewChanged:(DDSegmentScrollView *)segmentView
{
    [self showViewController:[self viewControllerAtIndex:segmentView.currentIndex]
          directionIsForward:segmentView.currentIndex>=segmentView.lastIndex];
}

#pragma mark -
- (NSUInteger)indexOfViewController:(UIViewController *)vc
{
    for (NSNumber *uniqueid in self.vcs) {
        if (self.vcs[uniqueid] == vc) {
            return uniqueid.integerValue;
        }
    }
    return NSNotFound;
}

- (UIViewController *)viewControllerAtIndex:(NSInteger)index
{
    if (index < 0 || index >= self.columnTitles.count) {
        return nil;
    }
    
    NSNumber *uniqueid = @(index);
    if (!self.vcs[uniqueid]) {
        YueduColumnBean *colunmBean = self.columnList.columnList[index];
        enum DefaultShowType showType = colunmBean.defaultShowType;
        
        if (showType == DefaultShowType_ALBUM) {
            YGAlbumListViewCtrl *vc = [YGAlbumListViewCtrl instanceFromStoryboard];
            vc.statisticsToken = [NSString stringWithFormat:YueduPage_List,@(colunmBean.id)];
            vc.columnBean = colunmBean;
            self.vcs[uniqueid] = vc;
        }else if (showType == DefaultShowType_ARTICLE){
            YGArticleListViewCtrl *vc = [YGArticleListViewCtrl instanceFromStoryboard];
            vc.statisticsToken = [NSString stringWithFormat:YueduPage_List,@(colunmBean.id)];
            vc.columnBean = colunmBean;
            self.vcs[uniqueid] = vc;
        }
    }
    return self.vcs[uniqueid];
}

- (void)setupPageViewController
{
    if (self.columnTitles.count != 0){
        self.pageVC.dataSource = self;
        self.pageVC.delegate = self;
        
        NSUInteger idx = [self.columnList indexOfColumnId:self.columnId];
        if (idx == NSNotFound) {
            idx = 0;
        }
        [self showViewController:[self viewControllerAtIndex:idx] directionIsForward:YES];
    }
}

- (void)showViewController:(UIViewController *)vc directionIsForward:(BOOL)isForward
{
    if (!vc) return;
    [self.pageVC setViewControllers:@[vc] direction:isForward?UIPageViewControllerNavigationDirectionForward:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
}

#pragma mark - UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:viewController];
    return (index!=NSNotFound)?[self viewControllerAtIndex:index+1]:nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = [self indexOfViewController:viewController];
    return (index!=NSNotFound)?[self viewControllerAtIndex:index-1]:nil;
}

#pragma mark - UIPageViewControllerDelegate
- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers
       transitionCompleted:(BOOL)completed
{
    self.segmentView.currentIndex = [self indexOfViewController:[pageViewController.viewControllers firstObject]];
}

#pragma mrk - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kYGYueduMainPageViewControllerSegueID]) {
        self.pageVC = segue.destinationViewController;
    }
}

@end
