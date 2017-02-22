//
//  YGSearchViewCtrl.m
//  Golf
//
//  Created by bo wang on 16/7/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGSearchViewCtrl.h"
#import "YGSearchResultStack.h"
#import "YGSearchTypeViewCtrl.h"
#import "YGSearchCustomBar.h"
#import "YGSearchResultViewCtrl.h"

#import "ClubMainViewController.h"
#import "YG_MallCommodityViewCtrl.h"
#import "YGProfileViewCtrl.h"
#import "TrendsDetailsViewController.h"
#import "CoachDetailsViewController.h"
#import "YGArticleDetailViewCtrl.h"
#import "YGArticleImagesDetailViewCtrl.h"

static NSString *const kYGSearchResultStackSegueID = @"YGSearchResultStackSegueID";
static NSString *const kYGSearchTypeSegueID = @"YGSearchTypeSegueID";

@interface YGSearchViewCtrl () <YGSearchCustomBarDelegate>
{
    BOOL _firstAppearFlag;
}

@property (strong, nonatomic) NSString *defaultKeywords;

// 背景模糊。
@property (strong, nonatomic) UIImage *backReferImage;
@property (weak, nonatomic) IBOutlet UIImageView *backReferImageView;
@property (weak, nonatomic) IBOutlet UIToolbar *blurToolBar;

// 自定义搜索框
@property (weak, nonatomic) IBOutlet YGSearchCustomBar *customSearchBar;

// 显示结果
@property (weak, nonatomic) IBOutlet UIView *resultContainer;
@property (strong, nonatomic) YGSearchResultStack *resultStack;

// 显示搜索类型
@property (weak, nonatomic) IBOutlet UIView *typeContainer;
@property (strong, nonatomic) YGSearchTypeViewCtrl *typeViewCtrl;

// 搜索
@property (assign, nonatomic) YGSearchType curSearchType;   //当前搜索结果类型
@property (assign, nonatomic) BOOL resultVisible; //是显示类型选择 还是显示搜索结果

@end

@implementation YGSearchViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self noLeftButton];
    
    self.backReferImageView.image = self.backReferImage;
    [self.customSearchBar.searchBar becomeFirstResponder];
    self.customSearchBar.defaultPlaceholder = self.defaultKeywords;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!_firstAppearFlag) {
        _firstAppearFlag = YES;
        if (self.curSearchType != YGSearchTypeAll) {
            self.resultVisible = YES;
            
            [[self.resultStack topSearchViewCtrl] setType:self.curSearchType];
            self.resultStack.topResultViewCtrlVisible = YES;
            self.customSearchBar.alwaysHiddenBackBtn = YES;
        }
        [self searchTypeDidChanged:self.curSearchType];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.customSearchBar.searchBar endEditing:YES];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGRect frame = self.customSearchBar.frame;
    if (CGRectGetMinX(frame) > 20.f) {
        frame.size.width = Device_Width;
        self.customSearchBar.frame = frame;
    }
}

#pragma mark - Update
- (void)searchTypeDidChanged:(YGSearchType)newType
{
    self.curSearchType = newType;
    [self.customSearchBar updateWithType:newType];
}

- (void)pushResultViewCtrlOfType:(YGSearchType)type keywords:(NSString *)keywords
{
    ygweakify(self);
    YGSearchResultViewCtrl *vc = [YGSearchResultViewCtrl instanceFromStoryboard];
    [vc setWillShowResultDetail:^(id bean) {
        ygstrongify(self);
        [self showSearchResultBeanDetail:bean];
    }];
    vc.type = type;
    [self.resultStack push:vc];
    if (keywords.length != 0) {
        [vc searchWithKeywords:keywords];
    }
}

- (void)handleSelectedType:(YGSearchType)type
{
    ygweakify(self);
    void (^push)(void) = ^{
        ygstrongify(self);
        self.resultVisible = YES;
        [self searchTypeDidChanged:type];
        [self pushResultViewCtrlOfType:type keywords:nil];
        if (![self.customSearchBar.searchBar isFirstResponder]) {
            [self.customSearchBar.searchBar becomeFirstResponder];
        }
    };
    
    if (type & YGSearchTypeUser && ![LoginManager sharedManager].loginState) {
        [[LoginManager sharedManager] loginWithDelegate:nil controller:self animate:YES blockRetrun:^(id data) {
            push();
        } cancelReturn:^(id data) {
        }];
    }else{
        push();
    }
}

#pragma mark - Property
- (void)setTypeViewCtrl:(YGSearchTypeViewCtrl *)typeViewCtrl
{
    _typeViewCtrl = typeViewCtrl;
    
    ygweakify(self);
    [typeViewCtrl setDidSelectedType:^(YGSearchType type) {
        ygstrongify(self);
        [self handleSelectedType:type];
    }];
}

- (void)setResultStack:(YGSearchResultStack *)resultStack
{
    _resultStack = resultStack;
    ygweakify(self);
    [resultStack setInteractiveCompleted:^(BOOL finished) {
        ygstrongify(self);
        if (finished) {
            //成功返回
            [self searchTypeDidChanged:[self.resultStack topSearchType]];
            self.resultVisible = self.resultStack.topResultViewCtrlVisible;
        }
    }];
}

- (void)setResultVisible:(BOOL)resultVisible
{
    _resultVisible = resultVisible;
    
    [UIView animateWithDuration:.2f animations:^{
        
        if (!resultVisible) {
            self.customSearchBar.searchBar.text = nil;
        }
        
        NSUInteger resultIdx = [self.view.subviews indexOfObject:self.resultContainer];
        NSUInteger typeIdx = [self.view.subviews indexOfObject:self.typeContainer];
        
        BOOL resultIsFront = resultIdx > typeIdx;
        if (resultIsFront != resultVisible) {
            [self.view exchangeSubviewAtIndex:resultIdx withSubviewAtIndex:typeIdx];
        }
    }];
    [self.resultContainer setHidden:!resultVisible animated:YES];
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *identifier = segue.identifier;
    if ([identifier isEqualToString:kYGSearchResultStackSegueID]) {
        self.resultStack = segue.destinationViewController;
        
        ygweakify(self);
        [self.resultStack.rootResultViewCtrl setWillShowAllResult:^(YGSearchType type) {
            ygstrongify(self);
            [self searchTypeDidChanged:type];
            [self pushResultViewCtrlOfType:type keywords:self.customSearchBar.keywords];
        }];
        [self.resultStack.rootResultViewCtrl setWillShowResultDetail:^(id bean) {
            ygstrongify(self);
            [self showSearchResultBeanDetail:bean];
        }];
        
    }else if ([identifier isEqualToString:kYGSearchTypeSegueID]){
        self.typeViewCtrl = segue.destinationViewController;
    }
}

- (void)showSearchResultBeanDetail:(id)bean
{
    if ([bean isKindOfClass:[CourseResultBean class]]) {
        //跳转到球场详情
        ConditionModel *m = [ConditionModel new];
        m.clubId = [(CourseResultBean *)bean courseId];
        NSDate *tomorrow = [Utilities getTheDay:[NSDate date] withNumberOfDays:1];
        m.date = [Utilities stringwithDate:tomorrow];
        m.time = @"07:30";
        
        ClubMainViewController *vc = [ClubMainViewController instanceFromStoryboard];
        //        vc.clubId = [(CourseResultBean *)bean courseId];
        vc.cm = m;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if ([bean isKindOfClass:[CommodityResultBean class]]){
        //跳转到商品详情
        YG_MallCommodityViewCtrl *vc = [YG_MallCommodityViewCtrl instanceFromStoryboard];
//        vc.commodityId = [(CommodityResultBean *)bean commodityId];
        vc.cid = [(CommodityResultBean *)bean commodityId];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if ([bean isKindOfClass:[TopicResultBean class]]){
        //跳转到动态详情
        TrendsDetailsViewController *vc = [TrendsDetailsViewController instanceFromStoryboard];
        vc.topicId = [(TopicResultBean *)bean topicId];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if ([bean isKindOfClass:[MemberResultBean class]]){
        //跳转到用户个人页
        YGProfileViewCtrl *vc = [YGProfileViewCtrl instanceFromStoryboard];
        vc.memberId = [(MemberResultBean *)bean memberId];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if ([bean isKindOfClass:[HeadLineResultBean class]]){
        //跳转到头条
        HeadLineResultBean *hBean = bean;
        int type = hBean.type;
        int articleid = [(HeadLineResultBean *)bean id];
        
        if (type == 2) {
            // 多图
            YGArticleImagesDetailViewCtrl *vc = [YGArticleImagesDetailViewCtrl instanceFromStoryboard];
            vc.articleId = @(articleid);
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            // 其他
            YGArticleDetailViewCtrl *vc = [YGArticleDetailViewCtrl instanceFromStoryboard];
            vc.articleId = @(articleid);
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else if ([bean isKindOfClass:[CoachResultBean class]]){
        //跳转到教练个人页
        CoachDetailsViewController *vc = [CoachDetailsViewController instanceFromStoryboard];
        vc.coachId = [(CoachResultBean *)bean coachId];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - CustomSearchBarDelegate
- (void)searchCustomBarWillBack
{
    //类型是all时，返回按钮是被隐藏的
    if (YGSearchTypeAll != self.curSearchType) {
        //返回一层
        [self.resultStack pop];
        [self searchTypeDidChanged:[self.resultStack topSearchType]];
        RunAfter(.2f, ^{
            // 延迟.2f秒 让动画执行完再调整层级
            self.resultVisible = self.resultStack.topResultViewCtrlVisible;
        });
    }
}

- (void)searchCustomBarWillCancel
{
    [self dismiss];
}

- (void)searchCustomBarWillSearch
{
    NSString *keywords = [self.customSearchBar.keywords stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (keywords.length != 0) {
        // 点击键盘搜索按钮 开始搜索
        self.resultVisible = YES;
        [[self.resultStack topSearchViewCtrl] searchWithKeywords:keywords];
        self.resultStack.topResultViewCtrlVisible = YES;
    }
}

- (void)searchCustomBarTextDidChanged:(NSString *)text
{
    if (text.length == 0) {
        //清空了输入框
        [[self.resultStack topSearchViewCtrl] searchWithKeywords:nil];
        if (self.curSearchType == YGSearchTypeAll) {
            self.resultVisible = NO;
            self.resultStack.topResultViewCtrlVisible = NO;
        }
    }else{
        [self searchCustomBarWillSearch];
    }
}

#pragma mark - display
- (void)displayFromViewController:(UINavigationController *)viewController
{
    [self displayFromViewController:viewController keywords:nil type:YGSearchTypeAll];
}

- (void)displayFromViewController:(UINavigationController *)viewController keywords:(NSString *)keywords
{
    [self displayFromViewController:viewController keywords:keywords type:YGSearchTypeAll];
}

- (void)displayFromViewController:(UINavigationController *)viewController type:(YGSearchType )type
{
    [self displayFromViewController:viewController keywords:nil type:type];
}

- (void)displayFromViewController:(UINavigationController *)viewController keywords:(NSString *)keywords type:(YGSearchType )type
{
    self.backReferImage = [viewController.view.window snapshotImage];
    self.curSearchType = type;
    self.defaultKeywords = keywords;
    
    [UIView transitionWithView:viewController.view duration:0.32f options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [viewController pushViewController:self animated:NO];
    } completion:^(BOOL finished) {
    }];
}

- (void)dismiss
{
    [self.navigationController popViewControllerAnimated:NO];
}

@end
