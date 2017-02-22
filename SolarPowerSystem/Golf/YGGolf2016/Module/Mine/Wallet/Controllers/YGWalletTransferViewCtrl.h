//
//  YGWalletTransferViewCtrl.h
//  Golf
//
//  Created by zhengxi on 15/12/14.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 转账
 */
@interface YGWalletTransferViewCtrl : BaseNavController
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

//添加打球球友
@property (nonatomic) BOOL isAddGolfer;
@property (strong, nonatomic) void (^addGolferBlock) (NSMutableArray *);
@property (strong, nonatomic) NSMutableArray *selectedCopyArray;

@end
