//
//  MyButton.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/19.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

//IB_DESIGNABLE

@interface MyButton : UIButton

//@property (nonatomic) IBInspectable CGFloat cornerRadius;
//@property (nonatomic) IBInspectable UIColor *highlightedColor;

@property (nonatomic,strong)  UIColor *highlightedColor;
@property (nonatomic,strong)  UIColor *selectedColor;
@property (nonatomic,strong)  UIColor *borderColor;
@property (nonatomic,strong)  UIColor *disabledColor;

@property (nonatomic,assign) id dataExtra;

@end
