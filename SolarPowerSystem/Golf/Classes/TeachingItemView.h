//
//  TeachingItemView.h
//  test2
//
//  Created by 廖瀚卿 on 15/6/4.
//  Copyright (c) 2015年 额度. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CellType) {
    CellTypeButton = 0,
    CellTypeLabel
};

@interface TeachingItemView : UIView

@property (nonatomic,strong) ReservationModel *reservationModel;
@property (weak, nonatomic) IBOutlet UIImageView *imgHead;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (nonatomic) CellType cellType;

@property (copy, nonatomic) BlockReturn blockRightPressed;
@property (copy, nonatomic) BlockReturn blockCellPressed;

@end
