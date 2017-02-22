//
//  YGDNDSettingViewCtrl.h
//  Golf
//
//  Created by zhengxi on 15/12/25.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YGDNDSettingViewCtrl : BaseNavController
@property (nonatomic) BOOL isOn;
@property (strong, nonatomic) void (^buttonBlock) (BOOL);
@end
