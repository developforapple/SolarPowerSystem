//
//  YGMallFlashSaleCell.h
//  Golf
//
//  Created by bo wang on 2016/11/16.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGMallFlashSaleLogic.h"

UIKIT_EXTERN NSString *const kYGMallFlashSaleCell;

@interface YGMallFlashSaleCell : UITableViewCell

+ (void)registerIn:(UITableView *)tableView;
+ (CGSize)cellSize;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

@property (strong, nonatomic) YGMallFlashSaleLogic *flashSale;
@property (copy, nonatomic) void (^didFinishLoadCallback)(void);

@end
