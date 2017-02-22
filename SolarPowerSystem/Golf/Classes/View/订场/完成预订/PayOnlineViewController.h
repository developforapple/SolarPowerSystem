//
//  PayOnlineViewController.h
//  Golf
//
//  Created by 黄希望 on 12-7-31.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConditionModel.h"
#import "TeeTimeModel.h"
#import "TeeTimeAgentModel.h"
#import "OrderDetailModel.h"
#import "OrderSuccessViewController.h"
#import "OrderSubmitModel.h"
#import "OrderService.h"
#import "DepositInfoModel.h"
#import "BaseNavController.h"
#import "PackageConditionModel.h"
//#import "UPPayPlugin.h"
#import "UPPaymentControl.h"
//#import "UPPayPluginDelegate.h"
#import "MyButton.h"

typedef NS_ENUM(NSUInteger, WaitPayType) {
    WaitPayTypeTeetime = 1,         //预定球场订单
    WaitPayTypeCommodity = 2,       //商品订单
    WaitPayTypeTeaching = 3,        //教学订单
    WaitPayTypePublicCourse = 4,    //教学公开课
    WaitPayTypeTeachBooking = 5,    //教学场馆打位预定
    
    WaitPayTypeMall = 6,            //新的商品订单，7.2新增。
};

@interface PayOnlineViewController : BaseNavController
<
//UPPayPluginDelegate,
UITableViewDataSource,UITableViewDelegate
>{
    MyButton *_payOnlineButton;
    UITableView *_tableView;
    
    OrderSubmitModel *_myOrderSubmit;
    UIView *_oquaeView;
    
    int _useAccount;
    int _currentTime;
    int _tranId;
    int _couponAmount;
    int _needToPay;
    BOOL _isDafualt;
}

@property (nonatomic) WaitPayType waitPayFlag;
/**
 订单id
 */
@property (nonatomic) int orderId;

/**
 是否是学院
 */
@property (nonatomic) BOOL isOffical;

/**
 是否是旅行订单
 */
@property (nonatomic,assign) BOOL isTraverPackage;
@property (nonatomic) float payTotal;       //单位为元
@property (nonatomic) float orderTotal;     //单位为元

/**
 商品id
 */
@property (nonatomic) int commodityId;
/**
 分类id
 */
@property (nonatomic) int categoryId;

/**
 品牌id
 */
@property (nonatomic) int brandId;
@property (nonatomic) int clubId;

/**
 产品ID
 */
@property (nonatomic) int productId;

/**
 学院ID
 */
@property (nonatomic) int academyId;

/**
 产品类型 1:标准课 2:团体课 3:公开课 4:套餐
 */
@property (nonatomic) int classType;

/**
 总课时
 */
@property (nonatomic) int classHour;

@property (nonatomic, copy) BlockReturn blockReturn;

@end
