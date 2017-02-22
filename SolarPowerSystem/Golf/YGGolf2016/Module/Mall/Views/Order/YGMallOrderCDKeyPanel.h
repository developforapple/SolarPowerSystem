//
//  YGMallOrderCDKeyPanel.h
//  Golf
//
//  Created by bo wang on 2016/11/11.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGMallOrderModel.h"

#define kEvidenceSpacing 12.f
#define kEvidenceUnitHeight 12.f

@interface YGMallOrderCDKeyPanel : UIView

- (void)setupWithCommodity:(YGMallOrderCommodity *)commodity
                   inOrder:(YGMallOrderModel *)order;

@end
