//
//  Time.h
//  Golf
//
//  Created by 黄希望 on 15/10/21.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Time : NSObject

// 是否被选中
@property (nonatomic,assign) BOOL selected;
// 原价
@property (nonatomic,assign) int price;
// special_offer代表特价，1：特价 0：正常价
@property (nonatomic,assign) int specialOffer;
// 时间
@property (nonatomic,strong) NSString *teetime;
// 日期
@property (nonatomic,strong) NSDate *date;

@property (nonatomic,copy) BlockReturn selectBlock;

@property (nonatomic,copy) BlockReturn selectEndBlock;

@end
