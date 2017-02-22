//
//  YGSearchCustomBar.h
//  Golf
//
//  Created by bo wang on 16/7/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGSearch.h"
#import "YGGlobalSearchBar.h"

@protocol YGSearchCustomBarDelegate <NSObject>
@optional
- (void)searchCustomBarWillBack;     //点击返回按钮
- (void)searchCustomBarWillCancel;   //点击取消按钮
- (void)searchCustomBarWillSearch;   //点击键盘的搜索按钮
- (void)searchCustomBarTextDidChanged:(NSString *)text;//输入框内容变化
@end

@interface YGSearchCustomBar : UIView

@property (strong, nonatomic) NSString *defaultPlaceholder;

@property (weak, nonatomic) IBOutlet YGGlobalSearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet id<YGSearchCustomBarDelegate> delegate;//IB中已连线设置了

/*!
 *  @brief 总是隐藏返回按钮。默认为NO。
 */
@property (assign, nonatomic) BOOL alwaysHiddenBackBtn;

@property (assign, readonly, nonatomic) YGSearchType type;
- (void)updateWithType:(YGSearchType)type;

- (NSString *)keywords;

@end
