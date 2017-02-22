//
//  YGMyLikedAlbumsListViewCtrl.h
//  Golf
//
//  Created by bo wang on 16/6/29.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGBaseViewController.h"

// 我收藏的专题
@interface YGMyLikedAlbumsListViewCtrl : YGBaseViewController

/*!
 *  如果需要实现导航栏和segment半透明，在滚动时显示底部的view。就需要设置此值。
 *  应当设置为状态栏+导航栏+segment的总高度 20 + 44 + 40;
 */
@property (assign, nonatomic) CGFloat contentEdgeInsetsTop;

@end
