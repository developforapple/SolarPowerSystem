//
//  MemberReservationModel.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/20.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MemberReservationModel : NSObject

@property (nonatomic) int remainHour;
@property (nonatomic) int classCount;

@property (nonatomic,strong) NSArray *dataList;

- (id)initWithDic:(id)data;

@end
