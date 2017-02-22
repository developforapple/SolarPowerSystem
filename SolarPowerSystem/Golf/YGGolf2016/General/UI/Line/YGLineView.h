//
//  YGLineView.h
//  Golf
//
//  Created by bo wang on 16/6/20.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, YGLineDirection) {
    YGLineDirectionHorizontal,          //水平位于顶部 insetsBottom 无效
    YGLineDirectionVertical,            //垂直位于左侧 insetsRight 无效
    YGLineDirectionHorizontalBottom,    //水平位于底部 insetsTop 无效
    YGLineDirectionVerticalRight,       //垂直位于右侧 insetsLeft 无效
};

#define kYGLineDirectionHorizontal @"top"
#define kYGLineDirectionVertical @"left"
#define kYGLineDirectionHorizontalBottom @"bottom"
#define kYGLineDirectionVerticalRight @"right"

/*!
 *  @brief 显示单线的view。xib中UIView设置为此类即可显示横线。默认为白色.5f宽度的横向线。
 */

@interface YGLineView : UIView

@property (strong, readonly, nonatomic) CALayer *lineLayer;

@property (strong, nonatomic) IBInspectable UIColor *lineColor; //默认白色
@property (assign, nonatomic) IBInspectable CGFloat lineWidth;  //默认.5f
@property (assign, nonatomic) IBInspectable NSUInteger direction;//默认YGLineDirectionHorizontal
@property (strong, nonatomic) IBInspectable NSString *directionDesc;

// 默认都是0
@property (assign, nonatomic) IBInspectable CGFloat insetsTop;
@property (assign, nonatomic) IBInspectable CGFloat insetsLeft;
@property (assign, nonatomic) IBInspectable CGFloat insetsBottom;
@property (assign, nonatomic) IBInspectable CGFloat insetsRight;

@property (assign, nonatomic) UIEdgeInsets insets;

@end