//
//  TeachingItemView.m
//  test2
//
//  Created by 廖瀚卿 on 15/6/4.
//  Copyright (c) 2015年 额度. All rights reserved.
//

#import "TeachingItemView.h"

@interface TeachingItemView()

@property (weak, nonatomic) IBOutlet UIButton *btnRightAction;

@end

@implementation TeachingItemView

-(void)setCellType:(CellType)cellType{
    switch (cellType) {
        case CellTypeButton:
            _labelTitle.hidden = YES;
            _btnRightAction.hidden = NO;
            break;
        case CellTypeLabel:
            _labelTitle.hidden = NO;
            _btnRightAction.hidden = YES;
            break;
        default:
            break;
    }
}

- (IBAction)rightBtnPressed:(id)sender {
    if (_blockRightPressed) {
        _blockRightPressed(_reservationModel);
    }
}

- (IBAction)cellPressed:(id)sender {
    if (_blockCellPressed) {
        _blockCellPressed(_reservationModel);
    }
}

@end
