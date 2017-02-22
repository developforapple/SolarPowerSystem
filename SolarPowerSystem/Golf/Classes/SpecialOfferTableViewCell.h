//
//  SpecialOfferTableViewCell.h
//  Golf
//
//  Created by liangqing on 16/4/12.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpecialOfferTableViewCell : UITableViewCell
@property (nonatomic,strong) IBOutlet UILabel *currentPriceLabel;
@property (nonatomic,strong) IBOutlet UILabel *originalPriceLabel;
@property (nonatomic,strong) IBOutlet UIImageView *lineImg;
@property (nonatomic,strong) IBOutlet UILabel *timeAreaLabel;
@property (weak, nonatomic) IBOutlet UILabel *clubNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgLineWidth;

@end
