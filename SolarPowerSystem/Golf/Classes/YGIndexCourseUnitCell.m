//
//  YGIndexCourseUnitCell.m
//  Golf
//
//  Created by bo wang on 2017/2/20.
//  Copyright © 2017年 云高科技. All rights reserved.
//

#import "YGIndexCourseUnitCell.h"
#import "TravelPackageService.h"

NSString *const kYGIndexCourseUnitCell = @"YGIndexCourseUnitCell";

@interface YGIndexCourseUnitCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *yunbiLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@property (strong, readwrite, nonatomic) HotCourseBean *course;
@property (strong, readwrite, nonatomic) TravelPackageBean *package;
@end

@implementation YGIndexCourseUnitCell

- (void)configureWithCourse:(HotCourseBean *)course
{
    self.course = course;
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:course.courseImg]];
    self.titleLabel.text = course.courseName;
    self.priceLabel.text = [NSString stringWithFormat:@"￥%d",course.price/100];
    self.descLabel.text = [NSString stringWithFormat:@"%d条动态",course.topicNum];
    if (course.giveYunbi > 0) {
        self.yunbiLabel.text = [NSString stringWithFormat:@"返%d",course.giveYunbi/100];
    }else{
        self.yunbiLabel.text = @"";
    }
    
}
- (void)configureWithPackage:(TravelPackageBean *)package
{
    self.package = package;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:[package.pictures firstObject]]];
    self.titleLabel.text = package.packageName;
    self.priceLabel.text = [NSString stringWithFormat:@"￥%d",package.price/100];
    self.descLabel.text = package.packageDesc;
    self.yunbiLabel.text = @"";
}

@end
