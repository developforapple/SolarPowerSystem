//
//  InvoiceViewController.h
//  Golf
//
//  Created by 黄希望 on 15/10/30.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "BaseNavController.h"
#import "Invoice.h"

@interface InvoiceViewController : BaseNavController

@property (nonatomic,strong) TTModel *ttm;
@property (nonatomic,strong) ConditionModel *cm;
@property (nonatomic,strong) Invoice *invoice;

@property (nonatomic,copy) BlockReturn blockReturn;

@end
