//
//  Star.m
//  Golf
//
//  Created by user on 13-6-5.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import "Star.h"

@implementation Star

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setImage:[UIImage imageNamed:@"ic_star_gray"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"ic_star_yellow"] forState:UIControlStateSelected];
    }
    return self;
}

@end
