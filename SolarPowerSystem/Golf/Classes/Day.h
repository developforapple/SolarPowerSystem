//
//  Day.h
//  Golf
//
//  Created by 黄希望 on 15/10/21.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Day : NSObject

// 是否被选中
@property (nonatomic,assign) BOOL selected;
// 原价
@property (nonatomic,assign) int price;
// special_offer代表特价，1：特价 0：正常价
@property (nonatomic,assign) int specialOffer;
// 某天
@property (nonatomic,assign) NSInteger day;
// 该天对应的周几 1.周一 0.周日
@property (nonatomic,assign) NSInteger weekDay;
// 日期
@property (nonatomic,strong) NSDate *date;
// 法定假日名
@property (nonatomic,strong) NSString *holidayName;

@property (nonatomic,copy) BlockReturn selectBlock;

@property (nonatomic,copy) BlockReturn selectEndBlock;

@end
