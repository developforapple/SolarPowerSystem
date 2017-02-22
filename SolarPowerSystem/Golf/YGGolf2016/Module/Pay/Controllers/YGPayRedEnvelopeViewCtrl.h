//
//  YGPayRedEnvelopeViewCtrl.h
//  Golf
//
//  Created by bo wang on 2016/11/12.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGBasePopViewController.h"

@interface YGPayRedEnvelopeViewCtrl : YGBasePopViewController

@property (assign, nonatomic) NSInteger redEnvelopeAmount;

@property (copy, nonatomic) void (^sendToFriendAction)(void);

@end
