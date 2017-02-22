//
//  YGOrdersSummaryViewCtrl.m
//  Golf
//
//  Created by bo wang on 2016/12/9.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGOrdersSummaryViewCtrl.h"
#import "YGOrdersSummaryCell.h"
#import "YGOrderListViewCtrl.h"

@interface YGOrdersSummaryViewCtrl () <UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowlayout;
@property (strong, nonatomic) NSArray <YGOrdersSummaryItem *> *items;
@end

@implementation YGOrdersSummaryViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI
{
    CGFloat w = floorf((Device_Width - self.flowlayout.sectionInset.left - self.flowlayout.sectionInset.right - self.flowlayout.minimumInteritemSpacing)/2.f);
    self.flowlayout.itemSize = CGSizeMake(w,w);
    self.collectionView.contentInset = UIEdgeInsetsMake(self.edgeInsetsTop, 0, 0, 0);
}

- (void)reload:(YGOrderManager *)manager
{
    self.items = manager.items;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YGOrdersSummaryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kYGOrdersSummaryCell forIndexPath:indexPath];
    cell.item = self.items[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    YGOrdersSummaryItem *item = self.items[indexPath.item];
    YGOrderListViewCtrl *vc = [YGOrderListViewCtrl instanceFromStoryboard];
    vc.orderType = item.type;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
