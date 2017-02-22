//
//  YGCollectionViewLayout.h
//  Golf
//
//  Created by bo wang on 16/6/20.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark - cell左对齐
/*!
 *  左对齐的FlowLayout。在悦读搜索的热词中使用
 */
@interface YGLeftAlignmentFlowLayout : UICollectionViewFlowLayout
/*!
 *  同一行中的间隔cell之间的最大间距。默认15
 */
@property (assign, nonatomic) CGFloat maximumInteritemSpacing;
@end


#pragma mark - 装饰背景

/*!
 *  使用lineView作为装饰背景。在教学练习位预定中使用
 */
@interface YGDecorationViewFlowLayout : UICollectionViewFlowLayout
@property (strong, nonatomic) UIView *decorationView;
@end

#pragma mark - 
@interface YGChartSpecFlowLayout : UICollectionViewFlowLayout
@end


#pragma mark - 左右分页排版

@interface YGHorizontalPageableFlowLayout : UICollectionViewFlowLayout
@property (nonatomic) NSUInteger itemCountPerRow;
@property (nonatomic) NSUInteger rowCount;
@end
