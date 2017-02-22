//
//  KDScrollView.m
//  Golf
//
//  Created by 黄希望 on 14-1-20.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "KDScrollView.h"

@interface KDScrollView (){
    NSUInteger lastIndex;
}

@property (nonatomic,strong) UIView *containerView;
- (void)tileGridsFromMinX:(CGFloat)minimumVisibleX toMaxX:(CGFloat)maximumVisibleX;
@end

@implementation KDScrollView
@synthesize visibleImg = _visibleImg;
@synthesize imgReusableQueue = _imgReusableQueue;
@synthesize pageWidth = _pageWidth;
@synthesize currentIndex = _currentIndex;
@synthesize containerView = _containerView;
@synthesize aDataSource = _aDataSource;

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.visibleImg = [NSMutableArray array];
        self.imgReusableQueue = [NSMutableArray array];
        self.containerView = [[UIView alloc] init];
        self.showsHorizontalScrollIndicator = NO;
        self.currentIndex = 0;
        self.pageWidth = 6.f;
        self.delegate = self;
        self.scrollEnabled = YES;
        [self addSubview:self.containerView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    //NSUInteger totalGrids = [self.aDataSource numberOfInfiniteImgs];
    self.contentSize = CGSizeMake(Device_Height*2, 40);// CGSizeMake(totalGrids * _pageWidth, 40);
    self.containerView.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
}

- (id)dequeueReusableImg{
    if (self.imgReusableQueue.count==0) {
        return nil;
    }
    id imgv = [self.imgReusableQueue lastObject];
    [self.imgReusableQueue removeObject:imgv];
    return imgv;
}

- (void)recenterIfNecessary {
    CGPoint currentOffset = self.contentOffset;
    CGFloat contentWidth = self.contentSize.width;
    CGFloat centerOffsetX = (contentWidth - self.bounds.size.width) / 2.0;
    CGFloat distanceFromCenter = fabs(currentOffset.x - centerOffsetX);
    
    if (distanceFromCenter > (contentWidth / 4.0)) {
        self.contentOffset = CGPointMake(centerOffsetX, currentOffset.y);
        
        for (UIImageView *imgv in self.visibleImg) {
            CGPoint center = [self.containerView convertPoint:imgv.center toView:self];
            center.x += (centerOffsetX - currentOffset.x);
            imgv.center = [self convertPoint:center toView:self.containerView];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self recenterIfNecessary];
    
    CGRect visibleBounds = [self convertRect:self.bounds toView:self.containerView];
    CGFloat minimumVisibleX = CGRectGetMinX(visibleBounds);
    CGFloat maximumVisibleX = CGRectGetMaxX(visibleBounds);
    
    [self tileGridsFromMinX:minimumVisibleX toMaxX:maximumVisibleX];
}

- (UIImageView *)insertImgWithIndex:(NSInteger)index {
    
    if (self.aDataSource && [self.aDataSource respondsToSelector:@selector(infiniteImgView:forIndex:)]) {
        int flag  = 0;
        if (abs((int)index)%10 == 0) {
            flag = 10;
        }else if (abs((int)index)%10 == 5){
            flag = 5;
        }else{
            flag = 1;
        }
        
        NSString *imageName = [NSString stringWithFormat:@"kd_%d",flag];
        
        UIImageView *kd = [self.aDataSource infiniteImgView:self forIndex:index];
        kd.image = [UIImage imageNamed:imageName];
        kd.tag = index;
        [self.containerView addSubview:kd];
        
        return kd;
    }
    return nil;
}

- (CGFloat)placeNewImgOnRight:(CGFloat)rightEdge {
    if ([self.visibleImg count] > 0) {
        UIView *lastGrid = [self.visibleImg lastObject];
        NSInteger nextIndex = lastGrid.tag + 1;
        self.currentIndex = nextIndex;
    }
    
    UIImageView *imgv = [self insertImgWithIndex:self.currentIndex];
    [self.visibleImg addObject:imgv];
    
    CGRect frame = imgv.frame;
    frame.origin.x = rightEdge;
    frame.origin.y = self.containerView.bounds.size.height - frame.size.height;
    imgv.frame = frame;
    
    return CGRectGetMaxX(frame);
}

- (CGFloat)placeNewImgOnLeft:(CGFloat)leftEdge {
    UIImageView *firstGrid = [self.visibleImg
                         objectAtIndex:0];
    NSInteger previousIndex = firstGrid.tag - 1;
    self.currentIndex = previousIndex;
    
    
    UIImageView *imgv = [self insertImgWithIndex:self.currentIndex];
    [self.visibleImg insertObject:imgv atIndex:0];
    
    CGRect frame = imgv.frame;
    frame.origin.x = leftEdge - frame.size.width;
    frame.origin.y = self.containerView.bounds.size.height - frame.size.height;
    imgv.frame = frame;
    
    return CGRectGetMinX(frame);
}

- (void)tileGridsFromMinX:(CGFloat)minimumVisibleX toMaxX:(CGFloat)maximumVisibleX {
    if ([self.visibleImg count] == 0) {
        [self placeNewImgOnRight:minimumVisibleX];
    }
    
    UIImageView *lastGrid = [self.visibleImg lastObject];
    CGFloat rightEdge = CGRectGetMaxX(lastGrid.frame);
    while (rightEdge < maximumVisibleX) {
        rightEdge = [self placeNewImgOnRight:rightEdge];
    }
    
    UIImageView *firstGrid = [self.visibleImg objectAtIndex:0];
    CGFloat leftEdge = CGRectGetMinX(firstGrid.frame);
    while (leftEdge > minimumVisibleX) {
        leftEdge = [self placeNewImgOnLeft:leftEdge];
    }
    
    lastGrid = [self.visibleImg lastObject];
    while (lastGrid.frame.origin.x > maximumVisibleX) {
        [lastGrid removeFromSuperview];
        [self.visibleImg removeLastObject];
        [self.imgReusableQueue addObject:lastGrid];
        
        lastGrid = [self.visibleImg lastObject];
    }
    
    firstGrid = [self.visibleImg objectAtIndex:0];
    while (CGRectGetMaxX(firstGrid.frame) < minimumVisibleX) {
        [firstGrid removeFromSuperview];
        [self.visibleImg removeObjectAtIndex:0];
        [self.imgReusableQueue addObject:firstGrid];
        
        firstGrid = [self.visibleImg objectAtIndex:0];
    }
}

- (UIImageView *)gridViewAtPoint:(CGPoint)point {
    __block UIImageView *gridView = nil;
    [self.visibleImg enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIImageView *visibleGridView = (UIImageView *)obj;
        if (CGRectContainsPoint(visibleGridView.frame, point)) {
            gridView = visibleGridView;
            *stop = YES;
        }
    }];
    return gridView;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    if ([self.aDataSource respondsToSelector:@selector(touchWithStatus:)]) {
        [self.aDataSource touchWithStatus:1];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([self.aDataSource respondsToSelector:@selector(touchWithStatus:)]) {
        [self.aDataSource touchWithStatus:0];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([self.aDataSource respondsToSelector:@selector(touchWithStatus:)]) {
        [self.aDataSource touchWithStatus:1];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        if ([self.aDataSource respondsToSelector:@selector(touchWithStatus:)]) {
            [self.aDataSource touchWithStatus:0];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (lastIndex != self.currentIndex) {
        if ([self.aDataSource respondsToSelector:@selector(handleAction:)]) {
            [self.aDataSource handleAction:self.currentIndex > lastIndex ? -1 : 1];
        }
    }
    lastIndex = self.currentIndex;
}

@end
