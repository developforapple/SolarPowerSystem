//
//  TwoLineLabel.m
//  Golf
//
//  Created by Main on 16/7/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "TwoLineLabel.h"

@implementation TwoLineLabel

+ (instancetype)nib{
    TwoLineLabel *view = [[[NSBundle mainBundle] loadNibNamed:@"TwoLineLabel" owner:nil options:nil] firstObject];
    view.translatesAutoresizingMaskIntoConstraints = YES;
    return view;
}

@end
