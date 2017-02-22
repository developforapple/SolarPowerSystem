//
//  HomeCoverView.h
//  Golf
//
//  Created by liangqing on 16/3/21.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CancelBtnActionBlock)(void);
typedef void(^ReceiverSoonBtnActionBlock)(void);

@interface HomeCoverView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *imageViewIcon;
+(instancetype)loadXibView;

@property(nonatomic,copy) CancelBtnActionBlock cancelBtnActionBlock;
@property(nonatomic,copy) ReceiverSoonBtnActionBlock reciverSoonBtnActionBlock;
@end
