//
//  YGYueduVideoCell.m
//  Golf
//
//  Created by liangqing on 16/9/1.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGYueduVideoCell.h"

@implementation YGYueduVideoCell

-(void)awakeFromNib{
    [super awakeFromNib];
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [[UIColor colorWithHexString:@"#eeeeee"] colorWithAlphaComponent:.5];
    self.selectedBackgroundView = view;
}


- (IBAction)play:(id)sender {
    if (self.blockPlay) {
        self.blockPlay(_headLineBean);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    if (!selected) {
        return;
    }
    NSDictionary *dict = @{@"data_extra":@"2",@"data_id":@(_headLineBean.id),@"data_type":@"yuedu",@"sub_type":@"1"};
    [[GolfAppDelegate shareAppDelegate] handlePushControllerWithData:dict];
}

@end
