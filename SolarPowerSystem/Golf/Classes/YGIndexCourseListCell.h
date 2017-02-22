//
//  YGIndexCourseListCell.h
//  Golf
//
//  Created by bo wang on 2017/2/20.
//  Copyright © 2017年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HotCourseBean;
@class TravelPackageBean;

UIKIT_EXTERN NSString *const kYGIndexCourseListCell;

@interface YGIndexCourseListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *cellTitleLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property (strong, readonly, nonatomic) NSArray<HotCourseBean *> *courseList;
@property (strong, readonly, nonatomic) NSArray<TravelPackageBean *> *packageList;

@property (assign, nonatomic) BOOL loading;

- (void)configureWithCourses:(NSArray<HotCourseBean *> *)courseList;
- (void)configureWithPackages:(NSArray<TravelPackageBean *> *)packageList;

@end
