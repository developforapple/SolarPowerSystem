//
//  OrderSubmitStatusCell.m
//  Golf
//
//  Created by 黄希望 on 15/11/3.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "OrderSubmitStatusCell.h"

@interface OrderSubmitStatusCell ()

@property (nonatomic,weak) IBOutlet UIImageView *lineImg;
@property (nonatomic,strong) IBOutletCollection(UIButton) NSArray *buttons;

@end

@implementation OrderSubmitStatusCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _lineImg.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"img_ppline_blue"]];
    
    for (UIButton *btn in _buttons) {
        [Utilities drawView:btn radius:3 bordLineWidth:1 borderColor:[UIColor colorWithHexString:@"249df3"]];
    }
}

- (IBAction)checkOrderDetail:(id)sender{
    if (_orderDetailBlock) {
        _orderDetailBlock (nil);
    }
}

- (IBAction)backHomeAction:(id)sender{
    if (_backHomeBlock) {
        _backHomeBlock (nil);
    }
}

@end
