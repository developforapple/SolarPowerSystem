//
//  DayView.h
//  Golf
//
//  Created by 黄希望 on 15/10/21.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Day.h"

#define K_DT_DISABLE_COLOR     [UIColor colorWithHexString:@"cccccc"]
#define K_DT_DATE_COLOR        [UIColor colorWithHexString:@"333333"]
#define K_DT_OP_COLOR          [UIColor colorWithHexString:@"999999"]
#define K_DT_CP_COLOR          [UIColor colorWithHexString:@"ff6d00"]
#define K_DT_WEEKEND_COLOR     [UIColor colorWithHexString:@"249df3"]

// 该类主要用于控制显示
@interface DayView : UIView

// 是否有价格体系参与
@property (nonatomic,assign) BOOL hasPrice;

@property (nonatomic,strong) Day *day;

@property (nonatomic,copy) BOOL (^scrolling) (void);


@end
