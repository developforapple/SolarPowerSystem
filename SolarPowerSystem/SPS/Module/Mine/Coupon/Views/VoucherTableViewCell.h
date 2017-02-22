//
//  VoucherNormalTableViewCell.h
//  Golf
//  现金券的五中样式， 高度 101pt
//  Created by 廖瀚卿 on 15/4/7.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, VoucherTableViewType) {
    VoucherTableViewTypeNone,           // 默认
    VoucherTableViewTypeDisabled,       // 现金券不可用状态
    VoucherTableViewTypeChecked,        // 复选框选中
    VoucherTableViewTypeUnchecked,      // 复选框没有选中
    VoucherTableViewTypeMore,           // 显示右边状态
    VoucherTableViewTypeCantUse,        // 券不能使用
};

@interface VoucherTableViewCell : UITableViewCell

@property (nonatomic) VoucherTableViewType viewType;

- (void)setPrice:(NSString *)price;
- (void)setTitle:(NSString *)title;
- (void)setOther:(NSString *)other;

//- (void)layout;
@end
 