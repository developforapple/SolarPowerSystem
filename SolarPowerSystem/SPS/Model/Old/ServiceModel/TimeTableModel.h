//
//  TimeTableModel.h
//  Golf
//
//  Created by 黄希望 on 15/11/2.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeTableModel : NSObject

@property (nonatomic,strong) NSString *time;
@property (nonatomic,assign) int minPrice;
@property (nonatomic,assign) int specialOffer;

- (id)initWithDic:(id)data;

@end
