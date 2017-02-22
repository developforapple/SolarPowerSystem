//
//  YGWalletTransferUserCell.h
//  Golf
//
//  Created by zhengxi on 15/12/14.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserFollowModel;

@interface YGWalletTransferUserCell : UITableViewCell
@property (strong, nonatomic) UserFollowModel *model;
@property (nonatomic) BOOL isSearchResults;
@property (weak, nonatomic) id delegate;

@end
