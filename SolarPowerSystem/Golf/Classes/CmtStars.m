//
//  CmtStars.m
//  Golf
//
//  Created by 黄希望 on 15/10/23.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "CmtStars.h"

@implementation CmtStars

+ (void)setStars:(NSArray*)stars cmtLevel:(int)cmtLevel large:(BOOL)large{
    for (UIImageView *iv in stars) {
        iv.image = [UIImage imageNamed: large ? @"ic_star_gray": @"ic_star_gray_small"];
        int n = cmtLevel / 20 ;
        int m = cmtLevel % 20 ;
        if (iv.tag <= n) {
            iv.image = [UIImage imageNamed:large ? @"ic_star_yellow": @"ic_star_yellow_small"];
        }
        if (m>5 && iv.tag == n+1) {
            iv.image = [UIImage imageNamed:large ? @"ic_star_big_half": @"ic_star_small_half"];
        }
    }
}

@end
