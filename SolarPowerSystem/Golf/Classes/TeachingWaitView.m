//
//  WaitTeachingView.m
//  test2
//
//  Created by 廖瀚卿 on 15/6/3.
//  Copyright (c) 2015年 额度. All rights reserved.
//

#import "TeachingWaitView.h"

@implementation TeachingWaitView

- (IBAction)btnAction:(id)sender {
    if (_blockCellPressed) {
        _blockCellPressed(@{@"type":@"cell",@"data":_reservationModel});
    }
}

@end
