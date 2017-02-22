//
//  TextTableViewCell.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/16.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "TextTableViewCell.h"

@implementation TextTableViewCell

- (IBAction)btnAction:(id)sender
{
    if (self.rightBtnAction) {
        self.rightBtnAction();
    }
}
@end
