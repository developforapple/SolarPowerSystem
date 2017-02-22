//
//  YGMapAnnotation.m
//  Golf
//
//  Created by bo wang on 2016/12/21.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMapAnnotation.h"

@implementation YGMapAnnotation
+ (NSArray<YGMapAnnotation *> *)annotations:(NSArray *)clubList
{
    NSMutableArray *list = [NSMutableArray array];
//    for (ClubModel *club in clubList) {
//        YGMapAnnotation *annotation = [YGMapAnnotation new];
//        annotation.title = club.clubName;
//        annotation.subtitle = club.address;
//        annotation.coordinate = CLLC2DMake(club.latitude, club.longitude);
//        annotation.club = club;
//        [list addObject:annotation];
//    }
    return list;
}
@end
