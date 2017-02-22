//
//  UIButton+Custom.h
//  Golf
//
//  Created by user on 13-4-11.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Custom)
+ (UIButton *)myButton:(id)target
                 Frame:(CGRect)frame
           NormalImage:(NSString*)norName
           SelectImage:(NSString*)selName
                 Title:(NSString*)title
            TitleColor:(UIColor*)color
                  Font:(float)size
                Action:(SEL)action;
@end
