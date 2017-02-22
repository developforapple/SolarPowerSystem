//
//  KDCycleBannerViewCell.h
//  Golf
//
//  Created by Main on 16/7/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDCycleBannerView.h"

@interface KDCycleBannerViewCell : UITableViewCell

@property (nonatomic,copy) BlockReturn blockSelected;

- (void)loadDatas:(NSArray *)arr; //加载数据

@end
