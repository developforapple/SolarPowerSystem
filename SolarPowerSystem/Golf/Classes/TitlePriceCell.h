//
//  TitlePriceCell.h
//  Golf
//
//  Created by 黄希望 on 15/10/27.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TitlePriceCell : UITableViewCell

// title
@property (nonatomic,weak) IBOutlet UILabel *ttLabel;
// 价格
@property (nonatomic,weak) IBOutlet UILabel *priceLabel;

@property (nonatomic,weak) IBOutlet UIView *bottomLine;

@end
