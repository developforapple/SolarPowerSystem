//
//  YGMyYueduViewCtrl.m
//  Golf
//
//  Created by bo wang on 16/6/29.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMyYueduViewCtrl.h"
#import "DDSegmentScrollView.h"
#import "YGMyLikedArticlesListViewCtrl.h"
#import "YGMyLikedAlbumsListViewCtrl.h"
//#import "YGMyDownloadedArticlesListViewCtrl.h"

static NSString *const kYGMyYueduPageViewControllerSegueID = @"YGMyYueduPageViewControllerSegueID";

@interface YGMyYueduViewCtrl ()<UIPageViewControllerDelegate,UIPageViewControllerDataSource>
@property (weak, nonatomic) IBOutlet DDSegmentScrollView *segmentView;
@property (weak, nonatomic) IBOutlet UIView *container;
@property (strong, nonatomic) UIPageViewController *pageViewCtrl;
@property (strong, nonatomic) YGMyLikedArticlesListViewCtrl *likedArticlesViewCtrl;
@property (strong, nonatomic) YGMyLikedAlbumsListViewCtrl *likedAlbumsViewCtrl;
//@property (strong, nonatomic) YGMyDownloadedArticlesListViewCtrl *downloadViewCtrl;
@end

@implementation YGMyYueduViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI
{
//    self.segmentView.titles = @[@"内容",@"缓存",@"专题"];
    self.segmentView.titles = @[@"内容",@"专题"];
    
    self.likedArticlesViewCtrl = [YGMyLikedArticlesListViewCtrl instanceFromStoryboard];
    self.likedAlbumsViewCtrl = [YGMyLikedAlbumsListViewCtrl instanceFromStoryboard];
//    self.downloadViewCtrl = [YGMyDownloadedArticlesListViewCtrl instanceFromStoryboard];
    
    self.likedArticlesViewCtrl.contentEdgeInsetsTop = 64.f+44.f;
    self.likedAlbumsViewCtrl.contentEdgeInsetsTop = 64.f+44.f;
    
    [self.pageViewCtrl setViewControllers:@[self.likedArticlesViewCtrl] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

- (IBAction)segmentDidChanged:(DDSegmentScrollView *)segment
{
    NSUInteger index = segment.currentIndex;
    UIViewController *vc;
    switch (index) {
        case 0: vc = self.likedArticlesViewCtrl;break;
//        case 1: vc = self.downloadViewCtrl;break;
//        case 2: vc = self.likedAlbumsViewCtrl;break;
        case 1: vc = self.likedAlbumsViewCtrl;
        default:break;
    }
    if (vc) {
        UIPageViewControllerNavigationDirection direction = index>segment.lastIndex?UIPageViewControllerNavigationDirectionForward:UIPageViewControllerNavigationDirectionReverse;
        [self.pageViewCtrl setViewControllers:@[vc] direction:direction animated:YES completion:nil];
    }
}
- (IBAction)exit:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIPageViewController
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
//    if (viewController == self.likedArticlesViewCtrl) {
//        return self.downloadViewCtrl;
//    }
//    if (viewController == self.downloadViewCtrl){
//        return self.likedAlbumsViewCtrl;
//    }
    if (viewController == self.likedArticlesViewCtrl) {
        return self.likedAlbumsViewCtrl;
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
//    if (viewController == self.likedAlbumsViewCtrl) {
//        return self.downloadViewCtrl;
//    }
//    if (viewController == self.downloadViewCtrl) {
//        return self.likedArticlesViewCtrl;
//    }
    if (viewController == self.likedAlbumsViewCtrl) {
        return self.likedArticlesViewCtrl;
    }
    return nil;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    NSUInteger index = 0;
    UIViewController *vc = [pageViewController.viewControllers firstObject];
//    if (vc == self.downloadViewCtrl) {
//        index = 1;
//    }else if (vc == self.likedAlbumsViewCtrl){
//        index = 2;
//    }
    if (vc == self.likedArticlesViewCtrl) {
        index = 0;
    }else if (vc == self.likedAlbumsViewCtrl){
        index = 1;
    }
    self.segmentView.currentIndex = index;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kYGMyYueduPageViewControllerSegueID]) {
        self.pageViewCtrl = segue.destinationViewController;
        self.pageViewCtrl.delegate = self;
        self.pageViewCtrl.dataSource = self;
    }
}

@end
