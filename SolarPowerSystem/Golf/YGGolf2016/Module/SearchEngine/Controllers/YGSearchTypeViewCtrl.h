//
//  YGSearchTypeViewCtrl.h
//  Golf
//
//  Created by bo wang on 16/7/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGSearch.h"

/*!
 *  @brief 搜索类型选择
 */
@interface YGSearchTypeViewCtrl : UIViewController

@property (copy, nonatomic) void (^didSelectedType)(YGSearchType type);

@end
