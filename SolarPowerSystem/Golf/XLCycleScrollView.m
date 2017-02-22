//
//  XLCycleScrollView.m
//  CycleScrollViewDemo
//
//  Created by xie liang on 9/14/12.
//  Copyright (c) 2012 xie liang. All rights reserved.
//

#import "XLCycleScrollView.h"
#import "UIImageView+WebCache.h"

@interface XLCycleScrollView ()

@end

@implementation XLCycleScrollView

@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize currentPage = _curPage;
@synthesize datasource = _datasource;
@synthesize delegate = _delegate;
@synthesize autoScroll = _autoScroll;
@synthesize totalPages = _totalPages;


- (id)initWithFrame:(CGRect)frame autoScroll:(BOOL)aAutoScroll;
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autoScroll = aAutoScroll;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _scrollView.delegate = self;
        _scrollView.contentSize = CGSizeMake(self.bounds.size.width * 3, self.bounds.size.height);
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentOffset = CGPointMake(self.bounds.size.width, 0);
        _scrollView.pagingEnabled = YES;
        [self addSubview:_scrollView];
        
        CGRect rect = self.bounds;
        rect.origin.y = rect.size.height - 15;
        rect.size.height = 15;
        _pageControl = [[UIPageControl alloc] initWithFrame:rect];
        _pageControl.userInteractionEnabled = NO;
        [self addSubview:_pageControl];
        
        _curPage = 0;
        
        if (self.autoScroll) {
            [self performSelector:@selector(pageNext) withObject:nil afterDelay:5];
        }
    }
    return self;
}

- (void)setNeedCustomIndicatorTintColor:(BOOL)needCustomIndicatorTintColor{
    if (needCustomIndicatorTintColor) {
        _pageControl.pageIndicatorTintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pagecontrol_normal"]];
        _pageControl.currentPageIndicatorTintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pagecontrol_select"]];
    }
}

- (void)clear{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pageNext) object:nil];
}

- (void)setDataource:(id<XLCycleScrollViewDatasource>)datasource
{
    _datasource = datasource;
    [self reloadData];
}

- (void)reloadData
{
    if ([self.datasource respondsToSelector:@selector(numberOfPages)]) {
        self.totalPages = [self.datasource numberOfPages];
        if (!self.totalPages) {
            return;
        }
        _pageControl.numberOfPages = self.totalPages;
        [self loadData];
    }
}

- (void)loadData
{
    if (self.totalPages == 0) {
        return;
    }
    _pageControl.currentPage = _curPage;
    
    NSArray *subViews = [_scrollView subviews];
    if([subViews count] != 0) {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    [self getDisplayImagesWithCurpage:_curPage];
    
    for (int i = 0; i < 3; i++) {
        UIView *v = [_curViews objectAtIndex:i];
        v.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(handleTap:)];
        [v addGestureRecognizer:singleTap];
        v.frame = CGRectOffset(v.frame, v.frame.size.width * i, 0);
        [_scrollView addSubview:v];
    }
    
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
    
    if (self.totalPages < 2) {
        _scrollView.pagingEnabled = NO;
        _pageControl.hidden = YES;
        _scrollView.scrollEnabled = NO;
    }else{
        _pageControl.hidden = NO;
        _scrollView.scrollEnabled = YES;
        _scrollView.pagingEnabled = YES;
    }
}

- (void)getDisplayImagesWithCurpage:(NSInteger)page {
    
    NSInteger pre = [self validPageValue:(_curPage-1)];
    
    NSInteger last = [self validPageValue:(_curPage+1)];
    if (!_curViews) {
        _curViews = [[NSMutableArray alloc] init];
    }
    
    [_curViews removeAllObjects];
    
    UIImageView *preImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [preImg sd_setImageWithURL:[NSURL URLWithString:[self.datasource pageAtIndex:pre]] placeholderImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#e6e6e6"]]];
    [_curViews addObject:preImg];
    
    UIImageView *currImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [currImg sd_setImageWithURL:[NSURL URLWithString:[self.datasource pageAtIndex:_curPage]] placeholderImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#e6e6e6"]]];
    [_curViews addObject:currImg];
    
    UIImageView *lastImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [lastImg sd_setImageWithURL:[NSURL URLWithString:[self.datasource pageAtIndex:last]] placeholderImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#e6e6e6"]]];
    [_curViews addObject:lastImg];
}

- (NSInteger)validPageValue:(NSInteger)value {
    if(value == -1) value = self.totalPages - 1;
    if(value == self.totalPages) value = 0;
    
    return value;
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    if ([_delegate respondsToSelector:@selector(XLCycleScrollViewClickAction:)]) {
        [_delegate XLCycleScrollViewClickAction:_curPage];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pageNext) object:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    int x = aScrollView.contentOffset.x;
    //往下翻一张
    if(x >= (2*self.frame.size.width)) {
        _curPage = [self validPageValue:_curPage+1];
        [self loadData];
    }
    
    //往上翻
    if(x <= 0) {
        _curPage = [self validPageValue:_curPage-1];
        [self loadData];
    }
    
    if (self.autoScroll) {
        [self performSelector:@selector(pageNext) withObject:nil afterDelay:5];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView {
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:YES];
}

- (void)pageNext{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pageNext) object:nil];
    
    if (self.totalPages < 2) {
        _scrollView.pagingEnabled = NO;
        _pageControl.hidden = YES;
        _scrollView.scrollEnabled = NO;
        return;
    }else{
        _pageControl.hidden = NO;
        _scrollView.scrollEnabled = YES;
        _scrollView.pagingEnabled = YES;
    }
    
    _targeX = _scrollView.contentOffset.x+ _scrollView.frame.size.width;
    [self moveToTargetPosition:_targeX];
    _curPage = [self validPageValue:_curPage];
    [self loadData];
    if (self.autoScroll) {
        [self performSelector:@selector(pageNext) withObject:nil afterDelay:5];
    }
}

- (void)moveToTargetPosition:(CGFloat)targetX
{
    [_scrollView setContentOffset:CGPointMake(_targeX, 0) animated:YES] ;
    _pageControl.currentPage = (int)(_targeX / _scrollView.frame.size.width);
}

@end
