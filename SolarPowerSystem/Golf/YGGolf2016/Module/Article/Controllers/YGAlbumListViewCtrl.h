//
//  YGAlbumListViewCtrl.h
//  Golf
//
//  Created by bo wang on 16/6/16.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGBaseViewController.h"

@class YueduColumnBean;

// 专题列表
@interface YGAlbumListViewCtrl : YGBaseViewController

/*!
 *  @brief 列表类型。
 */
@property (strong, nonatomic) YueduColumnBean *columnBean;

@end
