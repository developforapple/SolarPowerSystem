//
//  YGReorderableLayout.m
//  Golf
//
//  Created by bo wang on 2016/12/16.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGReorderableLayout.h"

@interface YGCellFakeView : UIView
@property (weak, nonatomic) UICollectionViewCell *cell;
@property (strong, nonatomic) UIImageView *cellFakeImageView;
@property (strong, nonatomic) UIImageView *cellFakeHightedView;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (assign, nonatomic) CGPoint originalCenter;
@property (assign, nonatomic) CGRect cellFrame;

- (instancetype)initWithCell:(UICollectionViewCell *)cell;
- (void)changeBoundsIfNeeded:(CGRect)bounds;
- (void)pushFowardView;
- (void)pushBackView:(void(^)(void))block;
@end


typedef NS_ENUM(NSUInteger, _Direction) {
    _toTop,
    _toEnd,
    _stay,
};

static CGFloat funcDirectionScrollValue(_Direction direction,CGFloat speedValue,CGFloat percentage){
    CGFloat v = 0.f;
    switch (direction) {
        case _toTop: v = -speedValue;   break;
        case _toEnd: v = speedValue;    break;
        case _stay:  return 0.f;        break;
    }
    CGFloat proofedPercentage = MAX(MIN(1.f, percentage), 0);
    return v * proofedPercentage;
}

@interface YGReorderableLayout () <UIGestureRecognizerDelegate>

@property (assign, nonatomic) _Direction continuousScrollDirection; //default _stay
@property (strong, nonatomic) CADisplayLink *displayLink;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPress;
@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;
@property (strong, nonatomic) YGCellFakeView *cellFakeView;

@property (assign, nonatomic) CGPoint panTranslation;
@property (assign, nonatomic) CGPoint fakeCellCenter;
@property (assign, nonatomic) UIEdgeInsets trigerInsets; //default 100,100,100,100
@property (assign, nonatomic) UIEdgeInsets trigerPadding; //default 0,0,0,0
@property (assign, nonatomic) CGFloat scrollSpeedValue;  //default 10

@end

@implementation YGReorderableLayout

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.continuousScrollDirection = _stay;
        self.trigerInsets = UIEdgeInsetsMake(100, 100, 100, 100);
        self.trigerPadding = UIEdgeInsetsZero;
        self.scrollSpeedValue = 10.f;
        self.reorderingItemAlpha = 0.f;
        [self configureObserver];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.continuousScrollDirection = _stay;
        self.trigerInsets = UIEdgeInsetsMake(100, 100, 100, 100);
        self.trigerPadding = UIEdgeInsetsZero;
        self.scrollSpeedValue = 10.f;
        self.reorderingItemAlpha = 0.f;
        [self configureObserver];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"collectionView"];
}

- (void)configureObserver
{
    [self addObserver:self forKeyPath:@"collectionView" options:kNilOptions context:NULL];
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    self.trigerInsets = [self getScrollTrigerEdgeInsets];
    self.trigerPadding = [self getScrollTrigerPadding];
    self.scrollSpeedValue = [self getScrollSpeedValue];
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    if (self.cellFakeView && self.cellFakeView.indexPath) {
        for (UICollectionViewLayoutAttributes *attributes in array) {
            if (attributes.representedElementCategory == UICollectionElementCategoryCell &&
                attributes.indexPath.section == self.cellFakeView.indexPath.section &&
                attributes.indexPath.item == self.cellFakeView.indexPath.item) {
                attributes.alpha = [self getReorderingItemAlphaInSection:attributes.indexPath.section];
            }
        }
    }
    return array;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"collectionView"]) {
        [self setUpGestureRecognizers];
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setUpDisplayLink
{
    if (!self.displayLink) {
        
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(continuousScroll)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)invalidateDisplayLink
{
    self.continuousScrollDirection = _stay;
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)beginScrollIfNeeded
{
    if (!self.cellFakeView) return;
    
    CGFloat fakeCellTopEdge = [self fakeCellTopEdge];
    CGFloat offsetFromTop = [self offsetFromTop];
    CGFloat triggerPaddingTop = [self triggerPaddingTop];
    CGFloat triggerInsetTop = [self triggerInsetTop];
    CGFloat fakeCellEndEdge = [self fakeCellEndEdge];
    CGFloat collectionViewLength = [self collectionViewLength];
    CGFloat triggerPaddingEnd = [self triggerPaddingEnd];
    CGFloat triggerInsetEnd = [self triggerInsetEnd];
    
    if (fakeCellTopEdge <= offsetFromTop + triggerPaddingTop + triggerInsetTop) {
        self.continuousScrollDirection = _toTop;
        [self setUpDisplayLink];
    }else if (fakeCellEndEdge >= offsetFromTop + collectionViewLength - triggerPaddingEnd - triggerInsetEnd){
        self.continuousScrollDirection = _toEnd;
        [self setUpDisplayLink];
    }else{
        [self invalidateDisplayLink];
    }
}

- (void)moveItemIfNeeded
{
    NSIndexPath *atIndexPath = self.cellFakeView.indexPath;
    NSIndexPath *toIndexPath = [self.collectionView indexPathForItemAtPoint:self.cellFakeView.center];
    if (!self.cellFakeView || !atIndexPath || !toIndexPath) return;
    if (atIndexPath.section == toIndexPath.section && atIndexPath.item == toIndexPath.item) return;
    
    BOOL canMove = [self getCanMoveItemAtIndexPath:atIndexPath to:toIndexPath];
    if (!canMove) return;
    
    [self callWillMoveItemAtIndexPath:atIndexPath to:toIndexPath];
    
    UICollectionViewLayoutAttributes *attribute = [self layoutAttributesForItemAtIndexPath:toIndexPath];
    __weak typeof(self) weakSelf = self;
    [self.collectionView performBatchUpdates:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.cellFakeView.indexPath = toIndexPath;
        strongSelf.cellFakeView.cellFrame = attribute.frame;
        [strongSelf.cellFakeView changeBoundsIfNeeded:attribute.bounds];
        
        [strongSelf.collectionView deleteItemsAtIndexPaths:@[atIndexPath]];
        [strongSelf.collectionView insertItemsAtIndexPaths:@[toIndexPath]];
        
        [strongSelf callDidMoveItemAtIndexPath:atIndexPath to:toIndexPath];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)continuousScroll
{
    if (!self.cellFakeView) return;
    
    CGFloat percentage = [self calcTriggerPercentage];
    CGFloat scrollRate =  funcDirectionScrollValue(self.continuousScrollDirection, self.scrollSpeedValue, percentage);
    CGFloat offset = [self offsetFromTop];
    CGFloat length = [self collectionViewLength];
    CGFloat insetsTop = [self insetsTop];
    CGFloat contentLength = [self contentLength];
    CGFloat insetsEnd = [self insetsEnd];
    
    if (contentLength + insetsTop + insetsEnd <= length) return;
    
    if (offset + scrollRate <= -insetsTop) {
        scrollRate = -insetsTop - offset;
    }else if (offset + scrollRate >= contentLength + insetsEnd - length){
        scrollRate = contentLength + insetsEnd - length - offset;
    }
    __weak typeof(self) weakSelf = self;
    [self.collectionView performBatchUpdates:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.scrollDirection == UICollectionViewScrollDirectionVertical) {
            CGPoint fakeCellCenter = strongSelf.fakeCellCenter;
            fakeCellCenter.y += scrollRate;
            strongSelf.fakeCellCenter = fakeCellCenter;
            
            CGPoint sfFakeCellCenter = strongSelf.cellFakeView.center;
            sfFakeCellCenter.y = fakeCellCenter.y + [strongSelf panTranslation].y;
            strongSelf.cellFakeView.center = sfFakeCellCenter;
            
            CGPoint offset = strongSelf.collectionView.contentOffset;
            offset.y += scrollRate;
            strongSelf.collectionView.contentOffset = offset;

        }else{
            CGPoint fakeCellCenter = strongSelf.fakeCellCenter;
            fakeCellCenter.x += scrollRate;
            strongSelf.fakeCellCenter = fakeCellCenter;
            
            CGPoint sfFakeCellCenter = strongSelf.cellFakeView.center;
            sfFakeCellCenter.x = fakeCellCenter.x + [strongSelf panTranslation].x;
            strongSelf.cellFakeView.center = sfFakeCellCenter;
            
            CGPoint offset = strongSelf.collectionView.contentOffset;
            offset.x += scrollRate;
            strongSelf.collectionView.contentOffset = offset;
        }
    } completion:^(BOOL finished) {
        
    }];
    
    [self moveItemIfNeeded];
}

- (CGFloat)calcTriggerPercentage
{
    if (!self.cellFakeView) return 0.f;
    
    CGFloat offset = [self offsetFromTop];
    CGFloat offsetEnd = offset + [self collectionViewLength];
    CGFloat paddingEnd = [self triggerPaddingEnd];
    
    CGFloat percentage = 0.f;
    
    if (self.continuousScrollDirection == _toTop) {
        CGFloat fakeCellTopEdge = [self fakeCellTopEdge];
        if (fakeCellTopEdge) {
            percentage = 1.f - ((fakeCellTopEdge - (offset + [self triggerPaddingTop])) / [self triggerInsetTop]);
        }
    }else if (self.continuousScrollDirection == _toEnd){
        CGFloat fakeCellEdge = [self fakeCellEndEdge];
        if (fakeCellEdge) {
            percentage = 1.f - ((([self insetsTop] + offsetEnd - paddingEnd) - (fakeCellEdge + [self insetsTop])) / [self triggerInsetEnd]);
        }
    }
    
    percentage = MIN(1.f, MAX(0, percentage));
    return percentage;
}

- (void)setUpGestureRecognizers
{
    if (!self.collectionView) return;
    if (self.longPress && self.panGesture) return;
    
    self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    
    self.longPress.delegate = self;
    self.panGesture.delegate = self;
    self.panGesture.maximumNumberOfTouches = 1;
    
    for (UIGestureRecognizer *gr in self.collectionView.gestureRecognizers) {
        if ([gr isKindOfClass:[UILongPressGestureRecognizer class]]) {
            [gr requireGestureRecognizerToFail:self.longPress];
        }
    }
    [self.collectionView addGestureRecognizer:self.longPress];
    [self.collectionView addGestureRecognizer:self.panGesture];
}

- (void)cancelDrag
{
    [self cancelDragToIndexPath:nil];
}

- (void)cancelDragToIndexPath:(NSIndexPath *)indexPath
{
    if (!self.cellFakeView) return;
    
    [self callWillEndDraggingItemTo:indexPath];
    
    self.collectionView.scrollsToTop = YES;
    self.fakeCellCenter = CGPointZero;
    [self invalidateDisplayLink];
    
    __weak typeof(self) weakSelf = self;
    [self.cellFakeView pushBackView:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.cellFakeView removeFromSuperview];
        strongSelf.cellFakeView = nil;
        [strongSelf invalidateLayout];
        
        [strongSelf callDidEndDraggingItemTo:indexPath];
    }];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress
{
    if (!self.dragEnabled) return;
    
    CGPoint location =  [longPress locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    
    if (self.cellFakeView) {
        indexPath = self.cellFakeView.indexPath;
    }
    
    if (!indexPath) return;
    
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:{
            [self callWillBeginDraggingItemAtIndexPath:indexPath];
            self.collectionView.scrollsToTop = NO;
            
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            
            self.cellFakeView = [[YGCellFakeView alloc] initWithCell:cell];
            self.cellFakeView.indexPath = indexPath;
            self.cellFakeView.originalCenter = cell.center;
            self.cellFakeView.cellFrame = [self layoutAttributesForItemAtIndexPath:indexPath].frame;
            
            [self.collectionView addSubview:self.cellFakeView];
            
            self.fakeCellCenter = self.cellFakeView.center;
            
            [self invalidateLayout];
            
            [self.cellFakeView pushFowardView];
            
            [self callDidBeginDraggingItemAt:indexPath];
            
        }   break;
        case UIGestureRecognizerStateEnded:{
            [self cancelDragToIndexPath:indexPath];
        }   break;
        default:
            break;
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture
{
    if (!self.dragEnabled) return;
    
    self.panTranslation = [panGesture translationInView:self.collectionView];
    if (self.cellFakeView) {
        
        switch (panGesture.state) {
            case UIGestureRecognizerStateChanged:{
                
                CGPoint center = self.cellFakeView.center;
                center.x = self.fakeCellCenter.x + self.panTranslation.x;
                center.y = self.fakeCellCenter.y + self.panTranslation.y;
                self.cellFakeView.center = center;
                
                [self beginScrollIfNeeded];
                [self moveItemIfNeeded];
                
            }   break;
            case UIGestureRecognizerStateCancelled:{
                [self invalidateDisplayLink];
            }   break;
            default:
                break;
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    BOOL allowMove = [self getAllowMoveItemAtIndexPath:indexPath];
    if (!allowMove) {
        return NO;
    }
    
    if (gestureRecognizer == self.longPress) {
        allowMove = !(self.collectionView.panGestureRecognizer.state != UIGestureRecognizerStatePossible && self.collectionView.panGestureRecognizer.state != UIGestureRecognizerStateFailed);
    }else if (gestureRecognizer == self.panGesture){
        allowMove = !(self.longPress.state == UIGestureRecognizerStatePossible || self.longPress.state == UIGestureRecognizerStateFailed);
    }
    return allowMove;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == self.panGesture) {
        return otherGestureRecognizer == self.longPress;
    }
    if (gestureRecognizer == self.collectionView.panGestureRecognizer) {
        return self.longPress.state != UIGestureRecognizerStatePossible || self.longPress.state != UIGestureRecognizerStateEnded;
    }
    return YES;
}

#pragma mark -
- (id)delegate
{
    return self.collectionView.delegate;
}

- (void)setDelegate:(id<YGReorderableLayoutDelegate>)delegate
{
    self.collectionView.delegate = delegate;
}

- (id)dataSource
{
    return self.collectionView.dataSource;
}

- (void)setDataSource:(id<YGReorderableLayoutDataSource>)dataSource
{
    self.collectionView.dataSource = dataSource;
}

#pragma mark - call Data Source Method

- (CGFloat)getReorderingItemAlphaInSection:(NSInteger)section
{
    CGFloat alpha = self.reorderingItemAlpha;
    if ([self.dataSource respondsToSelector:@selector(collectionView:reorderingItemAlphaInSection:)]) {
        alpha = [self.dataSource collectionView:self.collectionView reorderingItemAlphaInSection:section];
    }
    return alpha;
}

- (UIEdgeInsets)getScrollTrigerEdgeInsets
{
    UIEdgeInsets insets = self.trigerInsets;
    if ([self.dataSource respondsToSelector:@selector(scrollTrigerEdgeInsetsInCollectionView:)]) {
        insets = [self.dataSource scrollTrigerEdgeInsetsInCollectionView:self.collectionView];
    }
    return insets;
}

- (UIEdgeInsets)getScrollTrigerPadding
{
    UIEdgeInsets padding = self.trigerPadding;
    if ([self.dataSource respondsToSelector:@selector(scrollTrigerPaddingInCollectionView:)]) {
        padding = [self.dataSource scrollTrigerPaddingInCollectionView:self.collectionView];
    }
    return padding;
}

- (CGFloat)getScrollSpeedValue
{
    CGFloat value = self.scrollSpeedValue;
    if ([self.dataSource respondsToSelector:@selector(scrollSpeedValueInCollectionView:)]) {
        value = [self.dataSource scrollSpeedValueInCollectionView:self.collectionView];
    }
    return value;
}

#pragma mark - call Delegate Method

- (BOOL)getAllowMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL allow = YES;
    if ([self.delegate respondsToSelector:@selector(collectionView:allowMoveItemAtIndexPath:)]) {
        allow = [self.delegate collectionView:self.collectionView allowMoveItemAtIndexPath:indexPath];
    }
    return allow;
}

- (BOOL)getCanMoveItemAtIndexPath:(NSIndexPath *)at to:(NSIndexPath *)to
{
    BOOL can = YES;
    if ([self.delegate respondsToSelector:@selector(collectionView:canMoveItemAtIndexPath:toIndexPath:)]) {
        can = [self.delegate collectionView:self.collectionView canMoveItemAtIndexPath:at toIndexPath:to];
    }
    return can;
}

- (void)callWillMoveItemAtIndexPath:(NSIndexPath *)at to:(NSIndexPath *)to
{
    if ([self.delegate respondsToSelector:@selector(collectionView:willMoveItemAtIndexPath:toIndexPath:)]) {
        [self.delegate collectionView:self.collectionView willMoveItemAtIndexPath:at toIndexPath:to];
    }
}

- (void)callDidMoveItemAtIndexPath:(NSIndexPath *)at to:(NSIndexPath *)to
{
    if ([self.delegate respondsToSelector:@selector(collectionView:didMoveItemAtIndexPath:toIndexPath:)]) {
        [self.delegate collectionView:self.collectionView didMoveItemAtIndexPath:at toIndexPath:to];
    }
}

- (void)callWillBeginDraggingItemAtIndexPath:(NSIndexPath *)at
{
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:willBeginDraggingItemAtIndexPath:)]) {
        [self.delegate collectionView:self.collectionView layout:self willBeginDraggingItemAtIndexPath:at];
    }
}

- (void)callDidBeginDraggingItemAt:(NSIndexPath *)at
{
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:didBeginDraggingItemAt:)]) {
        [self.delegate collectionView:self.collectionView layout:self didBeginDraggingItemAt:at];
    }
}


- (void)callWillEndDraggingItemTo:(NSIndexPath *)to
{
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:willEndDraggingItemTo:)]) {
        [self.delegate collectionView:self.collectionView layout:self willEndDraggingItemTo:to];
    }
}


- (void)callDidEndDraggingItemTo:(NSIndexPath *)to
{
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:didEndDraggingItemTo:)]) {
        [self.delegate collectionView:self.collectionView layout:self didEndDraggingItemTo:to];
    }
}


#pragma mark -
- (CGFloat)offsetFromTop
{
    CGPoint offset = self.collectionView.contentOffset;
    return self.scrollDirection == UICollectionViewScrollDirectionVertical?offset.y:offset.x;
}

- (CGFloat)insetsTop
{
    UIEdgeInsets insets = self.collectionView.contentInset;
    return self.scrollDirection == UICollectionViewScrollDirectionVertical?insets.top:insets.left;
}

- (CGFloat)insetsEnd
{
    UIEdgeInsets insets = self.collectionView.contentInset;
    return self.scrollDirection == UICollectionViewScrollDirectionVertical?insets.bottom:insets.right;
}

- (CGFloat)contentLength
{
    CGSize size = self.collectionView.contentSize;
    return self.scrollDirection == UICollectionViewScrollDirectionVertical?size.height:size.width;
}

- (CGFloat)collectionViewLength
{
    CGSize size = self.collectionView.bounds.size;
    return self.scrollDirection == UICollectionViewScrollDirectionVertical?size.height:size.width;
}

- (CGFloat)fakeCellTopEdge
{
    if (self.cellFakeView) {
        return self.scrollDirection == UICollectionViewScrollDirectionVertical?CGRectGetMinY(self.cellFakeView.frame):CGRectGetMinX(self.cellFakeView.frame);
    }
    return 0.f;
}

- (CGFloat)fakeCellEndEdge
{
    if (self.cellFakeView) {
        return self.scrollDirection == UICollectionViewScrollDirectionVertical?CGRectGetMaxY(self.cellFakeView.frame):CGRectGetMaxX(self.cellFakeView.frame);
    }
    return 0.f;
}

- (CGFloat)triggerInsetTop
{
    return self.scrollDirection == UICollectionViewScrollDirectionVertical?self.trigerInsets.top:self.trigerInsets.left;
}

- (CGFloat)triggerInsetEnd
{
    return self.scrollDirection == UICollectionViewScrollDirectionVertical?self.trigerInsets.top:self.trigerInsets.left;
}

- (CGFloat)triggerPaddingTop
{
    return self.scrollDirection == UICollectionViewScrollDirectionVertical?self.trigerPadding.top:self.trigerPadding.left;
}

- (CGFloat)triggerPaddingEnd
{
    return self.scrollDirection == UICollectionViewScrollDirectionVertical?self.trigerPadding.bottom:self.trigerPadding.right;
}

@end

@implementation YGCellFakeView

- (instancetype)initWithCell:(UICollectionViewCell *)cell
{
    self = [super initWithFrame:cell.frame];
    if (self) {
        self.cell = cell;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowOpacity = 0.f;
        self.layer.shadowRadius = 5.f;
        self.layer.shouldRasterize = NO;
        
        self.cellFakeImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.cellFakeImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.cellFakeImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.cellFakeHightedView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.cellFakeHightedView.contentMode = UIViewContentModeScaleAspectFill;
        self.cellFakeHightedView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        cell.highlighted = YES;
        self.cellFakeHightedView.image = [self getCellImage];
        cell.highlighted = NO;
        self.cellFakeImageView.image = [self getCellImage];
    
        [self addSubview:self.cellFakeImageView];
        [self addSubview:self.cellFakeHightedView];
    }
    return self;
}

- (void)changeBoundsIfNeeded:(CGRect)bounds
{
    if (CGRectIsEmpty(bounds)) return;
    
    [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.bounds = bounds;
    } completion:nil];
}

- (void)pushFowardView
{
    [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.center = self.originalCenter;
        self.transform = CGAffineTransformMakeScale(1.f, 1.f);
        self.cellFakeHightedView.alpha = 0;
        CABasicAnimation *shadowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
        shadowAnimation.fromValue = @0.f;
        shadowAnimation.toValue = @.7f;
        shadowAnimation.removedOnCompletion = NO;
        shadowAnimation.fillMode = kCAFillModeForwards;
        [self.layer addAnimation:shadowAnimation forKey:@"applyShadow"];
        
    } completion:^(BOOL finished) {
        
        [self.cellFakeHightedView removeFromSuperview];
    }];
}

- (void)pushBackView:(void (^)(void))block
{
    [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.transform = CGAffineTransformIdentity;
        self.frame = self.cellFrame;
        CABasicAnimation *shadowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
        shadowAnimation.fromValue = @.7f;
        shadowAnimation.toValue = @0.f;
        shadowAnimation.removedOnCompletion = NO;
        shadowAnimation.fillMode = kCAFillModeForwards;
        [self.layer addAnimation:shadowAnimation forKey:@"removeShadow"];
    } completion:^(BOOL finished) {
        if (block) {
            block();
        }
    }];
}

- (UIImage *)getCellImage
{
    UIGraphicsBeginImageContextWithOptions(self.cell.bounds.size, NO, [UIScreen mainScreen].scale * 2);
    [self.cell drawViewHierarchyInRect:self.cell.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
