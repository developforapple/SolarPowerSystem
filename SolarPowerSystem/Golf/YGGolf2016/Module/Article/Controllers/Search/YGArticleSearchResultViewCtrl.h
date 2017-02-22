//
//  YGArticleSearchResultViewCtrl.h
//  Golf
//
//  Created by bo wang on 16/6/16.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGBaseViewController.h"

// 显示搜索结果
@interface YGArticleSearchResultViewCtrl : YGBaseViewController

@property (copy, nonatomic) void (^completion)(void);

- (void)search:(NSString *)keywords;

- (void)reset;

@end
