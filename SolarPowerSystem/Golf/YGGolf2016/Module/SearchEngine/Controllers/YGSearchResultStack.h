//
//  YGSearchResultStack.h
//  Golf
//
//  Created by bo wang on 16/7/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGSearch.h"

@class YGSearchResultViewCtrl;

// 搜索结果层级
@interface YGSearchResultStack : UINavigationController

// 返回一层
- (void)pop;

// 压入一层
- (void)push:(YGSearchResultViewCtrl *)result;

// 顶层的搜索类型。如果顶层为nil, 返回all
- (YGSearchType)topSearchType;

// 顶层的控制器
- (YGSearchResultViewCtrl *)topSearchViewCtrl;

// 数量
- (NSUInteger)stackCount;

/*!
 *  @brief 手势返回的操作结束。finished标记是否完成返回。YES：成功返回。NO：返回取消
 */
@property (copy, nonatomic) void (^interactiveCompleted)(BOOL finished);

/*!
 *  @brief 根控制器。这个控制器拿来显示类型为all的搜索结果。默认是隐藏的。
 */
@property (strong, readonly, nonatomic) YGSearchResultViewCtrl *rootResultViewCtrl;


/*!
 *  @brief 顶层的结果是否显示
 */
@property (assign, nonatomic) BOOL topResultViewCtrlVisible;
- (void)setTopResultViewCtrlVisible:(BOOL)topResultViewCtrlVisible;

@end
