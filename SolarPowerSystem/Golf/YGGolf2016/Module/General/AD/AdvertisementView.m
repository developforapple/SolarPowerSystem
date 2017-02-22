//
//  AdvertisementView.m
//  Golf
//
//  Created by zhengxi on 15/11/10.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "AdvertisementView.h"

@implementation AdvertisementView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)removeFromTheSuperView:(id)sender {
    if (_skipAdsBlock) {
        _skipAdsBlock();
    }
}
@end
