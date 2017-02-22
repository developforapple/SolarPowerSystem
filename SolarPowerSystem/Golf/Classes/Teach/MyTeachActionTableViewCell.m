//
//  MyTeachActionTableViewCell.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/20.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "MyTeachActionTableViewCell.h"

@implementation MyTeachActionTableViewCell

- (IBAction)btnAction:(UIButton *)sender {
    switch (sender.tag) {
        case 0:
            if (_blockCourseTimeReturn) {
                _blockCourseTimeReturn(nil);
            }
            break;
        case 1:
            if (_blockYueTeacher) {
                _blockYueTeacher(nil);
            }
            break;
        default:
            break;
    }
}


@end
