//
//  YGSearchResultViewCtrl.h
//  Golf
//
//  Created by bo wang on 16/7/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGSearch.h"

// 搜索结果页
@interface YGSearchResultViewCtrl : UIViewController

@property (assign, nonatomic) YGSearchType type;

/*!
 *  @brief 开始搜索
 *
 *  @param keywords 关键词为nil或@"" 时，不进行搜索，将清空已有结果。
 */
- (void)searchWithKeywords:(NSString *)keywords;

/*!
 *  @brief 查看更多相关
 */
@property (copy, nonatomic) void (^willShowAllResult)(YGSearchType type);

/*!
 *  @brief 点击搜索结果进行跳转
 */
@property (copy, nonatomic) void (^willShowResultDetail)(id bean);

@end
