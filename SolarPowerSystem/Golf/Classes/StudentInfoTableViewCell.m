//
//  StudentInfoTableViewCell.m
//  Golf
//
//  Created by 廖瀚卿 on 15/6/9.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "StudentInfoTableViewCell.h"

@interface StudentInfoTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *imgHead;
@property (weak, nonatomic) IBOutlet UILabel *labelCourseName;
@property (weak, nonatomic) IBOutlet UILabel *labelCount;
@property (weak, nonatomic) IBOutlet UILabel *labelName;

@end

@implementation StudentInfoTableViewCell


-(void)loadData:(id)data{
    [_imgHead sd_setImageWithURL:[NSURL URLWithString:[data valueForKeyPath:@"headImage"]] placeholderImage:[UIImage imageNamed:@"head_member"]];
    [_labelCount setText:[NSString stringWithFormat:@"%d",[[data valueForKeyPath:@"remainHour"] intValue]]];
    [_labelName setText:[data valueForKeyPath:@"nickName"]];
    [_labelCourseName setText:[data valueForKeyPath:@"productName"]];
}

@end
