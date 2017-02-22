//
//  YGGlobalSearchBar.h
//  Golf
//
//  Created by bo wang on 16/8/4.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YGGlobalSearchBar : UISearchBar

// 占位字符串颜色。默认 70%black
@property (strong, nonatomic) IBInspectable UIColor *placeholderColor;

// 文本字体。默认 14
@property (assign, nonatomic) IBInspectable NSInteger textFontSize;

// 初始化时是否显示取消按钮
@property (assign, nonatomic) IBInspectable BOOL cancelBtnShouldShow;

// 可能的关键词。将自动在这些词随机选取进行展示
@property (strong, nonatomic) NSArray *possibleKeywords;
- (NSString *)currentKeywords;

@end
