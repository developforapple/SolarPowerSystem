//
//  HomeCoverView.m
//  Golf
//
//  Created by liangqing on 16/3/21.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "HomeCoverView.h"

@implementation HomeCoverView

+(instancetype)loadXibView{
    
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"HomeCoverView" owner:nil options:nil];
    return array.firstObject;
}
- (IBAction)cancelBgViewBtn:(id)sender {
    
    if (self.cancelBtnActionBlock) {
        self.cancelBtnActionBlock();
    }
}

- (IBAction)receiveSoonBtn:(id)sender {
    
    if (self.reciverSoonBtnActionBlock) {
        self.reciverSoonBtnActionBlock();
    }
    
    NSLog(@"立即领取");
}
@end
