//
//  CommodityCategory.h
//  Golf
//
//  Created by 黄希望 on 15/3/30.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommodityCategory : NSObject

@property (nonatomic,assign) int categoryId;
@property (nonatomic,copy) NSString *categoryName;
@property (nonatomic,assign) int relativeType; //1球具 2: 球场 3: 学院
@property (nonatomic,strong) NSString *categoryIcon; // 类别图片
@property (nonatomic,strong) NSMutableArray *subCategoryList;

- (id)initWithDic:(id)data;

@end
