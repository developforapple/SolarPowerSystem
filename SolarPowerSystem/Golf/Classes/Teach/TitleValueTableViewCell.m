//
//  TitleValueTableViewCell.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/13.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "TitleValueTableViewCell.h"

@implementation TitleValueTableViewCell{
    
}

- (IBAction)btnPressed:(id)sender {
    if (_blockReturn) {
        _blockReturn(_rm);
    }
}


@end
