//
//  XLCycleScrollView.h
//  CycleScrollViewDemo
//
//  Created by xie liang on 9/14/12.
//  Copyright (c) 2012 xie liang. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol XLCycleScrollViewDelegate;
@protocol XLCycleScrollViewDatasource;

@interface XLCycleScrollView : UIView<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
    
    id<XLCycleScrollViewDelegate> __weak _delegate;
    id<XLCycleScrollViewDatasource> _datasource;
    
    NSInteger _curPage;
    
    NSMutableArray *_curViews;
    
    CGFloat _targeX;
}

@property (nonatomic,readonly) UIScrollView *scrollView;
@property (nonatomic,readonly) UIPageControl *pageControl;
@property (nonatomic,assign) NSInteger currentPage;
@property (nonatomic) NSInteger totalPages;
@property (nonatomic,setter = setDataource:) id<XLCycleScrollViewDatasource> datasource;
@property (nonatomic,weak,setter = setDelegate:) id<XLCycleScrollViewDelegate> delegate;
@property (nonatomic) BOOL autoScroll;
@property (nonatomic,assign) BOOL needCustomIndicatorTintColor;

- (id)initWithFrame:(CGRect)frame autoScroll:(BOOL)autoScroll;
- (void)clear;
- (void)reloadData;
- (void)pageNext;

@end

@protocol XLCycleScrollViewDelegate <NSObject>

@optional
- (void)XLCycleScrollViewClickAction:(NSInteger)page;;

@end

@protocol XLCycleScrollViewDatasource <NSObject>

@required
- (NSInteger)numberOfPages;
- (id)pageAtIndex:(NSInteger)index;

@end
