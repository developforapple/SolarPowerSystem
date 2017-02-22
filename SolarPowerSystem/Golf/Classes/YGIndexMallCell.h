//
//  YGIndexMallCell.h
//  Golf
//
//  Created by bo wang on 2016/11/17.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "YGIndexCellProtocol.h"

UIKIT_EXTERN NSString *const kYGIndexMallCell;

/**
 首页商城入口cell
 */
@interface YGIndexMallCell : UITableViewCell //<YGIndexCellProtocol>

- (void)configureWithData:(ThemeCommodityList *)data;

@end
