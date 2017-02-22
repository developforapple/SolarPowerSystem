//
//  Province.h
//  Golf
//
//  Created by 黄希望 on 15/10/19.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Province : NSObject

// 是否展开
@property (nonatomic) BOOL open;
// 省份id
@property (nonatomic) int pId;
// 身份名字
@property (nonatomic,copy) NSString *pName;
// 省份内的城市
@property (nonatomic,strong) NSArray *citys;

@end
