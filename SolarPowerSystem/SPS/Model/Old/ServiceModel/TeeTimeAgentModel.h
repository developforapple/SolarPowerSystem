//
//  TeeTimeAgentModel.h
//  Golf
//
//  Created by 黄希望 on 12-7-26.
//

#import <Foundation/Foundation.h>

@interface TeeTimeAgentModel : NSObject {
    /** 代理id **/
    int _agentId;
    /** 每人保证金多少元 **/
    int _depositEachMan;
    /** 是否仅支持全额预付 **/
    BOOL _isOnlyCreditCard;
    /** 代理名称 **/
    NSString *_agentName;
    /** 时间 **/
    NSString *_teetime;
    /** 价格 **/
    int _price;
    int _payType;
    /** 已经参加人数 **/
    int _normalCancelBookHours;
    int _holidayCancelBookHours;
    /** 联系电话 **/
    NSString *_agentPhone; 
    NSString *_description;
    NSString *_priceContent;
    int _orderId;
    
}

@property(nonatomic) int agentId;
@property(nonatomic) int depositEachMan;
@property(nonatomic,assign) BOOL isOnlyCreditCard;
@property(nonatomic,copy) NSString *agentName;
@property(nonatomic,copy) NSString *teetime;
@property(nonatomic) int price;
@property(nonatomic) int payType;
@property(nonatomic) int normalCancelBookHours;
@property(nonatomic) int holidayCancelBookHours;
@property(nonatomic,copy) NSString *agentPhone;
@property(nonatomic,copy) NSString *description;
@property(nonatomic) int orderId;
@property(nonatomic,copy) NSString *priceContent;

- (id)initWithDic:(id)data;
@end
