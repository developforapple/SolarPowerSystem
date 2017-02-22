//
//  PublicCourseCell.m
//  Golf
//
//  Created by 黄希望 on 15/5/8.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "PublicCourseCell.h"
#import "UIView+AutoLayout.h"

@interface PublicCourseCell()
@property (nonatomic,weak) IBOutlet UILabel *titleLabel;
@property (nonatomic,weak) IBOutlet UILabel *dateLabel;
@property (nonatomic,weak) IBOutlet UILabel *addressLabel;
@property (nonatomic,weak) IBOutlet UILabel *memNumLabel;
@property (nonatomic,strong) IBOutlet UIImageView *imageV;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *unitLabel;
@property (weak, nonatomic) IBOutlet UIView *viewContainer;

@property (weak, nonatomic) IBOutlet UIView *viewProgressValue;
@property (weak, nonatomic) IBOutlet UIView *viewProgress;

@end

@implementation PublicCourseCell{
    NSLayoutConstraint *ncWidth;
    UIColor *grayColor,*orangeColor,*progressInnerOrangeColor,*progressInnerGrayColor;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    grayColor = [UIColor colorWithHexString:@"#999999"];
    orangeColor = [UIColor colorWithHexString:@"#ff6d00"];
    progressInnerGrayColor = [UIColor colorWithHexString:@"#c8c8c8"];
    progressInnerOrangeColor = [UIColor colorWithHexString:@"#ffac6f"];
    
    _viewProgress.layer.cornerRadius = 15.0/2;
}

- (void)setPublicCourse:(PublicCourseModel *)publicCourse{
    
    if (_publicCourse == nil || _publicCourse != publicCourse) {
        [_imageV sd_setImageWithURL:[NSURL URLWithString:publicCourse.productImage] placeholderImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#e6e6e6"]]];
        
        [self setPrice];
        
        [_titleLabel setText:publicCourse.productName.length > 0 ? publicCourse.productName:@""];
        [_dateLabel setText:publicCourse.openDate.length > 0&&publicCourse.openTime.length > 0 ? [NSString stringWithFormat:@"%@ %@",publicCourse.openDate,publicCourse.openTime]:@""];
        [_addressLabel setText:publicCourse.shortAddress.length > 0 ? [NSString stringWithFormat:@"%.2fkm  %@",publicCourse.distance,publicCourse.shortAddress]:[NSString stringWithFormat:@"%.2fkm",publicCourse.distance]];
        [_memNumLabel setText:[NSString stringWithFormat:@"%d/%d人",publicCourse.personJoin,publicCourse.personLimit]];
        
        if (publicCourse.personLimit > 0) {
            CGFloat width = (float)publicCourse.personJoin / (float)publicCourse.personLimit * 75.0; //75px
            BOOL flag = YES;
            for (NSLayoutConstraint *c  in [_viewProgressValue constraints]) {
                if (c.firstAttribute == NSLayoutAttributeWidth) {
                    c.constant = width;
                    ncWidth = c;
                    flag = NO;
                    break;
                }
            }
            
            if (flag) { //标记是否有设置width约束，如果没有则设置
                [_viewProgressValue constrainToWidth:width];
            }
            
            [UIView animateWithDuration:.5 animations:^{
                [_viewProgressValue layoutIfNeeded];
            }];
        }
    }
    _publicCourse = publicCourse;
}

- (void)setPrice{
    switch (_publicCourse.classStatus) {
        case 0:
        {
            if (_publicCourse.sellingPrice == 0) {
                [_priceLabel setText:@"免费"];
                [self setColorGray:NO];
                _unitLabel.hidden = YES;
            }else{
                [_priceLabel setText:[NSString stringWithFormat:@"%d",_publicCourse.sellingPrice]];
                [self setColorGray:NO];
                _unitLabel.hidden = NO;
            }
        }
            break;
        case 1:
        {
            _priceLabel.text = @"报名结束";
            [self setColorGray:YES];
            _unitLabel.hidden = YES;
        }
            break;
        case 2:
            _priceLabel.text = @"报名已满";
            [self setColorGray:YES];
            _unitLabel.hidden = YES;
            break;
        case 3:
            _priceLabel.text = @"课程结束";
            [self setColorGray:YES];
            _unitLabel.hidden = YES;
            break;
        default:
            break;
    }
}

- (void)setColorGray:(BOOL)flag{
    _priceLabel.textColor = flag ? grayColor : orangeColor;
    _viewProgressValue.backgroundColor = flag ? grayColor : orangeColor;
    _viewProgress.backgroundColor = flag ? progressInnerGrayColor : progressInnerOrangeColor;
}



@end
