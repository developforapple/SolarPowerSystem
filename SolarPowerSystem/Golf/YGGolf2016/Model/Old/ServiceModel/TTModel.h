//
//  TTModel.h
//  Golf
//
//  Created by 黄希望 on 13-12-30.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTModel : NSObject

@property(nonatomic) int courseId;
@property(nonatomic,copy) NSString *courseName;
@property(nonatomic) int agentId;
@property(nonatomic,copy) NSString *agentName;
@property(nonatomic) int depositEachMan;
@property(nonatomic,copy) NSString *teetime;
@property(nonatomic) int price;
@property(nonatomic) int mans;
@property(nonatomic) int payType;
@property(nonatomic,copy) NSString *phone;
@property(nonatomic,copy) NSString *priceContent;
@property(nonatomic,copy) NSString *description;
@property(nonatomic,copy) NSString *cancelNote;
@property(nonatomic,copy) NSString *bookNote;
@property(nonatomic) BOOL recommendFlag;
@property(nonatomic) int canBook;
@property(nonatomic) int yunbi;
@property(nonatomic,assign) NSInteger hasInvoice; //1 :可提供发票 0：不提供发票
@property(nonatomic,assign) int minBuyQuantity; // 起订人数

@property(nonatomic,assign) int spreeId;
@property(nonatomic,strong) NSString *date;

- (id)initWithDic:(id)data;

@end
