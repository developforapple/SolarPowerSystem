//
//  YGTagsEditingViewCtrl.m
//  Golf
//
//  Created by 黄希望 on 14-9-22.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "YGTagsEditingViewCtrl.h"
#import "YGCollectionViewLayout.h"
#import "YGTagsTableCell.h"

#import "CCAlertView.h"

@interface _YGTag : NSObject
@property (strong, nonatomic) NSString *tag;
@property (assign, nonatomic) BOOL selected;
@property (strong, nonatomic) NSValue *size;
@end

@implementation _YGTag
- (CGSize)estimateSize
{
    if (self.size) {
        return self.size.CGSizeValue;
    }
    CGFloat width = [self.tag sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}].width;
    CGSize size = CGSizeMake(width + 30.f, 28.f);
    self.size = [NSValue valueWithCGSize:size];
    return size;
}
@end

@interface YGTagsEditingViewCtrl ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet YGLeftAlignmentFlowLayout *flowLayout;

@property (strong, nonatomic) NSMutableArray<_YGTag *> *allTags;

@property (strong, nonatomic) NSArray<_YGTag *> *selectedTags;
@property (strong, nonatomic) NSArray<_YGTag *> *randomTags;

// 外部传入的所有标签
@property (strong, nonatomic) NSArray<NSString *> *oldTags;

@end

@implementation YGTagsEditingViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.allTags = [NSMutableArray array];
    
    self.collectionView.hidden = YES;
    self.collectionView.allowsMultipleSelection = YES;
    self.flowLayout.maximumInteritemSpacing = 13.f;
    
    self.oldTags = [self.personalTag componentsSeparatedByString:@","];
    
    [self rightButtonAction:@"保存"];
    
    [[ServiceManager serviceManagerWithDelegate:self] userTagAll];
}

- (void)doRightNavAction
{
    NSMutableArray *array = [NSMutableArray array];
    for (_YGTag *tag in self.allTags) {
        if (tag.selected) {
            [array addObject:tag.tag];
        }
    }
    NSString *string = [array componentsJoinedByString:@","];
    if ([self.delegate respondsToSelector:@selector(editPersonalTagCallBack:identifier:)]) {
        [self.delegate editPersonalTagCallBack:string identifier:@"personalTag"];
    }
    [self back];
}

#pragma mark - 业务方法
- (IBAction)showAddTagView:(id)sender {
    CCAlertView *alert = [[CCAlertView alloc] initWithTitle:nil message:@"请输入标签"];
    [alert setAlertViewStyle:(UIAlertViewStylePlainTextInput)];
    UITextField *tf = [alert textFieldAtIndex:0];
    tf.placeholder = @"请输入";
    [alert addButtonWithTitle:@"取消" block:nil];
    [alert addButtonWithTitle:@"确定" block:^{
        [self addTag:tf.text];
    }];
    [alert show];
}

- (void)addTag:(NSString *)str
{
    NSString *tag = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (tag.length == 0) return;
    
    _YGTag *theTag = [_YGTag new];
    theTag.tag = tag;
    theTag.selected = YES;
    [self.allTags addObject:theTag];
    [self reloadVisibleTags:NO];
}

- (IBAction)changeTags:(id)sender
{
    [self reloadVisibleTags:YES];
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag
{
    NSArray *arr = (NSArray*)data;
    
    NSMutableArray *allTags = [NSMutableArray array];
    for (NSString *tag in arr) {
        _YGTag *theTag = [_YGTag new];
        theTag.tag = tag;
        theTag.selected = [self.oldTags containsObject:tag];
        [allTags addObject:theTag];
    }
    self.allTags = allTags;
    [self reloadVisibleTags:YES];
    [self.collectionView setHidden:NO animated:YES];
}

- (void)reloadVisibleTags:(BOOL)random
{
    NSMutableArray *selectedTags = [NSMutableArray array];
    NSMutableArray *otherTags = [NSMutableArray array];
    for (_YGTag *aTag in self.allTags) {
        if (aTag.selected) {
            [selectedTags addObject:aTag];
        }else{
            [otherTags addObject:aTag];
        }
        [aTag estimateSize];    //这里事先计算一次size
    }
    
    NSArray *randomTags;
    
    // 强制随机 或者 从未随机过
    if (random || !self.randomTags) {
        // 打乱顺序
        [otherTags shuffle];
        if (otherTags.count >= 40) {
            randomTags = [otherTags subarrayWithRange:NSMakeRange(0, 40)];
        }else{
            randomTags = otherTags;
        }
    }else{
        randomTags = self.randomTags;
    }
    
    self.selectedTags = selectedTags;
    self.randomTags = randomTags;
    [self.collectionView reloadData];
    
    NSUInteger count = self.selectedTags.count + self.randomTags.count;
    
    ygweakify(self);
    [self.collectionView performBatchUpdates:^{
        ygstrongify(self);
        for (NSUInteger idx = 0; idx < count; idx ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:0];
            _YGTag *tag = [self tagAtIndexPath:indexPath];
            if (tag.selected) {
                [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            }else{
                [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
            }
        }
    } completion:^(BOOL finished) {
        
    }];
}

- (_YGTag *)tagAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    if (row < self.selectedTags.count) {
        return self.selectedTags[row];
    }
    return self.randomTags[row-self.selectedTags.count];
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.selectedTags.count + self.randomTags.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YGTagCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YGTagCell" forIndexPath:indexPath];
    _YGTag *tag = [self tagAtIndexPath:indexPath];
    cell.selectedEnable = YES;
    cell.tagLabel.text = tag.tag;
    cell.selected = tag.selected;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    _YGTag *tag = [self tagAtIndexPath:indexPath];
    tag.selected = YES;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    _YGTag *tag = [self tagAtIndexPath:indexPath];
    tag.selected = NO;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    _YGTag *tag = [self tagAtIndexPath:indexPath];
    return [tag estimateSize];
}

@end
