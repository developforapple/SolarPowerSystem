//
//  YGArticleListViewCtrl.h
//  Golf
//
//  Created by wwwbbat on 16/5/27.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGBaseViewController.h"

@class YueduColumnBean;

// 文章列表
@interface YGArticleListViewCtrl : YGBaseViewController

/*!
 *  @brief 列表类型。
 */
@property (strong, nonatomic) YueduColumnBean *columnBean;

@end
