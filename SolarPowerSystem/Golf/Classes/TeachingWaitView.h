//
//  WaitTeachingView.h
//  test2
//
//  Created by 廖瀚卿 on 15/6/3.
//  Copyright (c) 2015年 额度. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeachingWaitView : UIView

@property (weak, nonatomic) IBOutlet UIView *viewLine;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelDatetime;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;

@property (strong, nonatomic) ReservationModel *reservationModel;

@property (copy, nonatomic) BlockReturn blockCellPressed;

@end
