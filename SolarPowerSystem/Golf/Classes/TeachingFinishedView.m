//
//  FinishedTeachingView.m
//  test2
//
//  Created by 廖瀚卿 on 15/6/3.
//  Copyright (c) 2015年 额度. All rights reserved.
//

#import "TeachingFinishedView.h"

@implementation TeachingFinishedView

- (IBAction)btnAction:(id)sender {
    if (_blockCellPressed) {
        _blockCellPressed(@{@"type":@"cell",@"data":_reservationModel});
    }
}

- (IBAction)rightBtnPressed:(id)sender {
    if (_blockRightPressed) {
        _blockRightPressed(@{@"type":@"right",@"data":_reservationModel});
    }
}

@end
