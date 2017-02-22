//
//  YGArticleMainViewCtrl.h
//  Golf
//
//  Created by wwwbbat on 16/5/27.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGBaseViewController.h"

// 文章主界面
@interface YGYueduMainViewCtrl : YGBaseViewController

// 进入时默认显示的栏目id。默认为0。显示服务器返回的第一个栏目。
// 新闻：1 热文：2 专题：3
@property (assign, nonatomic) NSUInteger columnId;

@end
