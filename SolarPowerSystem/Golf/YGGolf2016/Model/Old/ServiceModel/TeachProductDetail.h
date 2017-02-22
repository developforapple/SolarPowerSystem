//
//  TeachProductDetail.h
//  Golf
//
//  Created by 黄希望 on 15/5/12.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TeachProductDetail : NSObject

@property (nonatomic,assign) int productId;
@property (nonatomic,strong) NSString *productName;
@property (nonatomic,strong) NSString *productIntro;
@property (nonatomic,assign) int sellingPrice;
@property (nonatomic,assign) int originalPrice;
@property (nonatomic,assign) int classHour;
@property (nonatomic,assign) int personLimit;
@property (nonatomic,strong) NSString *productImage;
@property (nonatomic,strong) NSString *productDetail;
@property (nonatomic,assign) int validDays;
@property (nonatomic,strong) NSString *buyGuide;
@property (nonatomic,assign) int classType; // 课程类型
@property (nonatomic) int giveYunbi;//返云币
- (id)initWithDic:(id)data;

@end
