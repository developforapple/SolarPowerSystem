//
//  TeeTimeModel.h
//  Golf
//
//  Created by 青 叶 on 11-11-26.
//  Copyright (c) 2011年 大展. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TeeTimeModel : NSObject {
    /** 支持保证金付款 **/
    BOOL _isOnlyCreditCard;
    /** 每人保证金多少元 **/
    int _depositEachMan;
    /** 分区id **/
    int _courseId;
    /** 分区名称 **/
    NSString *_courseName;
    /** 时间 **/
    NSString *_teetime;
    /** 价格 **/
    int _price;
    /** 已经参加人数 **/
    int _mans;
    int _normalCancelBookHours;
    int _holidayCancelBookHours;
    /** 是否过期 **/
    BOOL _isSearchTeetime;
    int _payType;
    /** 联系电话 **/
    NSString *_phone;
    NSString *_priceContent;
    NSString *_description;
    BOOL _isOnlyVip;
}

@property(nonatomic) BOOL isOnlyCreditCard;
@property(nonatomic) int depositEachMan;
@property(nonatomic) int courseId;
@property(nonatomic,copy) NSString *courseName;
@property(nonatomic,copy) NSString *teetime;
@property(nonatomic) int price;
@property(nonatomic) int mans;
@property(nonatomic) int payType;
@property(nonatomic) int normalCancelBookHours;
@property(nonatomic) int holidayCancelBookHours;
@property(nonatomic) BOOL isSearchTeetime;
@property(nonatomic,copy) NSString *phone;
@property(nonatomic,copy) NSString *priceContent;
@property(nonatomic,copy) NSString *description;
@property(nonatomic) BOOL isOnlyVip;

- (id)initWithDic:(id)data;

@end
