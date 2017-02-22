//
//  YGTagsTableCell.h
//  Golf
//
//  Created by bo wang on 2016/9/22.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGCollectionViewLayout.h"

@interface YGTagCell : UICollectionViewCell
@property (assign, nonatomic) BOOL selectedEnable;
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;
@end

@interface YGTagsTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UICollectionView *tagCollectionView;
@property (weak, nonatomic) IBOutlet YGLeftAlignmentFlowLayout *tagFlowlayout;

@property (strong, nonatomic) NSArray *tags;

- (void)configureWithTags:(NSArray *)tags;
- (CGFloat)contentHeight;

- (void)display;

@end
