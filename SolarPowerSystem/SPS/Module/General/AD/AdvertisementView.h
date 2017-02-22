//
//  AdvertisementView.h
//  Golf
//
//  Created by zhengxi on 15/11/10.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdvertisementView : UIView
@property (copy, nonatomic) void (^skipAdsBlock)(void);
@property (weak, nonatomic) IBOutlet UIImageView *adsImageView;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton1;

@end
