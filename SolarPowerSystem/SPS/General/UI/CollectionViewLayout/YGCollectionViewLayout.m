//
//  YGCollectionViewLayout.m
//  Golf
//
//  Created by bo wang on 16/6/20.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGCollectionViewLayout.h"

#pragma mark - LeftAlignment Layout
@implementation YGLeftAlignmentFlowLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.maximumInteritemSpacing = 15.f;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.maximumInteritemSpacing = 15.f;
    }
    return self;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    //使用系统帮我们计算好的结果。
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    
    CGSize contnetSize = [self collectionViewContentSize];
    
    //第0个cell没有上一个cell，所以从1开始
    for(int i = 1; i < [attributes count]; ++i) {
        //这里 UICollectionViewLayoutAttributes 的排列总是按照 indexPath的顺序来的。
        UICollectionViewLayoutAttributes *curAttr = attributes[i];
        UICollectionViewLayoutAttributes *preAttr = attributes[i-1];
        
        NSInteger origin = CGRectGetMaxX(preAttr.frame);
        //根据  maximumInteritemSpacing 计算出的新的 x 位置
        CGFloat targetX = origin + _maximumInteritemSpacing;
        // 只有系统计算的间距大于  maximumInteritemSpacing 时才进行调整
        if (CGRectGetMinX(curAttr.frame) > targetX) {
            // 换行时不用调整
            if (targetX + CGRectGetWidth(curAttr.frame) < contnetSize.width) {
                CGRect frame = curAttr.frame;
                frame.origin.x = targetX;
                curAttr.frame = frame;
            }
        }
    }
    return attributes;
}

@end

#pragma mark - Decoration Layout
#import "YGLineView.h"

@interface YGDecorationAttributes : UICollectionViewLayoutAttributes
@property (weak, nonatomic) UIView *decorationView;
@end
@implementation YGDecorationAttributes
@end

@interface YGDecorationView : UICollectionReusableView
@property (weak, nonatomic) UIView *decorationView;
@end

@implementation YGDecorationView

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.decorationView.frame = self.bounds;
}

- (void)applyLayoutAttributes:(YGDecorationAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    self.decorationView = layoutAttributes.decorationView;
    self.decorationView.frame = layoutAttributes.bounds;
    [self addSubview:layoutAttributes.decorationView];
}

@end

static NSString *const kDecorationViewKind = @"YGDecorationView";

@interface YGDecorationViewFlowLayout ()
@property (strong, nonatomic) YGDecorationAttributes *lineViewAttribute;
@end

@implementation YGDecorationViewFlowLayout
- (void)prepareLayout
{
    [super prepareLayout];
    [self registerClass:[YGDecorationView class] forDecorationViewOfKind:kDecorationViewKind];
}

- (CGSize)collectionViewContentSize
{
    return [super collectionViewContentSize];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    if ([elementKind isEqualToString:kDecorationViewKind]) {
        YGDecorationAttributes *att = [YGDecorationAttributes layoutAttributesForDecorationViewOfKind:elementKind withIndexPath:indexPath];
        att.decorationView = self.decorationView;
        return att;
    }
    return [super layoutAttributesForDecorationViewOfKind:elementKind atIndexPath:indexPath];
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *att = [NSMutableArray arrayWithArray:[super layoutAttributesForElementsInRect:rect]];
    
    if (!self.lineViewAttribute) {
        self.lineViewAttribute = (YGDecorationAttributes *)[self layoutAttributesForDecorationViewOfKind:kDecorationViewKind atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
    CGSize contentSize = [self collectionViewContentSize];
    self.lineViewAttribute.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
    [att addObject:self.lineViewAttribute];
    return att;
}
@end

@implementation YGChartSpecFlowLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return NO;
}
@end

@interface YGHorizontalPageableFlowLayout ()
@property (strong, nonatomic) NSMutableArray *allAttributes;
@end

@implementation YGHorizontalPageableFlowLayout
- (void)prepareLayout
{
    [super prepareLayout];
    
    self.allAttributes = [NSMutableArray array];
    
    NSUInteger count = [self.collectionView numberOfItemsInSection:0];
    for (NSUInteger i = 0; i<count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        [self.allAttributes addObject:attributes];
    }
}

- (CGSize)collectionViewContentSize
{
    return [super collectionViewContentSize];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger item = indexPath.item;
    NSUInteger x;
    NSUInteger y;
    [self targetPositionWithItem:item resultX:&x resultY:&y];
    NSUInteger item2 = [self originItemAtX:x y:y];
    NSIndexPath *theNewIndexPath = [NSIndexPath indexPathForItem:item2 inSection:indexPath.section];
    
    UICollectionViewLayoutAttributes *theNewAttr = [super layoutAttributesForItemAtIndexPath:theNewIndexPath];
    theNewAttr.indexPath = indexPath;
    return theNewAttr;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    
    NSMutableArray *tmp = [NSMutableArray array];
    
    for (UICollectionViewLayoutAttributes *attr in attributes) {
        for (UICollectionViewLayoutAttributes *attr2 in self.allAttributes) {
            if (attr.indexPath.item == attr2.indexPath.item) {
                [tmp addObject:attr2];
                break;
            }
        }
    }
    return tmp;
}

// 根据 item 计算目标item的位置
// x 横向偏移  y 竖向偏移
- (void)targetPositionWithItem:(NSUInteger)item
                       resultX:(NSUInteger *)x
                       resultY:(NSUInteger *)y
{
    NSUInteger page = item/(self.itemCountPerRow*self.rowCount);
    
    NSUInteger theX = item % self.itemCountPerRow + page * self.itemCountPerRow;
    NSUInteger theY = item / self.itemCountPerRow - page * self.rowCount;
    if (x != NULL) {
        *x = theX;
    }
    if (y != NULL) {
        *y = theY;
    }
}

// 根据偏移量计算item
- (NSUInteger)originItemAtX:(NSUInteger)x
                          y:(NSUInteger)y
{
    NSUInteger item = x * self.rowCount + y;
    return item;
}
@end
