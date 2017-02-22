//
//  OrderSubmitStatusCell.h
//  Golf
//
//  Created by 黄希望 on 15/11/3.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderSubmitStatusCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIButton *orderStatusBtn;
@property (nonatomic,copy) BlockReturn orderDetailBlock;
@property (nonatomic,copy) BlockReturn backHomeBlock;

@end
