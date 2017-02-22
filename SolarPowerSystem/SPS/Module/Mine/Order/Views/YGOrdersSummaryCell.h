//
//  YGOrdersSummaryCell.h
//  Golf
//
//  Created by bo wang on 2016/12/9.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGOrderManager.h"

@class YGOrdersSummaryItem;

UIKIT_EXTERN NSString *const kYGOrdersSummaryCell;

@interface YGOrdersSummaryCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *amountBtn;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) YGOrdersSummaryItem *item;
@end
