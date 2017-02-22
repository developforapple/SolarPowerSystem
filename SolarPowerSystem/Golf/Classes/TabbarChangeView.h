//
//  TabbarChangeView.h
//  Golf
//
//  Created by 黄希望 on 15/11/13.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabbarChangeView : UIView

@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIButton *btn2;
@property (nonatomic,copy) BlockReturn clickBlock;

- (void)changeLineView:(NSInteger)index animated:(BOOL)animated;
- (void)changeBlur:(BOOL)flag;//控制是否毛玻璃效果

@end
