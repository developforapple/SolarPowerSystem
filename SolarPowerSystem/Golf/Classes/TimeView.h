//
//  TimeView.h
//  Golf
//
//  Created by 黄希望 on 15/10/21.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Time.h"

@interface TimeView : UIView

// 是否有价格体系参与
@property (nonatomic,assign) BOOL hasPrice;

@property (nonatomic,strong) Time *time;

@property (nonatomic,copy) BOOL (^scrolling) (void);


@end
