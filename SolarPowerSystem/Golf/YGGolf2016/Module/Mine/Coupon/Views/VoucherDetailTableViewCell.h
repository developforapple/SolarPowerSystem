//
//  VoucherDetailTableViewCell.h
//  Golf
//
//  Created by 廖瀚卿 on 15/4/9.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CouponModel.h"

@interface VoucherDetailTableViewCell : UITableViewCell

//hide表示是否隐藏券底部的横线和文字描述
-(void)setCouponModel:(CouponModel *)model hideLine:(BOOL)hide;
@end
