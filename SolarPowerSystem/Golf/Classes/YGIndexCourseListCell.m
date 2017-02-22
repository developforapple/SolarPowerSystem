//
//  YGIndexCourseListCell.m
//  Golf
//
//  Created by bo wang on 2017/2/20.
//  Copyright © 2017年 云高科技. All rights reserved.
//

#import "YGIndexCourseListCell.h"
#import "TravelPackageService.h"
#import "YGIndexCourseUnitCell.h"
#import "ClubMainViewController.h"
#import "YGPackageDetailViewCtrl.h"
#import "ClubListViewController.h"
#import "YGPackageIndexViewCtrl.h"

NSString *const kYGIndexCourseListCell = @"YGIndexCourseListCell";

@interface YGIndexCourseListCell () <UICollectionViewDelegate,UICollectionViewDataSource>
@property (strong, readwrite, nonatomic) NSArray *courseList;
@property (strong, readwrite, nonatomic) NSArray *packageList;

@end

@implementation YGIndexCourseListCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setLoading:(BOOL)loading
{
    _loading = loading;
    self.loadingIndicator.animating_ = loading;
}

- (void)configureWithCourses:(NSArray *)courseList
{
    self.courseList = courseList;
    self.packageList = nil;
    if ([GolfAppDelegate shareAppDelegate].isLocationSuccess) {
        self.cellTitleLabel.text = @"附近热门球场";
    }else{
        self.cellTitleLabel.text = @"热门球场";
    }
    [self.collectionView reloadData];
}

- (void)configureWithPackages:(NSArray *)packageList
{
    self.courseList = nil;
    self.packageList = packageList;
    self.cellTitleLabel.text = @"旅行套餐";
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.courseList?self.courseList.count:self.packageList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YGIndexCourseUnitCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kYGIndexCourseUnitCell forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(YGIndexCourseUnitCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.courseList) {
        [cell configureWithCourse:self.courseList[indexPath.item]];
    }else{
        [cell configureWithPackage:self.packageList[indexPath.item]];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.courseList) {
        [self didSelectedCourse:self.courseList[indexPath.item]];
    }else if (self.packageList){
        [self didSelectedPackage:self.packageList[indexPath.item]];
    }
}

#pragma mark -
- (IBAction)more:(id)sender
{
    [[API shareInstance] statisticalNewWithBuriedpoint:25 objectID:0 Success:nil failure:nil];//埋点
    
    if (self.courseList) {
        HotCourseBean *hotCourseBean1 = [self.courseList firstObject];
        ConditionModel *nextCondition = [[ConditionModel alloc] init];
        NSDate *tomorrow = [Utilities getTheDay:[NSDate date] withNumberOfDays:1];
        NSString *date = [Utilities stringwithDate:tomorrow];
        NSString *time = @"07:30";
        nextCondition.clubId = hotCourseBean1.courseId;
        nextCondition.date = date;
        nextCondition.time = time;
        nextCondition.price = 0;
        nextCondition.people = 0;
        nextCondition.cityId = 0;
        nextCondition.provinceId = 0;
        nextCondition.cityName = [GolfAppDelegate shareAppDelegate].isLocationSuccess?@"当前位置":@"推荐排序";
        ClubListViewController *vc = [ClubListViewController instanceFromStoryboard];
        vc.cm = nextCondition;
        [[[self viewController] navigationController] pushViewController:vc animated:YES];
    }else if (self.packageList){
        YGPackageIndexViewCtrl *vc = [YGPackageIndexViewCtrl instanceFromStoryboard];
        [[[self viewController] navigationController] pushViewController:vc animated:YES];
    }
}

- (void)didSelectedCourse:(HotCourseBean *)course
{
    [[API shareInstance] statisticalNewWithBuriedpoint:26 objectID:0 Success:nil failure:nil];//埋点
    //跳转到球场详情
    NSDate *tomorrow = [Utilities getTheDay:[NSDate date] withNumberOfDays:1];
    NSString *date = [Utilities stringwithDate:tomorrow];
    NSString *time = @"07:30";
    
    ClubMainViewController *vc = [ClubMainViewController instanceFromStoryboard];
    ConditionModel *nextCondition = [[ConditionModel alloc] init];
    nextCondition.clubId = course.courseId;
    nextCondition.date = date;
    nextCondition.time = time;
    vc.cm = nextCondition;
    [[[self viewController] navigationController] pushViewController:vc animated:YES];
}

- (void)didSelectedPackage:(TravelPackageBean *)package
{
    [[API shareInstance] statisticalNewWithBuriedpoint:26 objectID:0 Success:nil failure:nil];//埋点
    
    YGPackageDetailViewCtrl *vc = [YGPackageDetailViewCtrl instanceFromStoryboard];
    vc.packageId = package.packageId;
    [[[self viewController] navigationController] pushViewController:vc animated:YES];
}

@end
