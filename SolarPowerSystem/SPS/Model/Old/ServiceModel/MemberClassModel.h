//
//  MemberClassModel.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/21.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MemberClassModel : NSObject

@property (nonatomic) int classId;
@property (nonatomic) int coachId;
@property (nonatomic,copy) NSString *nickName;
@property (nonatomic,copy) NSString *headImage;
@property (nonatomic) int classHour;
@property (nonatomic) int remainHour;
@property (nonatomic) int productId;
@property (nonatomic,copy) NSString *productName;
@property (nonatomic,copy) NSString *orderTime;
@property (nonatomic) int publicClassId;
@property (nonatomic,copy) NSString *expireDate;
@property (nonatomic,copy) NSString *teachingSite;
@property (nonatomic) int price;
@property (nonatomic) int classType;
@property (nonatomic,copy) NSString *mobilePhone;
@property (nonatomic) int orderState;

// 课时Id
@property (assign, nonatomic) int periodId;

@property (nonatomic,strong) NSArray *reservationList;

- (id)initWithDic:(id)dic;

@end
