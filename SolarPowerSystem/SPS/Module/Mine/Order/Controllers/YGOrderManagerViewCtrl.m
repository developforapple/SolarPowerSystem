//
//  YGOrderManagerViewCtrl.m
//  Golf
//
//  Created by bo wang on 2016/12/9.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGOrderManagerViewCtrl.h"
#import "YGOrdersSummaryViewCtrl.h"
#import "YGOrdersRecentListViewCtrl.h"
#import "DDSegmentScrollView.h"
#import "YGOrderManager.h"

@interface YGOrderManagerViewCtrl () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet DDSegmentScrollView *segmentControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentPanelHeightConstraint;
@property (strong, nonatomic) YGOrdersSummaryViewCtrl *summaryViewCtrl;
@property (strong, nonatomic) YGOrdersRecentListViewCtrl *recentViewCtrl;
@property (strong, nonatomic) YGOrderManager *manager;
@end

@implementation YGOrderManagerViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.segmentControl.titles = @[@"最近订单",@"全部订单"];
    self.manager = [[YGOrderManager alloc] init];
    ygweakify(self);
    [self.manager setDidLoadDataBlock:^(BOOL suc,BOOL isMore){
        ygstrongify(self);
        [self.summaryViewCtrl reload:self.manager];
        [self.recentViewCtrl reload:self.manager isMore:isMore];
    }];
    [self.manager reload];
}

- (IBAction)segmentDidChanged:(DDSegmentScrollView *)segment
{
    CGFloat offsetX = Device_Width * segment.currentIndex;
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    BOOL isSummary = scrollView.contentOffset.x > Device_Width/2;
    self.segmentControl.currentIndex = isSummary?YGOrderManagerSegmentSummary:YGOrderManagerSegmentRecent;
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"YGOrdersSummaryViewCtrlSegueID"]) {
        self.summaryViewCtrl = segue.destinationViewController;
        self.summaryViewCtrl.edgeInsetsTop = 64.f + self.segmentPanelHeightConstraint.constant;
    }else if ([segue.identifier isEqualToString:@"YGOrdersRecentListViewCtrlSegueID"]){
        self.recentViewCtrl = segue.destinationViewController;
        self.recentViewCtrl.edgeInsetsTop = 64.f + self.segmentPanelHeightConstraint.constant;
    }
}
@end
