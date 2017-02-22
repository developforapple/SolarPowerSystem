//
//  CoachDataRpt.h
//  Golf
//
//  Created by 黄希望 on 15/6/16.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataReport : NSObject

@property (nonatomic,strong) NSString *productName;
@property (nonatomic,assign) int orderCount;
@property (nonatomic,assign) int orderAmount;
@property (nonatomic,assign) int teachCount;

- (id)initWithDic:(id)data;

@end

@interface CoachDataRpt : NSObject

@property (nonatomic,assign) int orderCount;
@property (nonatomic,assign) int orderAmount;
@property (nonatomic,assign) int teachCount;
@property (nonatomic,strong) NSMutableArray *dataList;

- (id)initWithDic:(id)data;

@end
