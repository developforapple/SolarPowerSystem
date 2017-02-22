//
//  SimpleContentTableViewCell.m
//  Golf
//
//  Created by 廖瀚卿 on 15/12/8.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "SimpleContentTableViewCell.h"

@implementation SimpleContentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [[UIColor colorWithHexString:@"#eeeeee"] colorWithAlphaComponent:.5];
    self.selectedBackgroundView = view;
}

- (IBAction)btnAction:(id)sender {
    if (_blockReturn) {
        _blockReturn(nil);
    }
}

@end
