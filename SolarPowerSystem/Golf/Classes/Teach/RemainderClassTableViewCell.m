//
//  RemainderClassTableViewCell.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/22.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "RemainderClassTableViewCell.h"


@interface RemainderClassTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *imgHead;
@property (weak, nonatomic) IBOutlet UILabel *labelCourseName;
@property (weak, nonatomic) IBOutlet UILabel *labelCount;
@property (weak, nonatomic) IBOutlet UILabel *labelName;

@end

@implementation RemainderClassTableViewCell{
    id m;
}

-(void)loadData:(id)data{
    m = data;
    [_imgHead sd_setImageWithURL:[NSURL URLWithString:[data valueForKeyPath:@"headImage"]] placeholderImage:[UIImage imageNamed:@"head_member"]];
    [_labelCount setText:[NSString stringWithFormat:@"%d",[[data valueForKeyPath:@"remainHour"] intValue]]];
    [_labelName setText:[data valueForKeyPath:@"nickName"]];
    [_labelCourseName setText:[data valueForKeyPath:@"productName"]];
}

- (IBAction)headBtnHead:(id)sender
{
    if (self.headBtnHeadTapBlock) {
        self.headBtnHeadTapBlock(m);
    }
}

- (IBAction)btnPressed:(id)sender {
    if (_blockReturn) {
        _blockReturn(m);
    }
}

@end
