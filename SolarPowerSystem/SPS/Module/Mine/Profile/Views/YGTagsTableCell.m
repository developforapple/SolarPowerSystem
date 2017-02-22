//
//  YGTagsTableCell.m
//  Golf
//
//  Created by bo wang on 2016/9/22.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGTagsTableCell.h"

@implementation YGTagCell
- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (self.selectedEnable) {
        self.tagLabel.backgroundColor = selected?MainHighlightColor:[UIColor whiteColor];
        self.tagLabel.textColor = selected?[UIColor whiteColor]:MainHighlightColor;
        
        self.tagLabel.layer.cornerRadius = 2.f;
        self.tagLabel.layer.masksToBounds = YES;
        self.tagLabel.layer.borderColor = selected?NULL:[MainHighlightColor CGColor];
        self.tagLabel.layer.borderWidth = selected?0.f:.5f;
    }
}
@end

@interface YGTagsTableCell () <UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
@property (strong, nonatomic) NSMutableDictionary<NSString *,NSValue *> *tagSizeCache;
@end

@implementation YGTagsTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    if (iOS8) {
        self.layoutMargins = UIEdgeInsetsZero;
    }
    self.tagFlowlayout.maximumInteritemSpacing = 5.f;
    self.tagSizeCache = [NSMutableDictionary dictionary];
}

- (void)configureWithTags:(NSArray *)tags
{
    self.tags = tags;
    [self.tagCollectionView reloadData];
}

- (CGFloat)contentHeight
{
    CGRect frame = self.tagCollectionView.frame;
    frame.size.width = Device_Width-CGRectGetMinX(frame);
    frame.size.height = 100000;
    self.tagCollectionView.frame = frame;
    [self.tagCollectionView reloadData];
    CGFloat height = [self.tagFlowlayout collectionViewContentSize].height;
    [self.contentView layoutIfNeeded];
    return height;
}

- (void)display
{
    [self.tagCollectionView setHidden:NO animated:YES];
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.tags.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YGTagCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YGTagCell" forIndexPath:indexPath];
    cell.tagLabel.text = self.tags[indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *tag = self.tags[indexPath.row];
    NSValue *theSize = self.tagSizeCache[tag];
    if (theSize) {
        return [theSize CGSizeValue];
    }
    
    CGFloat width = [tag sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width;
    CGSize size = CGSizeMake(width + 24.f, 24.f);
    self.tagSizeCache[tag] = [NSValue valueWithCGSize:size];
    return size;
}
@end
