//
//  MemberReservationModel.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/20.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "MemberReservationModel.h"
#import "ReservationModel.h"

@implementation MemberReservationModel

- (id)initWithDic:(id)data{
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    
    NSDictionary *dic = (NSDictionary *)data;
    if ([dic objectForKey:@"remain_hour"]) {
        self.remainHour = [[dic objectForKey:@"remain_hour"] intValue];
    }
    if ([dic objectForKey:@"class_count"]) {
        self.classCount = [[dic objectForKey:@"class_count"] intValue];
    }
    if ([dic objectForKey:@"data_list"]) {
        NSArray *arr = [dic objectForKey:@"data_list"];
        if (arr && arr.count > 0) {
            NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:arr.count];
            for (id obj in arr) {
                ReservationModel *m = [[ReservationModel alloc] initWithDic:obj];
                [list addObject:m];
            }
            self.dataList = list;
        }
    }
    return self;
}
@end
