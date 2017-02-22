//
//  ThreeActionTableViewCell.m
//  Golf
//
//  Created by 廖瀚卿 on 15/6/11.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "ThreeActionTableViewCell.h"

@interface ThreeActionTableViewCell()

@end

@implementation ThreeActionTableViewCell


- (IBAction)btn1Pressed:(id)sender {
    if (_btn1Return) {
        _btn1Return(nil);
    }
}

- (IBAction)btn2Pressed:(id)sender {
    if (_btn2Return) {
        _btn2Return(nil);
    }
}

- (IBAction)btn3Pressed:(id)sender {
    if (_btn3Return) {
        _btn3Return(nil);
    }
}

- (IBAction)btn4Pressed:(id)sender {
    if (_btn4Return) {
        _btn4Return(nil);
    }
}

@end
