//
//  YGMallCommoditySpecInfoView.h
//  Golf
//
//  Created by bo wang on 2016/10/12.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const kYGMallCommoditySpecHeader;

/**
 作为UICollectionView的header使用
 */
@interface YGMallCommoditySpecInfoView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (void)configureWithAttrModel:(CommoditySpecAttrModel *)attrModel;

@end
