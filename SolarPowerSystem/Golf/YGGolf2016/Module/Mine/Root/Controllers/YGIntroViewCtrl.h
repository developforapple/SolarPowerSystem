//
//  YGIntroViewCtrl.h
//  Golf
//
//  Created by 黄希望 on 14-3-18.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseNavController.h"

@interface YGIntroViewCtrl : BaseNavController
@property (nonatomic) BOOL isPressentModelView;

- (void)loadWebViewWithUrl:(NSString*)aUrl;
- (void)loadWebViewWithUrl:(NSString*)aUrl title:(NSString*)title;

@end
