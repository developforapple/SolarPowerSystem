//
//  YGMallCommodityDetailDescView.h
//  Golf
//
//  Created by bo wang on 2016/11/22.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YGMallCommodityDetailDescView : UIView

@property (copy, nonatomic) void (^updateCallback)(CGFloat height);
@property (weak, nonatomic) UIViewController *viewCtrl; //必须赋值

@property (strong, nonatomic) CommodityInfoModel *commodity;
- (void)configureWithCommodity:(CommodityInfoModel *)commodity;

@end
