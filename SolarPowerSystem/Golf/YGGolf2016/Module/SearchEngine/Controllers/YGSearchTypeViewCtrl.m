//
//  YGSearchTypeViewCtrl.m
//  Golf
//
//  Created by bo wang on 16/7/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGSearchTypeViewCtrl.h"

@interface YGSearchTypeViewCtrl ()<UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

@end

@implementation YGSearchTypeViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
}

- (void)initUI
{
    CGFloat itemW = self.flowLayout.itemSize.width;
    CGFloat spacing = (Device_Width - 3*itemW)/4;   //间距等分
    
    UIEdgeInsets sectionInsets = self.flowLayout.sectionInset;
    sectionInsets.left = (int)spacing;
    sectionInsets.right = (int)spacing;
    self.flowLayout.sectionInset = sectionInsets;
    self.flowLayout.minimumInteritemSpacing = (int)spacing;
}

- (IBAction)tap:(id)sender
{
    [self.view.window endEditing:YES];
}

#pragma mark - UICollectioView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 6;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const kYGSearchTypeCell = @"YGSearchTypeCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kYGSearchTypeCell forIndexPath:indexPath];
    YGSearchType type = 1<<indexPath.item;
    UIImageView *iconImageView = [cell viewWithTag:10086];
    UILabel *titleLabel = [cell viewWithTag:10010];
    iconImageView.image = [UIImage imageNamed:SearchIconNameOfType(type)];
    titleLabel.text = SearchTitleOfType(type);
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    YGSearchType type = 1<<indexPath.item;
    if (self.didSelectedType) {
        self.didSelectedType(type);
    }
}

#pragma mark - Gesture
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ![[touch.view superview] isKindOfClass:[UICollectionViewCell class]];
}

@end
