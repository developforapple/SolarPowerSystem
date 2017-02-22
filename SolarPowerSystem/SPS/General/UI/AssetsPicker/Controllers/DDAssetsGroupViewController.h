//
//  DDAssetsGroupListViewController.h
//  QuizUp
//
//  Created by Normal on 15/12/8.
//  Copyright © 2015年 Bo Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDAssetsManager.h"

#define kDefaultGroupListFullHeight 416.f

@interface DDAssetsGroupViewController : UIViewController

@property (copy, nonatomic) void (^didDisplayedBlock)();
@property (copy, nonatomic) void (^didEndDisplayedBlock)();

// ALAssetsGroup or PHAssetCollection
@property (copy, nonatomic) void (^didSelectedGroupBlock)(id<DDGroupProtocol>);

@property (getter=isDisplayed, nonatomic) BOOL display;

@end
