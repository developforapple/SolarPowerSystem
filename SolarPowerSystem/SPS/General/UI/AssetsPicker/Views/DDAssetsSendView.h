//
//  DDSendView.h
//  QuizUp
//
//  Created by Normal on 15/12/9.
//  Copyright © 2015年 Bo Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDAssetsManager.h"

@interface DDAssetsSendView : UIView

@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UILabel *sendLabel;
@property (weak, nonatomic) IBOutlet UILabel *assetsCountLabel;

@property (copy, nonatomic) void (^sendAction)(void);

// 两个必须成对调用。
- (void)startMonitoringSelectedAssets:(DDAssetsManager *)manager;
- (void)endMonitoring:(DDAssetsManager *)manager;

@end
