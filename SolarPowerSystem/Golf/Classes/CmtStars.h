//
//  CmtStars.h
//  Golf
//
//  Created by 黄希望 on 15/10/23.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

// 根据评分处理星星的显示
@interface CmtStars : NSObject

+ (void)setStars:(NSArray*)stars cmtLevel:(int)cmtLevel large:(BOOL)large;

@end
