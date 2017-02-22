//
//  YGMallFlashSaleCell.m
//  Golf
//
//  Created by bo wang on 2016/11/16.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallFlashSaleCell.h"

@interface _YGMallFlashSaleTimerView : UIView
@property (weak, nonatomic) IBOutlet UILabel *noticeLabel;
@property (weak, nonatomic) IBOutlet UILabel *hourLabel;
@property (weak, nonatomic) IBOutlet UILabel *minLabel;
@property (weak, nonatomic) IBOutlet UILabel *secLabel;
@end

@implementation _YGMallFlashSaleTimerView
@end

#import "YGMallFlashSaleCellUnit.h"
#import "YGMallFlashSaleLogic.h"
#import "YGMallFlashSaleListViewCtrl.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

#define kMargin 13.f
#define kSpacing 6.f

static NSString *const kYGMallFlashSaleLoadMoreCell = @"YGMallFlashSaleLoadMoreCell";

@interface YGMallFlashSaleCell () <UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet _YGMallFlashSaleTimerView *timerView;
@property (weak, nonatomic) IBOutlet UILabel *inFlashSaleLabel;
@property (assign, nonatomic) BOOL loadMoreFlag;
@end

NSString *const kYGMallFlashSaleCell = @"YGMallFlashSaleCell";

@implementation YGMallFlashSaleCell

+ (void)registerIn:(UITableView *)tableView
{
    [tableView registerNib:[UINib nibWithNibName:@"YGMallFlashSaleCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kYGMallFlashSaleCell];
}

+ (CGSize)cellSize
{
    // 46.f 顶部时间区域高度
    return CGSizeMake(Device_Width, [self unitSize].height + 46.f);
}

+ (CGSize)unitSize
{
    static CGSize size;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSInteger unitCount = 3;
        CGFloat unitW = (Device_Width - 2 * kMargin - (unitCount - 1) * kSpacing)/(CGFloat)unitCount;
        CGFloat imageH = unitW * 442.f / 640.f;
        CGFloat priceTop = 12.f;
        CGFloat priceH = 20.f;
        CGFloat priceBottom = 24.f;
        CGFloat unitH = imageH + priceTop + priceH + priceBottom;
        size = CGSizeMake(unitW, unitH);
    });
    return size;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self.collectionView registerNib:[UINib nibWithNibName:@"YGMallFlashSaleCellUnit" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kYGMallFlashSaleCellUnit];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kYGMallFlashSaleLoadMoreCell];
    self.flowLayout.sectionInset = UIEdgeInsetsMake(0, kMargin, 0, kMargin);
    self.flowLayout.minimumInteritemSpacing = kSpacing;
    self.flowLayout.minimumLineSpacing = kSpacing;
    self.flowLayout.itemSize = [YGMallFlashSaleCell unitSize];
}

- (void)dealloc
{
    self.flashSale.callback = nil;
    [self.flashSale.timer cancel];
}

- (void)setFlashSale:(YGMallFlashSaleLogic *)flashSale
{
    if (_flashSale != flashSale) {
        _flashSale = flashSale;
        
        ygweakify(self);
        [flashSale setCallback:^(BOOL suc, BOOL isMore, id object) {
            ygstrongify(self);
            UIEdgeInsets insets = self.flowLayout.sectionInset;
            if ([self showLoadMore]) {
                insets.right = 0.f;
            }
            self.flowLayout.sectionInset = insets;
            [self.collectionView reloadData];
            [self refreshSaleTimestamp];
            
            if (self.didFinishLoadCallback) {
                self.didFinishLoadCallback();
            }
        }];
        [self.collectionView reloadData];
        [self.flashSale refresh];
    }
}

- (void)refreshSaleTimestamp
{
    ygweakify(self);
    [self.flashSale refreshFlashSaleTimestamp:^(long long nextTime) {
        ygstrongify(self);
        if (nextTime != 0) {
            [self startCountdownIfNeed];
        }else{
            [self showFlashSaleStatus];
        }
    }];
}

- (void)startCountdownIfNeed
{
    YGCountdownTimer *timer = self.flashSale.timer;
    
    NSString *(^map)(NSNumber *value) = ^NSString *(NSNumber *value){
        NSInteger v = value.integerValue;
        v = MAX(0, MIN(99, v));
        return [NSString stringWithFormat:@"%02ld",(long)v];
    };
    
    ygweakify(self);
    [[RACObserve(timer, hour) map:map]
     subscribeNext:^(id x) {
         ygstrongify(self);
         self.timerView.hourLabel.text = x;
     }];
    [[RACObserve(timer, minute) map:map]
     subscribeNext:^(id x) {
         ygstrongify(self);
         self.timerView.minLabel.text = x;
     }];
    [[RACObserve(timer, second) map:map]
     subscribeNext:^(id x) {
         ygstrongify(self);
         self.timerView.secLabel.text = x;
     }];
    
//    RAC(self.timerView.hourLabel,text) = [[RACObserve(timer, hour) map:map] switchToLatest];
//    RAC(self.timerView.minLabel,text) = [[RACObserve(timer, minute) map:map] switchToLatest];
//    RAC(self.timerView.secLabel,text) = [[RACObserve(timer, second) map:map] switchToLatest];
    
    self.timerView.noticeLabel.text = self.flashSale.flashSaleNotice;
    self.timerView.hidden = NO;
    self.inFlashSaleLabel.hidden = YES;
}

- (void)showFlashSaleStatus
{
    self.inFlashSaleLabel.hidden = NO;
    self.inFlashSaleLabel.text = self.flashSale.flashSaleNotice;
    self.timerView.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        [self showFlashSaleList];
    }
}

- (void)showFlashSaleList
{
    [[API shareInstance] statisticalNewWithBuriedpoint:50 objectID:0 Success:nil failure:nil];
    YGMallFlashSaleListViewCtrl *vc = [YGMallFlashSaleListViewCtrl instanceFromStoryboard];
    [[[self viewController] navigationController] pushViewController:vc animated:YES];
}

- (BOOL)showLoadMore
{
    return self.flashSale.data.count >= 4 && self.flashSale.scene == YGMallFlashSaleSceneMallIndex;
}

- (BOOL)isLoadMoreCell:(NSInteger)item
{
    return [self showLoadMore] && item + 1 == [self.collectionView numberOfItemsInSection:0];
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger extraCell = [self showLoadMore]?1:0;
    return self.flashSale.data.count + extraCell;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isLoadMoreCell:indexPath.item]) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kYGMallFlashSaleLoadMoreCell forIndexPath:indexPath];
        UILabel *label = [cell viewWithTag:10086];
        if (!label) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(cell.bounds), CGRectGetHeight(cell.bounds)-12.f)];
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentCenter;
            label.text = @"左\n滑\n查\n看\n更\n多";
            label.font = [UIFont systemFontOfSize:12];
            label.textColor = RGBColor(153, 153, 153, 1);
            label.tag = 10086;
            label.backgroundColor = RGBColor(244, 244, 244, 1);
            [cell.contentView addSubview:label];
        }
        
        return cell;
    }
    
    YGMallFlashSaleCellUnit *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kYGMallFlashSaleCellUnit forIndexPath:indexPath];
    [cell configureWithCommodity:self.flashSale.data[indexPath.item]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isLoadMoreCell:indexPath.item]) {
        self.loadMoreFlag = NO;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isLoadMoreCell:indexPath.item]) {
        return CGSizeMake(25, self.flowLayout.itemSize.height);
    }
    return self.flowLayout.itemSize;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([self showLoadMore]) {
        if ([self scrollViewOffsetSuportShowMore:scrollView.contentOffset.x]) {
            if (!self.loadMoreFlag) {
                self.loadMoreFlag = YES;
                [self showFlashSaleList];
            }
        }else{
            self.loadMoreFlag = NO;
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self showLoadMore]) {
        if (![self scrollViewOffsetSuportShowMore:scrollView.contentOffset.x]) {
            self.loadMoreFlag = NO;
        }
    }
}

- (BOOL)scrollViewOffsetSuportShowMore:(CGFloat)offsetX
{
    return offsetX > self.collectionView.contentSize.width - CGRectGetWidth(self.collectionView.frame) + 64.f;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self showFlashSaleList];
}

@end
