//
//  YGIndexCourseUnitCell.h
//  Golf
//
//  Created by bo wang on 2017/2/20.
//  Copyright © 2017年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TravelPackageBean;
@class HotCourseBean;

UIKIT_EXTERN NSString *const kYGIndexCourseUnitCell;

@interface YGIndexCourseUnitCell : UICollectionViewCell
@property (strong, readonly, nonatomic) HotCourseBean *course;
@property (strong, readonly, nonatomic) TravelPackageBean *package;

- (void)configureWithCourse:(HotCourseBean *)course;
- (void)configureWithPackage:(TravelPackageBean *)package;

@end
