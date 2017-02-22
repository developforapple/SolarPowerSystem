//
//  SubCommodityCategory.h
//  Golf
//
//  Created by 黄希望 on 15/3/30.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubCommodityCategory : NSObject

@property (nonatomic,assign) int subCategoryId;
@property (nonatomic,strong) NSString *subCategoryName;

- (id)initWithDic:(id)data;

@end
