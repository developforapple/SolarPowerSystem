//
//  HyperLinkLabel.h
//  Golf
//
//  Created by 黄希望 on 15/8/7.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGCommon.h"

@class HyperLinkLabel;

typedef void (^HyperlinkLabelURLHandler)(HyperLinkLabel *label, NSURL *URL, NSRange textRange, NSArray *textRects);


@interface HyperLinkLabel : UILabel

@property (nonatomic) IBInspectable BOOL superResponseEnabled;
@property (nonatomic) IBInspectable BOOL copyingEnabled;
@property (nonatomic) IBInspectable BOOL jubaoEnabled;
@property (nonatomic) IBInspectable BOOL deleteEnabled;

@property (nonatomic,strong) id data;
/*
 *  控件单击响应事件
 */
@property (nonatomic,copy) BlockReturn labelClickBlock;
@property (nonatomic,copy) BlockReturn copyingBlock;//复制菜单点击block
@property (nonatomic,copy) BlockReturn jubaoBlock;
@property (nonatomic,copy) BlockReturn blockDeleteItem;//删除block


- (void)hyperLinkWithText:(NSString*)aText
                textColor:(UIColor*)textColor
                linkColor:(UIColor*)linkColor
                 fontSize:(CGFloat)fontSize
          limitLineNumber:(NSInteger)limitLineNumber
          urlClickHandler:(HyperlinkLabelURLHandler)urlClickHandler  // 链接单击响应事件
      urlLongPressHandler:(HyperlinkLabelURLHandler)urlLongPressHandler;  // 链接长按响应事件

// 跳转
- (void)hyperLinkResp:(NSURL*)url;

@end
