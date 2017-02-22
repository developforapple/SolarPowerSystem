//
//  YGSearch.h
//  Golf
//
//  Created by bo wang on 16/7/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#ifndef YGSearch_h
#define YGSearch_h

// 搜索类型。
typedef NS_OPTIONS(NSUInteger, YGSearchType) {
    YGSearchTypeAll         = 0,            //全部类型
    YGSearchTypeCourse      = 1 << 0,       //球场
    YGSearchTypeCommodity   = 1 << 1,       //商品
    YGSearchTypeFeed        = 1 << 2,       //动态
    YGSearchTypeUser        = 1 << 3,       //用户
    YGSearchTypeYuedu       = 1 << 4,       //头条
    YGSearchTypeCoach       = 1 << 5        //教练
};

/*!
 *  @brief 一个整形是否是有效的搜索类型
 *
 *  @param aType
 *
 *  @return YES,有效。NO无效
 */
FOUNDATION_EXTERN BOOL
IsValidSearchType(NSInteger aType);

/*!
 *  @brief 搜索类型对应的标题。总是返回第一个匹配的类型。
 *
 *  @param type 类型
 *
 *  @return 标题
 */
FOUNDATION_EXTERN NSString *
SearchTitleOfType(YGSearchType type);

/*!
 *  @brief 搜索类型对应的查看更多提示
 *
 *  @param type 类型
 *
 *  @return 提示
 */
FOUNDATION_EXTERN NSString *
SearchFooterOfType(YGSearchType type);

/*!
 *  @brief 搜索类型对应的图标。总是返回第一个匹配的类型。
 *
 *  @param type 类型
 *
 *  @return 图标Name
 */
FOUNDATION_EXTERN NSString *
SearchIconNameOfType(YGSearchType type);

/*!
 *  @brief 搜索类型对应的小图标。总是返回第一个匹配的类型
 *
 *  @param type 类型
 *
 *  @return 图标name
 */
FOUNDATION_EXTERN NSString *
SearchSmallIconNameOfType(YGSearchType type);

/*!
 *  @brief 向服务器提交的搜索类型的值
 *
 *  @param type 类型
 *
 *  @return 值
 */
FOUNDATION_EXTERN NSUInteger
SearchQueryValue(YGSearchType type);

// 搜索结果cell类型
typedef NS_ENUM(NSUInteger, YGSearchCellType) {
    YGSearchCellTypeHeaderFooter,//头尾cell
    YGSearchCellTypeCourse,       //球场
    YGSearchCellTypeCommodity,    //商品
    YGSearchCellTypeFeed,       //动态
    YGSearchCellTypeUser,       //用户和教练
    YGSearchCellTypeYuedu,       //头条
};


#endif /* YGSearch_h */
