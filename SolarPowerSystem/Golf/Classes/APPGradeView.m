//
//  APPGradeView.m
//  Golf
//
//  Created by liangqing on 16/9/18.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "APPGradeView.h"
#import <StoreKit/StoreKit.h>
@interface APPGradeView()<SKStoreProductViewControllerDelegate>
@end
@implementation APPGradeView

+(instancetype)loadAPPGradeViewFromNib{
    APPGradeView *v = [[NSBundle mainBundle] loadNibNamed:@"APPGradeView" owner:nil options:nil].firstObject;
    return v;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        
    }
    return self;
}

- (IBAction)RejectClick:(id)sender {
    if (self.blockCancel) {
        self.blockCancel(nil);
    }
}
- (IBAction)praiseClick:(id)sender {
    if (self.blockEvaluate) {
        self.blockEvaluate(nil);
    }
}
@end
