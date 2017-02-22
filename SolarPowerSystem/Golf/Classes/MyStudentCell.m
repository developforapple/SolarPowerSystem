//
//  MyStudentCell.m
//  Golf
//
//  Created by 黄希望 on 15/6/5.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "MyStudentCell.h"

@interface MyStudentCell()

@property (nonatomic,weak) IBOutlet UIImageView *headImageV;
@property (nonatomic,weak) IBOutlet UILabel *nameLabel;
@property (nonatomic,strong) IBOutletCollection(UIView) NSArray *views;

@end

@implementation MyStudentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [Utilities drawView:_headImageV radius:25 bordLineWidth:0 borderColor:[UIColor whiteColor]];
}

- (void)setStudent:(StudentModel *)student{
    _student = student;
    
    for (UIView *av in _views) {
        for (UIView *sv in av.subviews) {
            if ([sv isKindOfClass:[UILabel class]]) {
                UILabel *lb = (UILabel*)sv;
                lb.text = @"";
            }
        }
    }
    
    if (_student) {
        if (_student.headImage.length>0) {
            [_headImageV sd_setImageWithURL:[NSURL URLWithString:_student.headImage] placeholderImage:[UIImage imageNamed:@"head_member"]];
        }else{
            _headImageV.image = [UIImage imageNamed:@"head_member"];
        }
        _nameLabel.text = _student.displayName;
        
        NSMutableArray *arr = [NSMutableArray array];
        [arr addObject:@[@"剩余",@(_student.remainHour)]];
        [arr addObject:@[@"待上课",@(_student.waitHour)]];
        [arr addObject:@[@"已完成",@(_student.completeHour)]];

        for (int i=0; i < arr.count; i++) {
            NSArray *a = arr[i];
            UIView *view = [self.contentView viewWithTag:i+1];
            view.hidden = NO;
            UILabel *titleLabel = (UILabel*)[view viewWithTag:(i+1)*10+1];
            UILabel *valueLabel = (UILabel*)[view viewWithTag:(i+1)*10+2];
            titleLabel.text = a[0];valueLabel.text = [a[1] description];
        }
    }
}

@end
