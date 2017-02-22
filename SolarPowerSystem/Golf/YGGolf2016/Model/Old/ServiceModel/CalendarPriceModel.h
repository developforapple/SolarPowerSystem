//
//  CalendarPriceModel.h
//  Golf
//
//  Created by 黄希望 on 15/10/22.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalendarPriceModel : NSObject

@property (nonatomic,strong) NSString *date;
@property (nonatomic,strong) NSString *holidayName;
@property (nonatomic,assign) int price;
@property (nonatomic,assign) int specialOffer;

- (id)initWithDic:(id)dic;

@end
